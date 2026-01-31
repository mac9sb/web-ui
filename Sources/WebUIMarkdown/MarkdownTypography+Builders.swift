import Foundation

// MARK: - Fluent Builder API for MarkdownTypography

/// Extension providing closure-based builder methods for configuring typography styles.
///
/// This extension adds a fluent, declarative API for configuring markdown typography
/// that mirrors the style modifier pattern used throughout WebUI. Each builder method
/// accepts a closure that receives a style builder with support for dark mode variants.
///
/// ## Example
///
/// ```swift
/// let typography = MarkdownTypography(defaultFontSize: .body)
///     .heading(.h1) { style in
///         style.font(family: "'Space Grotesk'", size: .extraLarge, weight: .bold)
///         style.color("#111817")
///             .onDark("#ffffff")
///         style.margins(top: "2.5rem", bottom: "1rem")
///     }
///     .codeBlock { style in
///         style.font(family: "monospace")
///         style.background("#f3f4f6")
///             .onDark("#1f2937")
///         style.padding(all: "1rem")
///     }
/// ```
extension MarkdownTypography {

    // MARK: - Heading Builders

    /// Configure a specific heading level with a builder closure.
    ///
    /// - Parameters:
    ///   - level: The heading level to configure (h1-h6)
    ///   - builder: A closure that configures the typography style using a style builder
    /// - Returns: A new typography instance with the heading style applied
    public func heading(_ level: HeadingLevel, _ builder: (StyleBuilder) -> Void) -> MarkdownTypography {
        let styleBuilder = StyleBuilder(baseStyle: headings[level])
        builder(styleBuilder)

        var newHeadings = headings
        newHeadings[level] = styleBuilder.build()

        return withHeadings(newHeadings)
    }

    /// Configure all heading levels with a shared builder closure.
    ///
    /// - Parameter builder: A closure that configures the typography style for all headings
    /// - Returns: A new typography instance with heading styles applied
    public func allHeadings(_ builder: (StyleBuilder) -> Void) -> MarkdownTypography {
        var newHeadings: [HeadingLevel: TypographyStyle] = [:]

        for level in HeadingLevel.allCases {
            let styleBuilder = StyleBuilder(baseStyle: headings[level])
            builder(styleBuilder)
            newHeadings[level] = styleBuilder.build()
        }

        return withHeadings(newHeadings)
    }

    // MARK: - Element Builders

    /// Configure paragraph styles.
    public func paragraph(_ builder: (StyleBuilder) -> Void) -> MarkdownTypography {
        element(.paragraph, builder)
    }

    /// Configure inline code styles.
    public func inlineCode(_ builder: (StyleBuilder) -> Void) -> MarkdownTypography {
        element(.inlineCode, builder)
    }

    /// Configure code block styles.
    public func codeBlock(_ builder: (StyleBuilder) -> Void) -> MarkdownTypography {
        element(.codeBlock, builder)
    }

    /// Configure blockquote styles.
    public func blockquote(_ builder: (StyleBuilder) -> Void) -> MarkdownTypography {
        element(.blockquote, builder)
    }

    /// Configure link styles.
    public func link(_ builder: (StyleBuilder) -> Void) -> MarkdownTypography {
        element(.link, builder)
    }

    /// Configure ordered list styles.
    public func orderedList(_ builder: (StyleBuilder) -> Void) -> MarkdownTypography {
        element(.orderedList, builder)
    }

    /// Configure unordered list styles.
    public func unorderedList(_ builder: (StyleBuilder) -> Void) -> MarkdownTypography {
        element(.unorderedList, builder)
    }

    /// Configure list item styles.
    public func listItem(_ builder: (StyleBuilder) -> Void) -> MarkdownTypography {
        element(.listItem, builder)
    }

    /// Configure table styles.
    public func table(_ builder: (StyleBuilder) -> Void) -> MarkdownTypography {
        element(.table, builder)
    }

    /// Configure table header styles.
    public func tableHeader(_ builder: (StyleBuilder) -> Void) -> MarkdownTypography {
        element(.tableHeader, builder)
    }

