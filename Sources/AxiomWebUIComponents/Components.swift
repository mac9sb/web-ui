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
