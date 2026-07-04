import Foundation
import Combine

/// ObservableObject holding the service's running state.
class ServerState: ObservableObject {
    @Published var isRunning = false
    @Published var isStarting = false
    @Published var lastError = ""

    private let manager = GoServerManager()

    func toggle() {
        if isStarting {
            return
        }

        if isRunning {
            manager.stop { [weak self] running, error in
                guard let self else { return }
                self.isRunning = running
                self.isStarting = false
                self.lastError = running ? error : ""
            }
        } else {
            do {
                try StaticFileManager.ensureStaticFiles()
            } catch {
                lastError = error.localizedDescription
                return
            }
            isStarting = true
            isRunning = false
            lastError = ""
            manager.start(
                logDir: DirectoryHelper.logDir,
                ftpRootDir: DirectoryHelper.ftpRootDir,
                staticDir: DirectoryHelper.staticDir,
                timezone: TimeZone.current.identifier
            ) { [weak self] running, error in
                guard let self else { return }
                self.isRunning = running
                self.isStarting = false
                self.lastError = running ? "" : error
            }
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
