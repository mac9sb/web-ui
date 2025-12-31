import Foundation

/// Thread-safe collector for CSS classes used during document rendering.
///
/// ClassCollector accumulates all CSS class names applied to elements during the
/// rendering process, enabling automatic CSS generation from actually-used utilities.
///
/// ## Architecture
///
/// The collector uses a singleton pattern with thread-safe access via NSLock,
/// ensuring safe concurrent collection during multi-threaded rendering scenarios
/// while remaining synchronous for integration with the rendering pipeline.
///
/// ## Usage
///
/// ```swift
/// // During rendering, classes are automatically collected
/// let element = Text("Hello")
///     .background(color: .blue(._500))  // Collects "bg-blue-500"
///     .padding(of: 4, at: .all)         // Collects "p-4"
///
/// // After rendering, generate CSS
/// let css = ClassCollector.shared.generateCSS()
/// ```
///
/// ## Benefits
///
/// - **Optimized output**: Generate only the CSS actually used
/// - **Smaller file sizes**: No unused utility classes in production
/// - **Self-contained**: No external dependencies
/// - **Better caching**: Static CSS files can be cached indefinitely
///
/// - SeeAlso: ``CSSGenerator``, ``StyleOperation``
public final class ClassCollector: @unchecked Sendable {
    /// Shared singleton instance
    public static let shared = ClassCollector()

    /// Lock for thread-safe access to collected classes
    private let lock = NSLock()

    /// Set of all collected CSS class names
    private var collectedClasses: Set<String> = []

    /// Private initializer to enforce singleton pattern
    private init() {}

    /// Adds a CSS class name to the collection.
    ///
    /// - Parameter className: The CSS class name to collect (e.g., "bg-blue-500", "p-4")
    public func addClass(_ className: String) {
        lock.lock()
        defer { lock.unlock() }
        collectedClasses.insert(className)
    }

    /// Adds multiple CSS class names to the collection.
    ///
    /// - Parameter classNames: Array of CSS class names to collect
    public func addClasses(_ classNames: [String]) {
        lock.lock()
        defer { lock.unlock() }
        for className in classNames {
            collectedClasses.insert(className)
        }
    }

    /// Returns all collected CSS class names.
    ///
    /// - Returns: A sorted array of unique CSS class names
    public func getClasses() -> [String] {
        lock.lock()
        defer { lock.unlock() }
        return Array(collectedClasses).sorted()
    }

    /// Clears all collected classes.
    ///
    /// Use this when starting a new rendering pass or in testing scenarios.
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        collectedClasses.removeAll()
    }

    /// Generates CSS from all collected classes.
    ///
    /// - Returns: A string containing CSS rules for all collected classes
    public func generateCSS() -> String {
        CSSGenerator.generateCSS(for: getClasses())
    }
}
