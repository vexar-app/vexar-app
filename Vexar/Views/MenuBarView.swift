import SwiftUI

// Main Menu Bar popover view with Vexar premium dark theme and animations
struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var homebrewManager: HomebrewManager
    
    // Animations
    @State private var animateBg = false
    @State private var pulseGlow = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated Background
                ZStack {
                    Color.vexarBackground.ignoresSafeArea()
                    
                    // Animated ambient glow (changes color based on status)
                    GeometryReader { proxy in
                        Circle()
                            .fill(statusColor.opacity(0.15))
                            .frame(width: 250, height: 280)
                            .blur(radius: 80)
                            .offset(x: animateBg ? -50 : 50, y: animateBg ? -80 : -20)
                            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animateBg)
                    }
                }
                
                VStack(spacing: 0) {
                    // Header with logo
                    headerView
                    
                    // Divider
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.1), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                    
                    // Main content
                    VStack(spacing: 16) {
                        // Connection status card (Large & Visual)
                        connectionStatusCard
                        
                        // Main toggle button
                        connectButton
                        
                        // Info text
                        Text(String(localized: "discord_launch_info"))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .opacity(0.8)
                        
                        // Warning if SpoofDPI not installed
                        if !homebrewManager.isSpoofDPIInstalled {
                            warningBanner
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(24)
                    
                    // Divider
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 1)
                    
                    // Bottom actions
                    bottomActions
                }
            }


            .background(GeometryReader { geometry in
                Color.clear.preference(key: ViewHeightKey.self, value: geometry.size.height)
            })

            .navigationDestination(for: String.self) { destination in
                if destination == "settings" {
                    SettingsView()
                        .environmentObject(appState)
                } else if destination == "logs" {
                    LogsView()
                        .environmentObject(appState)
                }
            }
        }


        .frame(width: 350, height: windowHeight) // Controlled height
        .preferredColorScheme(.dark)
        .onAppear {
            animateBg = true
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseGlow = true
            }
        }
        .onPreferenceChange(ViewHeightKey.self) { height in
            if height > 0 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    windowHeight = height
                }
            }
        }
    }
    
    @State private var windowHeight: CGFloat = 500

    
    private var statusColor: Color {
        if appState.isConnecting { return .vexarOrange }
        if appState.isConnected { return .vexarGreen }
        return .vexarBlue
    }
    
    // MARK: - Warning Banner
    
    private var warningBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.vexarOrange)
                .font(.system(size: 14))
            Text("SpoofDPI kurulu değil")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.vexarOrange)
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.vexarOrange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.vexarOrange.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack(spacing: 12) {
            // Logo with glow
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.vexarBlue.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 5,
                            endRadius: 22
                        )
                    )
                    .frame(width: 44, height: 44)
                    .opacity(pulseGlow ? 1 : 0.7)
                
                Image("VexarLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "app_name"))
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .white.opacity(0.1), radius: 2)
                
                Text(String(localized: "version"))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status dot
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
                .shadow(color: statusColor.opacity(0.8), radius: pulseGlow ? 6 : 2)
                .overlay(
                    Circle()
                        .stroke(statusColor.opacity(0.3), lineWidth: 4)
                        .scaleEffect(pulseGlow ? 1.5 : 1)
                        .opacity(pulseGlow ? 0 : 0.5)
                )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Connection Status Card
    
    private var connectionStatusCard: some View {
        ZStack {
            // Glass background
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .opacity(0.6)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.02))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    statusColor.opacity(appState.isConnected ? 0.3 : 0.1),
                                    statusColor.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: statusColor.opacity(appState.isConnected ? 0.2 : 0.05),
                    radius: 20,
                    y: 5
                )
            
            VStack(spacing: 16) {
                // Large Animated Icon
                ZStack {
                    // Outer glow rings
                    if appState.isConnected || appState.isConnecting {
                        ForEach(0..<2) { i in
                            Circle()
                                .stroke(statusColor.opacity(0.3), lineWidth: 1)
                                .frame(width: 60 + CGFloat(i * 20), height: 60 + CGFloat(i * 20))
                                .scaleEffect(pulseGlow ? 1.1 : 0.9)
                                .opacity(pulseGlow ? 0 : 0.5)
                                .animation(
                                    .easeInOut(duration: 2).repeatForever(autoreverses: false).delay(Double(i) * 0.5),
                                    value: pulseGlow
                                )
                        }
                    }
                    
                    Image(systemName: statusIconName)
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [statusColor, statusColor.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(
                            color: statusColor.opacity(0.5),
                            radius: 15
                        )
                        .rotationEffect(.degrees(appState.isConnecting ? 360 : 0))
                        .animation(
                            appState.isConnecting ? .linear(duration: 2).repeatForever(autoreverses: false) : .spring(),
                            value: appState.isConnecting
                        )
                }
                .frame(height: 100)
                
                // Status Text
                Text(statusText)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: statusColor.opacity(0.3), radius: 8)
            }
            .padding(.vertical, 24)
        }
    }
    
    private var statusIconName: String {
        if appState.isConnecting { return "arrow.triangle.2.circlepath" }
        if appState.isConnected { return "shield.fill" }
        return "shield.slash"
    }
    
    private var statusText: String {
        if appState.isConnecting {
            return String(localized: "status_connecting")
        } else if appState.isConnected {
            return String(localized: "status_connected")
        } else {
            return String(localized: "status_disconnected")
        }
    }
    
    // MARK: - Connect Button
    
    private var connectButton: some View {
        Button(action: {
            if appState.isConnected {
                withAnimation(.spring()) {
                    appState.disconnect()
                }
            } else {
                withAnimation(.spring()) {
                    appState.connect()
                }
            }
        }) {
            HStack(spacing: 10) {
                Image(systemName: "power")
                    .font(.system(size: 18, weight: .bold))
                
                Text(appState.isConnected
                    ? String(localized: "disconnect")
                    : String(localized: "connect"))
                    .font(.system(size: 16, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    if appState.isConnected {
                        Color.vexarCardBackground
                    } else {
                        LinearGradient(
                            colors: [.vexarBlue, .vexarBlue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: appState.isConnected
                                ? [.white.opacity(0.1), .clear]
                                : [.white.opacity(0.4), .white.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
            .foregroundColor(appState.isConnected ? .vexarOrange : .white)
            .cornerRadius(16)
            .shadow(
                color: appState.isConnected
                    ? Color.black.opacity(0.2)
                    : Color.vexarBlue.opacity(0.4),
                radius: 12, y: 6
            )
            .scaleEffect(plainButtonStylePressed ? 0.98 : 1)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(appState.isConnecting || !homebrewManager.isSpoofDPIInstalled)
        .opacity(homebrewManager.isSpoofDPIInstalled ? 1 : 0.5)
    }
    
    @State private var plainButtonStylePressed = false
    
    // MARK: - Bottom Actions
    
    private var bottomActions: some View {
        HStack(spacing: 0) {
            NavigationLink(value: "settings") {
                VStack(spacing: 4) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14))
                    Text(String(localized: "settings"))
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            Divider()
                .frame(height: 24)
                .background(Color.white.opacity(0.1))
            
            NavigationLink(value: "logs") {
                VStack(spacing: 4) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 14))
                    Text(String(localized: "logs"))
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            Divider()
                .frame(height: 24)
                .background(Color.white.opacity(0.1))
            
            Button {
                appState.disconnect()
                NSApplication.shared.terminate(nil)
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "power")
                        .font(.system(size: 14))
                    Text(String(localized: "quit"))
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    MenuBarView()
        .environmentObject(AppState())
        .environmentObject(HomebrewManager())
}
