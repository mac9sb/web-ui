import Foundation

public enum BrowserError: Error, Sendable {
    case invalidURL(String)
    case navigationFailed(url: String, underlying: Error?)
    case webViewNotReady
    case javascriptDisabled
    case javaScriptEvaluationFailed(script: String, underlying: Error?)
    case elementNotFound(selector: String)
    case elementDetached(description: String)
    case invalidSelector(String)
    case timeout(operation: String, seconds: TimeInterval)
    case snapshotFailed(reason: String, underlying: Error?)
    case snapshotMismatch(name: String, percentDifference: Double, threshold: Double)
    case screenshotFailed(reason: String, underlying: Error?)
    case internalInconsistency(message: String)
    case unsupportedFeature(String)
}

extension BrowserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let value):
            return "Invalid URL: \(value)"
        case .navigationFailed(let url, let underlying):
            if let underlying {
                return "Navigation failed for \(url): \(underlying.localizedDescription)"
            }
            return "Navigation failed for \(url)."
        case .webViewNotReady:
            return "Browser is not ready. Call launch() before using the page."
        case .javascriptDisabled:
            return "JavaScript is disabled for this browser configuration."
        case .javaScriptEvaluationFailed(let script, let underlying):
            if let underlying {
                return "JavaScript evaluation failed for script '\(script)': \(underlying.localizedDescription)"
            }
            return "JavaScript evaluation failed for script '\(script)'."
        case .elementNotFound(let selector):
            return "Element not found for selector: \(selector)"
        case .elementDetached(let description):
            return "Element is detached from DOM: \(description)"
        case .invalidSelector(let selector):
            return "Invalid selector: \(selector)"
        case .timeout(let operation, let seconds):
            return "Operation timed out after \(seconds)s: \(operation)"
        case .snapshotFailed(let reason, let underlying):
            if let underlying {
                return "Snapshot failed: \(reason). \(underlying.localizedDescription)"
            }
            return "Snapshot failed: \(reason)."
        case .snapshotMismatch(let name, let percentDifference, let threshold):
            return "Snapshot mismatch for \(name): \(percentDifference) > \(threshold)."
        case .screenshotFailed(let reason, let underlying):
            if let underlying {
                return "Screenshot failed: \(reason). \(underlying.localizedDescription)"
            }
            return "Screenshot failed: \(reason)."
        case .internalInconsistency(let message):
            return "Internal error: \(message)"
        case .unsupportedFeature(let feature):
            return "Unsupported feature: \(feature)"
        }
    }
}
