import SwiftUI

/// Onboarding view for first-time setup with Premium Visuals
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var homebrewManager: HomebrewManager
    @Binding var isPresented: Bool
    
    @State private var showError = false
    @State private var isDiscordInstalled = false
    
    // Animations
    @State private var appearAnimation = false
    @State private var animateBg = false
    
    var body: some View {
        ZStack {
            // Animated Background
            ZStack {
                Color.vexarBackground.ignoresSafeArea()
                
                // Animated gradient blobs
                GeometryReader { proxy in
                    Circle()
                        .fill(Color.vexarBlue.opacity(0.15))
                        .frame(width: 300, height: 300)
                        .blur(radius: 80)
                        .offset(x: animateBg ? -50 : 150, y: animateBg ? -50 : 50)
                        .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animateBg)
                    
                    Circle()
                        .fill(Color.vexarOrange.opacity(0.1))
                        .frame(width: 250, height: 250)
                        .blur(radius: 70)
                        .offset(x: proxy.size.width - (animateBg ? 100 : 250), y: proxy.size.height - (animateBg ? 50 : 250))
                        .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animateBg)
                }
            }
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    // Logo and title
                    headerSection
                        .offset(y: appearAnimation ? 0 : 30)
                        .opacity(appearAnimation ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appearAnimation)
                    
                    // Status cards
                    statusSection
                        .offset(y: appearAnimation ? 0 : 40)
                        .opacity(appearAnimation ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: appearAnimation)
                    
                    // Action button
                    actionSection
                        .offset(y: appearAnimation ? 0 : 50)
                        .opacity(appearAnimation ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: appearAnimation)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 30)
            }
        }
        .frame(width: 380, height: 550)
        .background(Color.vexarBackground)
        .preferredColorScheme(.dark)
        .alert(String(localized: "install_failed"), isPresented: $showError) {
            Button(String(localized: "ok"), role: .cancel) {}
        } message: {
            Text(homebrewManager.installError ?? "")
        }
        .onAppear {
            homebrewManager.checkInstallations()
            checkDiscord()
            
            withAnimation {
                appearAnimation = true
                animateBg = true
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Logo with glow
            ZStack {
                // Rotating outer ring
                Circle()
                    .strokeBorder(
                        AngularGradient(colors: [.vexarBlue.opacity(0.5), .clear, .vexarBlue.opacity(0.5), .clear], center: .center),
                        lineWidth: 2
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(animateBg ? 360 : 0))
                    .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: animateBg)
                
                // Glow
                Circle()
                    .fill(Color.vexarBlue.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .blur(radius: 20)
                
                // Logo
                Image("VexarLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .vexarBlue.opacity(0.5), radius: 10)
            }
            .padding(.top, 10)
            
            VStack(spacing: 8) {
                Text("Vexar'a Hoş Geldiniz")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(String(localized: "version"))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.white.opacity(0.05)))
            }
            
            // Description
            Text("Discord bağlantı sorunlarını çözmek için\nSpoofDPI proxy'si kullanır.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 10)
            
            // CPU Architecture badge
            HStack(spacing: 6) {
                Image(systemName: "cpu")
                    .font(.system(size: 11))
                Text(homebrewManager.cpuArchitecture.displayName)
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(LinearGradient(colors: [.vexarBlue, .vexarBlue.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .opacity(0.8)
            )
            .shadow(color: .vexarBlue.opacity(0.3), radius: 5)
        }
    }
    
    // MARK: - Status Section
    
    private var statusSection: some View {
        VStack(spacing: 16) {
            statusRow(
                icon: "cube.box.fill",
                iconColor: .green,
                title: "Homebrew",
                subtitle: homebrewManager.isHomebrewInstalled ? "Kurulu" : "brew.sh",
                isInstalled: homebrewManager.isHomebrewInstalled
            )
            
            statusRow(
                icon: "network.badge.shield.half.filled",
                iconColor: .blue,
                title: "SpoofDPI",
                subtitle: homebrewManager.isSpoofDPIInstalled ? "Kurulu" : "brew install spoofdpi",
                isInstalled: homebrewManager.isSpoofDPIInstalled
            )
            
            statusRow(
                icon: "gamecontroller.fill",
                iconColor: .purple,
                title: "Discord",
                subtitle: isDiscordInstalled ? "Kurulu" : "/Applications/Discord.app",
                isInstalled: isDiscordInstalled
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .opacity(0.8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
    
    private func statusRow(icon: String, iconColor: Color, title: String, subtitle: String, isInstalled: Bool) -> some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(isInstalled ? iconColor.opacity(0.1) : Color.white.opacity(0.05))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isInstalled ? iconColor : .secondary.opacity(0.6))
            }
            
            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status icon
            if isInstalled {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.vexarGreen)
                    .shadow(color: .vexarGreen.opacity(0.4), radius: 4)
            } else {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.vexarOrange)
                    .opacity(0.8)
            }
        }
    }
    
    // MARK: - Action Section
    
    private var actionSection: some View {
        VStack(spacing: 16) {
            // Progress indicator
            if homebrewManager.isInstalling {
                HStack(spacing: 10) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text(homebrewManager.installProgress)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
                .transition(.opacity)
            }
            
            // Main action button
            mainActionButton
            
            // Secondary actions
            secondaryActions
        }
    }
    
    @ViewBuilder
    private var mainActionButton: some View {
        if homebrewManager.isSpoofDPIInstalled {
            // All ready - Continue button
            Button(action: dismissOnboarding) {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Devam Et")
                }
                .font(.system(size: 16, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.vexarGreen, .vexarGreen.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundColor(.white) // Ensure text is set to white
                .cornerRadius(16) // Correctly apply corner radius
                .shadow(color: .vexarGreen.opacity(0.4), radius: 10, y: 4)
            }
            .buttonStyle(PlainButtonStyle()) // Ensures button behaves correctly
        } else if !homebrewManager.isHomebrewInstalled {
            // Install Homebrew first
            Button(action: {
                homebrewManager.openTerminalForHomebrew()
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "terminal.fill")
                    Text("Homebrew'u Terminal'de Kur")
                }
                .font(.system(size: 15, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.vexarOrange)
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: .vexarOrange.opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            // Install SpoofDPI
            Button(action: installSpoofDPI) {
                HStack(spacing: 10) {
                    if homebrewManager.isInstalling {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.down.circle.fill")
                    }
                    Text("SpoofDPI Kur")
                }
                .font(.system(size: 16, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.vexarBlue, .vexarOrange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: .vexarBlue.opacity(0.3), radius: 10, y: 5)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(homebrewManager.isInstalling)
            .opacity(homebrewManager.isInstalling ? 0.7 : 1)
        }
    }
    
    private var secondaryActions: some View {
        HStack(spacing: 20) {
            // Refresh button
            Button(action: {
                withAnimation {
                    homebrewManager.checkInstallations()
                    checkDiscord()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("Yenile")
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .padding(8)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            // Skip button (if not installed)
            if !homebrewManager.isSpoofDPIInstalled {
                Button(action: dismissOnboarding) {
                    Text("Atla")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.6))
                        .padding(8)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func checkDiscord() {
        isDiscordInstalled = FileManager.default.fileExists(atPath: "/Applications/Discord.app")
    }
    
    private func installSpoofDPI() {
        Task {
            let success = await homebrewManager.installSpoofDPI()
            if !success && homebrewManager.installError != nil {
                showError = true
            }
        }
    }
    
    private func dismissOnboarding() {
        withAnimation {
            UserDefaults.standard.set(true, forKey: "onboardingDismissed")
            isPresented = false
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
        .environmentObject(AppState())
        .environmentObject(HomebrewManager())
}
