import SwiftUI
import ServiceManagement

/// Settings view for Launch at Login with Premium Visuals
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    // Animation states
    @State private var appearAnimation = false
    @State private var hoverClose = false
    @State private var animateBg = false
    
    // Dynamic Height
    @State private var contentHeight: CGFloat = 430 // Default fallback
    
    var body: some View {
        ZStack {
            // Animated Background
            ZStack {
                Color.vexarBackground.ignoresSafeArea()
                
                // Animated gradient blobs
                GeometryReader { proxy in
                    Circle()
                        .fill(Color.vexarBlue.opacity(0.15))
                        .frame(width: 200, height: 200)
                        .blur(radius: 60)
                        .offset(x: animateBg ? -50 : 50, y: animateBg ? -50 : 50)
                        .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animateBg)
                    
                    Circle()
                        .fill(Color.vexarOrange.opacity(0.1))
                        .frame(width: 250, height: 250)
                        .blur(radius: 70)
                        .offset(x: proxy.size.width - (animateBg ? 100 : 200), y: proxy.size.height - (animateBg ? 50 : 150))
                        .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: animateBg)
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(
                                LinearGradient(colors: [.vexarBlue, .vexarGreen], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .rotationEffect(.degrees(appearAnimation ? 360 : 0))
                            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1), value: appearAnimation)
                        
                        Text(String(localized: "settings_title"))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .shadow(color: .white.opacity(0.2), radius: 5)
                    }
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(hoverClose ? .white : .secondary)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(hoverClose ? Color.white.opacity(0.1) : Color.clear)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .onHover { hoverClose = $0 }
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.vexarBlue.opacity(0.3), .vexarOrange.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1),
                    alignment: .bottom
                )
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Launch at Login card
                        settingsCard(delay: 0.1) {
                            Toggle(isOn: $appState.launchAtLogin) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.vexarBlue.opacity(0.2), Color.vexarBlue.opacity(0.05)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.vexarBlue.opacity(0.3), lineWidth: 1)
                                            )
                                            .shadow(color: .vexarBlue.opacity(0.2), radius: 8)
                                        
                                        Image(systemName: "power")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.vexarBlue)
                                            .shadow(color: .vexarBlue.opacity(0.5), radius: 5)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(String(localized: "launch_at_login"))
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)
                                        Text(String(localized: "launch_at_login_desc"))
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .vexarBlue))
                        }
                        
                        // App info card
                        settingsCard(delay: 0.2) {
                            VStack(spacing: 16) {
                                infoRow(
                                    icon: "info.circle.fill",
                                    color: .vexarBlue,
                                    title: String(localized: "version_label"),
                                    value: "1.0.0"
                                )
                                
                                Divider()
                                    .background(
                                        LinearGradient(
                                            colors: [.clear, .white.opacity(0.1), .clear],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                HStack {
                                    HStack(spacing: 8) {
                                        Image(systemName: "server.rack")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 12))
                                        
                                        Text(String(localized: "spoofdpi_status"))
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(spoofDPIInstalled ? Color.vexarGreen : Color.vexarOrange)
                                            .frame(width: 8, height: 8)
                                            .shadow(color: (spoofDPIInstalled ? Color.vexarGreen : Color.vexarOrange).opacity(0.6), radius: 4)
                                        
                                        Text(spoofDPIInstalled 
                                            ? String(localized: "installed") 
                                            : String(localized: "not_found"))
                                            .font(.system(size: 12, weight: .bold))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                Capsule()
                                                    .fill((spoofDPIInstalled ? Color.vexarGreen : Color.vexarOrange).opacity(0.15))
                                            )
                                            .foregroundColor(spoofDPIInstalled ? .vexarGreen : .vexarOrange)
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .padding(20)
                    .readHeight { height in
                        let newHeight = height + 80
                        if abs(contentHeight - newHeight) > 1 {
                            // Debounce to prevent crash during transition
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    contentHeight = newHeight
                                }
                            }
                        }
                    }
                    }
                }
            }

        // Emit height preference instead of resizing self
        .background(GeometryReader { _ in
            Color.clear.preference(key: ViewHeightKey.self, value: min(contentHeight, 600))
        })
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation {
                appearAnimation = true
                animateBg = true
            }
        }
    }
    
    // MARK: - Components
    
    private func settingsCard<Content: View>(delay: Double, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading) {
            content()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .opacity(0.8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.1), .white.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 15, y: 5)
        .offset(y: appearAnimation ? 0 : 20)
        .opacity(appearAnimation ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(delay), value: appearAnimation)
    }
    
    private func infoRow(icon: String, color: Color, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 14))
                .shadow(color: color.opacity(0.4), radius: 4)
            
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.05))
                )
        }
    }
    
    // MARK: - Helpers
    
    private var spoofDPIInstalled: Bool {
        let paths = [
            "/opt/homebrew/bin/spoofdpi",
            "/usr/local/bin/spoofdpi",
            Bundle.main.path(forResource: "spoofdpi", ofType: nil)
        ].compactMap { $0 }
        
        return paths.contains { FileManager.default.isExecutableFile(atPath: $0) }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
