import Foundation

/// Represents CSS list-style-type values
///
/// Used to control the appearance of list markers, including hiding disclosure markers
/// on <summary> elements.
public enum ListStyleType: String, Sendable {
    /// No marker displayed (removes list marker entirely)
    case none
    /// Filled circle marker
    case disc
    /// Hollow circle marker
    case circle
    /// Filled square marker
    case square
    /// Decimal numbers (1, 2, 3...)
    case decimal
    /// Lowercase letters (a, b, c...)
    case lowerAlpha = "lower-alpha"
    /// Uppercase letters (A, B, C...)
    case upperAlpha = "upper-alpha"
    /// Lowercase Roman numerals (i, ii, iii...)
    case lowerRoman = "lower-roman"
    /// Uppercase Roman numerals (I, II, III...)
    case upperRoman = "upper-roman"
}
