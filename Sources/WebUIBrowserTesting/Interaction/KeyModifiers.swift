import Foundation

public struct KeyModifiers: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let shift = KeyModifiers(rawValue: 1 << 0)
    public static let control = KeyModifiers(rawValue: 1 << 1)
    public static let option = KeyModifiers(rawValue: 1 << 2)
    public static let command = KeyModifiers(rawValue: 1 << 3)

    var jsObjectLiteral: String {
        let shift = contains(.shift) ? "true" : "false"
        let control = contains(.control) ? "true" : "false"
        let option = contains(.option) ? "true" : "false"
        let command = contains(.command) ? "true" : "false"
        return "{ shiftKey: \(shift), ctrlKey: \(control), altKey: \(option), metaKey: \(command) }"
    }
}
