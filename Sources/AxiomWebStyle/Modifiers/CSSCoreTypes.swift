import Foundation

public enum CSSLengthUnit: String, Sendable {
    case px
    case rem
    case em
    case vw
    case vh
    case percent = "%"
}

public struct CSSProperty: Hashable, Sendable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = CSSProperty.sanitize(rawValue)
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }

    private static func sanitize(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return "--invalid"
        }

        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_")
        if trimmed.hasPrefix("--") {
            let suffix = String(trimmed.dropFirst(2))
            let cleanedSuffix = String(suffix.unicodeScalars.map { allowed.contains($0) ? Character($0) : "-" })
            return "--\(cleanedSuffix)"
        }

        let cleaned = String(trimmed.unicodeScalars.map { allowed.contains($0) ? Character($0) : "-" })
        return cleaned.lowercased()
    }
}

public struct CSSValue: Hashable, Sendable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = CSSValue.sanitize(rawValue)
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }

    public static func keyword(_ value: String) -> CSSValue {
        CSSValue(value)
    }

    public static func number(_ value: Double) -> CSSValue {
        CSSValue(formatNumber(value))
    }

    public static func integer(_ value: Int) -> CSSValue {
        CSSValue("\(value)")
    }

    public static func length(_ value: Double, _ unit: CSSLengthUnit) -> CSSValue {
        if unit == .percent {
            return CSSValue("\(formatNumber(value))%")
        }
        return CSSValue("\(formatNumber(value))\(unit.rawValue)")
    }

    public static func raw(_ value: String) -> CSSValue {
        CSSValue(value)
    }

    private static func sanitize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
            .replacingOccurrences(of: ";", with: "")
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
    }

    private static func formatNumber(_ value: Double) -> String {
        if value.rounded() == value {
            return String(format: "%.0f", value)
        }
        return String(format: "%.6f", value)
            .replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\.$"#, with: "", options: .regularExpression)
    }
}

public enum ArbitraryStyleRegistry {
    private static let lock = NSLock()
    private static nonisolated(unsafe) var classByDeclaration: [String: String] = [:]
    private static nonisolated(unsafe) var declarationByClass: [String: String] = [:]

    public static func className(property: CSSProperty, value: CSSValue) -> String {
        let declaration = "\(property.rawValue):\(value.rawValue)"

        lock.lock()
        defer { lock.unlock() }

        if let existing = classByDeclaration[declaration] {
            return existing
        }

        var attempt = 0
        var className = ""

        while true {
            let input = attempt == 0 ? declaration : "\(declaration)#\(attempt)"
            className = "ax-\(fnv1aHex(input))"

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
