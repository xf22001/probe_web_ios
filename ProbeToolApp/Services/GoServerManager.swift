import Foundation
import ProbeTool

/// Wraps the Go ServerStart() / ServerStop() C functions.
/// gomobile generates top-level C functions, not ObjC class methods.
class GoServerManager {
    private let queue = DispatchQueue(label: "com.probetool.go-server")

    func start(logDir: String, ftpRootDir: String, staticDir: String, timezone: String, completion: @escaping (Bool, String) -> Void) {
        queue.async {
            ServerStart(logDir, ftpRootDir, staticDir, timezone)
            let running = ServerIsRunning()
            let error = running ? "" : ServerLastError()
            DispatchQueue.main.async {
                completion(running, error.isEmpty ? "Server failed to start" : error)
            }
        }
    }

    func stop(completion: @escaping (Bool, String) -> Void) {
        queue.async {
            ServerStop()
            let running = ServerIsRunning()
            let error = ServerLastError()
            DispatchQueue.main.async {
                completion(running, error)
            }
        }
    }
}
