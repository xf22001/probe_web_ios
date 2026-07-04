import Foundation

/// Copies the static web files from the app bundle to the sandbox directory.
/// Called once at first launch before starting the Go service.
/// Mirrors Android's asset extraction in GoForegroundService.onStartCommand().
class StaticFileManager {
    private static let didExtractKey = "static_files_extracted"

    static func ensureStaticFiles() {
        guard !UserDefaults.standard.bool(forKey: didExtractKey) else { return }

        let targetDir = URL(fileURLWithPath: DirectoryHelper.staticDir)
        guard let bundleDir = Bundle.main.resourceURL?.appendingPathComponent("Static") else {
            print("Static directory not found in bundle")
            return
        }

        do {
            if FileManager.default.fileExists(atPath: targetDir.path) {
                try FileManager.default.removeItem(at: targetDir)
            }
            try FileManager.default.createDirectory(at: targetDir, withIntermediateDirectories: true)

            let files = try FileManager.default.contentsOfDirectory(at: bundleDir, includingPropertiesForKeys: nil)
            for file in files {
                let dest = targetDir.appendingPathComponent(file.lastPathComponent)
                try FileManager.default.copyItem(at: file, to: dest)
            }

            UserDefaults.standard.set(true, forKey: didExtractKey)
            print("Static files extracted to \(targetDir.path)")
        } catch {
            print("Failed to extract static files: \(error)")
        }
    }
}
