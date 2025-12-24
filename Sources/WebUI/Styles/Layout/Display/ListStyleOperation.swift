import Foundation

/// Style operation for list-style styling
///
/// Provides a unified implementation for list-style that can be used to control
/// list markers, including hiding the disclosure marker on <summary> elements.
public struct ListStyleOperation: StyleOperation, @unchecked Sendable {
    /// Parameters for list-style styling
    public struct Parameters {
        /// The list style type
        public let type: ListStyleType

        /// Creates parameters for list-style styling
        ///
        /// - Parameter type: The list style type
        public init(type: ListStyleType) {
            self.type = type
        }

        /// Creates parameters from a StyleParameters container
        ///
        /// - Parameter params: The style parameters container
        /// - Returns: ListStyleOperation.Parameters
        public static func from(_ params: StyleParameters) -> Parameters {
            Parameters(
                type: params.get("type")!
            )
        }
    }

    /// Applies the list-style and returns the appropriate stylesheet classes
    ///
    /// - Parameter params: The parameters for list-style styling
    /// - Returns: An array of stylesheet class names to be applied to elements
    public func applyClasses(params: Parameters) -> [String] {
        ["list-\(params.type.rawValue)"]
    }

    /// Shared instance for use across the framework
    public static let shared = ListStyleOperation()

    /// Private initializer to enforce singleton usage
    private init() {}
}

// Extension for Markup to provide list-style styling
extension Markup {
    /// Sets the CSS list-style property with optional modifiers.
    ///
    /// Commonly used to hide disclosure markers on <summary> elements or customize list bullets.
    ///
    /// - Parameters:
    ///   - type: The list style type to apply.
    ///   - modifiers: Zero or more modifiers (e.g., `.hover`, `.md`) to scope the styles.
    /// - Returns: Markup with updated list-style classes.
    ///
    /// ## Example
    /// ```swift
    /// // Hide disclosure marker on summary
    /// Summary {
    ///     Text("Menu")
    /// }
    /// .listStyle(.none)
    ///
    /// // Custom list style on hover
    /// Element(tag: "ul")
    ///     .listStyle(.disc, on: .hover)
    /// ```
    public func listStyle(
        _ type: ListStyleType,
        on modifiers: Modifier...
    ) -> some Markup {
        let params = ListStyleOperation.Parameters(type: type)

        return ListStyleOperation.shared.applyTo(
            self,
            params: params,
            modifiers: Array(modifiers)
        )
    }
}

// Extension for ResponsiveBuilder to provide list-style styling
extension ResponsiveBuilder {
    /// Sets the CSS list-style property in a responsive context.
    ///
    /// - Parameter type: The list style type to apply.
    /// - Returns: The builder for method chaining.
    @discardableResult
    public func listStyle(_ type: ListStyleType) -> ResponsiveBuilder {
        let params = ListStyleOperation.Parameters(type: type)

        return ListStyleOperation.shared.applyToBuilder(self, params: params)
    }
}

// Global function for Declarative DSL
/// Sets the CSS list-style property in the responsive context.
///
/// - Parameter type: The list style type to apply.
/// - Returns: A responsive modification for list-style.
public func listStyle(_ type: ListStyleType) -> ResponsiveModification {
    let params = ListStyleOperation.Parameters(type: type)

    return ListStyleOperation.shared.asModification(params: params)
}
