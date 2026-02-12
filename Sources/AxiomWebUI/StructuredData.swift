import Foundation
import AxiomWebI18n

public enum StructuredDataValidationError: Error, Equatable, CustomStringConvertible {
    case missingRequiredField(nodeType: String, field: String)
    case invalidNode(nodeType: String, reason: String)

    public var description: String {
        switch self {
        case .missingRequiredField(let nodeType, let field):
            return "Structured data node \(nodeType) is missing required field '\(field)'."
        case .invalidNode(let nodeType, let reason):
            return "Structured data node \(nodeType) is invalid: \(reason)."
        }
    }
}

public struct StructuredDataProperty: Sendable, Equatable {
    public let key: String
    public let value: StructuredDataValue

    public init(_ key: String, _ value: StructuredDataValue) {
        self.key = key
        self.value = value
    }
}

public enum StructuredDataValue: Sendable, Equatable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case date(Date)
    case localized(LocalizedString)
    case node(StructuredDataNode)
    case array([StructuredDataValue])
    case object([StructuredDataProperty])

    fileprivate func jsonObject(locale: LocaleCode) -> Any {
        switch self {
        case .string(let value):
            return value
        case .int(let value):
            return value
        case .double(let value):
            return value
        case .bool(let value):
            return value
        case .date(let value):
            return ISO8601DateFormatter().string(from: value)
        case .localized(let value):
            return value.resolve(locale: locale)
        case .node(let value):
            return value.jsonObject(locale: locale)
        case .array(let value):
            return value.map { $0.jsonObject(locale: locale) }
        case .object(let properties):
            var dictionary: [String: Any] = [:]
            for property in properties {
                dictionary[property.key] = property.value.jsonObject(locale: locale)
            }
            return dictionary
        }
    }
}

public struct OrganizationNode: Sendable, Equatable {
    public var id: String?
    public var name: LocalizedString
    public var url: String
    public var logo: String?
    public var sameAs: [String]

    public init(id: String? = nil, name: LocalizedString, url: String, logo: String? = nil, sameAs: [String] = []) {
        self.id = id
        self.name = name
        self.url = url
        self.logo = logo
        self.sameAs = sameAs
    }
}

public struct PersonNode: Sendable, Equatable {
    public var id: String?
    public var name: LocalizedString
    public var url: String?
    public var image: String?
    public var jobTitle: LocalizedString?

    public init(
        id: String? = nil,
        name: LocalizedString,
        url: String? = nil,
        image: String? = nil,
        jobTitle: LocalizedString? = nil
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.image = image
        self.jobTitle = jobTitle
    }
}

public struct ArticleNode: Sendable, Equatable {
    public var id: String?
    public var headline: LocalizedString
    public var description: LocalizedString?
    public var image: String?
    public var authorName: LocalizedString
    public var publisherName: LocalizedString?
    public var datePublished: Date
    public var dateModified: Date?
    public var url: String?

    public init(
        id: String? = nil,
        headline: LocalizedString,
        description: LocalizedString? = nil,
        image: String? = nil,
        authorName: LocalizedString,
        publisherName: LocalizedString? = nil,
        datePublished: Date,
        dateModified: Date? = nil,
        url: String? = nil
    ) {
        self.id = id
        self.headline = headline
        self.description = description
        self.image = image
        self.authorName = authorName
        self.publisherName = publisherName
        self.datePublished = datePublished
        self.dateModified = dateModified
        self.url = url
    }
}

public struct ProductNode: Sendable, Equatable {
    public var id: String?
    public var name: LocalizedString
    public var description: LocalizedString
    public var sku: String?
    public var brand: LocalizedString?
    public var offers: [StructuredDataProperty]

    public init(
        id: String? = nil,
        name: LocalizedString,
        description: LocalizedString,
        sku: String? = nil,
        brand: LocalizedString? = nil,
        offers: [StructuredDataProperty] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.sku = sku
        self.brand = brand
        self.offers = offers
    }
}

public struct FAQPageNode: Sendable, Equatable {
    public struct Question: Sendable, Equatable {
        public var question: LocalizedString
        public var answer: LocalizedString

        public init(question: LocalizedString, answer: LocalizedString) {
            self.question = question
            self.answer = answer
        }
    }

    public var id: String?
    public var questions: [Question]

    public init(id: String? = nil, questions: [Question]) {
        self.id = id
        self.questions = questions
    }
}

public struct BreadcrumbListNode: Sendable, Equatable {
    public struct Item: Sendable, Equatable {
        public var name: LocalizedString
        public var item: String

        public init(name: LocalizedString, item: String) {
            self.name = name
            self.item = item
        }
    }

    public var id: String?
    public var items: [Item]

    public init(id: String? = nil, items: [Item]) {
        self.id = id
        self.items = items
    }
}

public struct WebsiteNode: Sendable, Equatable {
    public var id: String?
    public var name: LocalizedString
    public var url: String

