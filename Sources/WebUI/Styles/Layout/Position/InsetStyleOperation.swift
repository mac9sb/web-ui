import Foundation

/// Style operation for inset positioning
///
/// Provides support for the `inset` property which sets all four position values at once
public struct InsetStyleOperation: StyleOperation, @unchecked Sendable {
    /// Parameters for inset styling
    public struct Parameters {
        /// The inset value (in pixels or special values)
        public let value: InsetValue

        /// Creates parameters for inset styling
        ///
        /// - Parameter value: The inset value
        public init(value: InsetValue) {
            self.value = value
        }

        /// Creates parameters from a StyleParameters container
        ///
        /// - Parameter params: The style parameters container
        /// - Returns: InsetStyleOperation.Parameters
        public static func from(_ params: StyleParameters) -> Parameters {
            guard let value: InsetValue = params.get("value") else {
                return Parameters(value: .zero)
            }
            return Parameters(value: value)
        }
    }

    /// Applies the inset style and returns the appropriate stylesheet classes
    ///
    /// - Parameter params: The parameters for inset styling
    /// - Returns: An array of stylesheet class names to be applied to elements
    public func applyClasses(params: Parameters) -> [String] {
        [params.value.rawValue]
    }

    /// Shared instance for use across the framework
    public static let shared = InsetStyleOperation()

    /// Private initializer to enforce singleton usage
    private init() {}
}

/// Defines inset values for positioning
public enum InsetValue: String {
    /// 0px inset on all sides
    case zero = "inset-0"
    /// 1px inset on all sides
    case px = "inset-px"
    /// Auto inset
    case auto = "inset-auto"
    /// Full inset
    case full = "inset-full"
}

// Extension for Markup to provide inset styling
extension Markup {
    /// Sets the inset property for positioning with optional modifiers.
    ///
    /// - Parameter value: The inset value to apply.
    /// - Returns: Markup with updated inset classes.
    ///
    /// ## Example
    /// ```swift
    /// // Apply 1px inset on all sides
    /// Stack {}.inset(.px)
    /// ```
    public func inset(
        _ value: InsetValue
    ) -> some Markup {
        let params = InsetStyleOperation.Parameters(value: value)

        return InsetStyleOperation.shared.applyTo(
            self,
            params: params
        )
    }
}

// Extension for ResponsiveBuilder to provide inset styling
extension ResponsiveBuilder {
    /// Sets the inset property in a responsive context.
    ///
    /// - Parameter value: The inset value.
    /// - Returns: The builder for method chaining.
    @discardableResult
    public func inset(_ value: InsetValue) -> ResponsiveBuilder {
        let params = InsetStyleOperation.Parameters(value: value)
        return InsetStyleOperation.shared.applyToBuilder(self, params: params)
    }
}

// Global function for Declarative DSL
/// Sets the inset property in the responsive context.
///
/// - Parameter value: The inset value.
/// - Returns: A responsive modification for inset positioning.
public func inset(_ value: InsetValue) -> ResponsiveModification {
    let params = InsetStyleOperation.Parameters(value: value)
    return InsetStyleOperation.shared.asModification(params: params)
}
