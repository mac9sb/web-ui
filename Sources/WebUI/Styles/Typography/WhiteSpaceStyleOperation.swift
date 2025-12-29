import Foundation

/// Style operation for white-space styling
///
/// Provides a unified implementation for white-space styling that can be used across
/// Element methods and the Declarative DSL functions.
public struct WhiteSpaceStyleOperation: StyleOperation, @unchecked Sendable {
    /// Parameters for white-space styling
    public struct Parameters {
        /// The white-space type
        public let type: WhiteSpaceType?

        /// Creates parameters for white-space styling
        ///
        /// - Parameter type: The white-space type
        public init(type: WhiteSpaceType? = nil) {
            self.type = type
        }

        /// Creates parameters from a StyleParameters container
        ///
        /// - Parameter params: The style parameters container
        /// - Returns: WhiteSpaceStyleOperation.Parameters
        public static func from(_ params: StyleParameters) -> Parameters {
            Parameters(type: params.get("type"))
        }
    }

    /// Applies the white-space style and returns the appropriate stylesheet classes
    ///
    /// - Parameter params: The parameters for white-space styling
    /// - Returns: An array of stylesheet class names to be applied to elements
    public func applyClasses(params: Parameters) -> [String] {
        guard let type = params.type else { return [] }
        return [type.rawValue]
    }

    /// Shared instance for use across the framework
    public static let shared = WhiteSpaceStyleOperation()

    /// Private initializer to enforce singleton usage
    private init() {}
}

/// White-space types
public enum WhiteSpaceType: String {
    /// Normal white-space handling
    case normal = "whitespace-normal"
    /// Prevent text wrapping
    case nowrap = "whitespace-nowrap"
    /// Preserve white-space
    case pre = "whitespace-pre"
    /// Preserve white-space and allow wrapping
    case preWrap = "whitespace-pre-wrap"
    /// Preserve line breaks
    case preLine = "whitespace-pre-line"
    /// Break words if needed
    case breakSpaces = "whitespace-break-spaces"
}

// Extension for Markup to provide white-space styling
extension Markup {
    /// Applies white-space styling to the element.
    ///
    /// - Parameters:
    ///   - type: The white-space type
    ///   - modifiers: Zero or more modifiers (e.g., `.hover`, `.md`) to scope the styles.
    /// - Returns: A new element with updated white-space classes.
    public func whiteSpace(
        _ type: WhiteSpaceType,
        on modifiers: Modifier...
    ) -> some Markup {
        let params = WhiteSpaceStyleOperation.Parameters(type: type)

        return WhiteSpaceStyleOperation.shared.applyTo(
            self,
            params: params,
            modifiers: Array(modifiers)
        )
    }
}

// Extension for ResponsiveBuilder to provide white-space styling
extension ResponsiveBuilder {
    /// Applies white-space styling in a responsive context.
    ///
    /// - Parameter type: The white-space type
    /// - Returns: The builder for method chaining.
    @discardableResult
    public func whiteSpace(_ type: WhiteSpaceType) -> ResponsiveBuilder {
        let params = WhiteSpaceStyleOperation.Parameters(type: type)

        return WhiteSpaceStyleOperation.shared.applyToBuilder(
            self, params: params)
    }
}

// Global function for Declarative DSL
/// Applies white-space styling in the responsive context.
///
/// - Parameter type: The white-space type
/// - Returns: A responsive modification for white-space.
public func whiteSpace(_ type: WhiteSpaceType) -> ResponsiveModification {
    let params = WhiteSpaceStyleOperation.Parameters(type: type)

    return WhiteSpaceStyleOperation.shared.asModification(params: params)
}
