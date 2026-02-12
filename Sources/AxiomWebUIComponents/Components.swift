import Foundation
import AxiomWebUI
import AxiomWebStyle
import AxiomWebI18n

public struct Card: Markup {
    private let content: MarkupGroup
    private let theme: ComponentTheme?

    public init(theme: ComponentTheme? = nil, @MarkupBuilder content: () -> MarkupGroup) {
        self.theme = theme
        self.content = content()
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current
        return Stack {
            content
        }
        .background(color: activeTheme.surfaceColor)
        .font(color: activeTheme.foregroundColor)
        .border(of: 1, color: activeTheme.borderColor)
        .padding(activeTheme.spacing(4))
        .borderRadius(activeTheme.cornerRadius)
        .boxShadow(.raw("0 10px 30px -18px rgb(15 23 42 / 0.45)"))
        .makeNodes(locale: locale)
    }
}

public struct ActionButton: Markup {
    public enum Tone: Sendable {
        case primary
        case secondary
        case destructive
        case ghost
    }

    public enum Kind: String, Sendable {
        case button
        case submit
        case reset
    }

    private let label: String
    private let tone: Tone
    private let kind: Kind
    private let id: String?
    private let theme: ComponentTheme?

    public init(
        _ label: String,
        tone: Tone = .primary,
        kind: Kind = .button,
        id: String? = nil,
        theme: ComponentTheme? = nil
    ) {
        self.label = label
        self.tone = tone
        self.kind = kind
        self.id = id
        self.theme = theme
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current
        var attributes: [HTMLAttribute] = [HTMLAttribute("type", kind.rawValue)]
        if let id, !id.isEmpty {
            attributes.append(HTMLAttribute("id", id))
        }

        let styled: any Markup = {
            let base = Node("button", attributes: attributes) {
                Text(label)
            }
            .padding(activeTheme.spacing(3))
            .borderRadius(activeTheme.cornerRadius)
            .font(weight: .semibold)
            .css(.lineHeight, .number(1.2))
            .css(.transition, .raw("transform 120ms ease, opacity 120ms ease"))
            .on {
                $0.hover {
                    $0.transform(.raw("translateY(-1px)"))
                }
                $0.active {
                    $0.transform(.raw("translateY(0)"))
                    $0.opacity(.number(0.92))
                }
            }

            switch tone {
            case .primary:
                return base
                    .background(color: activeTheme.accentColor)
                    .font(color: .white)
                    .border(of: 1, color: activeTheme.accentColor)
            case .secondary:
                return base
                    .background(color: activeTheme.surfaceColor)
                    .font(color: activeTheme.foregroundColor)
                    .border(of: 1, color: activeTheme.borderColor)
            case .destructive:
                return base
                    .background(color: activeTheme.destructiveColor)
                    .font(color: .white)
                    .border(of: 1, color: activeTheme.destructiveColor)
            case .ghost:
                return base
                    .background(color: .transparent)
                    .font(color: activeTheme.accentColor)
                    .border(of: 1, color: activeTheme.borderColor)
            }
        }()

        return AnyMarkup(styled).makeNodes(locale: locale)
    }
}

public struct Badge: Markup {
    public enum Tone: Sendable {
        case neutral
        case accent
        case destructive
    }

    private let value: String
    private let tone: Tone
    private let theme: ComponentTheme?

    public init(_ value: String, tone: Tone = .neutral, theme: ComponentTheme? = nil) {
        self.value = value
        self.tone = tone
        self.theme = theme
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current
        let (background, text) = toneColors(theme: activeTheme)
        return Node("span", attributes: [HTMLAttribute("class", "ax-badge")]) {
            Text(value)
        }
        .display(.keyword("inline-flex"))
        .padding(.raw("0.35rem 0.6rem"))
        .borderRadius(.raw("9999px"))
        .font(size: .sm, weight: .semibold, color: text)
        .background(color: background)
        .makeNodes(locale: locale)
    }

    private func toneColors(theme: ComponentTheme) -> (ColorToken, ColorToken) {
        switch tone {
        case .neutral:
            return (theme.mutedColor, .white)
        case .accent:
            return (theme.accentColor, .white)
        case .destructive:
            return (theme.destructiveColor, .white)
        }
    }
}

