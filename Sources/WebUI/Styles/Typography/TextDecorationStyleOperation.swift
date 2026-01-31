import Foundation

/// Style operation for text decoration styling
///
/// Provides a unified implementation for text decoration styling that can be used across
/// Element methods and the Declarative DSL functions.
public struct TextDecorationStyleOperation: StyleOperation, @unchecked Sendable {
    /// Parameters for text decoration styling
    public struct Parameters {
        /// The text decoration type
        public let type: TextDecorationType?

        /// Creates parameters for text decoration styling
        ///
        /// - Parameter type: The text decoration type
        public init(type: TextDecorationType? = nil) {
            self.type = type
        }

        /// Creates parameters from a StyleParameters container
        ///
        /// - Parameter params: The style parameters container
        /// - Returns: TextDecorationStyleOperation.Parameters
        public static func from(_ params: StyleParameters) -> Parameters {
            Parameters(type: params.get("type"))
        }
    }

    /// Applies the text decoration style and returns the appropriate stylesheet classes
    ///
    /// - Parameter params: The parameters for text decoration styling
    /// - Returns: An array of stylesheet class names to be applied to elements
    public func applyClasses(params: Parameters) -> [String] {
        guard let type = params.type else { return [] }
        return [type.rawValue]
    }

    /// Shared instance for use across the framework
    public static let shared = TextDecorationStyleOperation()

    /// Private initializer to enforce singleton usage
    private init() {}
}

/// Text decoration types
public enum TextDecorationType: String {
    /// No text decoration
    case none = "no-underline"
    /// Underline text decoration
    case underline
    /// Line-through text decoration
    case lineThrough = "line-through"
}

// Extension for Markup to provide text decoration styling
extension Markup {
    /// Applies text decoration styling to the element.
    ///
    /// - Parameter type: The text decoration type
    /// - Returns: A new element with updated text decoration classes.
    public func textDecoration(
        _ type: TextDecorationType
    ) -> some Markup {
        let params = TextDecorationStyleOperation.Parameters(type: type)

        return TextDecorationStyleOperation.shared.applyTo(
            self,
            params: params
        )
    }
}

// Extension for ResponsiveBuilder to provide text decoration styling
extension ResponsiveBuilder {
    /// Applies text decoration styling in a responsive context.
    ///
    /// - Parameter type: The text decoration type
    /// - Returns: The builder for method chaining.
    @discardableResult
    public func textDecoration(_ type: TextDecorationType) -> ResponsiveBuilder {
        let params = TextDecorationStyleOperation.Parameters(type: type)

        return TextDecorationStyleOperation.shared.applyToBuilder(
            self, params: params)
    }
}

// Global function for Declarative DSL
/// Applies text decoration styling in the responsive context.
///
/// - Parameter type: The text decoration type
/// - Returns: A responsive modification for text decoration.
public func textDecoration(_ type: TextDecorationType) -> ResponsiveModification {
    let params = TextDecorationStyleOperation.Parameters(type: type)

    return TextDecorationStyleOperation.shared.asModification(params: params)
}
