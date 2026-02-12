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

    public func attribute(of selector: String, name: String) async throws -> String? {
        let query = javascriptLiteral(selector)
        let attributeName = javascriptLiteral(name)
        let script = "(function(){const node=document.querySelector(\(query));if(!node){return null;}return node.getAttribute(\(attributeName));})()"
        return try await evaluate(script) as? String
    }

    public func submit(_ selector: String) async throws {
        let query = javascriptLiteral(selector)
        let script = "(function(){const node=document.querySelector(\(query));if(!node){return false;}if(typeof node.requestSubmit==='function'){node.requestSubmit();}else if(typeof node.submit==='function'){node.submit();}else{return false;}return true;})()"
        let didSubmit = (try await evaluate(script) as? Bool) ?? false
        if !didSubmit {
            throw BrowserError.elementNotFound(selector)
        }
    }

    public func waitForText(
        _ text: String,
        in selector: String? = nil,
        timeout: Duration = .seconds(2),
        pollEvery: Duration = .milliseconds(50)
    ) async throws {
        let expected = text
        let start = ContinuousClock.now
        while true {
            let current: String
            if let selector {
                current = try await textContent(of: selector) ?? ""
            } else {
                current = (try await evaluate("document.body ? document.body.textContent : ''") as? String) ?? ""
            }

            if current.contains(expected) {
                return
            }

            if start.duration(to: .now) >= timeout {
                throw BrowserError.timeout("Timed out waiting for text: \(text)")
            }

            try await Task.sleep(for: pollEvery)
        }
    }

    public func normalizedSnapshot(options: SnapshotComparisonOptions = .init()) async throws -> String {
        let html = try await content()
        return SnapshotTesting.normalize(html, options: options)
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

public struct SnapshotSuite: Sendable, Equatable {
    private var baselines: [String: String]

    public init(baselines: [String: String] = [:]) {
        self.baselines = baselines
    }

    public var names: [String] {
        baselines.keys.sorted()
    }

    public mutating func record(name: String, baseline: String) {
        baselines[name] = baseline
    }

    public func baseline(named name: String) -> String? {
        baselines[name]
    }

    public func compare(
        name: String,
        actual: String,
        options: SnapshotComparisonOptions = .init()
    ) -> SnapshotResult? {
        guard let expected = baselines[name] else {
            return nil
        }
        return SnapshotTesting.compare(expected: expected, actual: actual, options: options)
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

public enum AccessibilityIssue: String, Sendable, Equatable, Codable {
    case imageMissingAlt
    case inputMissingLabel
    case missingMainLandmark
    case buttonMissingAccessibleName
    case missingHTMLLang
    case positiveTabIndexDetected
    case motionWithoutReducedMotionFallback
    case invalidARIArole
    case focusStyleRemoved
    case lowContrastText
}

public enum AccessibilitySeverity: String, Sendable, Equatable, Codable {
    case info
    case warning
    case error
}

public struct AccessibilityFinding: Sendable, Equatable, Codable {
    public let issue: AccessibilityIssue
    public let severity: AccessibilitySeverity
    public let message: String
    public let selector: String?

    public init(
        issue: AccessibilityIssue,
        severity: AccessibilitySeverity,
        message: String,
        selector: String? = nil
    ) {
        self.issue = issue
        self.severity = severity
        self.message = message
        self.selector = selector
    }
}

public struct AccessibilityAuditOptions: Sendable, Equatable {
    public var checkImageAlt: Bool
    public var checkInputLabels: Bool
    public var checkMainLandmark: Bool
    public var checkButtonNames: Bool
    public var checkHTMLLang: Bool
    public var checkTabIndex: Bool
    public var checkMotion: Bool
    public var checkRoles: Bool
    public var checkFocusStyles: Bool
    public var checkContrast: Bool
    public var minimumContrastRatio: Double

    public init(
        checkImageAlt: Bool = true,
        checkInputLabels: Bool = true,
        checkMainLandmark: Bool = true,
        checkButtonNames: Bool = true,
        checkHTMLLang: Bool = true,
        checkTabIndex: Bool = true,
        checkMotion: Bool = true,
        checkRoles: Bool = true,
        checkFocusStyles: Bool = true,
        checkContrast: Bool = true,
        minimumContrastRatio: Double = 4.5
    ) {
        self.checkImageAlt = checkImageAlt
        self.checkInputLabels = checkInputLabels
        self.checkMainLandmark = checkMainLandmark
        self.checkButtonNames = checkButtonNames
        self.checkHTMLLang = checkHTMLLang
        self.checkTabIndex = checkTabIndex
        self.checkMotion = checkMotion
        self.checkRoles = checkRoles
        self.checkFocusStyles = checkFocusStyles
        self.checkContrast = checkContrast
        self.minimumContrastRatio = max(1.0, minimumContrastRatio)
    }
}

public struct AccessibilityAuditReport: Sendable, Equatable, Codable {
    public let findings: [AccessibilityFinding]

    public init(findings: [AccessibilityFinding]) {
        self.findings = findings
    }

    public var issues: [AccessibilityIssue] {
        var seen = Set<AccessibilityIssue>()
        return findings.compactMap { finding in
            if seen.insert(finding.issue).inserted {
                return finding.issue
            }
            return nil
        }
    }

    public var hasErrors: Bool {
        findings.contains { $0.severity == .error }
    }

    public var hasWarnings: Bool {
        findings.contains { $0.severity == .warning }
    }

    public var passed: Bool {
        !hasErrors
    }
}

public enum AccessibilityCIReportFormat: Sendable {
    case markdown
    case json
}

public enum AccessibilityCIGateError: Error, Equatable {
    case failed(errorCount: Int, warningCount: Int)
}

public struct AccessibilityCIGateOptions: Sendable, Equatable {
    public var failOnWarnings: Bool

    public init(failOnWarnings: Bool = false) {
        self.failOnWarnings = failOnWarnings
    }
}

public enum AccessibilityCIReporter {
    public static func render(
        _ report: AccessibilityAuditReport,
        format: AccessibilityCIReportFormat = .markdown
    ) -> String {
        switch format {
        case .markdown:
            return markdown(report)
        case .json:
            return json(report)
        }
    }

    private static func markdown(_ report: AccessibilityAuditReport) -> String {
        guard !report.findings.isEmpty else {
            return "## Accessibility Audit\n\nNo issues found."
        }

        var lines: [String] = []
        lines.append("## Accessibility Audit")
        lines.append("")
        lines.append("| Severity | Issue | Selector | Message |")
        lines.append("| --- | --- | --- | --- |")
        for finding in report.findings {
            let selector = finding.selector ?? "-"
            lines.append("| \(finding.severity.rawValue) | \(finding.issue.rawValue) | \(selector) | \(finding.message) |")
        }
        return lines.joined(separator: "\n")
    }

    private static func json(_ report: AccessibilityAuditReport) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(report),
              let value = String(data: data, encoding: .utf8) else {
            return "{\"findings\":[]}"
        }
        return value
    }
}

public enum AccessibilityCIGate {
    public static func validate(
        _ report: AccessibilityAuditReport,
        options: AccessibilityCIGateOptions = .init()
    ) throws {
        let errorCount = report.findings.filter { $0.severity == .error }.count
        let warningCount = report.findings.filter { $0.severity == .warning }.count

        if errorCount > 0 || (options.failOnWarnings && warningCount > 0) {
            throw AccessibilityCIGateError.failed(errorCount: errorCount, warningCount: warningCount)
        }
    }
}

public enum AccessibilityAuditRunner {
    public static func audit(html: String) -> [AccessibilityIssue] {
        auditReport(html: html).issues
    }

    public static func auditReport(
        html: String,
        options: AccessibilityAuditOptions = .init()
    ) -> AccessibilityAuditReport {
        let lower = html.lowercased()
        var findings: [AccessibilityFinding] = []

        func add(
            _ issue: AccessibilityIssue,
            severity: AccessibilitySeverity,
            _ message: String,
            selector: String? = nil
        ) {
            if findings.contains(where: { $0.issue == issue && $0.selector == selector && $0.message == message }) {
                return
            }
            findings.append(
                AccessibilityFinding(
                    issue: issue,
                    severity: severity,
                    message: message,
                    selector: selector
                )
            )
        }

        if options.checkImageAlt {
            for match in tagMatches(pattern: #"<img\b[^>]*>"#, in: html, options: [.caseInsensitive]) {
                let attributes = parseAttributes(fromTag: match.value)
                if attributes["alt"] == nil {
                    add(
                        .imageMissingAlt,
                        severity: .error,
                        "Image is missing an alt attribute.",
                        selector: "img"
                    )
                }
            }
        }

        if options.checkInputLabels {
            for control in formControlMatches(in: html) {
                if control.isLabelled(in: html) {
                    continue
                }
                add(
                    .inputMissingLabel,
                    severity: .error,
                    "Form control is missing an associated label or aria-label.",
                    selector: control.selector
                )
            }
        }

        if options.checkMainLandmark,
           html.range(of: #"<main\b"#, options: [.regularExpression, .caseInsensitive]) == nil {
            add(
                .missingMainLandmark,
                severity: .warning,
                "Document is missing a <main> landmark.",
                selector: "main"
            )
        }

        if options.checkButtonNames {
            for match in tagMatches(
                pattern: #"<button\b([^>]*)>(.*?)</button>"#,
                in: html,
                options: [.caseInsensitive, .dotMatchesLineSeparators]
            ) {
                let attributes = parseAttributes(fromTag: match.captures.first ?? "")
                let labelled = attributes["aria-label"] != nil || attributes["aria-labelledby"] != nil
                let content = stripHTML(match.captures.count > 1 ? match.captures[1] : "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !labelled && content.isEmpty {
                    add(
                        .buttonMissingAccessibleName,
                        severity: .error,
                        "Button has no accessible name.",
                        selector: "button"
                    )
                }
            }
        }

        if options.checkHTMLLang,
           html.range(of: #"<html\b"#, options: [.regularExpression, .caseInsensitive]) != nil,
           html.range(of: #"<html\b[^>]*\blang\s*="#, options: [.regularExpression, .caseInsensitive]) == nil {
            add(
                .missingHTMLLang,
                severity: .warning,
                "Root <html> element is missing a lang attribute.",
                selector: "html"
            )
        }

        if options.checkTabIndex,
           html.range(of: #"tabindex\s*=\s*\"?[1-9][0-9]*\"?"#, options: [.regularExpression, .caseInsensitive]) != nil {
            add(
                .positiveTabIndexDetected,
                severity: .warning,
                "Positive tabindex values can break expected keyboard navigation order."
            )
        }

        if options.checkMotion,
           (lower.contains("animation:") || lower.contains("transition:") || lower.contains("@keyframes")),
           !lower.contains("prefers-reduced-motion") {
            add(
                .motionWithoutReducedMotionFallback,
                severity: .warning,
                "Detected motion styles without prefers-reduced-motion fallback."
            )
        }

        if options.checkRoles {
            for roleValue in attributeValues(for: "role", in: html) {
                let tokens = roleValue
                    .split(whereSeparator: \.isWhitespace)
                    .map { $0.lowercased() }
                for token in tokens where !knownARIARoles.contains(token) {
                    add(
                        .invalidARIArole,
                        severity: .error,
                        "Unknown ARIA role: \(token)."
                    )
                }
            }
        }

        if options.checkFocusStyles {
            let css = collectedCSS(from: html).lowercased()
            let removesFocusOutline = css.range(
                of: #":focus[^{]*\{[^}]*outline\s*:\s*(none|0)\b"#,
                options: .regularExpression
            ) != nil || css.range(
                of: #"outline\s*:\s*(none|0)\b"#,
                options: .regularExpression
            ) != nil
            let hasFocusVisibleFallback = css.range(
                of: #":focus-visible[^{]*\{[^}]*((outline|box-shadow)\s*:)"#,
                options: .regularExpression
            ) != nil

            if removesFocusOutline && !hasFocusVisibleFallback {
                add(
                    .focusStyleRemoved,
                    severity: .warning,
                    "Focus styling appears removed without a :focus-visible fallback."
                )
            }
        }

        if options.checkContrast {
            for style in inlineStyleAttributes(in: html) {
                let declarations = parseStyleDeclarations(style)
                guard let foregroundRaw = declarations["color"],
                      let backgroundRaw = declarations["background-color"],
                      let foreground = parseColor(foregroundRaw),
                      let background = parseColor(backgroundRaw) else {
                    continue
                }

                let ratio = contrastRatio(foreground: foreground, background: background)
                if ratio < options.minimumContrastRatio {
                    add(
                        .lowContrastText,
                        severity: .warning,
                        "Text contrast ratio \(String(format: "%.2f", ratio)) is below \(String(format: "%.2f", options.minimumContrastRatio))."
                    )
                }
            }
        }

        return AccessibilityAuditReport(findings: findings)
    }
}

private struct HTMLMatch {
    let value: String
    let captures: [String]
    let range: NSRange
}

private struct FormControlMatch {
    let tag: String
    let attributes: [String: String]
    let range: NSRange

    var selector: String {
        if let id = attributes["id"], !id.isEmpty {
            return "\(tag)#\(id)"
        }
        return tag
    }

    func isLabelled(in html: String) -> Bool {
        if attributes["aria-label"] != nil || attributes["aria-labelledby"] != nil {
            return true
        }

        if let id = attributes["id"], !id.isEmpty {
            let escaped = NSRegularExpression.escapedPattern(for: id)
            let pattern = #"<label\b[^>]*\bfor\s*=\s*["']\#(escaped)["'][^>]*>"#
            if html.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil {
                return true
            }
        }

        return isWrappedByLabel(in: html)
    }

    private func isWrappedByLabel(in html: String) -> Bool {
        let ns = html as NSString
        let beforeRange = NSRange(location: 0, length: range.location)
        guard beforeRange.length > 0 else {
            return false
        }

        guard let lastLabelOpen = html.lastRegexRange(of: #"<label\b[^>]*>"#, within: beforeRange),
              let lastLabelClose = html.lastRegexRange(of: #"</label>"#, within: beforeRange) else {
            if let _ = html.lastRegexRange(of: #"<label\b[^>]*>"#, within: beforeRange) {
                let afterRange = NSRange(location: range.location, length: ns.length - range.location)
                return html.firstRegexRange(of: #"</label>"#, within: afterRange) != nil
            }
            return false
        }

        if lastLabelOpen.location > lastLabelClose.location {
            let afterRange = NSRange(location: range.location, length: ns.length - range.location)
            return html.firstRegexRange(of: #"</label>"#, within: afterRange) != nil
        }
        return false
    }
}

private func tagMatches(
    pattern: String,
    in html: String,
    options: NSRegularExpression.Options = []
) -> [HTMLMatch] {
    guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
        return []
    }
    let ns = html as NSString
    let matches = regex.matches(in: html, range: NSRange(location: 0, length: ns.length))
    return matches.map { match in
        var captures: [String] = []
        if match.numberOfRanges > 1 {
            for index in 1..<match.numberOfRanges {
                let captureRange = match.range(at: index)
                if captureRange.location == NSNotFound {
                    captures.append("")
                } else {
                    captures.append(ns.substring(with: captureRange))
                }
            }
        }
        return HTMLMatch(value: ns.substring(with: match.range), captures: captures, range: match.range)
    }
}

private func formControlMatches(in html: String) -> [FormControlMatch] {
    let matches = tagMatches(pattern: #"<(input|textarea|select)\b[^>]*>"#, in: html, options: [.caseInsensitive])
    return matches.compactMap { match in
        let tag = extractTagName(from: match.value)?.lowercased() ?? ""
        if tag.isEmpty {
            return nil
        }

        let attributes = parseAttributes(fromTag: match.value)
        if tag == "input" {
            let type = attributes["type"]?.lowercased() ?? "text"
            if ["hidden", "submit", "button", "reset", "image"].contains(type) {
                return nil
            }
        }
        return FormControlMatch(tag: tag, attributes: attributes, range: match.range)
    }
}

private func extractTagName(from tag: String) -> String? {
    guard let regex = try? NSRegularExpression(pattern: #"<\s*([a-zA-Z0-9:-]+)"#, options: []),
          let match = regex.firstMatch(in: tag, range: NSRange(location: 0, length: (tag as NSString).length)),
          match.numberOfRanges > 1 else {
        return nil
    }
    return (tag as NSString).substring(with: match.range(at: 1))
}

private func parseAttributes(fromTag tag: String) -> [String: String] {
    guard let regex = try? NSRegularExpression(
        pattern: #"([a-zA-Z_:][a-zA-Z0-9_:\-\.]*)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+))"#,
        options: []
    ) else {
        return [:]
    }

    let ns = tag as NSString
    let matches = regex.matches(in: tag, range: NSRange(location: 0, length: ns.length))
    var attributes: [String: String] = [:]
    for match in matches {
        guard match.numberOfRanges >= 5 else { continue }
        let key = ns.substring(with: match.range(at: 1)).lowercased()
        let valueRange = [2, 3, 4]
            .map { match.range(at: $0) }
            .first { $0.location != NSNotFound } ?? NSRange(location: NSNotFound, length: 0)
        if valueRange.location != NSNotFound {
            attributes[key] = ns.substring(with: valueRange)
        }
    }
    return attributes
}

private func attributeValues(for attribute: String, in html: String) -> [String] {
    let escaped = NSRegularExpression.escapedPattern(for: attribute)
    guard let regex = try? NSRegularExpression(
        pattern: #"\b\#(escaped)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+))"#,
        options: [.caseInsensitive]
    ) else {
        return []
    }

    let ns = html as NSString
    return regex.matches(in: html, range: NSRange(location: 0, length: ns.length)).compactMap { match in
        for index in 1..<match.numberOfRanges {
            let range = match.range(at: index)
            if range.location != NSNotFound {
                return ns.substring(with: range)
            }
        }
        return nil
    }
}

private func stripHTML(_ html: String) -> String {
    html.replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
}

private func collectedCSS(from html: String) -> String {
    let styleBlocks = tagMatches(
        pattern: #"<style\b[^>]*>(.*?)</style>"#,
        in: html,
        options: [.caseInsensitive, .dotMatchesLineSeparators]
    ).compactMap { $0.captures.first }

    let inlineStyles = inlineStyleAttributes(in: html)
    return (styleBlocks + inlineStyles).joined(separator: "\n")
}

private func inlineStyleAttributes(in html: String) -> [String] {
    let values = attributeValues(for: "style", in: html)
    return values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
}

private func parseStyleDeclarations(_ style: String) -> [String: String] {
    var output: [String: String] = [:]
    for pair in style.split(separator: ";", omittingEmptySubsequences: true) {
        let parts = pair.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
        guard parts.count == 2 else { continue }
        let key = parts[0].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let value = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty, !value.isEmpty else { continue }
        output[key] = value
    }
    return output
}

private struct RGBColor {
    let r: Double
    let g: Double
    let b: Double
}

private func parseColor(_ raw: String) -> RGBColor? {
    let value = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    if let hex = parseHexColor(value) {
        return hex
    }
    if let rgb = parseRGBColor(value) {
        return rgb
    }
    return namedColors[value]
}

private func parseHexColor(_ value: String) -> RGBColor? {
    guard value.hasPrefix("#") else {
        return nil
    }
    let hex = String(value.dropFirst())
    if hex.count == 3 {
        let chars = Array(hex)
        let expanded = String([chars[0], chars[0], chars[1], chars[1], chars[2], chars[2]])
        return parseHexColor("#\(expanded)")
    }
    guard hex.count == 6, let intValue = Int(hex, radix: 16) else {
        return nil
    }
    return RGBColor(
        r: Double((intValue >> 16) & 0xFF) / 255.0,
        g: Double((intValue >> 8) & 0xFF) / 255.0,
        b: Double(intValue & 0xFF) / 255.0
    )
}

private func parseRGBColor(_ value: String) -> RGBColor? {
    guard value.hasPrefix("rgb(") || value.hasPrefix("rgba(") else {
        return nil
    }
    guard let start = value.firstIndex(of: "("), let end = value.firstIndex(of: ")") else {
        return nil
    }
    let payload = value[value.index(after: start)..<end]
    let components = payload
        .split(separator: ",")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    guard components.count >= 3 else {
        return nil
    }
    guard let r = Double(components[0]),
          let g = Double(components[1]),
          let b = Double(components[2]) else {
        return nil
    }
    return RGBColor(
        r: min(max(r, 0), 255) / 255.0,
        g: min(max(g, 0), 255) / 255.0,
        b: min(max(b, 0), 255) / 255.0
    )
}

private func contrastRatio(foreground: RGBColor, background: RGBColor) -> Double {
    let foregroundLuminance = relativeLuminance(foreground)
    let backgroundLuminance = relativeLuminance(background)
    let lighter = max(foregroundLuminance, backgroundLuminance)
    let darker = min(foregroundLuminance, backgroundLuminance)
    return (lighter + 0.05) / (darker + 0.05)
}

private func relativeLuminance(_ color: RGBColor) -> Double {
    func transform(_ channel: Double) -> Double {
        if channel <= 0.03928 {
            return channel / 12.92
        }
        return pow((channel + 0.055) / 1.055, 2.4)
    }
    return 0.2126 * transform(color.r) + 0.7152 * transform(color.g) + 0.0722 * transform(color.b)
}

private let namedColors: [String: RGBColor] = [
    "black": RGBColor(r: 0, g: 0, b: 0),
    "white": RGBColor(r: 1, g: 1, b: 1),
    "gray": RGBColor(r: 0.5019607843, g: 0.5019607843, b: 0.5019607843),
    "grey": RGBColor(r: 0.5019607843, g: 0.5019607843, b: 0.5019607843),
    "red": RGBColor(r: 1, g: 0, b: 0),
    "green": RGBColor(r: 0, g: 0.5019607843, b: 0),
    "blue": RGBColor(r: 0, g: 0, b: 1),
    "yellow": RGBColor(r: 1, g: 1, b: 0),
]

private let knownARIARoles: Set<String> = [
    "alert", "alertdialog", "application", "article", "banner", "blockquote", "button", "caption",
    "cell", "checkbox", "code", "columnheader", "combobox", "command", "complementary", "contentinfo",
    "definition", "deletion", "dialog", "directory", "document", "emphasis", "feed", "figure", "form",
    "generic", "grid", "gridcell", "group", "heading", "img", "insertion", "link", "list", "listbox",
    "listitem", "log", "main", "marquee", "math", "menu", "menubar", "menuitem", "menuitemcheckbox",
    "menuitemradio", "meter", "navigation", "none", "note", "option", "paragraph", "presentation",
    "progressbar", "radio", "radiogroup", "region", "row", "rowgroup", "rowheader", "scrollbar",
    "search", "searchbox", "separator", "slider", "spinbutton", "status", "strong", "subscript",
    "superscript", "switch", "tab", "table", "tablist", "tabpanel", "term", "textbox", "time", "timer",
    "toolbar", "tooltip", "tree", "treegrid", "treeitem",
]

private extension String {
    func firstRegexRange(of pattern: String, within range: NSRange) -> NSRange? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        return regex.firstMatch(in: self, range: range)?.range
    }

    func lastRegexRange(of pattern: String, within range: NSRange) -> NSRange? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        let matches = regex.matches(in: self, range: range)
        return matches.last?.range
    }
}
