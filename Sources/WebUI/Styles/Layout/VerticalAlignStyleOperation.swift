import Foundation

/// Style operation for vertical-align styling
///
/// Provides a unified implementation for vertical-align styling that can be used across
/// Element methods and the Declarative DSL functions.
public struct VerticalAlignStyleOperation: StyleOperation, @unchecked Sendable {
    /// Parameters for vertical-align styling
    public struct Parameters {
        /// The vertical-align type
        public let type: VerticalAlignType?

        /// Creates parameters for vertical-align styling
        ///
        /// - Parameter type: The vertical-align type
        public init(type: VerticalAlignType? = nil) {
            self.type = type
        }

        /// Creates parameters from a StyleParameters container
        ///
        /// - Parameter params: The style parameters container
        /// - Returns: VerticalAlignStyleOperation.Parameters
        public static func from(_ params: StyleParameters) -> Parameters {
            Parameters(type: params.get("type"))
        }
    }

    /// Applies the vertical-align style and returns the appropriate stylesheet classes
    ///
    /// - Parameter params: The parameters for vertical-align styling
    /// - Returns: An array of stylesheet class names to be applied to elements
    public func applyClasses(params: Parameters) -> [String] {
        guard let type = params.type else { return [] }
        return ["align-\(type.rawValue)"]
    }

    /// Shared instance for use across the framework
    public static let shared = VerticalAlignStyleOperation()

    /// Private initializer to enforce singleton usage
    private init() {}
}

/// Vertical align types
public enum VerticalAlignType: String {
    /// Align to baseline
    case baseline
    /// Align to top
    case top
    /// Align to middle
    case middle
    /// Align to bottom
    case bottom
    /// Align to text-top
    case textTop = "text-top"
    /// Align to text-bottom
    case textBottom = "text-bottom"
    /// Align to sub
    case sub
    /// Align to super
    case `super`
}

// Extension for Markup to provide vertical-align styling
extension Markup {
    /// Applies vertical-align styling to the element.
    ///
    /// - Parameter type: The vertical-align type
    /// - Returns: A new element with updated vertical-align classes.
    public func verticalAlign(
        _ type: VerticalAlignType
    ) -> some Markup {
        let params = VerticalAlignStyleOperation.Parameters(type: type)

        return VerticalAlignStyleOperation.shared.applyTo(
            self,
            params: params
        )
    }
}

// Extension for ResponsiveBuilder to provide vertical-align styling
extension ResponsiveBuilder {
    /// Applies vertical-align styling in a responsive context.
    ///
    /// - Parameter type: The vertical-align type
    /// - Returns: The builder for method chaining.
    @discardableResult
    public func verticalAlign(_ type: VerticalAlignType) -> ResponsiveBuilder {
        let params = VerticalAlignStyleOperation.Parameters(type: type)

        return VerticalAlignStyleOperation.shared.applyToBuilder(
            self, params: params)
    }
}

// Global function for Declarative DSL
/// Applies vertical-align styling in the responsive context.
///
/// - Parameter type: The vertical-align type
/// - Returns: A responsive modification for vertical-align.
public func verticalAlign(_ type: VerticalAlignType) -> ResponsiveModification {
    let params = VerticalAlignStyleOperation.Parameters(type: type)

    return VerticalAlignStyleOperation.shared.asModification(params: params)
}
