import Foundation

/// Provides common styling utilities for HTML elements
public enum ElementStyling {
    /// Applies stylesheet classes to HTML content
    ///
    /// - Parameters:
    ///   - content: The HTML content to apply classes to
    ///   - classes: The stylesheet classes to apply
    /// - Returns: Markup content with classes applied
    public static func applyClasses<T: Markup>(_ content: T, classes: [String])
        -> some Markup
    {
        // Collect classes for CSS generation
        ClassCollector.shared.addClasses(classes)
        return content.addingClasses(classes)
    }

    /// Combines base classes
    ///
    /// - Parameters:
    ///   - baseClasses: The base stylesheet classes
    /// - Returns: The stylesheet classes unchanged
    public static func combineClasses(
        _ baseClasses: [String]
    ) -> [String] {
        baseClasses
    }
}

/// Extension to provide styling helpers for HTML protocol
extension Markup {
    /// Adds stylesheet classes to an HTML element
    ///
    /// - Parameter classNames: The stylesheet class names to add
    /// - Returns: Markup with the classes applied
    public func addClass(_ classNames: String...) -> some Markup {
        addingClasses(classNames)
    }

    /// Adds stylesheet classes to an HTML element
    ///
    /// - Parameter classNames: The stylesheet class names to add
    /// - Returns: Markup with the classes applied
    public func addClasses(_ classNames: [String]) -> some Markup {
        addingClasses(classNames)
    }

    /// Applies a style to the element
    ///
    /// - Parameters:
    ///   - baseClasses: The base stylesheet classes to apply
    /// - Returns: Markup with the styled classes applied
    public func applyStyle(baseClasses: [String])
        -> some Markup
    {
        let classes = ElementStyling.combineClasses(baseClasses)
        return addingClasses(classes)
    }

    /// Conditionally applies a modifier based on a boolean condition
    ///
    /// This provides SwiftUI-style conditional modification syntax.
    ///
    /// - Parameters:
    ///   - condition: Boolean condition that determines whether to apply the modifier
    ///   - modifier: Closure that applies styling when condition is true
    /// - Returns: Markup with conditional styling applied
    ///
    /// ## Example
    /// ```swift
    /// Text("Hello, world!")
    ///     .if(isHighlighted) { $0.background(color: .yellow) }
    ///     .if(isLarge) { $0.font(size: .xl) }
    /// ```
    public func `if`<T: Markup>(_ condition: Bool, _ modifier: (Self) -> T) -> AnyMarkup {
        guard condition else {
            return AnyMarkup(self)
        }
        return AnyMarkup(modifier(self))
    }
}
