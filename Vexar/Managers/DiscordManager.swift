import Foundation
import AppKit

/// Manages Discord app launching with proxy configuration
final class DiscordManager {
    
    private let discordAppPath = "/Applications/Discord.app"
    private let discordBinaryPath = "/Applications/Discord.app/Contents/MacOS/Discord"
    
    enum DiscordError: LocalizedError {
        case notInstalled
        case launchFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .notInstalled:
                return "Discord is not installed at /Applications/Discord.app"
            case .launchFailed(let reason):
                return "Failed to launch Discord: \(reason)"
            }
        }
    }
    
    /// Check if Discord is installed
    var isDiscordInstalled: Bool {
        FileManager.default.fileExists(atPath: discordAppPath)
    }
    
    /// Kill any running Discord process
    func killDiscord(completion: @escaping () -> Void) {
        // Kill via NSWorkspace
        let runningApps = NSWorkspace.shared.runningApplications
        for app in runningApps {
            if app.bundleIdentifier == "com.hnc.Discord" || 
               app.bundleIdentifier?.contains("discord") == true ||
               app.localizedName == "Discord" {
                app.forceTerminate()
            }
        }
        
        // Also try pkill as backup
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pkill")
        process.arguments = ["-9", "-f", "Discord"]
        try? process.run()
        process.waitUntilExit()
        
        // Wait for Discord to fully close
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            completion()
        }
    }
    
    /// Launch Discord with proxy server flag
    func launchDiscord(withProxyPort port: Int, completion: ((Bool) -> Void)? = nil) {
        killDiscord { [self] in
            self.launchDiscordWithProxy(port: port, completion: completion)
        }
    }
    
    private func launchDiscordWithProxy(port: Int, completion: ((Bool) -> Void)?) {
        guard FileManager.default.fileExists(atPath: discordBinaryPath) else {
            print("[Vexar] Discord binary not found at \(discordBinaryPath)")
            completion?(false)
            return
        }
        
        // Discord uses Chromium, so it supports --proxy-server flag
        // SpoofDPI creates an HTTP proxy, so we use http://
        let proxyArg = "--proxy-server=http://127.0.0.1:\(port)"
        
        print("[Vexar] Launching Discord with: \(proxyArg)")
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: discordBinaryPath)
        process.arguments = [proxyArg]
        
        // Set environment to help with proxy
        var env = ProcessInfo.processInfo.environment
        env["HTTP_PROXY"] = "http://127.0.0.1:\(port)"
        env["HTTPS_PROXY"] = "http://127.0.0.1:\(port)"
        env["http_proxy"] = "http://127.0.0.1:\(port)"
        env["https_proxy"] = "http://127.0.0.1:\(port)"
        process.environment = env
        
        do {
            try process.run()
            print("[Vexar] Discord launched successfully with proxy on port \(port)")
            TelemetryManager.shared.sendEvent(eventName: "discord_launched", parameters: ["port": port, "status": "success"])
            completion?(true)
        } catch {
            print("[Vexar] Failed to launch Discord: \(error)")
            TelemetryManager.shared.sendEvent(eventName: "discord_launched", parameters: ["status": "failed", "error": error.localizedDescription])
            completion?(false)
        }
    }
    
    /// Launch Discord normally (without proxy)
    func launchDiscordNormally() {
        NSWorkspace.shared.open(URL(fileURLWithPath: discordAppPath))
    }
}