public struct Alert: Markup {
    public enum Tone: Sendable {
        case info
        case success
        case warning
        case error
    }

    private let title: String
    private let message: String
    private let tone: Tone
    private let theme: ComponentTheme?

    public init(
        title: String,
        message: String,
        tone: Tone = .info,
        theme: ComponentTheme? = nil
    ) {
        self.title = title
        self.message = message
        self.tone = tone
        self.theme = theme
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current
        let accent = toneColor(theme: activeTheme)

        return Stack {
            Heading(.h3, title)
                .font(size: .base, weight: .semibold)
                .margins(of: .one, at: .bottom)
            Paragraph(message)
                .font(size: .sm)
        }
        .background(color: activeTheme.surfaceColor)
        .font(color: activeTheme.foregroundColor)
        .border(of: 1, color: activeTheme.borderColor)
        .padding(activeTheme.spacing(4))
        .borderRadius(activeTheme.cornerRadius)
        .css(.borderLeft, .raw("0.375rem solid"))
        .css(.borderLeftColor, .raw("hsl(0 0% 0%)"))
        .modifier("border-\(accent.classFragment)")
        .makeNodes(locale: locale)
    }

    private func toneColor(theme: ComponentTheme) -> ColorToken {
        switch tone {
        case .info:
            return theme.accentColor
        case .success:
            return .emerald(600)
        case .warning:
            return .amber(600)
        case .error:
            return theme.destructiveColor
        }
    }
}

public struct Accordion: Markup {
    private let content: MarkupGroup
    private let theme: ComponentTheme?

    public init(theme: ComponentTheme? = nil, @MarkupBuilder content: () -> MarkupGroup) {
        self.theme = theme
        self.content = content()
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current
        return Stack {
            content
        }
        .display(.keyword("grid"))
        .rowGap(activeTheme.spacing(2))
        .makeNodes(locale: locale)
    }
}

public struct AccordionItem: Markup {
    public let title: String
    private let content: MarkupGroup
    private let theme: ComponentTheme?

    public init(
        _ title: String,
        theme: ComponentTheme? = nil,
        @MarkupBuilder content: () -> MarkupGroup
    ) {
        self.title = title
        self.theme = theme
        self.content = content()
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current
        return Details {
            Summary(title)
                .font(weight: .semibold)
                .css(.cursor, .keyword("pointer"))
            Stack {
                content
            }
            .margins(of: .two, at: .top)
        }
        .background(color: activeTheme.surfaceColor)
        .font(color: activeTheme.foregroundColor)
        .border(of: 1, color: activeTheme.borderColor)
        .padding(activeTheme.spacing(3))
        .borderRadius(activeTheme.cornerRadius)
        .makeNodes(locale: locale)
    }
}

public struct Popover: Markup {
    public let id: String
    public let triggerLabel: String
    private let content: MarkupGroup
    private let theme: ComponentTheme?

    public init(
        id: String,
        triggerLabel: String,
        theme: ComponentTheme? = nil,
        @MarkupBuilder content: () -> MarkupGroup
    ) {
        self.id = id
        self.triggerLabel = triggerLabel
        self.theme = theme
        self.content = content()
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current
        return [
            AnyMarkup(ActionButton(triggerLabel, tone: .secondary, theme: activeTheme))
                .makeNodes(locale: locale)
                .first?
                .addingAttribute(HTMLAttribute("popovertarget", id)) ?? .text(""),
            AnyMarkup(
                Stack {
                    content
                }
                .background(color: activeTheme.surfaceColor)
                .font(color: activeTheme.foregroundColor)
                .border(of: 1, color: activeTheme.borderColor)
                .padding(activeTheme.spacing(3))
                .borderRadius(activeTheme.cornerRadius)
                .css(.maxWidth, .raw("min(90vw, 22rem)"))
                .css(.boxShadow, .raw("0 18px 40px -24px rgb(0 0 0 / 0.55)"))
            )
            .makeNodes(locale: locale)
            .first?
            .addingAttribute(HTMLAttribute("id", id))
            .addingAttribute(HTMLAttribute("popover")) ?? .text("")
        ]
    }
}

