import Foundation
import AxiomWebI18n

public enum ContentType: String, Sendable {
    case website
    case article
    case profile
    case video
}

public struct ThemeColor: Sendable, Equatable {
    public var light: String
    public var dark: String?

    public init(_ light: String, dark: String? = nil) {
        self.light = light
        self.dark = dark
    }
}

public struct Favicon: Sendable, Equatable {
    public enum Kind: String, Sendable {
        case png = "image/png"
        case icon = "image/x-icon"
        case svg = "image/svg+xml"
    }

    public var light: String
    public var dark: String?
    public var type: Kind
    public var size: String?

    public init(_ light: String, dark: String? = nil, type: Kind = .png, size: String? = nil) {
        self.light = light
        self.dark = dark
        self.type = type
        self.size = size
    }
}

public struct Metadata: Sendable, Equatable {
    public enum StructuredDataMergeStrategy: Sendable {
        case append
        case replace
    }

    public var site: String?
    public var title: String?
    public var titleSeparator: String
    public var description: String?
    public var date: Date?
    public var image: String?
    public var author: String?
    public var keywords: [String]
    public var twitter: String?
    public var locale: LocaleCode
    public var type: ContentType
    public var themeColor: ThemeColor?
    public var favicons: [Favicon]
    public var canonicalURL: String?
    public var alternateURLs: [LocaleCode: String]
    public var structuredData: [StructuredDataNode]

    public init(
        site: String? = nil,
        title: String? = nil,
        titleSeparator: String = " | ",
        description: String? = nil,
        date: Date? = nil,
        image: String? = nil,
        author: String? = nil,
        keywords: [String] = [],
        twitter: String? = nil,
        locale: LocaleCode = .en,
        type: ContentType = .website,
        themeColor: ThemeColor? = nil,
        favicons: [Favicon] = [],
        canonicalURL: String? = nil,
        alternateURLs: [LocaleCode: String] = [:],
        structuredData: [StructuredDataNode] = []
    ) {
        self.site = site
        self.title = title
        self.titleSeparator = titleSeparator
        self.description = description
        self.date = date
        self.image = image
        self.author = author
        self.keywords = keywords
        self.twitter = twitter
        self.locale = locale
        self.type = type
        self.themeColor = themeColor
        self.favicons = favicons
        self.canonicalURL = canonicalURL
        self.alternateURLs = alternateURLs
        self.structuredData = structuredData
    }

    public init(
        from base: Metadata,
        site: String? = nil,
        title: String? = nil,
        titleSeparator: String? = nil,
        description: String? = nil,
        date: Date? = nil,
        image: String? = nil,
        author: String? = nil,
        keywords: [String]? = nil,
        twitter: String? = nil,
        locale: LocaleCode? = nil,
        type: ContentType? = nil,
        themeColor: ThemeColor? = nil,
        favicons: [Favicon]? = nil,
        canonicalURL: String? = nil,
        alternateURLs: [LocaleCode: String]? = nil,
        structuredData: [StructuredDataNode]? = nil,
        structuredDataMergeStrategy: StructuredDataMergeStrategy = .append
    ) {
        self.site = site ?? base.site
        self.title = title ?? base.title
        self.titleSeparator = titleSeparator ?? base.titleSeparator
        self.description = description ?? base.description
        self.date = date ?? base.date
        self.image = image ?? base.image
        self.author = author ?? base.author
        self.keywords = keywords ?? base.keywords
        self.twitter = twitter ?? base.twitter
        self.locale = locale ?? base.locale
        self.type = type ?? base.type
        self.themeColor = themeColor ?? base.themeColor
        self.favicons = favicons ?? base.favicons
        self.canonicalURL = canonicalURL ?? base.canonicalURL
        self.alternateURLs = alternateURLs ?? base.alternateURLs

        switch structuredDataMergeStrategy {
        case .append:
            self.structuredData = base.structuredData + (structuredData ?? [])
        case .replace:
            self.structuredData = structuredData ?? base.structuredData
        }
    }

    public var pageTitle: String {
        switch (title, site) {
        case (.some(let title), .some(let site)):
            return "\(title)\(titleSeparator)\(site)"
        case (.some(let title), .none):
            return title
        case (.none, .some(let site)):
            return site
        case (.none, .none):
            return ""
        }
    }

    public var structuredDataGraph: StructuredDataGraph {
        StructuredDataGraph(structuredData)
    }
}
