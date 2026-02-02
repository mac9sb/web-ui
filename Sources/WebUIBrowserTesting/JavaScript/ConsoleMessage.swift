import Foundation

public struct ConsoleMessage: Sendable {
    public let text: String
    public let level: String

    public init(text: String, level: String) {
        self.text = text
        self.level = level
    }
}