public struct ModalDialog: Markup {
    public let id: String
    public let triggerLabel: String
    public let dismissLabel: String
    private let content: MarkupGroup
    private let theme: ComponentTheme?

    public init(
        id: String,
        triggerLabel: String,
        dismissLabel: String = "Close",
        theme: ComponentTheme? = nil,
        @MarkupBuilder content: () -> MarkupGroup
    ) {
        self.id = id
        self.triggerLabel = triggerLabel
        self.dismissLabel = dismissLabel
        self.theme = theme
        self.content = content()
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current
        return [
            .element(
                HTMLElementNode(
                    tag: "button",
                    attributes: [
                        HTMLAttribute("type", "button"),
                        HTMLAttribute("commandfor", id),
                        HTMLAttribute("command", "show-modal"),
                    ],
                    children: [.text(triggerLabel)]
                )
            ),
            AnyMarkup(
                Node("dialog", attributes: [HTMLAttribute("id", id)]) {
                    Stack {
                        content
                        Node("form", attributes: [HTMLAttribute("method", "dialog")]) {
                            ActionButton(dismissLabel, tone: .secondary, kind: .submit, theme: activeTheme)
                        }
                        .margins(of: .three, at: .top)
                    }
                }
                .background(color: activeTheme.surfaceColor)
                .font(color: activeTheme.foregroundColor)
                .border(of: 1, color: activeTheme.borderColor)
                .padding(activeTheme.spacing(4))
                .borderRadius(activeTheme.cornerRadius)
            )
            .makeNodes(locale: locale)
            .first ?? .text("")
        ]
    }
}

public struct DropdownMenu: Markup {
    public let label: String
    private let items: MarkupGroup
    private let theme: ComponentTheme?

    public init(
        label: String,
        theme: ComponentTheme? = nil,
        @MarkupBuilder items: () -> MarkupGroup
    ) {
        self.label = label
        self.theme = theme
        self.items = items()
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current
        return Details {
            Summary(label)
                .font(weight: .semibold)
                .css(.cursor, .keyword("pointer"))
            Stack {
                items
            }
            .display(.keyword("grid"))
            .rowGap(activeTheme.spacing(1))
            .margins(of: .two, at: .top)
        }
        .background(color: activeTheme.surfaceColor)
        .font(color: activeTheme.foregroundColor)
        .border(of: 1, color: activeTheme.borderColor)
        .padding(activeTheme.spacing(3))
        .borderRadius(activeTheme.cornerRadius)
        .css(.minWidth, .raw("12rem"))
        .makeNodes(locale: locale)
    }
}

public struct FormTextField: Markup {
    public let label: String
    public let name: String
    public let placeholder: String?
    public let required: Bool
    public let id: String?
    private let theme: ComponentTheme?

    public init(
        label: String,
        name: String,
        placeholder: String? = nil,
        required: Bool = false,
        id: String? = nil,
        theme: ComponentTheme? = nil
    ) {
        self.label = label
        self.name = name
        self.placeholder = placeholder
        self.required = required
        self.id = id
        self.theme = theme
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current
        let identifier = id ?? name
        return Stack {
            Label(for: identifier, label)
                .font(size: .sm, weight: .semibold, color: activeTheme.foregroundColor)
            Input(name: name, placeholder: placeholder, required: required, id: identifier)
                .padding(activeTheme.spacing(2))
                .border(of: 1, color: activeTheme.borderColor)
                .background(color: activeTheme.surfaceColor)
                .font(color: activeTheme.foregroundColor)
                .borderRadius(activeTheme.cornerRadius)
        }
        .display(.keyword("grid"))
        .rowGap(activeTheme.spacing(1))
        .makeNodes(locale: locale)
    }
}

public struct FormTextArea: Markup {
    public let label: String
    public let name: String
    public let placeholder: String?
    public let required: Bool
    public let id: String?
    private let theme: ComponentTheme?

