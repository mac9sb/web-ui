import Foundation

enum SourceParitySupport {
    static func packageRoot(filePath: StaticString = #filePath) -> URL {
        var url = URL(filePath: "\(filePath)")
        url.deleteLastPathComponent() // filename
        url.deleteLastPathComponent() // AxiomWebTests
        url.deleteLastPathComponent() // Tests
        return url
    }

    static func swiftFileContents(in directory: URL) throws -> [URL: String] {
        let manager = FileManager.default
        guard let enumerator = manager.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey]
        ) else {
            return [:]
        }

        var results: [URL: String] = [:]
        for case let fileURL as URL in enumerator {
            guard fileURL.pathExtension == "swift" else { continue }
            let values = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
            guard values.isRegularFile == true else { continue }
            results[fileURL] = try String(contentsOf: fileURL, encoding: .utf8)
        }
        return results
    }

    static func allMatches(
        pattern: String,
        in source: String,
        group: Int = 1
    ) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        let range = NSRange(source.startIndex..<source.endIndex, in: source)
        return regex.matches(in: source, options: [], range: range).compactMap { match in
            guard let matchRange = Range(match.range(at: group), in: source) else {
                return nil
            }
            return String(source[matchRange])
        }
    }

    static func camelCaseCSSMemberName(for property: String) -> String {
        let pieces = property.split(separator: "-").map(String.init)
        guard let first = pieces.first else {
            return property
        }
        let rest = pieces.dropFirst().map { piece in
            guard let first = piece.first else { return piece }
            return "\(String(first).uppercased())\(piece.dropFirst())"
        }
        return ([first] + rest).joined()
    }
}
