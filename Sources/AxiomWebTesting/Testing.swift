import Foundation
import AxiomWebRender
import AxiomWebUI

#if canImport(WebKit)
import WebKit

@MainActor
public final class BrowserPage {
    private let webView: WKWebView

    public init() {
        self.webView = WKWebView(frame: .zero)
    }

    public func goto(_ url: URL) {
        webView.load(URLRequest(url: url))
    }

    public func setHTML(_ html: String) {
        webView.loadHTMLString(html, baseURL: nil)
    }

    public func content() async throws -> String {
        let result = try await webView.evaluateJavaScript("document.documentElement.outerHTML")
        return result as? String ?? ""
    }
}
#endif

public struct SnapshotResult: Sendable, Equatable {
    public let matched: Bool
    public let expected: String
    public let actual: String
}

public enum SnapshotTesting {
    public static func compare(expected: String, actual: String) -> SnapshotResult {
        SnapshotResult(matched: expected == actual, expected: expected, actual: actual)
    }
}

public enum AccessibilityIssue: Sendable, Equatable {
    case imageMissingAlt
    case inputMissingLabel
    case missingMainLandmark
}

public enum AccessibilityAuditRunner {
    public static func audit(html: String) -> [AccessibilityIssue] {
        var issues: [AccessibilityIssue] = []

        if html.contains("<img") && !html.contains("alt=") {
            issues.append(.imageMissingAlt)
        }

        if html.contains("<input") && !html.contains("<label") {
            issues.append(.inputMissingLabel)
        }

        if !html.contains("<main") {
            issues.append(.missingMainLandmark)
        }

        return issues
    }
}
