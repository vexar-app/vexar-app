import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var homebrewManager: HomebrewManager
    @Environment(\.dismiss) private var dismiss
    
    // Dynamic Height State
    @State private var contentHeight: CGFloat = 430
    
    // Animation
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            // 1. Shared Living Background
            AnimatedMeshBackground(statusColor: .vexarBlue, isVisible: true)
            
            // 2. Glass Overlay
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {


                // Header
                HStack {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(appearAnimation ? 360 : 0))
                        .animation(.spring(response: 1, dampingFraction: 0.7), value: appearAnimation)
                    
                    Text("AYARLAR")
                        .font(.system(size: 16, weight: .heavy, design: .default)) // Fixed font design
                        .tracking(1)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(20)
                .background(.ultraThinMaterial) // Header glass
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Setup Wizard Button (Moved to Top)
                        Button {
                            UserDefaults.standard.set(false, forKey: "onboardingDismissed")
                            homebrewManager.checkInstallations()
                            dismiss()
                        } label: {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(colors: [.vexarBlue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 32, height: 32)
                                    
                                    Image(systemName: "wand.and.stars")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Kurulum Sihirbazı")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Gerekli bileşenleri tekrar kurun.")
                                        .font(.system(size: 11))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            .padding(12)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        
                        // Launch at Login Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("GENEL")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white.opacity(0.5))
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Başlangıçta Çalıştır")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                    Text("Bilgisayar açıldığında Vexar otomatik başlar.")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                Spacer()
                                
                                Spacer()
                                
                                // Sliding Toggle
                                Button {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        appState.launchAtLogin.toggle()
                                    }
                                } label: {
                                    ZStack {
                                        // Track
                                        Capsule()
                                            .fill(Color.black.opacity(0.4))
                                            .frame(width: 130, height: 36)
                                            .overlay(
                                                Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1)
                                            )
                                        
                                        // Sliding Knob Container
                                        HStack {
                                            if appState.launchAtLogin {
                                                Spacer()
                                            }
                                            
                                            // Knob
                                            HStack(spacing: 6) {
                                                Image(systemName: appState.launchAtLogin ? "checkmark" : "power")
                                                    .font(.system(size: 12, weight: .bold))
                                                Text(appState.launchAtLogin ? "AÇIK" : "KAPALI")
                                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                            }
                                            .foregroundColor(appState.launchAtLogin ? .white : .white.opacity(0.6))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(
                                                        appState.launchAtLogin ?
                                                        LinearGradient(colors: [.vexarGreen, .vexarGreen.opacity(0.8)], startPoint: .top, endPoint: .bottom) :
                                                            LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                                                    )
                                                    .shadow(color: appState.launchAtLogin ? .vexarGreen.opacity(0.4) : .black.opacity(0.3), radius: 5)
                                                    .overlay(
                                                        Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                    )
                                            )
                                            .frame(height: 32)
                                            
                                            if !appState.launchAtLogin {
                                                Spacer()
                                            }
                                        }
                                        .padding(.horizontal, 2)
                                        .frame(width: 130)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(16)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                        
                        // Privacy Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("GİZLİLİK")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white.opacity(0.5))
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Anonim Veri Toplama")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                    Text("Vexar'ın geliştirilmesine katkıda bulunmak için anonim kullanım verilerini paylaşın.")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.6))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                                
                                // Analytic Toggle
                                Button {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        appState.isAnalyticsEnabled.toggle()
                                        if appState.isAnalyticsEnabled {
                                            TelemetryManager.shared.sendEvent(eventName: "analytics_opt_in")
                                        }
                                    }
                                } label: {
                                    ZStack {
                                        // Track
                                        Capsule()
                                            .fill(Color.black.opacity(0.4))
                                            .frame(width: 130, height: 36)
                                            .overlay(
                                                Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1)
                                            )
                                        
                                        // Sliding Knob Container
                                        HStack {
                                            if appState.isAnalyticsEnabled {
                                                Spacer()
                                            }
                                            
                                            // Knob
                                            HStack(spacing: 6) {
                                                Image(systemName: appState.isAnalyticsEnabled ? "chart.bar.fill" : "chart.bar")
                                                    .font(.system(size: 12, weight: .bold))
                                                Text(appState.isAnalyticsEnabled ? "AÇIK" : "KAPALI")
                                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                            }
                                            .foregroundColor(appState.isAnalyticsEnabled ? .white : .white.opacity(0.6))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(
                                                        appState.isAnalyticsEnabled ?
                                                        LinearGradient(colors: [.vexarBlue, .vexarBlue.opacity(0.8)], startPoint: .top, endPoint: .bottom) :
                                                            LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                                                    )
                                                    .shadow(color: appState.isAnalyticsEnabled ? .vexarBlue.opacity(0.4) : .black.opacity(0.3), radius: 5)
                                                    .overlay(
                                                        Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                    )
                                            )
                                            .frame(height: 32)
                                            
                                            if !appState.isAnalyticsEnabled {
                                                Spacer()
                                            }
                                        }
                                        .padding(.horizontal, 2)
                                        .frame(width: 130)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(16)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.white.opacity(0.1), lineWidth: 1)
                            )
                        }

                        


                            

                            
                            // Developer Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("GELİŞTİRİCİ")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white.opacity(0.5))
                                
                                VStack(spacing: 16) {
                                    // Profile Header
                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                                                )
                                                .frame(width: 48, height: 48)
                                                .shadow(color: .red.opacity(0.4), radius: 6)
                                            
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("ConsolAktif")
                                                .font(.system(size: 17, weight: .bold))
                                                .foregroundColor(.white)
                                            
                                            Text("Vexar Geliştiricisi")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                        
                                        Spacer()
                                    }
                                    
                                    // Subscribe Button
                                    Button {
                                        if let url = URL(string: "https://www.youtube.com/@ConsolAktif/videos") {
                                            NSWorkspace.shared.open(url)
                                        }
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "play.rectangle.fill")
                                                .font(.system(size: 16))
                                            Text("YouTube'da Abone Ol")
                                                .font(.system(size: 13, weight: .bold))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(red: 0.9, green: 0, blue: 0)) // YouTube Red
                                                .shadow(color: .red.opacity(0.4), radius: 5, y: 2)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(ScaleButtonStyle())
                                }
                                .padding(16)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                            
                            // Danger Zone
                            VStack(alignment: .leading, spacing: 12) {
                                Text("TEHLİKELİ BÖLGE")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.red.opacity(0.5))
                                
                                Button {
                                    withAnimation {
                                        uninstallStep = .confirmation
                                    }
                                } label: {
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(Color.red.opacity(0.2))
                                                .frame(width: 32, height: 32)
                                            
                                            Image(systemName: "trash.fill")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.red)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Uygulamayı Tamamen Kaldır")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.red)
                                            Text("Vexar ve bileşenlerini siler.")
                                                .font(.system(size: 11))
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.red.opacity(0.5))
                                    }
                                    .padding(12)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.red.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        } // End VStack
                        .padding(20)
                        .readHeight { height in
                           // ...
                        }
                    }
                }
            
            // 3. Uninstall Overlay
            if uninstallStep != .initial {
                ZStack {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Block taps from reaching the popover dismissal behavior
                        }
                    
                    VStack(spacing: 24) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.red)
                        
                        Text("Vexar Kaldırma Aracı")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        if uninstallStep == .confirmation {
                            Text("Bu işlem uygulamayı ve tüm verilerini silecektir.\nSpoofDPI otomatik olarak kaldırılacak, diğer bileşenler için size sorulacaktır.\n\nDevam etmek istiyor musunuz?")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        } else {
                            Text(uninstallStatus)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        if uninstallStep == .removingSpoofDPI || uninstallStep == .final {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.5)
                        } else {
                            HStack(spacing: 20) {
                                Button {
                                    if uninstallStep == .confirmation {
                                        withAnimation {
                                            uninstallStep = .initial
                                        }
                                    } else {
                                        handleUninstallChoice(remove: false)
                                    }
                                } label: {
                                    Text("Hayır")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(Capsule().fill(Color.white.opacity(0.1)))
                                }
                                .buttonStyle(.plain)
                                
                                Button {
                                    if uninstallStep == .confirmation {
                                        startUninstall()
                                    } else {
                                        handleUninstallChoice(remove: true)
                                    }
                                } label: {
                                    Text("Evet")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(Capsule().fill(Color.red))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.1)))
                    )
                    .contentShape(Rectangle()) // Capture clicks on the card
                    .onTapGesture { } // Swallow clicks on the card
                    .padding(40)
                    .transition(.opacity.combined(with: .scale))
                }
                .zIndex(100)
            }
        }
        // Height Preference Emit
        .background(GeometryReader { _ in
            Color.clear.preference(key: ViewHeightKey.self, value: min(contentHeight, 600))
        })
        .preferredColorScheme(.dark)
        .onAppear {
            appearAnimation = true
        }
    }
    
    // MARK: - Uninstall Logic
    
    enum UninstallStep {
        case initial
        case confirmation
        case removingSpoofDPI
        case askDiscord
        case askHomebrew
        case final
    }
    
    @State private var showUninstallAlert = false
    @State private var uninstallStep: UninstallStep = .initial
    @State private var uninstallStatus: String = ""
    
    func startUninstall() {
        withAnimation {
            uninstallStep = .removingSpoofDPI
            uninstallStatus = "SpoofDPI ve servisler durduruluyor..."
        }
        
        Task {
            // Wait for UI animation
            try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
            
            // Remove SpoofDPI
            await MainActor.run { uninstallStatus = "SpoofDPI kaldırılıyor..." }
            _ = await homebrewManager.uninstallSpoofDPI()
            
            try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
            
            // Move to Discord Step
            await MainActor.run {
                withAnimation {
                    uninstallStep = .askDiscord
                    uninstallStatus = "Discord uygulamasını da kaldırmak ister misiniz?\n(Sadece Vexar ile yüklediyseniz önerilir)"
                }
            }
        }
    }
    
    func handleUninstallChoice(remove: Bool) {
        Task {
            if uninstallStep == .askDiscord {
                if remove {
                    await MainActor.run { uninstallStatus = "Discord kaldırılıyor..." }
                    _ = await homebrewManager.uninstallDiscord()
                }
                
                await MainActor.run {
                    withAnimation {
                        uninstallStep = .askHomebrew
                        uninstallStatus = "Homebrew paket yöneticisini de kaldırmak ister misiniz?\n(Eğer başka geliştirici araçları kullanıyorsanız SAKLAYIN)"
                    }
                }
            } else if uninstallStep == .askHomebrew {
                if remove {
                    await MainActor.run { uninstallStatus = "Homebrew kaldırma betiği çalıştırılıyor..." }
                    homebrewManager.uninstallHomebrew()
                    // Give user time to see terminal
                    try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                }
                
                await MainActor.run {
                    withAnimation {
                        uninstallStep = .final
                        uninstallStatus = "Vexar temizleniyor...\nHoşçakalın! 👋"
                    }
                }
                
                try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                homebrewManager.selfDestruct()
            }
        }
    }

}
