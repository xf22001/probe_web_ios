import SwiftUI
import WebKit

/// WKWebView wrapper for SwiftUI.
/// Loads http://127.0.0.1:8000 when the Go service is running.
struct WebViewContainer: UIViewRepresentable {
    let urlString: String
    let isRunning: Bool

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true

        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs

        let view = WKWebView(frame: .zero, configuration: config)
        view.navigationDelegate = context.coordinator
        view.scrollView.contentInsetAdjustmentBehavior = .automatic
        view.isOpaque = false
        view.backgroundColor = .black
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let target = isRunning ? urlString : "stopped"
        guard context.coordinator.lastTarget != target else {
            return
        }
        context.coordinator.lastTarget = target

        if isRunning {
            if let url = URL(string: urlString) {
                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
                uiView.load(request)
            }
        } else {
            uiView.loadHTMLString("<html><body style='background:#000'></body></html>", baseURL: nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var lastTarget = ""

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView navigation failed: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("WebView provisional navigation failed: \(error.localizedDescription)")
        }
    }
}
