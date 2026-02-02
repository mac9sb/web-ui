import Foundation

/// Represents a manifest of shared CSS bundles and their associated pages.
public struct CSSBundleManifest: Sendable, Codable {
    /// Mapping of bundle name to the set of page slugs that should include it.
    public let bundles: [String: [String]]

    /// Mapping of page slug to the list of CSS files that should be linked for it.
    public let pageCSSFiles: [String: [String]]

    /// Creates a new manifest.
    /// - Parameters:
    ///   - bundles: Dictionary of bundle name -> page slugs.
    ///   - pageCSSFiles: Dictionary of page slug -> CSS file list.
    public init(bundles: [String: [String]], pageCSSFiles: [String: [String]]) {
        self.bundles = bundles
        self.pageCSSFiles = pageCSSFiles
    }

    /// Returns the bundles that should be included for a given page slug.
    /// - Parameter slug: Page slug.
    /// - Returns: Array of bundle names.
    public func bundles(for slug: String) -> [String] {
        bundles.compactMap { name, pages in
            pages.contains(slug) ? name : nil
        }.sorted()
    }

    /// Returns the CSS files that should be included for a given page slug.
    /// - Parameter slug: Page slug.
    /// - Returns: Array of CSS file paths.
    public func cssFiles(for slug: String) -> [String] {
        pageCSSFiles[slug] ?? []
    }

    /// Encodes the manifest as a JSON string.
    /// - Returns: JSON string or `nil` if encoding fails.
    public func toJSONString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Decodes a manifest from JSON data.
    /// - Parameter data: JSON data.
    /// - Returns: Decoded manifest or `nil` if decoding fails.
    public static func fromJSON(_ data: Data) -> CSSBundleManifest? {
        let decoder = JSONDecoder()
        return try? decoder.decode(CSSBundleManifest.self, from: data)
    }
}
