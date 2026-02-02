import Foundation

/// Provides CSS minification functionality to reduce file size and improve performance.
///
/// The `CSSMinifier` removes unnecessary whitespace, comments, and redundant
/// formatting from CSS content while preserving the stylesheet's behavior.
///
/// ## Example
/// ```swift
/// let css = """
///     /* Button styles */
///     .btn {
///         padding: 12px 16px;
///         color: white;
///     }
///     @media (min-width: 768px) {
///         .btn { padding: 16px 20px; }
///     }
/// """
/// let minified = CSSMinifier.minify(css)
/// // Result: ".btn{padding:12px 16px;color:white}@media (min-width:768px){.btn{padding:16px 20px}}"
/// ```
public struct CSSMinifier {
    /// Minifies CSS by removing unnecessary whitespace and comments.
    ///
    /// This method performs the following optimizations:
    /// - Removes block comments (`/* ... */`)
    /// - Collapses consecutive whitespace into single spaces
    /// - Removes spaces around common punctuation (`{`, `}`, `:`, `;`, `,`, `>`, `+`, `~`)
    /// - Removes trailing semicolons before `}`
    ///
    /// - Parameter css: The CSS content to minify.
    /// - Returns: Minified CSS as a string.
    public static func minify(_ css: String) -> String {
        var result = css

        // Remove block comments (/* ... */)
        result = removeComments(from: result)

        // Preserve string literals before whitespace and punctuation normalization
        let (withoutLiterals, literals) = replaceStringLiterals(in: result)
        result = withoutLiterals

        // Normalize whitespace to single spaces
        result = normalizeWhitespace(result)

        // Remove spaces around punctuation
        result = removeSpacesAroundPunctuation(result)

        // Remove optional semicolons before closing braces
        result = removeTrailingSemicolons(result)

        // Restore preserved string literals
        result = restoreStringLiterals(in: result, from: literals)

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func removeComments(from css: String) -> String {
        let pattern = "/\\*[^*]*\\*+(?:[^/*][^*]*\\*+)*/"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
            let range = NSRange(location: 0, length: css.utf16.count)
            return regex.stringByReplacingMatches(in: css, options: [], range: range, withTemplate: "")
        } catch {
            return css
        }
    }

    private static func normalizeWhitespace(_ css: String) -> String {
        var result = css
        do {
            let whitespaceRegex = try NSRegularExpression(pattern: "\\s+", options: [])
            let range = NSRange(location: 0, length: result.utf16.count)
            result = whitespaceRegex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: " ")
        } catch {
            result = result.replacingOccurrences(of: "\n", with: " ")
            result = result.replacingOccurrences(of: "\r", with: " ")
            result = result.replacingOccurrences(of: "\t", with: " ")
        }
        return result
    }

    private static func replaceStringLiterals(in css: String) -> (String, [String: String]) {
        var output = ""
        var literals: [String: String] = [:]
        var index = 0
        var isInString = false
        var quote: Character = "\""
        var escape = false
        var current = ""

        for ch in css {
            if isInString {
                current.append(ch)
                if escape {
                    escape = false
                } else if ch == "\\" {
                    escape = true
                } else if ch == quote {
                    let placeholder = "/*__CSS_LITERAL_\(index)__*/"
                    literals[placeholder] = current
                    output += placeholder
                    index += 1
                    current = ""
                    isInString = false
                }
            } else {
                if ch == "\"" || ch == "'" {
                    isInString = true
                    quote = ch
                    current = String(ch)
                } else {
                    output.append(ch)
                }
            }
        }

        if isInString {
            output += current
        }

        return (output, literals)
    }

    private static func restoreStringLiterals(in css: String, from literals: [String: String]) -> String {
        var result = css
        for (placeholder, literal) in literals {
            result = result.replacingOccurrences(of: placeholder, with: literal)
        }
        return result
    }

    private static func removeSpacesAroundPunctuation(_ css: String) -> String {
        var result = css

        let replacements: [(String, String)] = [
            (" {", "{"),
            ("{ ", "{"),
            (" }", "}"),
            ("} ", "}"),
            (" :", ":"),
            (": ", ":"),
            (" ;", ";"),
            ("; ", ";"),
            (" ,", ","),
            (", ", ","),
            (" > ", ">"),
            (" + ", "+"),
            (" ~ ", "~"),
            ("( ", "("),
            (" )", ")")
        ]

        for (pattern, replacement) in replacements {
            result = result.replacingOccurrences(of: pattern, with: replacement)
        }

        return result
    }

    private static func removeTrailingSemicolons(_ css: String) -> String {
        // Replace ";}" with "}"
        return css.replacingOccurrences(of: ";}", with: "}")
    }
}
