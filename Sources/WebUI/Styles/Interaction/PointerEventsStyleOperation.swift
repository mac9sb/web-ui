import Foundation

/// Style operation for pointer-events styling
///
/// Controls whether an element responds to pointer events
public struct PointerEventsStyleOperation: StyleOperation, @unchecked Sendable {
    /// Parameters for pointer-events styling
    public struct Parameters {
        /// The pointer-events value
        public let value: PointerEventsValue

        /// Creates parameters for pointer-events styling
        ///
        /// - Parameter value: The pointer-events value
        public init(value: PointerEventsValue) {
            self.value = value
        }

        /// Creates parameters from a StyleParameters container
        ///
        /// - Parameter params: The style parameters container
        /// - Returns: PointerEventsStyleOperation.Parameters
        public static func from(_ params: StyleParameters) -> Parameters {
            guard let value: PointerEventsValue = params.get("value") else {
                return Parameters(value: .auto)
            }
            return Parameters(value: value)
        }
    }

    /// Applies the pointer-events style and returns the appropriate stylesheet classes
    ///
    /// - Parameter params: The parameters for pointer-events styling
    /// - Returns: An array of stylesheet class names to be applied to elements
    public func applyClasses(params: Parameters) -> [String] {
        [params.value.rawValue]
    }

    /// Shared instance for use across the framework
    public static let shared = PointerEventsStyleOperation()

    /// Private initializer to enforce singleton usage
    private init() {}
}

/// Defines pointer-events values
public enum PointerEventsValue: String {
    /// Element does not respond to pointer events
    case none = "pointer-events-none"
    /// Element responds to pointer events (default)
    case auto = "pointer-events-auto"
}

// Extension for Markup to provide pointer-events styling
extension Markup {
    /// Sets the pointer-events property with optional modifiers.
    ///
    /// - Parameter value: The pointer-events value to apply.
    /// - Returns: Markup with updated pointer-events classes.
    ///
    /// ## Example
    /// ```swift
    /// // Make element not respond to pointer events
    /// Stack {}.pointerEvents(.none)
    /// ```
    public func pointerEvents(
        _ value: PointerEventsValue
    ) -> some Markup {
        let params = PointerEventsStyleOperation.Parameters(value: value)

        return PointerEventsStyleOperation.shared.applyTo(
            self,
            params: params
        )
    }
}

// Extension for ResponsiveBuilder to provide pointer-events styling
extension ResponsiveBuilder {
    /// Sets the pointer-events property in a responsive context.
    ///
    /// - Parameter value: The pointer-events value.
    /// - Returns: The builder for method chaining.
    @discardableResult
    public func pointerEvents(_ value: PointerEventsValue) -> ResponsiveBuilder {
        let params = PointerEventsStyleOperation.Parameters(value: value)
        return PointerEventsStyleOperation.shared.applyToBuilder(self, params: params)
    }
}

// Global function for Declarative DSL
/// Sets the pointer-events property in the responsive context.
///
/// - Parameter value: The pointer-events value.
/// - Returns: A responsive modification for pointer-events.
public func pointerEvents(_ value: PointerEventsValue) -> ResponsiveModification {
    let params = PointerEventsStyleOperation.Parameters(value: value)
    return PointerEventsStyleOperation.shared.asModification(params: params)
}
