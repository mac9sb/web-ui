import Foundation

/// Utilities for working with style operations
public enum StyleUtilities {
    /// Converts a varargs parameter to an array
    ///
    /// This is useful for converting the `edges: Edge...` parameter to an array
    /// that can be used with style operations.
    ///
    /// - Parameter varargs: The varargs parameter
    /// - Returns: An array containing the varargs elements, or [.all] if empty
    public static func toArray<T>(_ varargs: T...) -> [T] {
        varargs.isEmpty ? [] : varargs
    }

    /// Safely combines a class
    ///
    /// Returns the base class as an array.
    ///
    /// - Parameter baseClass: The base class name
    /// - Returns: The class name in an array
    public static func combineClass(
        _ baseClass: String
    ) -> [String] {
        [baseClass]
    }

    /// Safely combines multiple classes
    ///
    /// Returns the base classes unchanged.
    ///
    /// - Parameter baseClasses: The base class names
    /// - Returns: The class names
    public static func combineClasses(
        _ baseClasses: [String]
    ) -> [String] {
        baseClasses
    }
}
