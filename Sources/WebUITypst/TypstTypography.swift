import Foundation

/// Typography styling configuration for rendered Typst content.
///
/// This structure controls the visual appearance of rendered content including
/// headings, paragraphs, code blocks, syntax highlighting, and more.
///
/// ## Default Styling
///
/// The default configuration provides a clean, readable style suitable for
/// most documentation and blog content.
///
/// ## Customization Example
///
/// ```swift
/// var typography = TypstTypography()
///     .withCodeBlock(
///         fontFamily: "Fira Code, monospace",
///         backgroundColor: "#1e1e2e"
///     )
///     .withSyntaxHighlighting(
///         keyword: "#cba6f7",
///         string: "#a6e3a1",
///         comment: "#6c7086"
///     )
/// ```
public struct TypstTypography: Sendable {

    // MARK: - Typography Components

    /// Styling for heading elements (h1-h6).
    public var headings: HeadingTypography

    /// Styling for paragraph elements.
    public var paragraphs: ParagraphTypography

    /// Styling for code block elements (pre > code).
    public var codeBlocks: CodeBlockTypography

    /// Styling for inline code elements.
    public var inlineCode: InlineCodeTypography

    /// Styling for blockquote elements.
    public var blockquotes: BlockquoteTypography

    /// Styling for anchor/link elements.
    public var links: LinkTypography

    /// Styling for ordered and unordered lists.
    public var lists: ListTypography

    /// Styling for table elements.
    public var tables: TableTypography

    /// Syntax highlighting colors for code blocks.
    public var syntaxHighlighting: SyntaxHighlighting

    /// A common class prefix applied to styled elements.
    public var classPrefix: String

    // MARK: - Initialization

    /// Creates typography with default styling.
    public init() {
        self.headings = HeadingTypography()
        self.paragraphs = ParagraphTypography()
        self.codeBlocks = CodeBlockTypography()
        self.inlineCode = InlineCodeTypography()
        self.blockquotes = BlockquoteTypography()
        self.links = LinkTypography()
        self.lists = ListTypography()
        self.tables = TableTypography()
        self.syntaxHighlighting = SyntaxHighlighting()
        self.classPrefix = "typst-"
    }

    // MARK: - Typography Component Styles

    /// Styling configuration for heading elements.
    public struct HeadingTypography: Sendable {
        /// Font family for heading text.
        public var fontFamily: String

        /// Base font size (multiplied by level).
        public var baseFontSize: String

        /// Font weight for headings.
        public var fontWeight: String

        /// Default text color.
        public var color: String

        /// Color in dark mode.
        public var darkColor: String

        /// Vertical spacing above headings.
        public var marginTop: String

        /// Vertical spacing below headings.
        public var marginBottom: String

        /// Line height for heading text.
        public var lineHeight: String

        public init(
            fontFamily: String = "system-ui, -apple-system, sans-serif",
            baseFontSize: String = "1.5rem",
            fontWeight: String = "bold",
            color: String = "#1c1917",
            darkColor: String = "#fafaf9",
            marginTop: String = "1.5rem",
            marginBottom: String = "0.75rem",
            lineHeight: String = "1.2"
        ) {
            self.fontFamily = fontFamily
            self.baseFontSize = baseFontSize
            self.fontWeight = fontWeight
            self.color = color
            self.darkColor = darkColor
            self.marginTop = marginTop
            self.marginBottom = marginBottom
            self.lineHeight = lineHeight
        }
    }

    /// Styling configuration for paragraph elements.
    public struct ParagraphTypography: Sendable {
        /// Vertical spacing below paragraphs.
        public var marginBottom: String

        /// Line height for paragraph text.
        public var lineHeight: String

        /// Text color.
        public var color: String

        /// Text color in dark mode.
        public var darkColor: String

        public init(
            marginBottom: String = "1rem",
            lineHeight: String = "1.75",
            color: String = "#3f3f46",
            darkColor: String = "#d4d4d8"
        ) {
            self.marginBottom = marginBottom
            self.lineHeight = lineHeight
            self.color = color
            self.darkColor = darkColor
        }
    }

