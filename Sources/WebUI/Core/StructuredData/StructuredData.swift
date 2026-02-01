import Foundation

/// Represents structured data in JSON-LD format for rich snippets in search results.
///
/// The `StructuredData` struct provides a type-safe way to define structured
/// data following various schema.org schemas like Article, Product, Organization, etc.
/// ## Thread Safety
///
/// This type uses `@unchecked Sendable` because it contains `[String: Any]` which
/// cannot be automatically verified as thread-safe by the compiler. However, thread
/// safety is guaranteed because:
///
/// 1. The `data` dictionary is immutable (`let`) and never modified after initialization
/// 2. All methods that access `data` only read from it, never mutate it
/// 3. The dictionary is copied on access, preventing shared mutable state
///
/// The `[String: Any]` is used for JSON-LD structured data serialization where the
/// values are typically strings, numbers, arrays, and dictionaries - all value types
/// or immutable reference types from Foundation.
public struct StructuredData: @unchecked Sendable {
    /// The type of schema used for this structured data.
    public let type: SchemaType

    /// The raw data to be included in the structured data.
    private let data: [String: Any]

    /// Returns a copy of the raw data dictionary.
    ///
    /// - Returns: A dictionary containing the structured data properties.
    public func retrieveStructuredDataDictionary() -> [String: Any] {
        data
    }

    /// Creates a custom structured data object with the specified schema type and data.
    ///
    /// - Parameters:
    ///   - type: The schema type for the structured data.
    ///   - data: The data to include in the structured data.
    /// - Returns: A structured data object with the specified type and data.
    ///
    /// - Example:
    ///   ```swift
    ///   let customData = StructuredData.custom(
    ///     type: .review,
    ///     data: [
    ///       "itemReviewed": ["@type": "Product", "name": "WebUI Framework"],
    ///       "reviewRating": ["@type": "Rating", "ratingValue": "5"],
    ///       "author": ["@type": "Person", "name": "Jane Developer"]
    ///     ]
    ///   )
    ///   ```
    public static func custom(type: SchemaType, data: [String: Any]) -> StructuredData {
        StructuredData(type: type, data: data)
    }

    /// Initializes a new structured data object with the specified schema type and data.
    ///
    /// - Parameters:
    ///   - type: The schema type for the structured data.
    ///   - data: The data to include in the structured data.
    public init(type: SchemaType, data: [String: Any]) {
        self.type = type
        self.data = data
    }

    /// Converts the structured data to a JSON string.
    ///
    /// - Returns: A JSON string representation of the structured data, or an empty string if serialization fails.
    public func convertToJsonString() -> String {
        var jsonObject: [String: Any] = [
            "@context": "https://schema.org",
            "@type": type.rawValue,
        ]

        // Merge the data dictionary with the base JSON object
        for (key, value) in data {
            jsonObject[key] = value
        }

        // Try to serialize the JSON object to data
        if let jsonData = try? JSONSerialization.data(
            withJSONObject: jsonObject,
            options: [.withoutEscapingSlashes]
        ) {
            // Convert the data to a string
            return String(data: jsonData, encoding: .utf8) ?? ""
        }

        return ""
    }


}
