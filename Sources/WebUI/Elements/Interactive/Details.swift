/// Generates an HTML details element for creating a disclosure widget.
///
/// Creates a disclosure widget where content can be shown or hidden. When open, the widget
/// displays the summary and the additional content. Details elements are commonly used for
/// FAQs, navigation menus, and collapsible sections.
///
/// ## Example
/// ```swift
/// Details(open: false) {
///   Summary { Text("Click to expand") }
///   Text("This content is hidden by default")
/// }
/// ```
public struct Details: Element {
    private let id: String?
    private let classes: [String]?
    private let role: AriaRole?
    private let label: String?
    private let data: [String: String]?
    private let open: Bool
    private let contentBuilder: MarkupContentBuilder

    /// Creates a new HTML details element for a disclosure widget.
    ///
    /// - Parameters:
    ///   - id: Unique identifier for the HTML element.
    ///   - classes: An array of stylesheet classnames for styling.
    ///   - role: ARIA role of the element for accessibility.
    ///   - label: ARIA label to describe the element's purpose.
    ///   - data: Dictionary of `data-*` attributes for storing custom data.
    ///   - open: Whether the details should be open by default.
    ///   - content: Closure providing the details content (should include a Summary element).
    ///
    /// ## Example
    /// ```swift
    /// Details(id: "menu", open: false) {
    ///   Summary { Text("Menu") }
    ///   Navigation {
    ///     Link(to: "/home") { "Home" }
    ///     Link(to: "/about") { "About" }
    ///   }
    /// }
    /// ```
    public init(
        id: String? = nil,
        classes: [String]? = nil,
        role: AriaRole? = nil,
        label: String? = nil,
        data: [String: String]? = nil,
        open: Bool = false,
        @MarkupBuilder content: @escaping MarkupContentBuilder = { [] }
    ) {
        self.id = id
        self.classes = classes
        self.role = role
        self.label = label
        self.data = data
        self.open = open
        self.contentBuilder = content
    }

    public var body: some Markup {
        MarkupString(content: buildMarkupTag())
    }

    private func buildMarkupTag() -> String {
        var attributes = AttributeBuilder.buildAttributes(
            id: id,
            classes: classes,
            role: role,
            label: label,
            data: data
        )

        // Add open attribute if needed
        if open {
            attributes.append("open")
        }

        let content = contentBuilder().map { $0.render() }.joined()

        return AttributeBuilder.buildMarkupTag(
            "details",
            attributes: attributes,
            content: content,
            escapeContent: false  // Content is already rendered markup
        )
    }
}