    /// Styling configuration for code block elements.
    public struct CodeBlockTypography: Sendable {
        /// Font family for code text.
        public var fontFamily: String

        /// Font size for code text.
        public var fontSize: String

        /// Background color.
        public var backgroundColor: String

        /// Background color in dark mode.
        public var darkBackgroundColor: String

        /// Text color.
        public var color: String

        /// Padding around code blocks.
        public var padding: String

        /// Border radius.
        public var borderRadius: String

        /// Whether to show line numbers.
        public var showLineNumbers: Bool

        /// Whether to show a copy button.
        public var showCopyButton: Bool

        /// Language label to display (e.g., "swift", "typescript").
        public var language: String?

        /// File name to display above the code block.
        public var fileName: String?

        /// Whether to enable horizontal scrolling.
        public var overflowX: Bool

        public init(
            fontFamily: String = "monospace",
            fontSize: String = "0.875rem",
            backgroundColor: String = "#18181b",
            darkBackgroundColor: String = "#09090b",
            color: String = "#e4e4e7",
            padding: String = "1rem",
            borderRadius: String = "0.5rem",
            showLineNumbers: Bool = true,
            showCopyButton: Bool = true,
            language: String? = nil,
            fileName: String? = nil,
            overflowX: Bool = true
        ) {
            self.fontFamily = fontFamily
            self.fontSize = fontSize
            self.backgroundColor = backgroundColor
            self.darkBackgroundColor = darkBackgroundColor
            self.color = color
            self.padding = padding
            self.borderRadius = borderRadius
            self.showLineNumbers = showLineNumbers
            self.showCopyButton = showCopyButton
            self.language = language
            self.fileName = fileName
            self.overflowX = overflowX
        }
    }

    /// Styling configuration for inline code elements.
    public struct InlineCodeTypography: Sendable {
        /// Font family for code text.
        public var fontFamily: String

        /// Background color.
        public var backgroundColor: String

        /// Background color in dark mode.
        public var darkBackgroundColor: String

        /// Text color.
        public var color: String

        /// Padding around inline code.
        public var padding: String

        /// Border radius.
        public var borderRadius: String

        /// Font size relative to parent.
        public var fontSize: String

        public init(
            fontFamily: String = "monospace",
            backgroundColor: String = "#27272a",
            darkBackgroundColor: String = "#3f3f46",
            color: String = "inherit",
            padding: String = "0.2em 0.4em",
            borderRadius: String = "0.25rem",
            fontSize: String = "0.875em"
        ) {
            self.fontFamily = fontFamily
            self.backgroundColor = backgroundColor
            self.darkBackgroundColor = darkBackgroundColor
            self.color = color
            self.padding = padding
            self.borderRadius = borderRadius
            self.fontSize = fontSize
        }
    }

    /// Styling configuration for blockquote elements.
    public struct BlockquoteTypography: Sendable {
        /// Left border style.
        public var borderLeft: String

        /// Padding inside the blockquote.
        public var paddingLeft: String

        /// Text color.
        public var color: String

        /// Text color in dark mode.
        public var darkColor: String

        /// Font style (italic, normal).
        public var fontStyle: String

        public init(
            borderLeft: String = "4px solid #0d9488",
            paddingLeft: String = "1rem",
            color: String = "#57534e",
            darkColor: String = "#a8a29e",
            fontStyle: String = "italic"
        ) {
            self.borderLeft = borderLeft
            self.paddingLeft = paddingLeft
            self.color = color
            self.darkColor = darkColor
            self.fontStyle = fontStyle
        }
    }

    /// Styling configuration for anchor/link elements.
    public struct LinkTypography: Sendable {
        /// Text color.
        public var color: String

        /// Text color in dark mode.
        public var darkColor: String

        /// Text decoration.
        public var textDecoration: String

        /// Text decoration on hover.
        public var hoverTextDecoration: String

