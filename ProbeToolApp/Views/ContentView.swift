import SwiftUI

/// Root view: full-screen WKWebView with a swipe-to-open native drawer.
/// Drawer contains service toggle and log export.
struct ContentView: View {
    @EnvironmentObject var serverState: ServerState
    @State private var drawerOffset: CGFloat = -280 // Hidden
    @State private var dragOffset: CGFloat = 0

    private let drawerWidth: CGFloat = 280

    var isDrawerOpen: Bool {
        drawerOffset >= 0
    }

    var body: some View {
        ZStack(alignment: .leading) {
            // — Layer 1: Full-screen WebView —
            WebViewContainer(
                urlString: "http://127.0.0.1:8000",
                isRunning: serverState.isRunning
            )
            .ignoresSafeArea()

            // — Layer 2: Dim overlay when drawer is open —
            if drawerOffset > -drawerWidth {
                Color.black.opacity(Double((drawerWidth + drawerOffset) / drawerWidth) * 0.4)
                    .ignoresSafeArea()
                    .onTapGesture { closeDrawer() }
            }

            // — Layer 3: Hamburger button —
            VStack {
                HStack {
                    Button(action: { openDrawer() }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 16)
                    .padding(.top, 50)
                    Spacer()
                }
                Spacer()
            }

            // — Layer 4: Drawer panel —
            SideDrawerMenu(isOpen: Binding(
                get: { drawerOffset >= 0 },
                set: { _ in }
            ))
            .offset(x: drawerOffset + dragOffset)
            .animation(.easeInOut(duration: 0.2), value: drawerOffset)
            .animation(.easeInOut(duration: 0.2), value: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let offset = value.translation.width
                        if drawerOffset <= 0 && offset > 0 {
                            // Opening gesture
                            dragOffset = min(offset, drawerWidth)
                        } else if drawerOffset >= 0 && offset < 0 {
                            // Closing gesture
                            dragOffset = max(offset, -drawerWidth)
                        }
                    }
                    .onEnded { value in
                        let velocity = value.predictedEndTranslation.width - value.translation.width
                        if drawerOffset + dragOffset + velocity > -drawerWidth / 2 {
                            openDrawer()
                        } else {
                            closeDrawer()
                        }
                        dragOffset = 0
                    }
            )
        }
        .onOpenURL { _ in
            closeDrawer()
        }
    }

    private func openDrawer() {
        withAnimation(.easeInOut(duration: 0.2)) {
            drawerOffset = 0
        }
    }

    private func closeDrawer() {
        withAnimation(.easeInOut(duration: 0.2)) {
            drawerOffset = -drawerWidth
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ServerState())
}