    /// Configure table cell styles.
    public func tableCell(_ builder: (StyleBuilder) -> Void) -> MarkdownTypography {
        element(.tableCell, builder)
    }

    /// Configure emphasis (italic) styles.
    public func emphasis(_ builder: (StyleBuilder) -> Void) -> MarkdownTypography {
        element(.emphasis, builder)
    }

    /// Configure strong (bold) styles.
    public func strong(_ builder: (StyleBuilder) -> Void) -> MarkdownTypography {
        element(.strong, builder)
    }

    /// Configure image styles.
    public func image(_ builder: (StyleBuilder) -> Void) -> MarkdownTypography {
        element(.image, builder)
    }

    /// Configure horizontal rule styles.
    public func horizontalRule(_ builder: (StyleBuilder) -> Void) -> MarkdownTypography {
        element(.horizontalRule, builder)
    }

    // MARK: - Generic Element Builder

    /// Configure any element type with a builder closure.
    ///
    /// - Parameters:
    ///   - elementType: The element type to configure
    ///   - builder: A closure that configures the typography style
    /// - Returns: A new typography instance with the element style applied
    public func element(_ elementType: ElementType, _ builder: (StyleBuilder) -> Void) -> MarkdownTypography {
        let styleBuilder = StyleBuilder(baseStyle: elements[elementType])
        builder(styleBuilder)

        var newElements = elements
        newElements[elementType] = styleBuilder.build()

        return withElements(newElements)
    }

    // MARK: - Syntax Highlighting Builder

    /// Configure syntax highlighting colors for code blocks.
    ///
    /// This creates CSS rules for common syntax highlighting classes with dark mode support.
    ///
    /// - Parameter builder: A closure that receives a syntax highlighting configurator
    /// - Returns: A new typography instance with syntax highlighting styles applied
    public func syntaxHighlighting(_ builder: (SyntaxHighlightingBuilder) -> Void) -> MarkdownTypography {
        let syntaxBuilder = SyntaxHighlightingBuilder()
        builder(syntaxBuilder)
        return syntaxBuilder.apply(to: self)
    }
}

// MARK: - Style Builder

/// A builder for creating typography styles with support for dark mode variants.
///
/// This builder provides a fluent API for configuring styles that automatically
/// handles light/dark mode variants similar to WebUI's responsive modifiers.
public final class StyleBuilder {
    private var style: MarkdownTypography.TypographyStyle
    private var darkModeOverrides: [String: String] = [:]

    init(baseStyle: MarkdownTypography.TypographyStyle? = nil) {
        self.style = baseStyle ?? MarkdownTypography.TypographyStyle()
    }

    /// Build the final typography style with dark mode support.
    func build() -> MarkdownTypography.TypographyStyle {
        var finalStyle = style

        // Add dark mode overrides to customProperties
        if !darkModeOverrides.isEmpty {
            var darkModeCSS = "@media (prefers-color-scheme: dark) { "
            for (property, value) in darkModeOverrides {
                darkModeCSS += "\(property): \(value); "
            }
            darkModeCSS += "}"
            finalStyle.customProperties["__dark_mode__"] = darkModeCSS
        }

        return finalStyle
    }

    // MARK: - Font Configuration

    /// Configure font properties.
    @discardableResult
    public func font(
        family: String? = nil,
        size: TextSize? = nil,
        weight: Weight? = nil,
        lineHeight: Leading? = nil
    ) -> StyleBuilder {
        let current = style.font ?? MarkdownTypography.FontProperties()
        style.font = MarkdownTypography.FontProperties(
            family: family ?? current.family,
            size: size ?? current.size,
            weight: weight ?? current.weight,
            alignment: current.alignment,
            color: current.color,
            lineHeight: lineHeight ?? current.lineHeight,
            letterSpacing: current.letterSpacing,
            textDecoration: current.textDecoration,
            textTransform: current.textTransform
        )
        return self
    }

