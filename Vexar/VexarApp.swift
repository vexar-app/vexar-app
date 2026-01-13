import SwiftUI
import ServiceManagement
import UserNotifications
import FirebaseCore

@main
struct VexarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState.shared
    @StateObject private var homebrewManager = HomebrewManager()
    @State private var showOnboarding = false
    
    init() {
        // Set default values (Opt-out model)
        UserDefaults.standard.register(defaults: ["isAnalyticsEnabled": true])
        
        FirebaseApp.configure()
        requestNotificationPermission()
    }

    var body: some Scene {
        MenuBarExtra {
            ContentView(showOnboarding: $showOnboarding)
                .environmentObject(appState)
                .environmentObject(homebrewManager)
                .onAppear {
                    sendLaunchNotification()
                    TelemetryManager.shared.sendEvent(eventName: "app_launched")
                }
        } label: {
            HStack(spacing: 4) {
                Image("MenuBarIcon") 
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
            }
            .foregroundStyle(appState.isConnected ? .green : .secondary)
        }
        .menuBarExtraStyle(.window)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    private func sendLaunchNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Vexar Çalışıyor"
        content.body = "Uygulama menü çubuğunda aktif. Kontrol etmek için ikona tıklayın."
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "launch_notification", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var quittingWindow: NSWindow?
    var isCleaningUp = false
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if isCleaningUp {
            return .terminateNow
        }
        
        // 1. Show Quitting UI
        showQuittingWindow()
        
        // 2. Start Cleanup
        isCleaningUp = true
        Task {
            await cleanup()
            
            // 3. Continue Termination after a brief delay for UX
            try? await Task.sleep(nanoseconds: 1 * 1_000_000_000) // 1s delay
            await MainActor.run {
                sender.terminate(self)
            }
        }
        
        return .terminateCancel
    }
    
    private func showQuittingWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 250),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.level = .floating
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        
        let hostingView = NSHostingView(rootView: QuittingView())
        window.contentView = hostingView
        
        window.makeKeyAndOrderFront(nil)
        self.quittingWindow = window
    }
    
    @MainActor
    private func cleanup() async {
        // Step 1
        withAnimation { AppState.shared.quittingStatus = "Bağlantılar kontrol ediliyor..." }
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        
        // Step 2
        withAnimation { AppState.shared.quittingStatus = "SpoofDPI servisi durduruluyor..." }
        AppState.shared.processManager.stopBlocking()
        try? await Task.sleep(nanoseconds: 800_000_000) // 0.8s
        
        // Step 3
        withAnimation { AppState.shared.quittingStatus = "Geçici dosyalar temizleniyor..." }
        try? await Task.sleep(nanoseconds: 800_000_000) // 0.8s
        
        // Step 4
        TelemetryManager.shared.sendEvent(eventName: "app_quit")
        withAnimation { AppState.shared.quittingStatus = "Hoşçakalın! 👋" }
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
    }
}

/// Content wrapper to handle onboarding
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var homebrewManager: HomebrewManager
    @Binding var showOnboarding: Bool
    
    // Reactive storage
    @AppStorage("onboardingDismissed") var onboardingDismissed: Bool = false
    
    var body: some View {
        Group {
            if !onboardingDismissed {
                OnboardingView(isPresented: $showOnboarding)
                    .environmentObject(appState)
                    .environmentObject(homebrewManager)
            } else {
                MenuBarView()
                    .environmentObject(appState)
                    .environmentObject(homebrewManager)
            }
        }
        .sheet(isPresented: $appState.updateManager.isUpdateAvailable) {
            UpdateView()
                .environmentObject(appState.updateManager)
        }
    }
}

// MARK: - Vexar Theme Colors

extension Color {
    static let vexarBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
    static let vexarOrange = Color(red: 1.0, green: 0.5, blue: 0.2)
    static let vexarGreen = Color(red: 0.2, green: 0.9, blue: 0.4)
    static let vexarGrey = Color(white: 0.4)
    static let vexarBackground = Color(red: 0.08, green: 0.08, blue: 0.1)
    static let vexarCardBackground = Color(red: 0.12, green: 0.12, blue: 0.15)
    static let vexarDivider = Color(white: 0.2)
}

// MARK: - View Height Helper

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    func readHeight(onChange: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ViewHeightKey.self, value: geometry.size.height)
            }
        )
        .onPreferenceChange(ViewHeightKey.self, perform: onChange)
    }
}

