import Foundation

/// Represents different CSS filter effects
public enum FilterEffect: Sendable {
    /// Inverts the colors of the element (0-100)
    case invert(Int = 100)
    /// Adjusts the brightness (0-200, 100 is normal)
    case brightness(Int)
    /// Adjusts the contrast (0-200, 100 is normal)
    case contrast(Int)
    /// Applies a grayscale effect (0-100)
    case grayscale(Int = 100)
    /// Applies a sepia effect (0-100)
    case sepia(Int = 100)
    /// Applies a blur effect in pixels
    case blur(Int)
    /// Adjusts the saturation (0-200, 100 is normal)
    case saturate(Int)
    /// Rotates the hue (0-360 degrees)
    case hueRotate(Int)
    /// Removes all filters
    case none

    var className: String {
        switch self {
        case .invert(let value):
            return value == 100 ? "invert" : "invert-\(value)"
        case .brightness(let value):
            return "brightness-\(value)"
        case .contrast(let value):
            return "contrast-\(value)"
        case .grayscale(let value):
            return value == 100 ? "grayscale" : "grayscale-\(value)"
        case .sepia(let value):
            return value == 100 ? "sepia" : "sepia-\(value)"
        case .blur(let value):
            return "blur-\(value)"
        case .saturate(let value):
            return "saturate-\(value)"
        case .hueRotate(let value):
            return "hue-rotate-\(value)"
        case .none:
            return "filter-none"
        }
    }
}

/// Style operation for CSS filter effects
///
/// Provides a unified implementation for filter styling that can be used across
/// Element methods and the Declarative DSL functions.
public struct FilterStyleOperation: StyleOperation, @unchecked Sendable {
    /// Parameters for filter styling
    public struct Parameters {
        /// The filter effect to apply
        public let effect: FilterEffect

        /// Creates parameters for filter styling
        ///
        /// - Parameter effect: The filter effect to apply
        public init(effect: FilterEffect) {
            self.effect = effect
        }

        /// Creates parameters from a StyleParameters container
        ///
        /// - Parameter params: The style parameters container
        /// - Returns: FilterStyleOperation.Parameters
        public static func from(_ params: StyleParameters) -> Parameters {
            guard let effect: FilterEffect = params.get("effect") else {
                return Parameters(effect: .none)
            }
            return Parameters(effect: effect)
        }
    }

    /// Applies the filter style and returns the appropriate stylesheet classes
    ///
    /// - Parameter params: The parameters for filter styling
    /// - Returns: An array of stylesheet class names to be applied to elements
    public func applyClasses(params: Parameters) -> [String] {
        [params.effect.className]
    }

    /// Shared instance for use across the framework
    public static let shared = FilterStyleOperation()

    /// Private initializer to enforce singleton usage
    private init() {}
}

// Extension for Markup to provide filter styling
extension Markup {
    /// Applies a filter effect to the element.
    ///
    /// - Parameter effect: The filter effect to apply.
    /// - Returns: Markup with updated filter classes.
    ///
    /// ## Example
    /// ```swift
    /// Image(source: "/images/photo.jpg", description: "Photo")
    ///   .filter(.grayscale())
    ///   .filter(.invert(), on: .hover)
    /// ```
    public func filter(_ effect: FilterEffect) -> some Markup {
        let params = FilterStyleOperation.Parameters(effect: effect)
        return FilterStyleOperation.shared.applyTo(self, params: params)
    }

    /// Inverts the colors of the element.
    ///
    /// - Parameter amount: The inversion amount (0-100). Default is 100 (fully inverted).
    /// - Returns: Markup with invert filter applied.
    ///
    /// ## Example
    /// ```swift
    /// Icon()
    ///   .invert()  // Fully inverts colors
    ///   .invert(50)  // Partially inverts colors
    /// ```
    public func invert(_ amount: Int = 100) -> some Markup {
        filter(.invert(amount))
    }

    /// Adjusts the brightness of the element.
    ///
    /// - Parameter amount: The brightness amount (0-200, 100 is normal).
    /// - Returns: Markup with brightness filter applied.
    public func brightness(_ amount: Int) -> some Markup {
        filter(.brightness(amount))
    }

    /// Adjusts the contrast of the element.
    ///
    /// - Parameter amount: The contrast amount (0-200, 100 is normal).
    /// - Returns: Markup with contrast filter applied.
    public func contrast(_ amount: Int) -> some Markup {
        filter(.contrast(amount))
    }