    public init(id: String? = nil, name: LocalizedString, url: String) {
        self.id = id
        self.name = name
        self.url = url
    }
}

public struct WebPageNode: Sendable, Equatable {
    public var id: String?
    public var name: LocalizedString
    public var url: String

    public init(id: String? = nil, name: LocalizedString, url: String) {
        self.id = id
        self.name = name
        self.url = url
    }
}

public struct EventNode: Sendable, Equatable {
    public var id: String?
    public var name: LocalizedString
    public var startDate: Date
    public var endDate: Date?
    public var locationName: LocalizedString?
    public var locationURL: String?

    public init(
        id: String? = nil,
        name: LocalizedString,
        startDate: Date,
        endDate: Date? = nil,
        locationName: LocalizedString? = nil,
        locationURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.locationName = locationName
        self.locationURL = locationURL
    }
}

public enum StructuredDataNode: Sendable, Equatable {
    case organization(OrganizationNode)
    case person(PersonNode)
    case article(ArticleNode)
    case product(ProductNode)
    case faqPage(FAQPageNode)
    case breadcrumbList(BreadcrumbListNode)
    case website(WebsiteNode)
    case webPage(WebPageNode)
    case event(EventNode)
    case custom(schemaType: String, id: String? = nil, properties: [StructuredDataProperty])

    public var identity: String? {
        switch self {
        case .organization(let value): return value.id
        case .person(let value): return value.id
        case .article(let value): return value.id
        case .product(let value): return value.id
        case .faqPage(let value): return value.id
        case .breadcrumbList(let value): return value.id
        case .website(let value): return value.id
        case .webPage(let value): return value.id
        case .event(let value): return value.id
        case .custom(_, let id, _): return id
        }
    }

    public var schemaType: String {
        switch self {
        case .organization: return "Organization"
        case .person: return "Person"
        case .article: return "Article"
        case .product: return "Product"
        case .faqPage: return "FAQPage"
        case .breadcrumbList: return "BreadcrumbList"
        case .website: return "WebSite"
        case .webPage: return "WebPage"
        case .event: return "Event"
        case .custom(let type, _, _): return type
        }
    }

    public func validate() throws {
        switch self {
        case .organization(let node):
            if node.url.isEmpty { throw StructuredDataValidationError.missingRequiredField(nodeType: schemaType, field: "url") }
            if node.name.resolve(locale: .en).isEmpty { throw StructuredDataValidationError.missingRequiredField(nodeType: schemaType, field: "name") }
        case .person(let node):
            if node.name.resolve(locale: .en).isEmpty { throw StructuredDataValidationError.missingRequiredField(nodeType: schemaType, field: "name") }
        case .article(let node):
            if node.headline.resolve(locale: .en).isEmpty { throw StructuredDataValidationError.missingRequiredField(nodeType: schemaType, field: "headline") }
            if node.authorName.resolve(locale: .en).isEmpty { throw StructuredDataValidationError.missingRequiredField(nodeType: schemaType, field: "author") }
        case .product(let node):
            if node.name.resolve(locale: .en).isEmpty { throw StructuredDataValidationError.missingRequiredField(nodeType: schemaType, field: "name") }
            if node.description.resolve(locale: .en).isEmpty { throw StructuredDataValidationError.missingRequiredField(nodeType: schemaType, field: "description") }
        case .faqPage(let node):
            if node.questions.isEmpty { throw StructuredDataValidationError.missingRequiredField(nodeType: schemaType, field: "questions") }
        case .breadcrumbList(let node):
            if node.items.isEmpty { throw StructuredDataValidationError.missingRequiredField(nodeType: schemaType, field: "items") }
        case .website(let node):
            if node.name.resolve(locale: .en).isEmpty { throw StructuredDataValidationError.missingRequiredField(nodeType: schemaType, field: "name") }
            if node.url.isEmpty { throw StructuredDataValidationError.missingRequiredField(nodeType: schemaType, field: "url") }
        case .webPage(let node):
            if node.name.resolve(locale: .en).isEmpty { throw StructuredDataValidationError.missingRequiredField(nodeType: schemaType, field: "name") }
            if node.url.isEmpty { throw StructuredDataValidationError.missingRequiredField(nodeType: schemaType, field: "url") }
        case .event(let node):
            if node.name.resolve(locale: .en).isEmpty { throw StructuredDataValidationError.missingRequiredField(nodeType: schemaType, field: "name") }
        case .custom(let schemaType, _, let properties):
            if schemaType.isEmpty {
                throw StructuredDataValidationError.missingRequiredField(nodeType: "custom", field: "schemaType")
            }
            if properties.isEmpty {
                throw StructuredDataValidationError.missingRequiredField(nodeType: schemaType, field: "properties")
            }
        }
    }

