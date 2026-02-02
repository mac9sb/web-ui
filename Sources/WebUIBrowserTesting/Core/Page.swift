import CoreGraphics
import Foundation
import WebUI

#if canImport(WebKit)
import WebKit

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

@MainActor
public final class Page {
    private let webView: WKWebView
    private let configuration: BrowserConfiguration
    private let navigationDelegate = NavigationDelegate()
    private let consoleHandler = ConsoleMessageHandler()
    private let dialogDelegate = DialogDelegate()

    private var consoleHandlers: [@MainActor (ConsoleMessage) -> Void] = []
    private var dialogHandlers: [@MainActor (Dialog) async -> Void] = []

    public var keyboard: Keyboard {
        Keyboard(page: self)
    }

    init(webView: WKWebView, configuration: BrowserConfiguration) {
        self.webView = webView
        self.configuration = configuration
        self.webView.navigationDelegate = navigationDelegate
        self.webView.uiDelegate = dialogDelegate
        self.dialogDelegate.onDialog = { [weak self] dialog in
            guard let self else {
                dialog.performDefaultAction()
                return
            }
            await self.emitDialog(dialog)
        }

        let userContentController = webView.configuration.userContentController
        consoleHandler.onMessage = { [weak self] message in
            guard let self else { return }
            Task { @MainActor in
                await self.emitConsoleMessage(message)
            }
        }
        userContentController.add(consoleHandler, name: "webui_console")
        let userScript = WKUserScript(
            source: Page.consoleOverrideScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        userContentController.addUserScript(userScript)
    }

    public func onConsole(_ handler: @escaping @MainActor (ConsoleMessage) -> Void) {
        consoleHandlers.append(handler)
    }

    public func onDialog(_ handler: @escaping @MainActor (Dialog) async -> Void) {
        dialogHandlers.append(handler)
    }

    public func goto(_ url: String, options: NavigationOptions = .default) async throws {
        guard let targetURL = URL(string: url) else {
            throw BrowserError.invalidURL(url)
        }
        guard configuration.enableJavaScript else {
            throw BrowserError.javascriptDisabled
        }

        let timeout = options.timeout ?? .seconds(30)
        let timeoutConfig = TimeoutConfiguration(
            duration: timeout,
            operationDescription: "goto(\(url))"
        )

        try await Timeout.withTimeout(timeoutConfig) { @MainActor in
            let request = URLRequest(url: targetURL)
            _ = self.webView.load(request)
            try await self.navigationDelegate.waitForNavigation()
            try await self.waitForLoadState(options.waitUntil, timeout: timeout)
        }
    }

    public func goBack() async throws -> Bool {
        guard webView.canGoBack else { return false }
        _ = webView.goBack()
        try await navigationDelegate.waitForNavigation()
        return true
    }

    public func goForward() async throws -> Bool {
        guard webView.canGoForward else { return false }
        _ = webView.goForward()
        try await navigationDelegate.waitForNavigation()
        return true
    }

    public func reload() async throws {
        _ = webView.reload()
        try await navigationDelegate.waitForNavigation()
    }

    public func content() async throws -> String {
        try await evaluate("document.documentElement.outerHTML")
    }

    public func title() async throws -> String {
        try await evaluate("document.title")
    }

    public func url() async -> String? {
        webView.url?.absoluteString
    }

    public func querySelector(_ selector: String) async -> ElementHandle? {
        await querySelector(.css(selector))
    }

    public func querySelectorAll(_ selector: String) async -> [ElementHandle] {
        await querySelectorAll(.css(selector))
    }

    public func xpath(_ selector: String) async -> ElementHandle? {
        await querySelector(.xpath(selector))
    }

    public func getByText(_ text: String) async -> ElementHandle? {
        await querySelector(.text(text))
    }

    public func getByRole(_ role: Role, name: String? = nil) async -> ElementHandle? {
        await querySelector(.role(role, name: name))
    }

    public func getByTestId(_ testId: String) async -> ElementHandle? {
        await querySelector(.testId(testId))
    }

    public func click(_ selector: String) async throws {
        guard let element = await querySelector(.css(selector)) else {
            throw BrowserError.elementNotFound(selector: selector)
        }
        try await element.click()
    }

    public func fill(_ selector: String, _ text: String) async throws {
        guard let element = await querySelector(.css(selector)) else {
            throw BrowserError.elementNotFound(selector: selector)
        }
        try await element.fill(text)
    }

    public func evaluate<T: Decodable>(_ script: String, args: [Any] = []) async throws -> T {
        try await evaluateRaw(script, args: args)
    }

    public func evaluate<T: Decodable>(_ script: BrowserScript) async throws -> T {
        let rendered = try script.render()
        return try await evaluateRaw(rendered)
    }

    func evaluateRaw<T: Decodable>(_ script: String, args: [Any] = []) async throws -> T {
        guard configuration.enableJavaScript else {
            throw BrowserError.javascriptDisabled
        }
        return try await JSBridge.evaluate(webView: webView, script: script, args: args)
    }

    public func addScriptTag(url: String) async throws {
        let script = BrowserScript {
            BrowserStatement.addScript(url: url)
            BrowserStatement.returnBool(true)
        }
        let _: Bool = try await evaluate(script)
    }

    public func addScriptTag(content: String) async throws {
        let script = BrowserScript {
            BrowserStatement.addScript(content: content)
            BrowserStatement.returnBool(true)
        }
        let _: Bool = try await evaluate(script)
    }

    public func setContent(_ markup: some Markup) async throws {
        let html = markup.render()
        let script = BrowserScript {
            BrowserStatement.setContent(html)
            BrowserStatement.returnBool(true)
        }
        let _: Bool = try await evaluate(script)
    }

    public func waitForNavigation(
        timeout: Duration = .seconds(30),
        action: @escaping @Sendable () async throws -> Void
    ) async throws {
        let timeoutConfig = TimeoutConfiguration(
            duration: timeout,
            operationDescription: "waitForNavigation"
        )

        try await Timeout.withTimeout(timeoutConfig) { @MainActor in
            async let navigation = self.navigationDelegate.waitForNavigation()
            try await action()
            try await navigation
        }
    }

    public func waitForSelector(
        _ selector: String,
        timeout: Duration = .seconds(5),
        pollingInterval: Duration = .milliseconds(100)
    ) async throws -> ElementHandle {
        let timeoutConfig = TimeoutConfiguration(
            duration: timeout,
            operationDescription: "waitForSelector(\(selector))"
        )

        return try await Timeout.withTimeout(timeoutConfig) { @MainActor in
            while true {
                if let element = await self.querySelector(selector) {
                    return element
                }
                try await Task.sleep(for: pollingInterval)
            }
        }
    }

    public func waitForFunction(
        _ script: String,
        timeout: Duration = .seconds(5),
        pollingInterval: Duration = .milliseconds(100)
    ) async throws {
        let timeoutConfig = TimeoutConfiguration(
            duration: timeout,
            operationDescription: "waitForFunction(\(script))"
        )

        _ = try await Timeout.withTimeout(timeoutConfig) { @MainActor in
            while true {
                let condition: Bool = try await self.evaluate(script)
                if condition { return true }
                try await Task.sleep(for: pollingInterval)
            }
        }
    }

    public func waitForTimeout(_ timeout: Duration) async throws {
        try await Task.sleep(for: timeout)
    }

    public func waitForURL(_ url: String, timeout: Duration = .seconds(5)) async throws {
        let urlLiteral = try JavaScriptString.literal(url)
        let script = "() => window.location.href === \(urlLiteral)"
        try await waitForFunction(script, timeout: timeout)
    }

    public func waitForLoadState(_ state: WaitStrategy, timeout: Duration = .seconds(30)) async throws {
        switch state {
        case .load:
            try await waitForFunction("() => document.readyState === 'complete'", timeout: timeout)
        case .domContentLoaded:
            try await waitForFunction("() => document.readyState === 'interactive' || document.readyState === 'complete'", timeout: timeout)
        case .networkIdle:
            try await waitForFunction("() => document.readyState === 'complete'", timeout: timeout)
            try await Task.sleep(for: .milliseconds(500))
        }
    }

    public func screenshot(options: ScreenshotOptions = .default) async throws -> CGImage {
        let configuration = WKSnapshotConfiguration()
        if let clip = options.clip {
            configuration.rect = clip
        } else if options.fullPage {
            #if os(macOS)
            let size = webView.bounds.size
            #else
            let size = webView.scrollView.contentSize
            #endif
            configuration.rect = CGRect(origin: .zero, size: size)
        }

        #if os(macOS)
        let image: NSImage = try await withCheckedThrowingContinuation { continuation in
            webView.takeSnapshot(with: configuration) { image, error in
                if let error {
                    continuation.resume(throwing: BrowserError.screenshotFailed(reason: "Snapshot failed", underlying: error))
                    return
                }
                guard let image else {
                    continuation.resume(throwing: BrowserError.screenshotFailed(reason: "Missing snapshot image", underlying: nil))
                    return
                }
                continuation.resume(returning: image)
            }
        }

        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw BrowserError.screenshotFailed(reason: "Failed to convert NSImage to CGImage", underlying: nil)
        }
        return cgImage
        #else
        let image: UIImage = try await withCheckedThrowingContinuation { continuation in
            webView.takeSnapshot(with: configuration) { image, error in
                if let error {
                    continuation.resume(throwing: BrowserError.screenshotFailed(reason: "Snapshot failed", underlying: error))
                    return
                }
                guard let image else {
                    continuation.resume(throwing: BrowserError.screenshotFailed(reason: "Missing snapshot image", underlying: nil))
                    return
                }
                continuation.resume(returning: image)
            }
        }

        guard let cgImage = image.cgImage else {
            throw BrowserError.screenshotFailed(reason: "Failed to convert UIImage to CGImage", underlying: nil)
        }
        return cgImage
        #endif
    }