    /// Set text color with optional dark mode variant.
    @discardableResult
    public func color(_ color: String) -> ColorBuilder {
        let current = style.font ?? MarkdownTypography.FontProperties()
        style.font = MarkdownTypography.FontProperties(
            family: current.family,
            size: current.size,
            weight: current.weight,
            alignment: current.alignment,
            color: color,
            lineHeight: current.lineHeight,
            letterSpacing: current.letterSpacing,
            textDecoration: current.textDecoration,
            textTransform: current.textTransform
        )
        return ColorBuilder(styleBuilder: self, property: "color", lightValue: color)
    }

    // MARK: - Background Configuration

    /// Set background color with optional dark mode variant.
    @discardableResult
    public func background(_ color: String) -> ColorBuilder {
        style.background = MarkdownTypography.BackgroundProperties(color: color)
        return ColorBuilder(styleBuilder: self, property: "background-color", lightValue: color)
    }

    // MARK: - Spacing Configuration

    /// Configure padding.
    @discardableResult
    public func padding(
        top: String? = nil,
        right: String? = nil,
        bottom: String? = nil,
        left: String? = nil
    ) -> StyleBuilder {
        style.padding = MarkdownTypography.PaddingProperties(top: top, right: right, bottom: bottom, left: left)
        return self
    }

    /// Configure padding uniformly.
    @discardableResult
    public func padding(all: String) -> StyleBuilder {
        style.padding = MarkdownTypography.PaddingProperties(all: all)
        return self
    }

    /// Configure padding vertically and horizontally.
    @discardableResult
    public func padding(vertical: String, horizontal: String) -> StyleBuilder {
        style.padding = MarkdownTypography.PaddingProperties(vertical: vertical, horizontal: horizontal)
        return self
    }

    /// Configure margins.
    @discardableResult
    public func margins(
        top: String? = nil,
        right: String? = nil,
        bottom: String? = nil,
        left: String? = nil
    ) -> StyleBuilder {
        style.margins = MarkdownTypography.MarginProperties(top: top, right: right, bottom: bottom, left: left)
        return self
    }

    /// Configure margins uniformly.
    @discardableResult
    public func margins(all: String) -> StyleBuilder {
        style.margins = MarkdownTypography.MarginProperties(all: all)
        return self
    }

    /// Configure margins vertically and horizontally.
    @discardableResult
    public func margins(vertical: String, horizontal: String) -> StyleBuilder {
        style.margins = MarkdownTypography.MarginProperties(vertical: vertical, horizontal: horizontal)
        return self
    }

    // MARK: - Border Configuration

    /// Configure border.
    @discardableResult
    public func border(
        width: String? = nil,
        style: String? = nil,
        color: String? = nil,
        radius: String? = nil
    ) -> StyleBuilder {
        self.style.border = MarkdownTypography.BorderProperties(width: width, style: style, color: color, radius: radius)
        return self
    }

    /// Set border color with optional dark mode variant.
    @discardableResult
    public func borderColor(_ color: String) -> ColorBuilder {
        let current = style.border ?? MarkdownTypography.BorderProperties()
        style.border = MarkdownTypography.BorderProperties(
            width: current.width,
            style: current.style,
            color: color,
            radius: current.radius
        )
        return ColorBuilder(styleBuilder: self, property: "border-color", lightValue: color)
    }

    // MARK: - Custom CSS

    /// Add custom CSS property.
    @discardableResult
    public func css(_ property: String, _ value: String) -> StyleBuilder {
        style.customProperties[property] = value
        return self
    }

    // MARK: - Internal Dark Mode Support

    fileprivate func addDarkModeOverride(property: String, value: String) {
        darkModeOverrides[property] = value
    }
}

// MARK: - Color Builder (for .onDark support)

/// A builder that enables dark mode color variants.
///
/// This builder is returned from color-setting methods and allows chaining
/// with `.onDark()` to specify dark mode variants.
public final class ColorBuilder {
    private let styleBuilder: StyleBuilder
    private let property: String
    private let lightValue: String

    init(styleBuilder: StyleBuilder, property: String, lightValue: String) {
        self.styleBuilder = styleBuilder
        self.property = property
        self.lightValue = lightValue
    }

