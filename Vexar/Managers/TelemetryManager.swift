import Foundation
import FirebaseFirestore

class TelemetryManager {
    static let shared = TelemetryManager()
    
    private let db = Firestore.firestore()
    private let userDefaultsKey = "com.vexar.anonymousUserId"
    
    var anonymousUserId: String {
        if let storedId = UserDefaults.standard.string(forKey: userDefaultsKey) {
            return storedId
        } else {
            let newId = UUID().uuidString
            UserDefaults.standard.set(newId, forKey: userDefaultsKey)
            return newId
        }
    }
    
    private init() {}
    
    func sendEvent(eventName: String, parameters: [String: Any] = [:]) {
        // Privacy Check: Only send if enabled
        guard UserDefaults.standard.bool(forKey: "isAnalyticsEnabled") else {
            print("[TelemetryManager] Analytics disabled, skipping event: \(eventName)")
            return
        }

        // Optimization: Throttle 'app_launched' to once every 30 minutes
        if eventName == "app_launched", shouldThrottle(event: eventName) {
            print("[TelemetryManager] Event '\(eventName)' throttled.")
            return
        }
    
        let baseData: [String: Any] = [
            "userId": anonymousUserId,
            "eventName": eventName,
            "timestamp": FieldValue.serverTimestamp(),
            "platform": "macOS",
            "parameters": parameters
        ]
        
        // Add to 'events' collection
        db.collection("events").addDocument(data: baseData) { error in
            if let error = error {
                print("[TelemetryManager] Error sending event: \(error.localizedDescription)")
            } else {
                print("[TelemetryManager] Event '\(eventName)' sent successfully.")
                self.saveLastEventTime(for: eventName)
            }
        }
    }
    
    // MARK: - Optimization Helpers
    
    private func shouldThrottle(event: String) -> Bool {
        let key = "last_sent_\(event)"
        guard let lastDate = UserDefaults.standard.object(forKey: key) as? Date else { return false }
        
        // 30 minutes interval
        return Date().timeIntervalSince(lastDate) < 1800
    }
    
    private func saveLastEventTime(for event: String) {
        let key = "last_sent_\(event)"
        UserDefaults.standard.set(Date(), forKey: key)
    }
}