    /// Applies a grayscale effect to the element.
    ///
    /// - Parameter amount: The grayscale amount (0-100). Default is 100 (fully grayscale).
    /// - Returns: Markup with grayscale filter applied.
    public func grayscale(_ amount: Int = 100) -> some Markup {
        filter(.grayscale(amount))
    }

    /// Applies a blur effect to the element.
    ///
    /// - Parameter amount: The blur amount in pixels.
    /// - Returns: Markup with blur filter applied.
    public func blur(_ amount: Int) -> some Markup {
        filter(.blur(amount))
    }
}

// Extension for ResponsiveBuilder to provide filter styling
extension ResponsiveBuilder {
    /// Applies a filter effect in a responsive context.
    ///
    /// - Parameter effect: The filter effect to apply.
    /// - Returns: The builder for method chaining.
    @discardableResult
    public func filter(_ effect: FilterEffect) -> ResponsiveBuilder {
        let params = FilterStyleOperation.Parameters(effect: effect)
        return FilterStyleOperation.shared.applyToBuilder(self, params: params)
    }

    /// Inverts the colors of the element.
    ///
    /// - Parameter amount: The inversion amount (0-100). Default is 100.
    /// - Returns: The builder for method chaining.
    @discardableResult
    public func invert(_ amount: Int = 100) -> ResponsiveBuilder {
        filter(.invert(amount))
    }

    /// Adjusts the brightness of the element.
    ///
    /// - Parameter amount: The brightness amount (0-200, 100 is normal).
    /// - Returns: The builder for method chaining.
    @discardableResult
    public func brightness(_ amount: Int) -> ResponsiveBuilder {
        filter(.brightness(amount))
    }

    /// Adjusts the contrast of the element.
    ///
    /// - Parameter amount: The contrast amount (0-200, 100 is normal).
    /// - Returns: The builder for method chaining.
    @discardableResult
    public func contrast(_ amount: Int) -> ResponsiveBuilder {
        filter(.contrast(amount))
    }

    /// Applies a grayscale effect to the element.
    ///
    /// - Parameter amount: The grayscale amount (0-100). Default is 100.
    /// - Returns: The builder for method chaining.
    @discardableResult
    public func grayscale(_ amount: Int = 100) -> ResponsiveBuilder {
        filter(.grayscale(amount))
    }

    /// Applies a blur effect to the element.
    ///
    /// - Parameter amount: The blur amount in pixels.
    /// - Returns: The builder for method chaining.
    @discardableResult
    public func blur(_ amount: Int) -> ResponsiveBuilder {
        filter(.blur(amount))
    }
}

// Global functions for Declarative DSL
/// Applies a filter effect in the responsive context.
///
/// - Parameter effect: The filter effect to apply.
/// - Returns: A responsive modification for filter.
public func filter(_ effect: FilterEffect) -> ResponsiveModification {
    let params = FilterStyleOperation.Parameters(effect: effect)
    return FilterStyleOperation.shared.asModification(params: params)
}

/// Inverts the colors in the responsive context.
///
/// - Parameter amount: The inversion amount (0-100). Default is 100.
/// - Returns: A responsive modification for invert.
public func invert(_ amount: Int = 100) -> ResponsiveModification {
    filter(.invert(amount))
}

/// Adjusts brightness in the responsive context.
///
/// - Parameter amount: The brightness amount (0-200, 100 is normal).
/// - Returns: A responsive modification for brightness.
public func brightness(_ amount: Int) -> ResponsiveModification {
    filter(.brightness(amount))
}

/// Adjusts contrast in the responsive context.
///
/// - Parameter amount: The contrast amount (0-200, 100 is normal).
/// - Returns: A responsive modification for contrast.
public func contrast(_ amount: Int) -> ResponsiveModification {
    filter(.contrast(amount))
}

/// Applies grayscale in the responsive context.
///
/// - Parameter amount: The grayscale amount (0-100). Default is 100.
/// - Returns: A responsive modification for grayscale.
public func grayscale(_ amount: Int = 100) -> ResponsiveModification {
    filter(.grayscale(amount))
}

/// Applies blur in the responsive context.
///
/// - Parameter amount: The blur amount in pixels.
/// - Returns: A responsive modification for blur.
public func blur(_ amount: Int) -> ResponsiveModification {
    filter(.blur(amount))
}
