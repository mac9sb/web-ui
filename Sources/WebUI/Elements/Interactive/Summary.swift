/// Generates an HTML summary element for use within a details element.
///
/// Defines a summary, caption, or legend for a details element's disclosure box.
/// When clicked, it toggles the visibility of the details element's content. The summary
/// is always visible and serves as the clickable control for the disclosure widget.
///
/// ## Example
/// ```swift
/// Details {
///   Summary { Text("Show more information") }
///   Text("Hidden content goes here")
/// }
/// ```
public struct Summary: Element {
    private let id: String?
    private let classes: [String]?
    private let role: AriaRole?
    private let label: String?
    private let data: [String: String]?
    private let contentBuilder: MarkupContentBuilder

    /// Creates a new HTML summary element for a details disclosure control.
    ///
    /// - Parameters:
    ///   - id: Unique identifier for the HTML element.
    ///   - classes: An array of stylesheet classnames for styling.
    ///   - role: ARIA role of the element for accessibility.
    ///   - label: ARIA label to describe the element's purpose.
    ///   - data: Dictionary of `data-*` attributes for storing custom data.
    ///   - content: Closure providing the summary content (typically text or icons).
    ///
    /// ## Example
    /// ```swift
    /// Summary(classes: ["menu-toggle"]) {
    ///   Stack {
    ///     Text("☰")
    ///     Text("Menu")
    ///   }
    /// }
    /// ```
    public init(
        id: String? = nil,
        classes: [String]? = nil,
        role: AriaRole? = nil,
        label: String? = nil,
        data: [String: String]? = nil,
        @MarkupBuilder content: @escaping MarkupContentBuilder = { [] }
    ) {
        self.id = id
        self.classes = classes
        self.role = role
        self.label = label
        self.data = data
        self.contentBuilder = content
    }

    public var body: some Markup {
        MarkupString(content: buildMarkupTag())
    }

    private func buildMarkupTag() -> String {
        let attributes = AttributeBuilder.buildAttributes(
            id: id,
            classes: classes,
            role: role,
            label: label,
            data: data
        )
        let content = contentBuilder().map { $0.render() }.joined()

        return AttributeBuilder.buildMarkupTag(
            "summary",
            attributes: attributes,
            content: content,
            escapeContent: false  // Content is already rendered markup
        )
    }
}
