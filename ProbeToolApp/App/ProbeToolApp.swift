import SwiftUI

@main
struct ProbeToolApp: App {
    @StateObject private var serverState = ServerState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(serverState)
        }
    }
}
