import CoreGraphics
import Foundation

#if canImport(WebKit)
import WebKit

@MainActor
public final class Browser {
    public let configuration: BrowserConfiguration
    private var pages: [Page] = []
    private var isLaunched = false

    public init(configuration: BrowserConfiguration = .default) {
        self.configuration = configuration
    }

    public func launch() async throws {
        guard !isLaunched else { return }
        if configuration.clearStorageOnLaunch {
            await clearWebsiteData()
        }
        isLaunched = true
    }

    public func newPage() async throws -> Page {
        guard isLaunched else {
            throw BrowserError.webViewNotReady
        }

        let webViewConfiguration = makeWebViewConfiguration()
        let webView = WKWebView(
            frame: CGRect(origin: .zero, size: configuration.viewportSize),
            configuration: webViewConfiguration
        )
        webView.customUserAgent = configuration.userAgent
        let page = Page(webView: webView, configuration: configuration)
        pages.append(page)
        return page
    }

    public func close() async throws {
        for page in pages {
            await page.close()
        }
        pages.removeAll()
        isLaunched = false
    }

    private func makeWebViewConfiguration() -> WKWebViewConfiguration {
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.preferences.javaScriptEnabled = configuration.enableJavaScript
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, visionOS 1.0, *) {
            webViewConfiguration.defaultWebpagePreferences.allowsContentJavaScript = configuration.enableJavaScript
        }
        return webViewConfiguration
    }

    private func clearWebsiteData() async {
        let dataStore = WKWebsiteDataStore.default()
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        await withCheckedContinuation { continuation in
            dataStore.removeData(ofTypes: dataTypes, modifiedSince: Date.distantPast) {
                continuation.resume()
            }
        }
    }
}

#else

@MainActor
public final class Browser {
    public let configuration: BrowserConfiguration

    public init(configuration: BrowserConfiguration = .default) {
        self.configuration = configuration
    }

    public func launch() async throws {
        throw BrowserError.unsupportedFeature("WebKit is not available on this platform.")
    }

    public func newPage() async throws -> Page {
        throw BrowserError.unsupportedFeature("WebKit is not available on this platform.")
    }

    public func close() async throws {
        throw BrowserError.unsupportedFeature("WebKit is not available on this platform.")
    }
}

#endif