        public init(
            color: String = "#0d9488",
            darkColor: String = "#2dd4bf",
            textDecoration: String = "none",
            hoverTextDecoration: String = "underline"
        ) {
            self.color = color
            self.darkColor = darkColor
            self.textDecoration = textDecoration
            self.hoverTextDecoration = hoverTextDecoration
        }
    }

    /// Styling configuration for list elements.
    public struct ListTypography: Sendable {
        /// Ordered list marker type.
        public var orderedMarker: String

        /// Unordered list marker type.
        public var unorderedMarker: String

        /// Padding inside lists.
        public var paddingLeft: String

        /// Vertical spacing between list items.
        public var itemMarginBottom: String

        public init(
            orderedMarker: String = "decimal",
            unorderedMarker: String = "disc",
            paddingLeft: String = "1.5rem",
            itemMarginBottom: String = "0.5rem"
        ) {
            self.orderedMarker = orderedMarker
            self.unorderedMarker = unorderedMarker
            self.paddingLeft = paddingLeft
            self.itemMarginBottom = itemMarginBottom
        }
    }

    /// Styling configuration for table elements.
    public struct TableTypography: Sendable {
        /// Border collapse behavior.
        public var borderCollapse: String

        /// Border color.
        public var borderColor: String

        /// Border color in dark mode.
        public var darkBorderColor: String

        /// Cell padding.
        public var cellPadding: String

        /// Header background color.
        public var headerBackgroundColor: String

        /// Header background color in dark mode.
        public var darkHeaderBackgroundColor: String

        /// Header font weight.
        public var headerFontWeight: String

        /// Header text color.
        public var headerColor: String

        /// Header text color in dark mode.
        public var darkHeaderColor: String

        public init(
            borderCollapse: String = "collapse",
            borderColor: String = "#3f3f46",
            darkBorderColor: String = "#52525b",
            cellPadding: String = "0.75rem",
            headerBackgroundColor: String = "#27272a",
            darkHeaderBackgroundColor: String = "#3f3f46",
            headerFontWeight: String = "600",
            headerColor: String = "inherit",
            darkHeaderColor: String = "inherit"
        ) {
            self.borderCollapse = borderCollapse
            self.borderColor = borderColor
            self.darkBorderColor = darkBorderColor
            self.cellPadding = cellPadding
            self.headerBackgroundColor = headerBackgroundColor
            self.darkHeaderBackgroundColor = darkHeaderBackgroundColor
            self.headerFontWeight = headerFontWeight
            self.headerColor = headerColor
            self.darkHeaderColor = darkHeaderColor
        }
    }

    /// Color configuration for syntax highlighting in code blocks.
    public struct SyntaxHighlighting: Sendable {
        /// Keywords (let, func, if, etc.).
        public var keyword: String

        /// String literals.
        public var string: String

        /// Comments.
        public var comment: String

        /// Number literals.
        public var number: String

        /// Function names.
        public var function: String

        /// Type names.
        public var type: String

        /// Operators.
        public var `operator`: String

        /// Property names.
        public var property: String

        /// Variable names.
        public var variable: String

        /// Punctuation.
        public var punctuation: String

        public init(
            keyword: String = "#f472b6",
            string: String = "#34d399",
            comment: String = "#71717a",
            number: String = "#fb923c",
            function: String = "#60a5fa",
            type: String = "#22d3ee",
            `operator`: String = "#a1a1aa",
            property: String = "#2dd4bf",
            variable: String = "#e4e4e7",
            punctuation: String = "#a1a1aa"
        ) {
            self.keyword = keyword
            self.string = string
            self.comment = comment
            self.number = number
            self.function = function
            self.type = type
            self.`operator` = `operator`
            self.property = property
            self.variable = variable
            self.punctuation = punctuation
        }
    }

    // MARK: - Builder Methods

    /// Returns new typography with modified heading styles.
    public func withHeadings(_ configure: (inout HeadingTypography) -> Void) -> TypstTypography {
        var copy = self
        configure(&copy.headings)
        return copy
    }

