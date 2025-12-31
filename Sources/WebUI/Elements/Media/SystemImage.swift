import Foundation

/// Creates HTML elements for system images/icons using SVG or icon fonts.
///
/// Represents system icons that can be used in buttons, labels, and other UI elements.
///
/// ## Usage
/// ```swift
/// SystemImage("checkmark")
/// SystemImage("arrow.down", classes: ["download-icon"])
/// SystemImage("settings", label: "Open settings")
/// ```
public struct SystemImage: Element {
    private let name: String
    private let id: String?
    private let classes: [String]?
    private let role: AriaRole?
    private let label: String?
    private let data: [String: String]?

    /// Creates a new system image element using a string identifier.
    ///
    /// - Parameters:
    ///   - name: The name/identifier of the icon.
    ///   - id: Unique identifier for the HTML element.
    ///   - classes: An array of CSS classnames for styling the icon.
    ///   - role: ARIA role of the element for accessibility.
    ///   - label: ARIA label to describe the icon for accessibility.
    ///   - data: Dictionary of `data-*` attributes for storing custom data.
    ///
    /// ## Example
    /// ```swift
    /// SystemImage("checkmark")
    /// SystemImage("custom-icon", classes: ["my-style"])
    /// ```
    public init(
        _ name: String,
        id: String? = nil,
        classes: [String]? = nil,
        role: AriaRole? = nil,
        label: String? = nil,
        data: [String: String]? = nil
    ) {
        self.name = name
        self.id = id
        self.classes = classes
        self.role = role
        self.label = label
        self.data = data
    }

    public var body: some Markup {
        MarkupString(content: buildMarkupTag())
    }

    private func buildMarkupTag() -> String {
        var allClasses: [String] = []

        // Use traditional system icon classes
        allClasses.append("system-image")
        allClasses.append("icon-\(name.replacingOccurrences(of: ".", with: "-"))")

        // Add custom classes
        if let classes = classes {
            allClasses.append(contentsOf: classes)
        }

        let attributes = AttributeBuilder.buildAttributes(
            id: id,
            classes: allClasses,
            role: role,
            label: label ?? name,
            data: data
        )

        return AttributeBuilder.buildMarkupTag(
            "span", attributes: attributes, content: ""
        )
    }
}
