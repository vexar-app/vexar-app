import Foundation
import FirebaseFirestore
import Security

/// TelemetryManager implements a "No-Log Policy" for Firestore quota protection.
/// Instead of creating individual event documents, we maintain a SINGLE device profile
/// per user in the "devices" collection, using FieldValue.increment() for all counters.
class TelemetryManager {
    static let shared = TelemetryManager()
    
    private let db = Firestore.firestore()
    private let keychainService = "com.vexar.deviceid"
    private let keychainAccount = "persistent_device_id"
    
    // MARK: - Persistent Device ID (Keychain-backed)
    
    /// Returns a persistent device UUID stored in Keychain.
    /// This ID survives app uninstalls and reinstalls.
    var deviceId: String {
        // 1. Try to retrieve from Keychain
        if let existingId = retrieveFromKeychain() {
            return existingId
        }
        
        // 2. Generate new UUID and save to Keychain
        let newId = UUID().uuidString
        saveToKeychain(newId)
        return newId
    }
    
    private init() {}
    
    // MARK: - Core Telemetry Functions
    
    /// Syncs privacy settings to Firestore.
    /// CRUCIAL: This MUST run even if isEnabled is false (to inform dashboard that user opted out).
    func syncPrivacySettings(isEnabled: Bool) {
        let data: [String: Any] = [
            "telemetry_enabled": isEnabled,
            "last_config_update": FieldValue.serverTimestamp()
        ]
        
        updateDeviceProfile(with: data)
        print("[TelemetryManager] Privacy settings synced: telemetry_enabled = \(isEnabled)")
    }
    
    /// Tracks app launch. Only runs if telemetry is enabled.
    /// Increments open_count and updates last_seen timestamp.
    func trackAppLaunch() {
        guard UserDefaults.standard.bool(forKey: "isAnalyticsEnabled") else {
            print("[TelemetryManager] Analytics disabled, skipping trackAppLaunch")
            return
        }
        
        let data: [String: Any] = [
            "open_count": FieldValue.increment(Int64(1)),
            "last_seen": FieldValue.serverTimestamp(),
            "macos_version": macOSVersion(),
            "app_version": appVersion(),
            "platform": "macOS"
        ]
        
        updateDeviceProfile(with: data)
        print("[TelemetryManager] App launch tracked")
    }
    
    /// Tracks successful VPN/DNS connection.
    /// Increments connection_count and updates last_connected_at and last_dns.
    func trackConnectionSuccess(dnsName: String) {
        guard UserDefaults.standard.bool(forKey: "isAnalyticsEnabled") else {
            print("[TelemetryManager] Analytics disabled, skipping trackConnectionSuccess")
            return
        }
        
        let data: [String: Any] = [
            "connection_count": FieldValue.increment(Int64(1)),
            "last_connected_at": FieldValue.serverTimestamp(),
            "last_dns": dnsName
        ]
        
        updateDeviceProfile(with: data)
        print("[TelemetryManager] Connection success tracked: \(dnsName)")
    }
    
    /// Tracks onboarding/wizard installation steps (Homebrew, Discord, SpoofDPI).
    /// Records success/failure status for debugging installation issues.
    func trackOnboardingStep(component: String, success: Bool, errorMessage: String? = nil) {
        guard UserDefaults.standard.bool(forKey: "isAnalyticsEnabled") else {
            print("[TelemetryManager] Analytics disabled, skipping trackOnboardingStep")
            return
        }
        
        var data: [String: Any] = [
            "onboarding_\(component)_status": success ? "success" : "failed",
            "onboarding_\(component)_last_attempt": FieldValue.serverTimestamp()
        ]
        
        if let error = errorMessage {
            data["onboarding_\(component)_error"] = error
        }
        
        // Also increment attempt counter
        data["onboarding_\(component)_attempts"] = FieldValue.increment(Int64(1))
        
        updateDeviceProfile(with: data)
        print("[TelemetryManager] Onboarding step tracked: \(component) -> \(success ? "✅" : "❌")")
    }
    
    /// Tracks uninstall actions (which components were deleted).
    /// Helps understand cleanup success rate and potential issues.
    func trackUninstallAction(component: String, success: Bool) {
        guard UserDefaults.standard.bool(forKey: "isAnalyticsEnabled") else {
            print("[TelemetryManager] Analytics disabled, skipping trackUninstallAction")
            return
        }
        
        let data: [String: Any] = [
            "uninstall_\(component)_status": success ? "deleted" : "failed",
            "uninstall_\(component)_timestamp": FieldValue.serverTimestamp()
        ]
        
        updateDeviceProfile(with: data)
        print("[TelemetryManager] Uninstall action tracked: \(component) -> \(success ? "🗑️" : "⚠️")")
    }
    
