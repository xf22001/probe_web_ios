import Foundation
import Combine

/// ObservableObject holding the service's running state.
/// Mirrors Android's `GoForegroundService.isRunning` StateFlow.
class ServerState: ObservableObject {
    @Published var isRunning = false

    private let manager = GoServerManager()

    func toggle() {
        if isRunning {
            manager.stop()
            isRunning = false
        } else {
            StaticFileManager.ensureStaticFiles()
            manager.start(
                logDir: DirectoryHelper.logDir,
                ftpRootDir: DirectoryHelper.ftpRootDir,
                staticDir: DirectoryHelper.staticDir,
                timezone: TimeZone.current.identifier
            )
            isRunning = true
        }
    }
}

struct DirectoryHelper {
    static var documentDir: String {
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }

    static var logDir: String {
        let dir = (documentDir as NSString).appendingPathComponent("logs")
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        return dir
    }

    static var ftpRootDir: String {
        let dir = (documentDir as NSString).appendingPathComponent("ftp_share")
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        return dir
    }

    static var staticDir: String {
        let dir = (documentDir as NSString).appendingPathComponent("static")
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        return dir
    }
}
