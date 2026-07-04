import SwiftUI

/// Native side drawer menu with service toggle and log export.
/// Mirrors the Android ModalNavigationDrawer content.
struct SideDrawerMenu: View {
    @EnvironmentObject var serverState: ServerState
    @Binding var isOpen: Bool
    @State private var showLogSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // — Top spacing —
            Spacer().frame(height: 60)

            // — Service status card —
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(serverState.isRunning ? Color.green : Color.orange)
                        .frame(width: 10, height: 10)
                    Text(serverState.isRunning ? "Service Running" : "Service Stopped")
                        .font(.headline)
                        .foregroundColor(serverState.isRunning ? Color(red: 0.18, green: 0.49, blue: 0.20) : Color(red: 0.90, green: 0.40, blue: 0.0))
                }

                Text(serverState.isRunning ? "http://127.0.0.1:8000" : "Tap to start")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button(action: {
                    serverState.toggle()
                    isOpen = false
                }) {
                    HStack {
                        Image(systemName: serverState.isRunning ? "stop.fill" : "play.fill")
                            .font(.caption)
                        Text(serverState.isRunning ? "STOP SERVICE" : "START SERVICE")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(serverState.isRunning ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.top, 4)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(serverState.isRunning ? Color(red: 0.91, green: 0.96, blue: 0.91) : Color(red: 1.0, green: 0.95, blue: 0.88))
            )
            .padding(.horizontal, 16)

            Divider().padding(.vertical, 20).padding(.horizontal, 16)

            // — Export Logs —
            Button(action: {
                isOpen = false
                showLogSheet = true
            }) {
                HStack(spacing: 14) {
                    Image(systemName: "square.and.arrow.up")
                        .frame(width: 22)
                    Text("Export Logs")
                        .font(.body)
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 28)
            }
            .foregroundColor(.primary)

            Spacer()
        }
        .frame(width: 280)
        .background(Color(.systemBackground))
        .sheet(isPresented: $showLogSheet) {
            LogExportSheet(isPresented: $showLogSheet)
        }
    }
}

/// Bottom sheet for selecting and sharing log files.
/// Mirrors Android's ModalBottomSheet with LazyColumn.
struct LogExportSheet: View {
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            List {
                let files = LogExportManager.logFiles()
                if files.isEmpty {
                    Text("No log files to share")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(files, id: \.path) { file in
                        Button(action: {
                            LogExportManager.shareLog(file)
                            isPresented = false
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(file.lastPathComponent)
                                    .font(.body)
                                if let attrs = try? FileManager.default.attributesOfItem(atPath: file.path) {
                                    let size = attrs[.size] as? Int64 ?? 0
                                    let date = attrs[.modificationDate] as? Date ?? Date()
                                    Text("Size: \(size) bytes, Modified: \(date.formatted(date: .numeric, time: .shortened))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Export Logs")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
}
