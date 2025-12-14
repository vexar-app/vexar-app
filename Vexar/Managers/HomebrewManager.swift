import Foundation
import AppKit

/// Manages Homebrew and SpoofDPI installation with Intel/Apple Silicon detection
@MainActor
final class HomebrewManager: ObservableObject {
    @Published var isHomebrewInstalled: Bool = false
    @Published var isSpoofDPIInstalled: Bool = false
    @Published var isInstalling: Bool = false
    @Published var installProgress: String = ""
    @Published var installError: String?
    @Published var cpuArchitecture: CPUArchitecture = .unknown
    @Published var installCommand: String = ""
    
    enum CPUArchitecture: String {
        case applesilicon = "arm64"
        case intel = "x86_64"
        case unknown = "unknown"
        
        var displayName: String {
            switch self {
            case .applesilicon: return "Apple Silicon (M1/M2/M3/M4)"
            case .intel: return "Intel"
            case .unknown: return "Unknown"
            }
        }
    }
    
    init() {
        detectArchitecture()
        checkInstallations()
    }
    
    /// Detect CPU architecture
    private func detectArchitecture() {
        var sysinfo = utsname()
        uname(&sysinfo)
        let machine = withUnsafePointer(to: &sysinfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: Int(_SYS_NAMELEN)) {
                String(cString: $0)
            }
        }
        
        if machine == "arm64" {
            cpuArchitecture = .applesilicon
        } else if machine == "x86_64" {
            cpuArchitecture = .intel
        } else {
            cpuArchitecture = .unknown
        }
        
        print("[Vexar] Detected CPU: \(cpuArchitecture.displayName)")
    }
    
    /// Check installations
    func checkInstallations() {
        let homebrewPaths = ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"]
        isHomebrewInstalled = homebrewPaths.contains { FileManager.default.fileExists(atPath: $0) }
        
        let spoofDPIPaths = ["/opt/homebrew/bin/spoofdpi", "/usr/local/bin/spoofdpi"]
        isSpoofDPIInstalled = spoofDPIPaths.contains { FileManager.default.fileExists(atPath: $0) }
        
        print("[Vexar] Homebrew: \(isHomebrewInstalled), SpoofDPI: \(isSpoofDPIInstalled)")
    }
    
    /// Get Homebrew path
    func getHomebrewPath() -> String? {
        let paths = ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"]
        return paths.first { FileManager.default.fileExists(atPath: $0) }
    }
    
    /// Get SpoofDPI path
    func getSpoofDPIPath() -> String? {
        let paths = ["/opt/homebrew/bin/spoofdpi", "/usr/local/bin/spoofdpi"]
        return paths.first { FileManager.default.fileExists(atPath: $0) }
    }
    
    /// Install SpoofDPI - copies command and opens Terminal
    func installSpoofDPI() async -> Bool {
        guard let brewPath = getHomebrewPath() else {
            installError = "Homebrew bulunamadı"
            return false
        }
        
        isInstalling = true
        installError = nil
        
        let command = "\(brewPath) install spoofdpi"
        installCommand = command
        
        // Copy to clipboard
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(command, forType: .string)
        
        // Open Terminal using shell script approach
        let scriptPath = "/tmp/vexar_install.sh"
        let scriptContent = """
        #!/bin/bash
        \(command)
        echo ""
        echo "✅ Kurulum tamamlandı! Bu pencereyi kapatabilirsiniz."
        read -p "Devam etmek için Enter'a basın..."
        """
        
        do {
            try scriptContent.write(toFile: scriptPath, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptPath)
            
            // Open Terminal with the script
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            process.arguments = ["-a", "Terminal", scriptPath]
            try process.run()
            
            installProgress = "Terminal'de kurulum başlatıldı!\nKomut panoya kopyalandı."
            isInstalling = false
            return true
        } catch {
            print("[Vexar] Error: \(error)")
            installError = "Komut panoya kopyalandı.\nTerminal'i açıp yapıştırın: ⌘V"
            isInstalling = false
            return false
        }
    }
    
    /// Install Homebrew
    func openTerminalForHomebrew() {
        let command = "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        installCommand = command
        
        // Copy to clipboard
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(command, forType: .string)
        
        // Create script file
        let scriptPath = "/tmp/vexar_homebrew.sh"
        let scriptContent = """
        #!/bin/bash
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        """
        
        do {
            try scriptContent.write(toFile: scriptPath, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptPath)
            
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            process.arguments = ["-a", "Terminal", scriptPath]
            try process.run()
        } catch {
            print("[Vexar] Error: \(error)")
            installError = "Komut panoya kopyalandı.\nTerminal'i açıp yapıştırın: ⌘V"
        }
    }
}
