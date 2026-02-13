import Foundation
import AxiomWebI18n

public struct HTML: HTMLTagElement {
    public static let tagName: HTMLTagName = .html
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup]

    public init(
        attributes: [HTMLAttribute] = [],
        @MarkupBuilder content: () -> MarkupGroup
    ) {
        self.attributes = attributes
        self.content = content().content
    }
}

public struct Head: HTMLTagElement {
    public static let tagName: HTMLTagName = .head
    public let attributes: [HTMLAttribute] = []
    public let content: [AnyMarkup]

    public init(@MarkupBuilder content: () -> MarkupGroup) {
        self.content = content().content
    }
}

public struct Body: HTMLTagElement {
    public static let tagName: HTMLTagName = .body
    public let attributes: [HTMLAttribute] = []
    public let content: [AnyMarkup]

    public init(@MarkupBuilder content: () -> MarkupGroup) {
        self.content = content().content
    }
}

public struct Title: HTMLTagElement {
    public static let tagName: HTMLTagName = .title
    public let attributes: [HTMLAttribute] = []
    public let content: [AnyMarkup]

    public init(_ value: String) {
        self.content = [AnyMarkup(RawText(value))]
    }
}

public struct Meta: HTMLTagElement {
    public static let tagName: HTMLTagName = .meta
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup] = []

    public init(attributes: [HTMLAttribute]) {
        self.attributes = attributes
    }

    public init(name: String, content: String) {
        self.attributes = [HTMLAttribute("name", name), HTMLAttribute("content", content)]
    }

    public init(property: String, content: String) {
        self.attributes = [HTMLAttribute("property", property), HTMLAttribute("content", content)]
    }
}

public struct LinkTag: HTMLTagElement {
    public static let tagName: HTMLTagName = .link
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup] = []

    public init(rel: String, href: String, extra: [HTMLAttribute] = []) {
        self.attributes = [HTMLAttribute("rel", rel), HTMLAttribute("href", href)] + extra
    }
}

public struct ScriptTag: HTMLTagElement {
    public static let tagName: HTMLTagName = .script
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup]

    public init(type: String? = nil, src: String? = nil, content: String = "") {
        var attrs: [HTMLAttribute] = []
        if let type { attrs.append(HTMLAttribute("type", type)) }
        if let src { attrs.append(HTMLAttribute("src", src)) }
        self.attributes = attrs
        if content.isEmpty {
            self.content = []
        } else {
            self.content = [AnyMarkup(RawText(content))]
        }
    }
}

public struct ResourceLink: HTMLTagElement {
    public static let tagName: HTMLTagName = .link
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup] = []

    public init(attributes: [HTMLAttribute] = []) {
        self.attributes = attributes
    }
}

public struct Base: HTMLTagElement {
    public static let tagName: HTMLTagName = .base
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup] = []

    public init(attributes: [HTMLAttribute] = []) {
        self.attributes = attributes
    }
}

public struct Style: HTMLTagElement {
    public static let tagName: HTMLTagName = .style
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup]

    public init(
        attributes: [HTMLAttribute] = [],
        @MarkupBuilder content: () -> MarkupGroup = { MarkupGroup([]) }
    ) {
        self.attributes = attributes
        self.content = content().content
    }
}

public struct NoScript: HTMLTagElement {
    public static let tagName: HTMLTagName = .noscript
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup]

    public init(
        attributes: [HTMLAttribute] = [],
        @MarkupBuilder content: () -> MarkupGroup = { MarkupGroup([]) }
    ) {
        self.attributes = attributes
        self.content = content().content
    }
}

public struct Template: HTMLTagElement {
    public static let tagName: HTMLTagName = .template
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup]

    public init(
        attributes: [HTMLAttribute] = [],
        @MarkupBuilder content: () -> MarkupGroup = { MarkupGroup([]) }
    ) {
        self.attributes = attributes
        self.content = content().content
    }
}