    /// Returns new typography with modified paragraph styles.
    public func withParagraphs(_ configure: (inout ParagraphTypography) -> Void) -> TypstTypography {
        var copy = self
        configure(&copy.paragraphs)
        return copy
    }

    /// Returns new typography with modified code block styles.
    public func withCodeBlock(_ configure: (inout CodeBlockTypography) -> Void) -> TypstTypography {
        var copy = self
        configure(&copy.codeBlocks)
        return copy
    }

    /// Returns new typography with modified inline code styles.
    public func withInlineCode(_ configure: (inout InlineCodeTypography) -> Void) -> TypstTypography {
        var copy = self
        configure(&copy.inlineCode)
        return copy
    }

    /// Returns new typography with modified blockquote styles.
    public func withBlockquotes(_ configure: (inout BlockquoteTypography) -> Void) -> TypstTypography {
        var copy = self
        configure(&copy.blockquotes)
        return copy
    }

    /// Returns new typography with modified link styles.
    public func withLinks(_ configure: (inout LinkTypography) -> Void) -> TypstTypography {
        var copy = self
        configure(&copy.links)
        return copy
    }

    /// Returns new typography with modified list styles.
    public func withLists(_ configure: (inout ListTypography) -> Void) -> TypstTypography {
        var copy = self
        configure(&copy.lists)
        return copy
    }

    /// Returns new typography with modified table styles.
    public func withTables(_ configure: (inout TableTypography) -> Void) -> TypstTypography {
        var copy = self
        configure(&copy.tables)
        return copy
    }

    /// Returns new typography with modified syntax highlighting.
    public func withSyntaxHighlighting(_ configure: (inout SyntaxHighlighting) -> Void) -> TypstTypography {
        var copy = self
        configure(&copy.syntaxHighlighting)
        return copy
    }

    /// Returns new typography with a modified class prefix.
    public func withClassPrefix(_ prefix: String) -> TypstTypography {
        var copy = self
        copy.classPrefix = prefix
        return copy
    }

    // MARK: - CSS Generation

    /// Generates CSS styles for all typography elements.
    public func generateCSS() -> String {
        var css = ""
        css += TypstCodeBlockStyles(classPrefix: classPrefix).generateCSS()
        css += generateHeadingCSS()
        css += generateParagraphCSS()
        css += generateInlineCodeCSS()
        css += generateBlockquoteCSS()
        css += generateLinkCSS()
        css += generateListCSS()
        css += generateTableCSS()
        css += generateSyntaxHighlightingCSS()
        return css
    }

    /// Applies typography classes to HTML content.
    public func apply(to html: String) -> String {
        var result = html

        result = applyHeadingClasses(to: result)
        result = applyCodeBlockClasses(to: result)
        result = applyInlineCodeClasses(to: result)
        result = applyBlockquoteClasses(to: result)
        result = applyLinkClasses(to: result)
        result = applyParagraphClasses(to: result)
        result = applyListClasses(to: result)
        result = applyTableClasses(to: result)

        return result
    }

    // MARK: - Private CSS Generation

    private func generateHeadingCSS() -> String {
        let prefix = classPrefix
        var css = ""

        for level in 1...6 {
            let multiplier = 1.0 - (Double(level - 1) * 0.1)
            let sizeValue = String(format: "%.2f", 1.5 * multiplier)
            let className = "\(prefix)h\(level)"

            css += ".\(className) {\n"
            css += "  font-family: \(headings.fontFamily);\n"
            css += "  font-size: \(sizeValue)rem;\n"
            css += "  font-weight: \(headings.fontWeight);\n"
            css += "  color: \(headings.color);\n"
            css += "  margin-top: \(headings.marginTop);\n"
            css += "  margin-bottom: \(headings.marginBottom);\n"
            css += "  line-height: \(headings.lineHeight);\n"
            css += "}\n\n"

            css += "@media (prefers-color-scheme: dark) {\n"
            css += "  .\(className) { color: \(headings.darkColor); }\n"
            css += "}\n\n"

        }

        return css
    }

