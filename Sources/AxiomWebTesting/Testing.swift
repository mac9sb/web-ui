import Foundation
import AxiomWebRender
import AxiomWebUI

#if canImport(WebKit)
import WebKit

public enum BrowserError: Error, Equatable {
    case navigationInProgress
    case navigationFailed(String)
    case evaluationFailed(String)
    case elementNotFound(String)
    case timeout(String)
}

@MainActor
public final class BrowserPage: NSObject, WKNavigationDelegate {
    private let webView: WKWebView
    private var navigationContinuation: CheckedContinuation<Void, Error>?

    public init(configuration: WKWebViewConfiguration = WKWebViewConfiguration()) {
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        super.init()
        webView.navigationDelegate = self
    }

    public func goto(_ url: URL) async throws {
        try await beginNavigation {
            webView.load(URLRequest(url: url))
        }
    }

    public func setHTML(_ html: String, baseURL: URL? = nil) async throws {
        try await beginNavigation {
            webView.loadHTMLString(html, baseURL: baseURL)
        }
    }

    public func content() async throws -> String {
        let value = try await evaluate("document.documentElement.outerHTML")
        return value as? String ?? ""
    }

    public func evaluate(_ script: String) async throws -> Any {
        do {
            return try await webView.evaluateJavaScript(script) as Any
        } catch {
            throw BrowserError.evaluationFailed(String(describing: error))
        }
    }

    public func exists(_ selector: String) async throws -> Bool {
        let query = javascriptLiteral(selector)
        let script = "document.querySelector(\(query)) !== null"
        return (try await evaluate(script) as? Bool) ?? false
    }

    public func textContent(of selector: String) async throws -> String? {
        let query = javascriptLiteral(selector)
        let script = "(function(){const node=document.querySelector(\(query));return node?node.textContent:null;})()"
        return try await evaluate(script) as? String
    }

    public func click(_ selector: String) async throws {
        let query = javascriptLiteral(selector)
        let script = "(function(){const node=document.querySelector(\(query));if(!node){return false;}node.click();return true;})()"
        let didClick = (try await evaluate(script) as? Bool) ?? false
        if !didClick {
            throw BrowserError.elementNotFound(selector)
        }
    }

    public func fill(_ selector: String, with value: String) async throws {
        let query = javascriptLiteral(selector)
        let jsValue = javascriptLiteral(value)
        let script = "(function(){const node=document.querySelector(\(query));if(!node){return false;}node.value=\(jsValue);node.dispatchEvent(new Event('input',{bubbles:true}));node.dispatchEvent(new Event('change',{bubbles:true}));return true;})()"
        let didFill = (try await evaluate(script) as? Bool) ?? false
        if !didFill {
            throw BrowserError.elementNotFound(selector)
        }
    }

    public func waitFor(selector: String, timeout: Duration = .seconds(2), pollEvery: Duration = .milliseconds(50)) async throws {
        let start = ContinuousClock.now
        while true {
            if try await exists(selector) {
                return
            }

            if start.duration(to: .now) >= timeout {
                throw BrowserError.timeout("Timed out waiting for selector: \(selector)")
            }

            try await Task.sleep(for: pollEvery)
        }
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        navigationContinuation?.resume()
        navigationContinuation = nil
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        navigationContinuation?.resume(throwing: BrowserError.navigationFailed(String(describing: error)))
        navigationContinuation = nil
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        navigationContinuation?.resume(throwing: BrowserError.navigationFailed(String(describing: error)))
        navigationContinuation = nil
    }

    private func beginNavigation(_ start: () -> Void) async throws {
        guard navigationContinuation == nil else {
            throw BrowserError.navigationInProgress
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            navigationContinuation = continuation
            start()
        }
    }

    private func javascriptLiteral(_ value: String) -> String {
        let escaped = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "")
        return "\"\(escaped)\""
    }
}
#endif

public struct SnapshotComparisonOptions: Sendable, Equatable {
    public var trimWhitespace: Bool
    public var collapseInterTagWhitespace: Bool

    public init(trimWhitespace: Bool = true, collapseInterTagWhitespace: Bool = true) {
        self.trimWhitespace = trimWhitespace
        self.collapseInterTagWhitespace = collapseInterTagWhitespace
    }
}

public struct SnapshotResult: Sendable, Equatable {
    public let matched: Bool
    public let expected: String
    public let actual: String
}

public enum SnapshotTesting {
    public static func compare(expected: String, actual: String, options: SnapshotComparisonOptions = .init()) -> SnapshotResult {
        let normalizedExpected = normalize(expected, options: options)
        let normalizedActual = normalize(actual, options: options)
        return SnapshotResult(matched: normalizedExpected == normalizedActual, expected: normalizedExpected, actual: normalizedActual)
    }

    public static func normalize(_ value: String, options: SnapshotComparisonOptions = .init()) -> String {
        var output = value
        if options.collapseInterTagWhitespace {
            output = output.replacingOccurrences(of: #">\s+<"#, with: "><", options: .regularExpression)
        }
        if options.trimWhitespace {
            output = output.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return output
    }
}

public enum ComponentSnapshot {
    public static func render(_ markup: some Markup) -> String {
        markup.renderHTML()
    }

    public static func render(document: any Document, options: RenderOptions = .init()) throws -> String {
        try RenderEngine.render(document: document, locale: .en, options: options).html
    }
}

public enum AccessibilityIssue: Sendable, Equatable {
    case imageMissingAlt
    case inputMissingLabel
    case missingMainLandmark
    case buttonMissingAccessibleName
    case missingHTMLLang
    case positiveTabIndexDetected
    case motionWithoutReducedMotionFallback
}

public enum AccessibilityAuditRunner {
    public static func audit(html: String) -> [AccessibilityIssue] {
        var issues: [AccessibilityIssue] = []

        if html.range(of: #"<img\b(?![^>]*\balt=)[^>]*>"#, options: .regularExpression) != nil {
            issues.append(.imageMissingAlt)
        }

        let unlabeledInputPattern = #"<(input|textarea|select)\b(?![^>]*\b(aria-label|aria-labelledby)=)[^>]*>"#
        if html.range(of: unlabeledInputPattern, options: .regularExpression) != nil,
           !html.contains("<label") {
            issues.append(.inputMissingLabel)
        }

        if !html.contains("<main") {
            issues.append(.missingMainLandmark)
        }

        let unnamedButtonPattern = #"<button\b(?![^>]*\b(aria-label|aria-labelledby)=)[^>]*>\s*</button>"#
        if html.range(of: unnamedButtonPattern, options: .regularExpression) != nil {
            issues.append(.buttonMissingAccessibleName)
        }

        if html.range(of: #"<html\b"#, options: .regularExpression) != nil,
           html.range(of: #"<html\b[^>]*\blang="#, options: .regularExpression) == nil {
            issues.append(.missingHTMLLang)
        }

        if html.range(of: #"tabindex\s*=\s*\"?[1-9][0-9]*\"?"#, options: .regularExpression) != nil {
            issues.append(.positiveTabIndexDetected)
        }

        if (html.contains("animation:") || html.contains("transition:")) && !html.contains("prefers-reduced-motion") {
            issues.append(.motionWithoutReducedMotionFallback)
        }

        return issues
    }
}
