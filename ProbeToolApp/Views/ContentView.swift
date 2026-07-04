import SwiftUI

/// Root view: full-screen WKWebView with hamburger-to-open native drawer.
/// No swipe gesture — only hamburger icon opens, tap dim overlay closes.
struct ContentView: View {
    @EnvironmentObject var serverState: ServerState
    @State private var isDrawerOpen = false

    private let drawerWidth: CGFloat = 280

    var body: some View {
        ZStack(alignment: .leading) {
            // — Layer 1: Full-screen WebView —
            WebViewContainer(
                urlString: "http://127.0.0.1:8000",
                isRunning: serverState.isRunning
            )
            .ignoresSafeArea()

            // — Layer 2: Dim overlay (tap to close) —
            if isDrawerOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { closeDrawer() }
            }

            // — Layer 3: Hamburger button —
            VStack {
                HStack {
                    Button(action: { openDrawer() }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.footnote)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 12)
                    .padding(.top, 50)
                    Spacer()
                }
                Spacer()
            }

            // — Layer 4: Drawer panel —
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
