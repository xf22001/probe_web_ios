import Foundation
import SwiftUI

/// Lists log files and presents the system share sheet.
/// Mirrors Android's share intent in MainActivity.shareLogFile().
class LogExportManager {
    static func logFiles() -> [URL] {
        let logDir = URL(fileURLWithPath: DirectoryHelper.logDir)
        guard FileManager.default.fileExists(atPath: logDir.path) else { return [] }
        let files = (try? FileManager.default.contentsOfDirectory(
            at: logDir, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]
        )) ?? []
        return files
            .filter { $0.pathExtension == "txt" && $0.lastPathComponent.hasPrefix("session_log_") }
            .sorted { a, b in
                let da = (try? a.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
                let db = (try? b.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
                return da > db
            }
    }

    static func shareLog(_ url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootVC.view
            rootVC.present(activityVC, animated: true)
        }
    }
}
