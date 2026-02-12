import Foundation

public struct StartingStyleDeclaration: Sendable, Hashable {
    public let property: CSSProperty
    public let value: CSSValue

    public init(_ property: CSSProperty, _ value: CSSValue) {
        self.property = property
        self.value = value
    }
}

public enum StartingStyleRegistry {
    private static let lock = NSLock()
    private static nonisolated(unsafe) var classByDeclaration: [String: String] = [:]
    private static nonisolated(unsafe) var declarationByClass: [String: String] = [:]

    public static func className(declarations: [StartingStyleDeclaration]) -> String {
        let declaration = declarations
            .sorted { $0.property.rawValue < $1.property.rawValue }
            .map { "\($0.property.rawValue):\($0.value.rawValue)" }
            .joined(separator: ";")

        lock.lock()
        defer { lock.unlock() }

        if let existing = classByDeclaration[declaration] {
            return existing
        }

        var attempt = 0
        var className = ""

        while true {
            let input = attempt == 0 ? declaration : "\(declaration)#\(attempt)"
            className = "axs-\(fnv1aHex(input))"

            if let existingDeclaration = declarationByClass[className], existingDeclaration != declaration {
                attempt += 1
                continue
            }

            classByDeclaration[declaration] = className
            declarationByClass[className] = declaration
            return className
        }
    }

    public static func declaration(for className: String) -> String? {
        lock.lock()
        defer { lock.unlock() }
        return declarationByClass[className]
    }

    private static func fnv1aHex(_ value: String) -> String {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in value.utf8 {
            hash ^= UInt64(byte)
            hash &*= 0x100000001b3
        }
        return String(format: "%016llx", hash)
    }
}