    public init(
        label: String,
        name: String,
        placeholder: String? = nil,
        required: Bool = false,
        id: String? = nil,
        theme: ComponentTheme? = nil
    ) {
        self.label = label
        self.name = name
        self.placeholder = placeholder
        self.required = required
        self.id = id
        self.theme = theme
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current
        let identifier = id ?? name
        return Stack {
            Label(for: identifier, label)
                .font(size: .sm, weight: .semibold, color: activeTheme.foregroundColor)
            TextArea(name: name, placeholder: placeholder, required: required, id: identifier)
                .padding(activeTheme.spacing(2))
                .border(of: 1, color: activeTheme.borderColor)
                .background(color: activeTheme.surfaceColor)
                .font(color: activeTheme.foregroundColor)
                .borderRadius(activeTheme.cornerRadius)
                .minHeight(.length(8, .rem))
        }
        .display(.keyword("grid"))
        .rowGap(activeTheme.spacing(1))
        .makeNodes(locale: locale)
    }
}

public struct Breadcrumbs: Markup {
    public struct Item: Sendable, Equatable {
        public let label: String
        public let href: String?
        public let current: Bool

        public init(_ label: String, href: String? = nil, current: Bool = false) {
            self.label = label
            self.href = href
            self.current = current
        }
    }

    public let items: [Item]
    public let separator: String
    private let theme: ComponentTheme?

    public init(items: [Item], separator: String = "/", theme: ComponentTheme? = nil) {
        self.items = items
        self.separator = separator
        self.theme = theme
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current

        return Navigation(attributes: [HTMLAttribute("aria-label", "Breadcrumb")]) {
            OrderedList {
                for index in items.indices {
                    let item = items[index]
                    let isCurrent = item.current || index == items.count - 1
                    ListItem {
                        if let href = item.href, !isCurrent {
                            Link(item.label, href: href)
                                .font(size: .sm, color: activeTheme.mutedColor)
                        } else {
                            Node("span", attributes: isCurrent ? [HTMLAttribute("aria-current", "page")] : []) {
                                Text(item.label)
                            }
                            .font(size: .sm, weight: .semibold, color: activeTheme.foregroundColor)
                        }

                        if index < items.count - 1 {
                            Node("span", attributes: [HTMLAttribute("aria-hidden", "true")]) {
                                Text(separator)
                            }
                            .font(size: .sm, color: activeTheme.mutedColor)
                        }
                    }
                    .display(.keyword("inline-flex"))
                    .alignItems(.keyword("center"))
                    .columnGap(activeTheme.spacing(2))
                }
            }
            .display(.keyword("flex"))
            .alignItems(.keyword("center"))
            .columnGap(activeTheme.spacing(2))
            .css(.listStyle, .keyword("none"))
            .css(.paddingLeft, .number(0))
            .css(.margin, .number(0))
        }
        .makeNodes(locale: locale)
    }
}

public struct Pagination: Markup {
    public let currentPage: Int
    public let totalPages: Int
    public let basePath: String
    public let queryKey: String
    private let theme: ComponentTheme?

    public init(
        currentPage: Int,
        totalPages: Int,
        basePath: String,
        queryKey: String = "page",
        theme: ComponentTheme? = nil
    ) {
        self.currentPage = max(1, currentPage)
        self.totalPages = max(1, totalPages)
        self.basePath = basePath
        self.queryKey = queryKey
        self.theme = theme
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current
        let current = min(currentPage, totalPages)

        return Navigation(attributes: [HTMLAttribute("aria-label", "Pagination")]) {
            OrderedList {
                if current > 1 {
                    ListItem {
                        Link("Previous", href: href(for: current - 1))
                            .font(size: .sm, color: activeTheme.foregroundColor)
                    }
                }

                for page in 1...totalPages {
                    ListItem {
                        if page == current {
                            Node("span", attributes: [HTMLAttribute("aria-current", "page")]) {
                                Text("\(page)")
                            }
                            .font(size: .sm, weight: .semibold, color: activeTheme.foregroundColor)
                        } else {
                            Link("\(page)", href: href(for: page))
                                .font(size: .sm, color: activeTheme.mutedColor)
                        }
                    }
                    .border(of: 1, color: activeTheme.borderColor)
                    .borderRadius(activeTheme.cornerRadius)
                    .padding(activeTheme.spacing(1))
                    .width(.raw("2.25rem"))
                    .css(.textAlign, .keyword("center"))
                }

                if current < totalPages {
                    ListItem {
                        Link("Next", href: href(for: current + 1))
                            .font(size: .sm, color: activeTheme.foregroundColor)
                    }
                }
            }
            .display(.keyword("flex"))
            .alignItems(.keyword("center"))
            .columnGap(activeTheme.spacing(2))
            .css(.listStyle, .keyword("none"))
            .css(.paddingLeft, .number(0))
            .css(.margin, .number(0))
        }
        .makeNodes(locale: locale)
    }