    /// Specify the dark mode variant for this color.
    ///
    /// - Parameter darkColor: The color to use in dark mode
    /// - Returns: The style builder for continued configuration
    @discardableResult
    public func onDark(_ darkColor: String) -> StyleBuilder {
        styleBuilder.addDarkModeOverride(property: property, value: darkColor)
        return styleBuilder
    }
}

// MARK: - Syntax Highlighting Builder

/// A builder for configuring syntax highlighting colors with dark mode support.
public final class SyntaxHighlightingBuilder {
    private var lightColors: [String: String] = [:]
    private var darkColors: [String: String] = [:]

    /// Set the color for keywords (if, let, var, func, etc.)
    @discardableResult
    public func keyword(_ color: String) -> SyntaxColorBuilder {
        lightColors["keyword"] = color
        return SyntaxColorBuilder(parent: self, className: "keyword")
    }

    /// Set the color for string literals.
    @discardableResult
    public func string(_ color: String) -> SyntaxColorBuilder {
        lightColors["string"] = color
        return SyntaxColorBuilder(parent: self, className: "string")
    }

    /// Set the color for comments.
    @discardableResult
    public func comment(_ color: String) -> SyntaxColorBuilder {
        lightColors["comment"] = color
        return SyntaxColorBuilder(parent: self, className: "comment")
    }

    /// Set the color for numbers.
    @discardableResult
    public func number(_ color: String) -> SyntaxColorBuilder {
        lightColors["number"] = color
        return SyntaxColorBuilder(parent: self, className: "number")
    }

    /// Set the color for function names.
    @discardableResult
    public func function(_ color: String) -> SyntaxColorBuilder {
        lightColors["function"] = color
        return SyntaxColorBuilder(parent: self, className: "function")
    }

    /// Set the color for type names.
    @discardableResult
    public func type(_ color: String) -> SyntaxColorBuilder {
        lightColors["type"] = color
        return SyntaxColorBuilder(parent: self, className: "type")
    }

    /// Set the color for operators.
    @discardableResult
    public func `operator`(_ color: String) -> SyntaxColorBuilder {
        lightColors["operator"] = color
        return SyntaxColorBuilder(parent: self, className: "operator")
    }

    /// Set the color for properties.
    @discardableResult
    public func property(_ color: String) -> SyntaxColorBuilder {
        lightColors["property"] = color
        return SyntaxColorBuilder(parent: self, className: "property")
    }

    /// Set the color for variables.
    @discardableResult
    public func variable(_ color: String) -> SyntaxColorBuilder {
        lightColors["variable"] = color
        return SyntaxColorBuilder(parent: self, className: "variable")
    }

    /// Set the color for punctuation.
    @discardableResult
    public func punctuation(_ color: String) -> SyntaxColorBuilder {
        lightColors["punctuation"] = color
        return SyntaxColorBuilder(parent: self, className: "punctuation")
    }

    fileprivate func setDarkColor(className: String, color: String) {
        darkColors[className] = color
    }

    func apply(to typography: MarkdownTypography) -> MarkdownTypography {
        var result = typography

        // Apply light mode colors
        for (className, color) in lightColors {
            result = result.element(.code) { style in
                style.css(".\(className)", "color: \(color)")
            }
        }

        // Apply dark mode colors if specified
        if !darkColors.isEmpty {
            var darkModeCSS = "@media (prefers-color-scheme: dark) { "
            for (className, color) in darkColors {
                darkModeCSS += ".\(className) { color: \(color); } "
            }
            darkModeCSS += "}"

            result = result.element(.code) { style in
                style.css("__syntax_dark__", darkModeCSS)
            }
        }

        return result
    }
}

/// A builder for syntax highlighting colors with dark mode support.
public final class SyntaxColorBuilder {
    private let parent: SyntaxHighlightingBuilder
    private let className: String

    init(parent: SyntaxHighlightingBuilder, className: String) {
        self.parent = parent
        self.className = className
    }

    /// Specify the dark mode variant for this syntax color.
    @discardableResult
    public func onDark(_ darkColor: String) -> SyntaxHighlightingBuilder {
        parent.setDarkColor(className: className, color: darkColor)
        return parent
    }
}
