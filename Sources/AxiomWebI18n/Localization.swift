import Foundation

public struct LocaleCode: Hashable, Sendable, ExpressibleByStringLiteral, Comparable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }

    public static func < (lhs: LocaleCode, rhs: LocaleCode) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public static let en: LocaleCode = "en"
}

public struct LocalizedStringKey: Hashable, Sendable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }
}

public struct LocalizedString: Sendable, Equatable {
    private let translations: [LocaleCode: String]

    public init(_ translations: [LocaleCode: String]) {
        self.translations = translations
    }

    public func resolve(locale: LocaleCode, fallback: LocaleCode = .en) -> String {
        if let localized = translations[locale] {
            return localized
        }
        if let fallbackLocalized = translations[fallback] {
            return fallbackLocalized
        }
        return translations.values.sorted().first ?? ""
    }

    public var supportedLocales: [LocaleCode] {
        translations.keys.sorted()
    }
}

public struct LocalizedStringTable: Sendable {
    private var entries: [LocalizedStringKey: LocalizedString] = [:]

    public init(_ entries: [LocalizedStringKey: LocalizedString] = [:]) {
        self.entries = entries
    }

    public mutating func register(_ key: LocalizedStringKey, value: LocalizedString) {
        entries[key] = value
    }

    public func resolve(
        _ key: LocalizedStringKey,
        locale: LocaleCode,
        fallback: LocaleCode = .en
    ) -> String {
        guard let localized = entries[key] else {
            return key.rawValue
        }
        return localized.resolve(locale: locale, fallback: fallback)
    }
}

public struct LocalizedRoute: Sendable, Equatable {
    public let locale: LocaleCode
    public let path: String

    public init(locale: LocaleCode, path: String) {
        self.locale = locale
        self.path = path
    }
}

public enum LocaleRouting {
    public static func localizedPath(_ path: String, locale: LocaleCode, defaultLocale: LocaleCode = .en) -> String {
        let normalized = path.hasPrefix("/") ? path : "/\(path)"
        if locale == defaultLocale {
            return normalized
        }
        if normalized == "/" {
            return "/\(locale.rawValue)"
        }
        return "/\(locale.rawValue)\(normalized)"
    }

    public static func localizedURL(
        baseURL: String,
        path: String,
        locale: LocaleCode,
        defaultLocale: LocaleCode = .en
    ) -> String {
        let root = baseURL.hasSuffix("/") ? String(baseURL.dropLast()) : baseURL
        let localized = localizedPath(path, locale: locale, defaultLocale: defaultLocale)
        return root + localized
    }
}