    private func href(for page: Int) -> String {
        if page <= 1 {
            return basePath
        }
        let separator = basePath.contains("?") ? "&" : "?"
        return "\(basePath)\(separator)\(queryKey)=\(page)"
    }
}

public struct ProgressBar: Markup {
    public let value: Double
    public let maximum: Double
    public let label: String?
    public let id: String?
    private let theme: ComponentTheme?

    public init(
        value: Double,
        maximum: Double = 100,
        label: String? = nil,
        id: String? = nil,
        theme: ComponentTheme? = nil
    ) {
        self.value = value
        self.maximum = max(1, maximum)
        self.label = label
        self.id = id
        self.theme = theme
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current
        let clamped = min(max(0, value), maximum)
        let progressID = id ?? "progress-\(Int(max(0, clamped)))"
        let labelID = "\(progressID)-label"
        var progressAttributes: [HTMLAttribute] = [
            HTMLAttribute("id", progressID),
            HTMLAttribute("value", numericString(clamped)),
            HTMLAttribute("max", numericString(maximum)),
        ]
        if let label, !label.isEmpty {
            progressAttributes.append(HTMLAttribute("aria-labelledby", labelID))
        }

        return Stack {
            if let label, !label.isEmpty {
                Node("label", attributes: [HTMLAttribute("id", labelID), HTMLAttribute("for", progressID)]) {
                    Text(label)
                }
                .font(size: .sm, weight: .medium, color: activeTheme.foregroundColor)
            }

            Progress(attributes: progressAttributes)
            .width(.length(100, .percent))
            .height(.length(0.75, .rem))
            .accentColor(.keyword("currentColor"))
            .font(color: activeTheme.accentColor)
            .borderRadius(activeTheme.cornerRadius)
        }
        .display(.keyword("grid"))
        .rowGap(activeTheme.spacing(1))
        .makeNodes(locale: locale)
    }

    private func numericString(_ value: Double) -> String {
        String(format: value.rounded() == value ? "%.0f" : "%.2f", value)
    }
}

public struct Separator: Markup {
    public enum Orientation: Sendable {
        case horizontal
        case vertical
    }

    public let orientation: Orientation
    private let theme: ComponentTheme?

    public init(_ orientation: Orientation = .horizontal, theme: ComponentTheme? = nil) {
        self.orientation = orientation
        self.theme = theme
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current

        switch orientation {
        case .horizontal:
            return HorizontalRule(
                attributes: [
                    HTMLAttribute("role", "separator"),
                    HTMLAttribute("aria-orientation", "horizontal"),
                ]
            )
            .css(.border, .number(0))
            .css(.borderTop, .raw("1px solid"))
            .css(.borderColor, .raw("hsl(0 0% 0%)"))
            .modifier("border-\(activeTheme.borderColor.classFragment)")
            .makeNodes(locale: locale)
        case .vertical:
            return Node(
                "div",
                attributes: [
                    HTMLAttribute("role", "separator"),
                    HTMLAttribute("aria-orientation", "vertical"),
                ]
            )
            .background(color: activeTheme.borderColor)
            .width(.length(1, .px))
            .height(.length(100, .percent))
            .makeNodes(locale: locale)
        }
    }
}

public struct Avatar: Markup {
    public let imageURL: String?
    public let alt: String
    public let fallbackText: String
    public let size: CSSValue
    private let theme: ComponentTheme?