    fileprivate func jsonObject(locale: LocaleCode) -> [String: Any] {
        var payload: [String: Any] = [
            "@context": "https://schema.org",
            "@type": schemaType,
        ]

        if let identity {
            payload["@id"] = identity
        }

        switch self {
        case .organization(let node):
            payload["name"] = node.name.resolve(locale: locale)
            payload["url"] = node.url
            if let logo = node.logo { payload["logo"] = logo }
            if !node.sameAs.isEmpty { payload["sameAs"] = node.sameAs }
        case .person(let node):
            payload["name"] = node.name.resolve(locale: locale)
            if let url = node.url { payload["url"] = url }
            if let image = node.image { payload["image"] = image }
            if let jobTitle = node.jobTitle { payload["jobTitle"] = jobTitle.resolve(locale: locale) }
        case .article(let node):
            payload["headline"] = node.headline.resolve(locale: locale)
            payload["author"] = ["@type": "Person", "name": node.authorName.resolve(locale: locale)]
            payload["datePublished"] = ISO8601DateFormatter().string(from: node.datePublished)
            if let description = node.description { payload["description"] = description.resolve(locale: locale) }
            if let image = node.image { payload["image"] = image }
            if let dateModified = node.dateModified { payload["dateModified"] = ISO8601DateFormatter().string(from: dateModified) }
            if let publisherName = node.publisherName {
                payload["publisher"] = ["@type": "Organization", "name": publisherName.resolve(locale: locale)]
            }
            if let url = node.url { payload["url"] = url }
        case .product(let node):
            payload["name"] = node.name.resolve(locale: locale)
            payload["description"] = node.description.resolve(locale: locale)
            if let sku = node.sku { payload["sku"] = sku }
            if let brand = node.brand {
                payload["brand"] = ["@type": "Brand", "name": brand.resolve(locale: locale)]
            }
            if !node.offers.isEmpty {
                payload["offers"] = Dictionary(uniqueKeysWithValues: node.offers.map { ($0.key, $0.value.jsonObject(locale: locale)) })
            }
        case .faqPage(let node):
            payload["mainEntity"] = node.questions.map {
                [
                    "@type": "Question",
                    "name": $0.question.resolve(locale: locale),
                    "acceptedAnswer": [
                        "@type": "Answer",
                        "text": $0.answer.resolve(locale: locale),
                    ],
                ]
            }
        case .breadcrumbList(let node):
            payload["itemListElement"] = node.items.enumerated().map { index, item in
                [
                    "@type": "ListItem",
                    "position": index + 1,
                    "name": item.name.resolve(locale: locale),
                    "item": item.item,
                ]
            }
        case .website(let node):
            payload["name"] = node.name.resolve(locale: locale)
            payload["url"] = node.url
        case .webPage(let node):
            payload["name"] = node.name.resolve(locale: locale)
            payload["url"] = node.url
        case .event(let node):
            payload["name"] = node.name.resolve(locale: locale)
            payload["startDate"] = ISO8601DateFormatter().string(from: node.startDate)
            if let endDate = node.endDate {
                payload["endDate"] = ISO8601DateFormatter().string(from: endDate)
            }
            if let locationName = node.locationName {
                var location: [String: Any] = ["@type": "Place", "name": locationName.resolve(locale: locale)]
                if let locationURL = node.locationURL {
                    location["url"] = locationURL
                }
                payload["location"] = location
            }
        case .custom(_, _, let properties):
            for property in properties {
                payload[property.key] = property.value.jsonObject(locale: locale)
            }
        }

        return payload
    }
}

public struct StructuredDataGraph: Sendable, Equatable {
    public var nodes: [StructuredDataNode]

    public init(_ nodes: [StructuredDataNode] = []) {
        self.nodes = nodes
    }

    public func merged(with other: StructuredDataGraph) -> StructuredDataGraph {
        StructuredDataGraph(nodes + other.nodes)
    }

    public func deduplicated() -> StructuredDataGraph {
        var seenIDs: Set<String> = []
        var seenNodeFingerprints: Set<String> = []
        var unique: [StructuredDataNode] = []

        for node in nodes {
            if let identity = node.identity {
                if seenIDs.contains(identity) {
                    continue
                }
                seenIDs.insert(identity)
                unique.append(node)
                continue
            }

            let fingerprint = "\(node.schemaType)|\(String(describing: node))"
            if seenNodeFingerprints.contains(fingerprint) {
                continue
            }
            seenNodeFingerprints.insert(fingerprint)
            unique.append(node)
        }

        return StructuredDataGraph(unique)
    }

    public func validated() throws -> StructuredDataGraph {
        for node in nodes {
            try node.validate()
        }
        return self
    }

    public func jsonLD(locale: LocaleCode) throws -> String {
        let payload: Any
        if nodes.count == 1, let only = nodes.first {
            payload = only.jsonObject(locale: locale)
        } else {
            payload = [
                "@context": "https://schema.org",
                "@graph": nodes.map { $0.jsonObject(locale: locale) },
            ]
        }

        let data = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys, .withoutEscapingSlashes])
        return String(decoding: data, as: UTF8.self)
    }
}
