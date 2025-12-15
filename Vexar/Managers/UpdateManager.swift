import Foundation

/// Model for GitHub Release
struct GitHubRelease: Codable {
    let tagName: String
    let htmlUrl: String
    let body: String
    let assets: [GitHubAsset]
    
    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlUrl = "html_url"
        case body
        case assets
    }
}

struct GitHubAsset: Codable {
    let browserDownloadUrl: String
    
    enum CodingKeys: String, CodingKey {
        case browserDownloadUrl = "browser_download_url"
    }
}

/// Manages update checking against GitHub Releases
@MainActor
class UpdateManager: ObservableObject {
    @Published var isUpdateAvailable: Bool = false
    @Published var latestVersion: String = ""
    @Published var releaseNotes: String = ""
    @Published var downloadURL: URL?
    
    // TODO: USER MUST CONFIGURE THIS
    private let githubOwner = "MuratGuelr" // CHANGE THIS
    private let githubRepo = "vexar-app"     // CHANGE THIS
    
    func checkForUpdates() async {
        guard let url = URL(string: "https://api.github.com/repos/\(githubOwner)/\(githubRepo)/releases/latest") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
            
            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
            
            if isNewerVersion(remote: release.tagName, current: currentVersion) {
                self.latestVersion = release.tagName
                self.releaseNotes = release.body
                
                // Find .dmg or .zip asset
                if let asset = release.assets.first(where: { $0.browserDownloadUrl.hasSuffix(".dmg") || $0.browserDownloadUrl.hasSuffix(".zip") }) {
                    self.downloadURL = URL(string: asset.browserDownloadUrl)
                } else {
                    self.downloadURL = URL(string: release.htmlUrl) // Fallback to release page
                }
                
                self.isUpdateAvailable = true
            }
        } catch {
            print("Update check failed: \(error)")
        }
    }
    
    private func isNewerVersion(remote: String, current: String) -> Bool {
        // Remove prefixes like "v"
        let remoteClean = remote.replacingOccurrences(of: "v", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        let currentClean = current.replacingOccurrences(of: "v", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        let remoteComponents = remoteClean.split(separator: ".").compactMap { Int($0) }
        let currentComponents = currentClean.split(separator: ".").compactMap { Int($0) }
        
        let maxLength = max(remoteComponents.count, currentComponents.count)
        
        for i in 0..<maxLength {
            let rVal = i < remoteComponents.count ? remoteComponents[i] : 0
            let cVal = i < currentComponents.count ? currentComponents[i] : 0
            
            if rVal > cVal {
                return true
            } else if rVal < cVal {
                return false
            }
        }
        
        return false // Exactly equal
    }
}
