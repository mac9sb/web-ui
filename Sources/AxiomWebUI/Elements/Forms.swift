import Foundation
import AxiomWebI18n

public struct FormElement: Markup {
    public let action: String
    public let method: String
    public let content: [AnyMarkup]

    public init(action: String, method: String = "post", @MarkupBuilder content: () -> MarkupGroup) {
        self.action = action
        self.method = method
        self.content = content().content
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(
            HTMLElementNode(
                tag: "form",
                attributes: [HTMLAttribute("action", action), HTMLAttribute("method", method)],
                children: content.flatMap { $0.makeNodes(locale: locale) }
            )
        )]
    }
}

public struct Form: HTMLTagElement {
    public static let tagName: HTMLTagName = .form
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

public struct Input: Markup {
    public let name: String
    public let type: String
    public let placeholder: String?
    public let required: Bool
    public let id: String?

    public init(name: String, type: String = "text", placeholder: String? = nil, required: Bool = false, id: String? = nil) {
        self.name = name
        self.type = type
        self.placeholder = placeholder
        self.required = required
        self.id = id
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        var attrs: [HTMLAttribute] = [
            HTMLAttribute("name", name),
            HTMLAttribute("type", type),
        ]
        if let placeholder { attrs.append(HTMLAttribute("placeholder", placeholder)) }
        if required { attrs.append(HTMLAttribute("required")) }
        if let id { attrs.append(HTMLAttribute("id", id)) }
        return [.element(HTMLElementNode(tag: "input", attributes: attrs))]
    }
}

public struct TextArea: Markup {
    public let name: String
    public let placeholder: String?
    public let required: Bool
    public let id: String?

    public init(name: String, placeholder: String? = nil, required: Bool = false, id: String? = nil) {
        self.name = name
        self.placeholder = placeholder
        self.required = required
        self.id = id
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        var attrs: [HTMLAttribute] = [HTMLAttribute("name", name)]
        if let placeholder { attrs.append(HTMLAttribute("placeholder", placeholder)) }
        if required { attrs.append(HTMLAttribute("required")) }
        if let id { attrs.append(HTMLAttribute("id", id)) }
        return [.element(HTMLElementNode(tag: "textarea", attributes: attrs))]
    }
}

public struct Label: Markup {
    public let target: String
    public let value: String

    public init(for target: String, _ value: String) {
        self.target = target
        self.value = value
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(HTMLElementNode(tag: "label", attributes: [HTMLAttribute("for", target)], children: [.text(value)]))]
    }
}

public struct Button: Markup {
    public let title: String
    public let type: String

    public init(_ title: String, type: String = "button") {
        self.title = title
        self.type = type
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [.element(HTMLElementNode(tag: "button", attributes: [HTMLAttribute("type", type)], children: [.text(title)]))]
    }
}

public struct FieldSet: HTMLTagElement {
    public static let tagName: HTMLTagName = .fieldset
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

public struct Legend: HTMLTagElement {
    public static let tagName: HTMLTagName = .legend
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

public struct DataList: HTMLTagElement {
    public static let tagName: HTMLTagName = .datalist
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

public struct OptionGroup: HTMLTagElement {
    public static let tagName: HTMLTagName = .optgroup
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

public struct Option: HTMLTagElement {
    public static let tagName: HTMLTagName = .option
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

public struct Output: HTMLTagElement {
    public static let tagName: HTMLTagName = .output
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

public struct Select: HTMLTagElement {
    public static let tagName: HTMLTagName = .select
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

public struct Meter: HTMLTagElement {
    public static let tagName: HTMLTagName = .meter
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

public struct Progress: HTMLTagElement {
    public static let tagName: HTMLTagName = .progress
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
