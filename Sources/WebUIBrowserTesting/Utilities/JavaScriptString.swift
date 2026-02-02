import Foundation

enum JavaScriptString {
    static func literal(_ value: String) throws -> String {
        let data = try JSONEncoder().encode(value)
        guard let string = String(data: data, encoding: .utf8) else {
            throw BrowserError.internalInconsistency(message: "Failed to encode JavaScript string literal.")
        }
        return string
    }
}