    public func snapshot(options: SnapshotOptions = .default) async throws -> Snapshot {
        let image = try await screenshot(
            options: ScreenshotOptions(fullPage: options.fullPage, clip: options.clip)
        )
        let metadata = SnapshotMetadata(
            timestamp: Date(),
            url: webView.url?.absoluteString,
            viewportSize: configuration.viewportSize,
            fullPage: options.fullPage,
            clip: options.clip
        )
        return Snapshot(image: image, metadata: metadata)
    }

    public func expectSnapshot(
        named name: String,
        threshold: Double = 0.0,
        snapshotDirectory: URL,
        options: SnapshotOptions = .default
    ) async throws -> SnapshotComparison {
        let snapshot = try await snapshot(options: options)
        let storage = SnapshotStorage(directory: snapshotDirectory)
        let manager = SnapshotManager(storage: storage)
        let comparison = try manager.expectSnapshot(named: name, snapshot: snapshot, threshold: threshold)
        if comparison.percentDifference > threshold {
            throw BrowserError.snapshotMismatch(
                name: name,
                percentDifference: comparison.percentDifference,
                threshold: threshold
            )
        }
        return comparison
    }

    public func expectSnapshot(
        named name: String,
        threshold: Double = 0.0,
        snapshotDirectory: String = ".snapshots",
        options: SnapshotOptions = .default
    ) async throws -> SnapshotComparison {
        let directoryURL = SnapshotStorage.resolveDirectory(snapshotDirectory)
        return try await expectSnapshot(
            named: name,
            threshold: threshold,
            snapshotDirectory: directoryURL,
            options: options
        )
    }