    private func generateParagraphCSS() -> String {
        let className = "\(classPrefix)p"
        var css = ""

        css += ".\(className) {\n"
        css += "  margin-bottom: \(paragraphs.marginBottom);\n"
        css += "  line-height: \(paragraphs.lineHeight);\n"
        css += "  color: \(paragraphs.color);\n"
        css += "}\n\n"

        css += "@media (prefers-color-scheme: dark) {\n"
        css += "  .\(className) { color: \(paragraphs.darkColor); }\n"
        css += "}\n\n"

        return css
    }

    private func generateSyntaxHighlightingCSS() -> String {
        let syntax = syntaxHighlighting
        let prefix = classPrefix
        let containerClass = "\(prefix)code-block"
        var css = ""

        css += "pre.\(containerClass) > code .kw { color: \(syntax.keyword); }\n"
        css += "pre.\(containerClass) > code .str { color: \(syntax.string); }\n"
        css += "pre.\(containerClass) > code .com { color: \(syntax.comment); }\n"
        css += "pre.\(containerClass) > code .num { color: \(syntax.number); }\n"
        css += "pre.\(containerClass) > code .fn { color: \(syntax.function); }\n"
        css += "pre.\(containerClass) > code .typ { color: \(syntax.type); }\n"
        css += "pre.\(containerClass) > code .op { color: \(syntax.operator); }\n"
        css += "pre.\(containerClass) > code .prop { color: \(syntax.property); }\n"
        css += "pre.\(containerClass) > code .var { color: \(syntax.variable); }\n"
        css += "pre.\(containerClass) > code .punct { color: \(syntax.punctuation); }\n\n"

        return css
    }

    private func generateInlineCodeCSS() -> String {
        let className = "\(classPrefix)code"
        var css = ""

        css += ".\(className) {\n"
        css += "  font-family: \(inlineCode.fontFamily);\n"
        css += "  background-color: \(inlineCode.backgroundColor);\n"
        css += "  color: \(inlineCode.color);\n"
        css += "  padding: \(inlineCode.padding);\n"
        css += "  border-radius: \(inlineCode.borderRadius);\n"
        css += "  font-size: \(inlineCode.fontSize);\n"
        css += "}\n\n"

        css += "@media (prefers-color-scheme: dark) {\n"
        css += "  .\(className) { background-color: \(inlineCode.darkBackgroundColor); }\n"
        css += "}\n\n"

        return css
    }

    private func generateBlockquoteCSS() -> String {
        let className = "\(classPrefix)blockquote"
        var css = ""

        css += ".\(className) {\n"
        css += "  border-left: \(blockquotes.borderLeft);\n"
        css += "  padding-left: \(blockquotes.paddingLeft);\n"
        css += "  color: \(blockquotes.color);\n"
        css += "  font-style: \(blockquotes.fontStyle);\n"
        css += "  margin: \(paragraphs.marginBottom) 0;\n"
        css += "}\n\n"

        css += "@media (prefers-color-scheme: dark) {\n"
        css += "  .\(className) { color: \(blockquotes.darkColor); }\n"
        css += "}\n\n"

        return css
    }

    private func generateLinkCSS() -> String {
        let className = "\(classPrefix)link"
        var css = ""

        css += "a.\(className) {\n"
        css += "  color: \(links.color);\n"
        css += "  text-decoration: \(links.textDecoration);\n"
        css += "}\n\n"

        css += "a.\(className):hover {\n"
        css += "  text-decoration: \(links.hoverTextDecoration);\n"
        css += "}\n\n"

        css += "@media (prefers-color-scheme: dark) {\n"
        css += "  a.\(className) { color: \(links.darkColor); }\n"
        css += "}\n\n"

        return css
    }