    public init(
        imageURL: String? = nil,
        alt: String,
        fallbackText: String,
        size: CSSValue = .length(2.5, .rem),
        theme: ComponentTheme? = nil
    ) {
        self.imageURL = imageURL
        self.alt = alt
        self.fallbackText = fallbackText
        self.size = size
        self.theme = theme
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current

        return Node("span", attributes: [HTMLAttribute("aria-label", alt)]) {
            if let imageURL, !imageURL.isEmpty {
                Image(attributes: [HTMLAttribute("src", imageURL), HTMLAttribute("alt", alt)])
                    .width(.length(100, .percent))
                    .height(.length(100, .percent))
                    .objectFit(.keyword("cover"))
            } else {
                Text(fallbackText)
            }
        }
        .display(.keyword("inline-flex"))
        .alignItems(.keyword("center"))
        .justifyContent(.keyword("center"))
        .width(size)
        .height(size)
        .borderRadius(.raw("9999px"))
        .overflow(.keyword("hidden"))
        .background(color: activeTheme.mutedColor)
        .font(size: .sm, weight: .semibold, color: .white)
        .makeNodes(locale: locale)
    }
}

public struct Skeleton: Markup {
    public let width: CSSValue
    public let height: CSSValue
    private let theme: ComponentTheme?

    public init(width: CSSValue = .length(100, .percent), height: CSSValue = .length(1, .rem), theme: ComponentTheme? = nil) {
        self.width = width
        self.height = height
        self.theme = theme
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current

        return Node("div", attributes: [HTMLAttribute("aria-hidden", "true")]) { }
            .width(width)
            .height(height)
            .borderRadius(activeTheme.cornerRadius)
            .background(color: activeTheme.borderColor)
            .animate(
                .pulse,
                duration: 1.2,
                timing: .easeInOut,
                iteration: .infinite,
                fillMode: .both
            )
            .makeNodes(locale: locale)
    }
}

public struct CheckboxField: Markup {
    public let id: String
    public let name: String
    public let label: String
    public let checked: Bool
    public let disabled: Bool
    private let theme: ComponentTheme?

    public init(
        id: String,
        name: String,
        label: String,
        checked: Bool = false,
        disabled: Bool = false,
        theme: ComponentTheme? = nil
    ) {
        self.id = id
        self.name = name
        self.label = label
        self.checked = checked
        self.disabled = disabled
        self.theme = theme
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current
        var inputAttributes: [HTMLAttribute] = [
            HTMLAttribute("id", id),
            HTMLAttribute("name", name),
            HTMLAttribute("type", "checkbox"),
        ]
        if checked {
            inputAttributes.append(HTMLAttribute("checked"))
        }
        if disabled {
            inputAttributes.append(HTMLAttribute("disabled"))
        }

        return Node("label", attributes: [HTMLAttribute("for", id)]) {
            Node("input", attributes: inputAttributes) { }
                .accentColor(.keyword("currentColor"))
                .font(color: activeTheme.accentColor)
            Text(label)
        }
        .display(.keyword("inline-flex"))
        .alignItems(.keyword("center"))
        .columnGap(activeTheme.spacing(2))
        .font(size: .sm, color: activeTheme.foregroundColor)
        .makeNodes(locale: locale)
    }
}

public struct SwitchField: Markup {
    public let id: String
    public let name: String
    public let label: String
    public let on: Bool
    public let disabled: Bool
    private let theme: ComponentTheme?

    public init(
        id: String,
        name: String,
        label: String,
        on: Bool = false,
        disabled: Bool = false,
        theme: ComponentTheme? = nil
    ) {
        self.id = id
        self.name = name
        self.label = label
        self.on = on
        self.disabled = disabled
        self.theme = theme
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current
        var inputAttributes: [HTMLAttribute] = [
            HTMLAttribute("id", id),
            HTMLAttribute("name", name),
            HTMLAttribute("type", "checkbox"),
            HTMLAttribute("role", "switch"),
        ]
        if on {
            inputAttributes.append(HTMLAttribute("checked"))
        }
        if disabled {
            inputAttributes.append(HTMLAttribute("disabled"))
        }

        return Node("label", attributes: [HTMLAttribute("for", id)]) {
            Node("input", attributes: inputAttributes) { }
                .accentColor(.keyword("currentColor"))
                .font(color: activeTheme.accentColor)
            Text(label)
        }
        .display(.keyword("inline-flex"))
        .alignItems(.keyword("center"))
        .columnGap(activeTheme.spacing(2))
        .font(size: .sm, color: activeTheme.foregroundColor)
        .makeNodes(locale: locale)
    }
}

