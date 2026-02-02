import Foundation

#if canImport(WebKit)
import WebKit

enum JSBridge {
    struct Response<Value: Decodable>: Decodable {
        let ok: Bool
        let value: Value
        let error: String?
    }

    static func evaluate<Value: Decodable>(
        webView: WKWebView,
        script: String,
        args: [Any]
    ) async throws -> Value {
        guard JSONSerialization.isValidJSONObject(args) else {
            throw BrowserError.internalInconsistency(message: "JavaScript arguments are not valid JSON.")
        }

        let argsData = try JSONSerialization.data(withJSONObject: args, options: [])
        guard let argsJSON = String(data: argsData, encoding: .utf8) else {
            throw BrowserError.internalInconsistency(message: "Failed to encode JavaScript arguments.")
        }

        let wrappedScript = """
        (() => {
            try {
                const __args = \(argsJSON);
                const __fn = \(script);
                const __result = (typeof __fn === 'function') ? __fn(...__args) : __fn;
                const __value = (__result === undefined) ? null : __result;
                return JSON.stringify({ ok: true, value: __value });
            } catch (error) {
                const message = (error && error.message) ? error.message : String(error);
                return JSON.stringify({ ok: false, value: null, error: message });
            }
        })()
        """

        let rawResult = try await webView.evaluateJavaScript(wrappedScript)
        guard let resultString = rawResult as? String else {
            throw BrowserError.javaScriptEvaluationFailed(script: script, underlying: nil)
        }

        let data = Data(resultString.utf8)
        let response = try JSONDecoder().decode(Response<Value>.self, from: data)

        if response.ok {
            return response.value
        }

        throw BrowserError.javaScriptEvaluationFailed(
            script: script,
            underlying: response.error.map { NSError(domain: "WebUIBrowserTesting", code: 1, userInfo: [NSLocalizedDescriptionKey: $0]) }
        )
    }
}

#else

enum JSBridge {
    static func evaluate<Value: Decodable>(
        webView: Any,
        script: String,
        args: [Any]
    ) async throws -> Value {
        throw BrowserError.unsupportedFeature("WebKit is not available on this platform.")
    }
}

#endif
