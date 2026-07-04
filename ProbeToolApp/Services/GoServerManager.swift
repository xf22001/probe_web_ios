import Foundation
import ProbeTool

/// Wraps the Go Server.start() / Server.stop() functions.
/// Mirrors Android's `GoForegroundService` call to Server.start/stop.
class GoServerManager {
    private let queue = DispatchQueue(label: "com.probetool.go-server")

    func start(logDir: String, ftpRootDir: String, staticDir: String, timezone: String) {
        queue.async {
            ProbeToolServer.start(logDir, ftpRootDir, staticDir, timezone)
        }
    }

    func stop() {
        queue.async {
            ProbeToolServer.stop()
        }
    }
}