public struct SelectFieldOption: Sendable, Equatable {
    public let value: String
    public let label: String
    public let selected: Bool

    public init(value: String, label: String, selected: Bool = false) {
        self.value = value
        self.label = label
        self.selected = selected
    }
}

public struct SelectField: Markup {
    public let label: String
    public let name: String
    public let options: [SelectFieldOption]
    public let id: String?
    public let required: Bool
    private let theme: ComponentTheme?

    public init(
        label: String,
        name: String,
        options: [SelectFieldOption],
        id: String? = nil,
        required: Bool = false,
        theme: ComponentTheme? = nil
    ) {
        self.label = label
        self.name = name
        self.options = options
        self.id = id
        self.required = required
        self.theme = theme
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current
        let identifier = id ?? name

        var selectAttributes: [HTMLAttribute] = [
            HTMLAttribute("id", identifier),
            HTMLAttribute("name", name),
        ]
        if required {
            selectAttributes.append(HTMLAttribute("required"))
        }

        return Stack {
            Label(for: identifier, label)
                .font(size: .sm, weight: .semibold, color: activeTheme.foregroundColor)

            Select(attributes: selectAttributes) {
                for option in options {
                    Option(
                        attributes: option.selected
                            ? [HTMLAttribute("value", option.value), HTMLAttribute("selected")]
                            : [HTMLAttribute("value", option.value)]
                    ) {
                        Text(option.label)
                    }
                }
            }
            .padding(activeTheme.spacing(2))
            .border(of: 1, color: activeTheme.borderColor)
            .background(color: activeTheme.surfaceColor)
            .font(color: activeTheme.foregroundColor)
            .borderRadius(activeTheme.cornerRadius)
        }
        .display(.keyword("grid"))
        .rowGap(activeTheme.spacing(1))
        .makeNodes(locale: locale)
    }
}

public struct DataTable: Markup {
    public struct Row: Sendable, Equatable {
        public let cells: [String]

        public init(_ cells: [String]) {
            self.cells = cells
        }
    }

    public let columns: [String]
    public let rows: [Row]
    public let caption: String?
    private let theme: ComponentTheme?

    public init(columns: [String], rows: [Row], caption: String? = nil, theme: ComponentTheme? = nil) {
        self.columns = columns
        self.rows = rows
        self.caption = caption
        self.theme = theme
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        let activeTheme = theme ?? ComponentThemeStore.current

        return Node("div") {
            Table {
                if let caption, !caption.isEmpty {
                    Node("caption") {
                        Text(caption)
                    }
                    .font(size: .sm, color: activeTheme.mutedColor)
                }

                TableHead {
                    TableRow {
                        for column in columns {
                            TableHeader {
                                Text(column)
                            }
                            .font(size: .sm, weight: .semibold, color: activeTheme.foregroundColor)
                            .padding(activeTheme.spacing(2))
                            .css(.textAlign, .keyword("left"))
                        }
                    }
                }

                TableBody {
                    for row in rows {
                        TableRow {
                            for cell in row.cells {
                                TableCell {
                                    Text(cell)
                                }
                                .font(size: .sm, color: activeTheme.foregroundColor)
                                .padding(activeTheme.spacing(2))
                            }
                        }
                        .css(.borderTop, .raw("1px solid"))
                        .modifier("border-\(activeTheme.borderColor.classFragment)")
                    }
                }
            }
            .width(.length(100, .percent))
            .css(.borderCollapse, .keyword("collapse"))
            .background(color: activeTheme.surfaceColor)
            .border(of: 1, color: activeTheme.borderColor)
            .borderRadius(activeTheme.cornerRadius)
        }
        .overflowX(.keyword("auto"))
        .makeNodes(locale: locale)
    }
}
