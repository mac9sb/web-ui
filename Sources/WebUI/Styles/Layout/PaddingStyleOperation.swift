import Foundation

/// Style operation for padding styling
///
/// Provides a unified implementation for padding styling that can be used across
/// Element methods and the Declaritive DSL functions.
public struct PaddingStyleOperation: StyleOperation, @unchecked Sendable {
    /// Parameters for padding styling
    public struct Parameters {
        /// The padding value (Int for scale, String for percentages/arbitrary values)
        public let length: Int?
        public let percentage: String?

        /// The edges to apply the padding to
        public let edges: [Edge]

        /// Creates parameters for padding styling with scale value
        ///
        /// - Parameters:
        ///   - length: The padding value
        ///   - edges: The edges to apply the padding to
        public init(
            length: Int? = 4,
            edges: [Edge] = [.all]
        ) {
            self.length = length
            self.percentage = nil
            self.edges = edges.isEmpty ? [.all] : edges
        }

        /// Creates parameters for padding styling with percentage/arbitrary value
        ///
        /// - Parameters:
        ///   - percentage: The padding value as percentage or arbitrary CSS value
        ///   - edges: The edges to apply the padding to
        public init(
            percentage: String,
            edges: [Edge] = [.all]
        ) {
            self.length = nil
            self.percentage = percentage
            self.edges = edges.isEmpty ? [.all] : edges
        }

        /// Creates parameters from a StyleParameters container
        ///
        /// - Parameter params: The style parameters container
        /// - Returns: PaddingStyleOperation.Parameters
        public static func from(_ params: StyleParameters) -> Parameters {
            Parameters(
                length: params.get("length"),
                edges: params.get("edges", default: [.all])
            )
        }
    }

    /// Applies the padding style and returns the appropriate stylesheet classes
    ///
    /// - Parameter params: The parameters for padding styling
    /// - Returns: An array of stylesheet class names to be applied
    public func applyClasses(params: Parameters) -> [String] {
        var classes: [String] = []

        for edge in params.edges {
            let prefix = edge == .all ? "p" : "p\(edge.rawValue)"

            if let percentage = params.percentage {
                // Use Tailwind arbitrary value syntax for percentages
                classes.append("\(prefix)-[\(percentage)]")
            } else if let length = params.length {
                classes.append("\(prefix)-\(length)")
            }
        }

        return classes
    }

    /// Shared instance for use across the framework
    public static let shared = PaddingStyleOperation()

    /// Private initializer to enforce singleton usage
    private init() {}
}

// Extension for HTML to provide padding styling
extension Markup {
    /// Applies padding styling to the element with one or more edges.
    ///
    /// - Parameters:
    ///   - length: The spacing value in `0.25rem` increments.
    ///   - edges: One or more edges to apply the padding to. Defaults to `.all`.
    ///   - modifiers: Zero or more modifiers (e.g., `.hover`, `.md`) to scope the styles.
    /// - Returns: A new element with updated padding classes.
    public func padding(
        of length: Int? = 4,
        at edges: Edge...,
        on modifiers: Modifier...
    ) -> some Markup {
        let params = PaddingStyleOperation.Parameters(
            length: length,
            edges: edges
        )

        return PaddingStyleOperation.shared.applyTo(
            self,
            params: params,
            modifiers: modifiers
        )
    }

    /// Applies padding styling with percentage or arbitrary value.
    ///
    /// - Parameters:
    ///   - percentage: The padding value as percentage (e.g., "50%", "10px") or arbitrary CSS value.
    ///   - edges: One or more edges to apply the padding to. Defaults to `.all`.
    ///   - modifiers: Zero or more modifiers (e.g., `.hover`, `.md`) to scope the styles.
    /// - Returns: A new element with updated padding classes.
    public func padding(
        of percentage: String,
        at edges: Edge...,
        on modifiers: Modifier...
    ) -> some Markup {
        let params = PaddingStyleOperation.Parameters(
            percentage: percentage,
            edges: edges
        )

        return PaddingStyleOperation.shared.applyTo(
            self,
            params: params,
            modifiers: modifiers
        )
    }
}

// Global function for Declaritive DSL
/// Applies padding styling in the responsive context with Declaritive syntax.
///
/// - Parameters:
///   - length: The padding value.
///   - edges: The edges to apply padding to.
/// - Returns: A responsive modification for padding.
public func padding(
    of length: Int? = 4,
    at edges: Edge...,
    on modifiers: Modifier...
) -> ResponsiveModification {
    let params = PaddingStyleOperation.Parameters(
        length: length,
        edges: edges
    )

    return PaddingStyleOperation.shared.asModification(params: params)
}