    /// Collects comprehensive device information ONLY on first launch.
    /// This runs once when device_info_collected flag is not set.
    /// Collects: macOS version, CPU model, RAM, storage capacity, Mac model.
    func collectDeviceInfo(completion: @escaping () -> Void = {}) {
        guard UserDefaults.standard.bool(forKey: "isAnalyticsEnabled") else {
            print("[TelemetryManager] Analytics disabled, skipping collectDeviceInfo")
            completion()
            return
        }
        
        let docRef = db.collection("devices").document(deviceId)
        
        // Check if device info was already collected
        docRef.getDocument { snapshot, error in
            if let error = error {
                print("[TelemetryManager] Error checking device document: \(error.localizedDescription)")
                // Even on error, try to collect (fail-safe)
                self.performDeviceInfoCollection()
                completion()
                return
            }
            
            // Check if device_info_collected flag exists and is true
            if let data = snapshot?.data(),
               let alreadyCollected = data["device_info_collected"] as? Bool,
               alreadyCollected {
                print("[TelemetryManager] Device info already collected, skipping")
                completion()
                return
            }
            
            // First launch or flag not set - collect device info
            print("[TelemetryManager] First launch detected, collecting device info...")
            self.performDeviceInfoCollection()
            completion()
        }
    }
    
    /// Actually performs the device info collection
    private func performDeviceInfoCollection() {
        let deviceData: [String: Any] = [
            "device_info_collected": true,
            "device_collected_at": FieldValue.serverTimestamp(),
            "device_model": self.deviceModel(),
            "device_cpu": self.cpuModel(),
            "device_ram_gb": self.ramSize(),
            "device_storage_gb": self.storageSize(),
            "device_macos_version": self.macOSVersion(),
            "device_architecture": self.cpuArchitecture()
        ]
        
        updateDeviceProfile(with: deviceData)
        print("[TelemetryManager] ✅ Device info collected: \(deviceData["device_model"] ?? "unknown"), \(deviceData["device_cpu"] ?? "unknown"), \(deviceData["device_ram_gb"] ?? 0)GB RAM")
    }

    
    // MARK: - Firestore Update Helper
    
    /// Updates the device profile document using merge: true.
    /// This ensures we never overwrite existing fields and only update specified ones.
    private func updateDeviceProfile(with data: [String: Any]) {
        let docRef = db.collection("devices").document(deviceId)
        
        docRef.setData(data, merge: true) { error in
            if let error = error {
                print("[TelemetryManager] Error updating device profile: \(error.localizedDescription)")
            } else {
                print("[TelemetryManager] Device profile updated successfully")
            }
        }
    }
    
    // MARK: - Device Information Helpers
    
    /// Returns the Mac model (e.g., "MacBookPro18,3")
    private func deviceModel() -> String {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
    }
    
    /// Returns CPU model/brand (e.g., "Apple M1", "Intel Core i7")
    private func cpuModel() -> String {
        var size = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        var brand = [CChar](repeating: 0, count: size)
        sysctlbyname("machdep.cpu.brand_string", &brand, &size, nil, 0)
        let brandString = String(cString: brand)
        
        // If empty (M1/M2 chips don't have brand_string), check for Apple Silicon
        if brandString.isEmpty {
            return "Apple Silicon"
        }
        return brandString
    }
    
    /// Returns CPU architecture (e.g., "arm64", "x86_64")
    private func cpuArchitecture() -> String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }
    
    /// Returns RAM size in GB (rounded)
    private func ramSize() -> Int {
        var size: UInt64 = 0
        var length = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &size, &length, nil, 0)
        return Int(size / 1_073_741_824) // Convert bytes to GB
    }
    
    /// Returns total storage size in GB (rounded)
    private func storageSize() -> Int {
        do {
            let fileURL = URL(fileURLWithPath: "/")
            let values = try fileURL.resourceValues(forKeys: [.volumeTotalCapacityKey])
            if let capacity = values.volumeTotalCapacity {
                return Int(capacity / 1_000_000_000) // Convert bytes to GB (using 1000 not 1024 for marketing size)
            }
        } catch {
            print("[TelemetryManager] Error getting storage size: \(error.localizedDescription)")
        }
        return 0
    }
    
    // MARK: - System Information Helpers
    
    private func macOSVersion() -> String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }
    
    private func appVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }
    
    // MARK: - Keychain Helpers
    
    private func saveToKeychain(_ value: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        // Delete any existing item first to ensure fresh attributes
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: data,
            // Allow access after first unlock without password prompt
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("[TelemetryManager] Failed to save to Keychain: \(status)")
        }
    }
    
    private func retrieveFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
}
