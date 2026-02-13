import Foundation
import AxiomWebI18n

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

public struct Input: HTMLTagElement {
    public static let tagName: HTMLTagName = .input
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup] = []

    public init(
        name: String,
        type: String = "text",
        placeholder: String? = nil,
        required: Bool = false,
        id: String? = nil,
        checked: Bool = false,
        disabled: Bool = false,
        list: String? = nil,
        attributes: [HTMLAttribute] = []
    ) {
        var attrs: [HTMLAttribute] = [
            HTMLAttribute("name", name),
            HTMLAttribute("type", type),
        ]
        if let placeholder { attrs.append(HTMLAttribute("placeholder", placeholder)) }
        if required { attrs.append(HTMLAttribute("required")) }
        if checked { attrs.append(HTMLAttribute("checked")) }
        if disabled { attrs.append(HTMLAttribute("disabled")) }
        if let list, !list.isEmpty { attrs.append(HTMLAttribute("list", list)) }
        if let id { attrs.append(HTMLAttribute("id", id)) }
        attrs.append(contentsOf: attributes)
        self.attributes = attrs
    }
}

public struct TextArea: HTMLTagElement {
    public static let tagName: HTMLTagName = .textarea
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup] = []

    public init(name: String, placeholder: String? = nil, required: Bool = false, id: String? = nil) {
        var attrs: [HTMLAttribute] = [HTMLAttribute("name", name)]
        if let placeholder { attrs.append(HTMLAttribute("placeholder", placeholder)) }
        if required { attrs.append(HTMLAttribute("required")) }
        if let id { attrs.append(HTMLAttribute("id", id)) }
        self.attributes = attrs
    }
}

public struct Label: HTMLTagElement {
    public static let tagName: HTMLTagName = .label
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup]

    public init(
        for target: String,
        _ value: String,
        attributes: [HTMLAttribute] = []
    ) {
        self.init(for: target, attributes: attributes) {
            RawText(value)
        }
    }

    public init(
        for target: String,
        attributes: [HTMLAttribute] = [],
        @MarkupBuilder content: () -> MarkupGroup
    ) {
        var attrs = attributes
        if !target.isEmpty {
            attrs.insert(HTMLAttribute("for", target), at: 0)
        }
        self.attributes = attrs
        self.content = content().content
    }

    public init(
        attributes: [HTMLAttribute] = [],
        @MarkupBuilder content: () -> MarkupGroup
    ) {
        self.attributes = attributes
        self.content = content().content
    }
}

public struct Button: HTMLTagElement {
    public static let tagName: HTMLTagName = .button
    public let attributes: [HTMLAttribute]
    public let content: [AnyMarkup]

    public init(
        _ title: String,
        type: String = "button",
        attributes: [HTMLAttribute] = []
    ) {
        self.init(type: type, attributes: attributes) {
            RawText(title)
        }
    }

    public init(
        type: String = "button",
        attributes: [HTMLAttribute] = [],
        @MarkupBuilder content: () -> MarkupGroup
    ) {
        var attrs = attributes
        if attrs.contains(where: { $0.name.caseInsensitiveCompare("type") == .orderedSame }) == false {
            attrs.insert(HTMLAttribute("type", type), at: 0)
        }
        self.attributes = attrs
        self.content = content().content
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