    private func generateListCSS() -> String {
        let prefix = classPrefix
        var css = ""

        css += ".\(prefix)list-ordered {\n"
        css += "  list-style-type: \(lists.orderedMarker);\n"
        css += "  padding-left: \(lists.paddingLeft);\n"
        css += "}\n\n"

        css += ".\(prefix)list-unordered {\n"
        css += "  list-style-type: \(lists.unorderedMarker);\n"
        css += "  padding-left: \(lists.paddingLeft);\n"
        css += "}\n\n"

        css += ".\(prefix)list-ordered li, .\(prefix)list-unordered li {\n"
        css += "  margin-bottom: \(lists.itemMarginBottom);\n"
        css += "}\n\n"

        return css
    }

    private func generateTableCSS() -> String {
        let className = "\(classPrefix)table"
        var css = ""

        css += ".\(className) {\n"
        css += "  border-collapse: \(tables.borderCollapse);\n"
        css += "  width: 100%;\n"
        css += "  margin: \(paragraphs.marginBottom) 0;\n"
        css += "}\n\n"

        css += ".\(className) th, .\(className) td {\n"
        css += "  border: 1px solid \(tables.borderColor);\n"
        css += "  padding: \(tables.cellPadding);\n"
        css += "}\n\n"

        css += "@media (prefers-color-scheme: dark) {\n"
        css += "  .\(className) th, .\(className) td { border-color: \(tables.darkBorderColor); }\n"
        css += "}\n\n"

        let headerClass = "\(classPrefix)table-header"
        css += ".\(headerClass) {\n"
        css += "  background-color: \(tables.headerBackgroundColor);\n"
        css += "  font-weight: \(tables.headerFontWeight);\n"
        css += "  color: \(tables.headerColor);\n"
        css += "}\n\n"

        css += "@media (prefers-color-scheme: dark) {\n"
        css += "  .\(headerClass) {\n"
        css += "    background-color: \(tables.darkHeaderBackgroundColor);\n"
        css += "    color: \(tables.darkHeaderColor);\n"
        css += "  }\n"
        css += "}\n\n"

        return css
    }

    // MARK: - Private Class Application

