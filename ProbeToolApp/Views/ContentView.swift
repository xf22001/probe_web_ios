import SwiftUI

/// Root view: native top bar plus WKWebView, with hamburger-to-open drawer.
/// No swipe gesture — only hamburger icon opens, tap dim overlay closes.
struct ContentView: View {
    @EnvironmentObject var serverState: ServerState
    @State private var isDrawerOpen = false

    private let drawerWidth: CGFloat = 280

    var body: some View {
        ZStack(alignment: .leading) {
            // — Layer 1: Native chrome + WebView content —
            VStack(spacing: 0) {
                HStack {
                    Button(action: { openDrawer() }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.footnote)
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
                    }
                    .accessibilityLabel("Open menu")

                    Spacer()
                }
                .padding(.horizontal, 4)
                .frame(height: 32)
                .background(Color(.systemBackground))

                WebViewContainer(
                    urlString: "http://127.0.0.1:8000",
                    isRunning: serverState.isRunning
                )
            }

            // — Layer 2: Dim overlay (tap to close) —
            if isDrawerOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { closeDrawer() }
            }

            // — Layer 3: Drawer panel —
            SideDrawerMenu(isOpen: $isDrawerOpen)
                .offset(x: isDrawerOpen ? 0 : -drawerWidth)
                .animation(.easeInOut(duration: 0.2), value: isDrawerOpen)
        }
        .onOpenURL { _ in
            closeDrawer()
        }
    }

    private func openDrawer() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isDrawerOpen = true
        }
    }

    private func closeDrawer() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isDrawerOpen = false
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ServerState())
}