    public func close() async {
        webView.stopLoading()
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "webui_console")
    }

    func querySelector(_ selector: Selector) async -> ElementHandle? {
        do {
            let expression = try selector.jsElementExpression()
            let script = "() => !!(\(expression))"
            let exists: Bool = try await evaluate(script)
            if exists {
                return ElementHandle(page: self, selector: selector)
            }
            return nil
        } catch {
            return nil
        }
    }

    func querySelectorAll(_ selector: Selector) async -> [ElementHandle] {
        do {
            let expression = try selector.jsElementsExpression()
            let script = "() => (\(expression)).length"
            let count: Int = try await evaluate(script)
            return (0..<count).map { ElementHandle(page: self, selector: selector, index: $0) }
        } catch {
            return []
        }
    }

    private func emitConsoleMessage(_ message: ConsoleMessage) {
        for handler in consoleHandlers {
            handler(message)
        }
    }

    private func emitDialog(_ dialog: Dialog) async {
        if dialogHandlers.isEmpty {
            dialog.performDefaultAction()
            return
        }

        for handler in dialogHandlers {
            await handler(dialog)
        }

        if !dialog.isHandled {
            dialog.performDefaultAction()
        }
    }

    private static let consoleOverrideScript = """
    (() => {
        const levels = ['log', 'info', 'warn', 'error', 'debug'];
        levels.forEach((level) => {
            const original = console[level];
            console[level] = function(...args) {
                try {
                    const text = args.map(arg => {
                        try { return typeof arg === 'string' ? arg : JSON.stringify(arg); }
                        catch { return String(arg); }
                    }).join(' ');
                    window.webkit?.messageHandlers?.webui_console?.postMessage({ level, text });
                } catch (_) {}
                if (original) {
                    original.apply(console, args);
                }
            };
        });
    })();
    """
}

