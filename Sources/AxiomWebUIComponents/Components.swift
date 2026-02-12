import AxiomWebUI
import AxiomWebStyle
import AxiomWebI18n

public struct Card<Content: Markup>: Markup {
    private let content: Content

    public init(@MarkupBuilder content: () -> Content) {
        self.content = content()
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        Div {
            AnyMarkup(content)
        }
        .background(color: .white)
        .padding(of: .four)
        .shadow("xl2")
        .makeNodes(locale: locale)
    }
}

public struct AccordionItem<Content: Markup>: Markup {
    public let title: String
    private let content: Content

    public init(_ title: String, @MarkupBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        Details {
            Summary(title)
            Div {
                AnyMarkup(content)
            }
            .margins(of: .two, at: .top)
        }
        .makeNodes(locale: locale)
    }
}

public struct Popover<Content: Markup>: Markup {
    public let id: String
    public let triggerLabel: String
    private let content: Content

    public init(id: String, triggerLabel: String, @MarkupBuilder content: () -> Content) {
        self.id = id
        self.triggerLabel = triggerLabel
        self.content = content()
    }

    public func makeNodes(locale: LocaleCode) -> [HTMLNode] {
        [
            .element(
                HTMLElementNode(
                    tag: "button",
                    attributes: [
                        HTMLAttribute("type", "button"),
                        HTMLAttribute("popovertarget", id),
                    ],
                    children: [.text(triggerLabel)]
                )
            ),
            .element(
                HTMLElementNode(
                    tag: "div",
                    attributes: [
                        HTMLAttribute("id", id),
                        HTMLAttribute("popover"),
                        HTMLAttribute("class", "popover-surface")
                    ],
                    children: AnyMarkup(content).makeNodes(locale: locale)
                )
            )
        ]
    }
}
