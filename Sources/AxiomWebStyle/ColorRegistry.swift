import Foundation

enum ColorRegistry {
    private static let lock = NSLock()
    private static nonisolated(unsafe) var customColors: [String: String] = [:]

    static func register(name: String, cssValue: String) {
        lock.lock()
        defer { lock.unlock() }
        customColors[name] = cssValue
    }

    static func value(for name: String) -> String? {
        lock.lock()
        defer { lock.unlock() }
        return customColors[name]
    }
}