private final class NavigationDelegate: NSObject, WKNavigationDelegate {
    private var continuation: CheckedContinuation<Void, Error>?

    func waitForNavigation() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        continuation?.resume()
        continuation = nil
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        continuation?.resume(throwing: BrowserError.navigationFailed(url: webView.url?.absoluteString ?? "unknown", underlying: error))
        continuation = nil
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        continuation?.resume(throwing: BrowserError.navigationFailed(url: webView.url?.absoluteString ?? "unknown", underlying: error))
        continuation = nil
    }
}

private final class ConsoleMessageHandler: NSObject, WKScriptMessageHandler {
    var onMessage: ((ConsoleMessage) -> Void)?

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let payload = message.body as? [String: Any] else { return }
        guard let level = payload["level"] as? String else { return }
        guard let text = payload["text"] as? String else { return }
        onMessage?(ConsoleMessage(text: text, level: level))
    }
}

private final class DialogDelegate: NSObject, WKUIDelegate {
    var onDialog: ((Dialog) async -> Void)?

    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        let dialog = Dialog(kind: .alert, message: message, defaultText: nil, completion: .alert(completionHandler))
        if let onDialog {
            Task { @MainActor in
                await onDialog(dialog)
            }
        } else {
            dialog.performDefaultAction()
        }
    }

    func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let dialog = Dialog(kind: .confirm, message: message, defaultText: nil, completion: .confirm(completionHandler))
        if let onDialog {
            Task { @MainActor in
                await onDialog(dialog)
            }
        } else {
            dialog.performDefaultAction()
        }
    }

    func webView(
        _ webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String,
        defaultText: String?,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (String?) -> Void
    ) {
        let dialog = Dialog(kind: .prompt, message: prompt, defaultText: defaultText, completion: .prompt(completionHandler))
        if let onDialog {
            Task { @MainActor in
                await onDialog(dialog)
            }
        } else {
            dialog.performDefaultAction()
        }
    }
}

#else

@MainActor
public final class Page {
    public func goto(_ url: String, options: NavigationOptions = .default) async throws {
        throw BrowserError.unsupportedFeature("WebKit is not available on this platform.")
    }

    public func querySelector(_ selector: String) async -> ElementHandle? {
        nil
    }
}

#endif
