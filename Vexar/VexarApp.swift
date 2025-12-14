import SwiftUI
import ServiceManagement

@main
struct VexarApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var homebrewManager = HomebrewManager()
    @State private var showOnboarding = false
    
    var body: some Scene {
        MenuBarExtra {
            ContentView(showOnboarding: $showOnboarding)
                .environmentObject(appState)
                .environmentObject(homebrewManager)
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
}

/// Content wrapper to handle onboarding
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var homebrewManager: HomebrewManager
    @Binding var showOnboarding: Bool
    
    var body: some View {
        Group {
            if shouldShowOnboarding {
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
    
    private var shouldShowOnboarding: Bool {
        // Show onboarding if SpoofDPI is not installed and hasn't been dismissed
        !homebrewManager.isSpoofDPIInstalled && !UserDefaults.standard.bool(forKey: "onboardingDismissed")
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

