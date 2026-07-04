import Foundation
import ProbeTool

/// Wraps the Go ServerStart() / ServerStop() C functions.
/// gomobile generates top-level C functions, not ObjC class methods.
class GoServerManager {
    private let queue = DispatchQueue(label: "com.probetool.go-server")

    func start(logDir: String, ftpRootDir: String, staticDir: String, timezone: String) {
        queue.async {
            ServerStart(logDir, ftpRootDir, staticDir, timezone)
        }
    }

    func stop() {
        queue.async {
            ServerStop()
        }
    }
}
