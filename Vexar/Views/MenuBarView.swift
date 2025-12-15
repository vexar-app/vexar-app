import SwiftUI

// MARK: - Vexar 1.0 Menu Bar View
struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var homebrewManager: HomebrewManager
    
    // Window Management
    @State private var windowHeight: CGFloat = 520
    
    // Animation States
    @State private var breathing: Bool = false
    @State private var rotation: Double = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Living Background
                AnimatedMeshBackground(statusColor: statusColor)
                
                // 2. Glass Overlay (Frosted effect)
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.9)
                
                // 3. Main Content
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Image("VexarLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .shadow(color: statusColor.opacity(0.5), radius: 8)
                        
                        Text("VEXAR")
                            .font(.system(size: 14, weight: .heavy, design: .default))
                            .tracking(2)
                            .foregroundStyle(.white.opacity(0.8))
                        
                        Spacer()
                        
                        // Status Badge
                        HStack(spacing: 6) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 6, height: 6)
                                .shadow(color: statusColor, radius: 4)
                            
                            Text(statusText.uppercased())
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundStyle(statusColor)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(statusColor.opacity(0.1))
                                .overlay(Capsule().stroke(statusColor.opacity(0.2), lineWidth: 1))
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    Spacer()
                    
                    // Core Reactor (Centerpiece)
                    PulseCoreView(
                        isConnected: appState.isConnected,
                        isConnecting: appState.isConnecting,
                        color: statusColor
                    )
                    .frame(height: 220)
                    .contentShape(Rectangle()) // Hit testing area
                    .onTapGesture {
                        toggleConnection()
                    }
                    
                    Spacer()
                    
                    // Warning Banner (if needed)
                    if !homebrewManager.isSpoofDPIInstalled {
                        Text("⚠️ SpoofDPI Bulunamadı")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.vexarOrange)
                            .padding(.bottom, 8)
                            .transition(.opacity)
                    }
                    
                    // Connect Button
                    Button(action: toggleConnection) {
                        HStack {
                            Image(systemName: "power")
                                .font(.system(size: 20, weight: .bold))
                            Text(appState.isConnected ? "BAĞLANTIYI KES" : "BAĞLAN")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(appState.isConnected ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            ZStack {
                                if appState.isConnected {
                                    Color.red.opacity(0.8)
                                } else {
                                    Color.white
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(
                            color: (appState.isConnected ? Color.red : Color.white).opacity(0.3),
                            radius: 20, y: 5
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(.white.opacity(0.5), lineWidth: 1)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                    .disabled(appState.isConnecting)
                    
                    // Bottom Navigation Bar
                    HStack(spacing: 0) {
                        NavButton(icon: "gearshape.fill", label: "AYARLAR", destination: "settings")
                        
                        Divider()
                            .frame(height: 20)
                            .background(Color.white.opacity(0.1))
                        
                        NavButton(icon: "doc.text.fill", label: "LOGLAR", destination: "logs")
                        
                        Divider()
                            .frame(height: 20)
                            .background(Color.white.opacity(0.1))
                        
                        Button {
                            NSApplication.shared.terminate(nil)
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "power")
                                    .font(.system(size: 16))
                                Text("ÇIKIŞ")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.secondary)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                    .background(Color.black.opacity(0.2))
                }
            }
            // Emit natural height preference
            .background(GeometryReader { geometry in
                Color.clear.preference(key: ViewHeightKey.self, value: geometry.size.height)
            })
            // Configure Navigation
            .navigationDestination(for: String.self) { destination in
                if destination == "settings" {
                    SettingsView()
                        .environmentObject(appState)
                        .environmentObject(homebrewManager)
                } else if destination == "logs" {
                    LogsView().environmentObject(appState)
                }
            }
        }
        .frame(width: 350, height: windowHeight)
        .preferredColorScheme(.dark)
        // Listen to preference changes for resizing
        .onPreferenceChange(ViewHeightKey.self) { height in
            if height > 0 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    windowHeight = height
                }
            }
        }
    }
    
    // Logic
    func toggleConnection() {
        let impact = NSHapticFeedbackManager.defaultPerformer
        impact.perform(.alignment, performanceTime: .default)
        
        if appState.isConnected {
            withAnimation { appState.disconnect() }
        } else {
            withAnimation { appState.connect() }
        }
    }
    
    var statusColor: Color {
        if appState.isConnecting { return .vexarOrange }
        if appState.isConnected { return .vexarGreen }
        return .vexarBlue
    }
    
    var statusText: String {
        if appState.isConnecting { return "Bağlanıyor..." }
        if appState.isConnected { return "Güvenli" }
        return "Pasif"
    }
}

// MARK: - Components

struct PulseCoreView: View {
    let isConnected: Bool
    let isConnecting: Bool
    let color: Color
    
    @State private var rotation: Double = 0
    @State private var pulse: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Background Glow
            Circle()
                .fill(color.opacity(0.1))
                .blur(radius: 40)
                .frame(width: 180, height: 180)
            
            // Outer Ring (Rotating)
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    AngularGradient(colors: [color.opacity(0), color], center: .center),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 160, height: 160)
                .rotationEffect(.degrees(rotation))
                .animation(.linear(duration: isConnecting ? 1 : 4).repeatForever(autoreverses: false), value: rotation)
            
            // Inner Ring (Counter Rotating)
            Circle()
                .trim(from: 0, to: 0.6)
                .stroke(
                    AngularGradient(colors: [color, color.opacity(0)], center: .center),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-rotation * 1.5))
            
            // Core
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Circle()
                    .stroke(color.opacity(0.5), lineWidth: 1)
                    .frame(width: 80, height: 80)
                
                Image(systemName: isConnected ? "shield.fill" : "shield.slash.fill")
                    .font(.system(size: 32))
                    .foregroundColor(color)
                    .shadow(color: color, radius: 10)
                    .scaleEffect(pulse)
            }
        }
        .onAppear {
            rotation = 360
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulse = 1.1
            }
        }
    }
}

struct AnimatedMeshBackground: View {
    let statusColor: Color
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Orb 1 (Centered, gentle float)
            Circle()
                .fill(statusColor.opacity(0.3))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: animate ? -40 : 40, y: animate ? -20 : 20)
            
            // Orb 2 (Centered, counter float)
            Circle()
                .fill(Color.purple.opacity(0.2))
                .frame(width: 250, height: 250)
                .blur(radius: 50)
                .offset(x: animate ? 40 : -40, y: animate ? 20 : -20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

struct NavButton: View {
    let icon: String
    let label: String
    let destination: String
    
    var body: some View {
        NavigationLink(value: destination) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(label)
                    .font(.system(size: 9, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundColor(.secondary)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    MenuBarView()
        .environmentObject(AppState())
        .environmentObject(HomebrewManager())
}