    private func applyHeadingClasses(to html: String) -> String {
        var result = html
        for level in 1...6 {
            let pattern = "<h\(level)([^>]*)>(.*?)</h\(level)>"
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) {
                let range = NSRange(result.startIndex..., in: result)
                result = regex.stringByReplacingMatches(
                    in: result, options: [], range: range,
                    withTemplate: "<h\(level) class=\"\(classPrefix)h\(level)\">$2</h\(level)>"
                )
            }
        }
        return result
    }

    private func applyCodeBlockClasses(to html: String) -> String {
        let pattern = "<pre>(<code[^>]*>)(.*?)</code></pre>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else {
            return html
        }

        let range = NSRange(html.startIndex..., in: html)
        let matches = regex.matches(in: html, options: [], range: range)

        var result = html
        for match in matches.reversed() {
            if let codeTagRange = Range(match.range(at: 1), in: html),
                let contentRange = Range(match.range(at: 2), in: html)
            {
                let codeTag = String(html[codeTagRange])
                let codeContent = String(html[contentRange])

                let language = extractDataLang(from: codeTag)
                let processedCode = processTypstCodeContent(codeContent)

                let newHTML = TypstCodeBlock.generateHTML(
                    code: processedCode,
                    language: language,
                    fileName: nil,
                    showLineNumbers: codeBlocks.showLineNumbers,
                    showCopyButton: codeBlocks.showCopyButton,
                    classPrefix: classPrefix
                )

                if let matchRange = Range(match.range, in: result) {
                    result.replaceSubrange(matchRange, with: newHTML)
                }
            }
        }
        return result
    }

    private func extractDataLang(from tag: String) -> String? {
        let pattern = "data-lang=\"([^\"]*)\""
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
            let match = regex.firstMatch(in: tag, options: [], range: NSRange(tag.startIndex..., in: tag)),
            let range = Range(match.range(at: 1), in: tag)
        {
            return String(tag[range])
        }
        return nil
    }

    private func processTypstCodeContent(_ content: String) -> String {
        var result = content

        // Remove malformed HTML comments from Typst syntax highlighting
        // These look like: <!--<span class="typ"--> or similar
        result = result.replacingOccurrences(of: "<!--<span[^>]*-->", with: "", options: .regularExpression)

        // Only unescape things that are Typst's annotation markup, not the actual code content
        // The code content (like &lt; in HTML code) should remain escaped for display in <code> tags
        result = result.replacingOccurrences(of: "&amp;", with: "&")
        result = result.replacingOccurrences(of: "<br>", with: "\n")

        return result
    }

    private func applyInlineCodeClasses(to html: String) -> String {
        let pattern = "<code>(?![^<]*</code></pre>)"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(html.startIndex..., in: html)
            return regex.stringByReplacingMatches(
                in: html, options: [], range: range,
                withTemplate: "<code class=\"\(classPrefix)code\">"
            )
        }
        return html
    }

    private func applyBlockquoteClasses(to html: String) -> String {
        let pattern = "<blockquote[^>]*>(.*?)</blockquote>"
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) {
            let range = NSRange(html.startIndex..., in: html)
            return regex.stringByReplacingMatches(
                in: html, options: [], range: range,
                withTemplate: "<blockquote class=\"\(classPrefix)blockquote\">$1</blockquote>"
            )
        }
        return html
    }

    private func applyLinkClasses(to html: String) -> String {
        let pattern = "<a href=\"([^\"]*)\"[^>]*>(.*?)</a>"
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) {
            let range = NSRange(html.startIndex..., in: html)
            return regex.stringByReplacingMatches(
                in: html, options: [], range: range,
                withTemplate: "<a href=\"$1\" class=\"\(classPrefix)link\">$2</a>"
            )
        }
        return html
    }

    private func applyParagraphClasses(to html: String) -> String {
        let pattern = "<p>(.*?)</p>"
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) {
            let range = NSRange(html.startIndex..., in: html)
            return regex.stringByReplacingMatches(
                in: html, options: [], range: range,
                withTemplate: "<p class=\"\(classPrefix)p\">$1</p>"
            )
        }
        return html
    }

    private func applyListClasses(to html: String) -> String {
        var result = html

        let orderedPattern = "<ol[^>]*>(.*?)</ol>"
        if let regex = try? NSRegularExpression(pattern: orderedPattern, options: [.dotMatchesLineSeparators]) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(
                in: result, options: [], range: range,
                withTemplate: "<ol class=\"\(classPrefix)list-ordered\">$1</ol>"
            )
        }

        let unorderedPattern = "<ul[^>]*>(.*?)</ul>"
        if let regex = try? NSRegularExpression(pattern: unorderedPattern, options: [.dotMatchesLineSeparators]) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(
                in: result, options: [], range: range,
                withTemplate: "<ul class=\"\(classPrefix)list-unordered\">$1</ul>"
            )
        }

        return result
    }

    private func applyTableClasses(to html: String) -> String {
        var result = html

        let tablePattern = "<table[^>]*>(.*?)</table>"
        if let regex = try? NSRegularExpression(pattern: tablePattern, options: [.dotMatchesLineSeparators]) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(
                in: result, options: [], range: range,
                withTemplate: "<table class=\"\(classPrefix)table\">$1</table>"
            )
        }

        let headerPattern = "<th[^>]*>(.*?)</th>"
        if let regex = try? NSRegularExpression(pattern: headerPattern, options: [.dotMatchesLineSeparators]) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(
                in: result, options: [], range: range,
                withTemplate: "<th class=\"\(classPrefix)table-header\">$1</th>"
            )
        }

        let cellPattern = "<td[^>]*>(.*?)</td>"
        if let regex = try? NSRegularExpression(pattern: cellPattern, options: [.dotMatchesLineSeparators]) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(
                in: result, options: [], range: range,
                withTemplate: "<td>$1</td>"
            )
        }

        return result
    }
}
