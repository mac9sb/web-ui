import Foundation

extension String {
    /// Expands tilde and standardizes the path.
    ///
    /// This helper combines tilde expansion and path standardization into a single
    /// operation, commonly needed when processing user-provided file paths.
    ///
    /// - Returns: The expanded and standardized absolute path.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let path = "~/Documents/my-project"
    /// let resolved = path.expandedStandardizedPath
    /// // Returns: "/Users/username/Documents/my-project"
    /// ```
    var expandedStandardizedPath: String {
        ((self as NSString).expandingTildeInPath as NSString).standardizingPath
    }
}
