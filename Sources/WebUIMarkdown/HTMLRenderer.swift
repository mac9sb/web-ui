import Foundation
import Markdown

/// A renderer that converts a Markdown Abstract Syntax Tree (AST) into HTML with advanced features.
///
/// `HTMLRenderer` walks through the Markdown document structure and generates appropriate
/// HTML tags for each Markdown element, with support for:
/// - Syntax highlighting with semantic HTML output
/// - Table of contents generation
/// - Interactive code block features (copy button, line numbers, run button)
/// - Typography styling integration
/// - Mathematical notation support
/// - Enhanced accessibility features
///
/// ## Usage
///
/// ```swift
/// // Basic usage with default options
/// let document = Document(parsing: markdownContent)
/// let options = MarkdownRenderingOptions.basic
/// let typography = MarkdownTypography.default
/// var renderer = HTMLRenderer(options: options, typography: typography)
/// let html = try renderer.render(document)
///
/// // With table of contents
/// var renderer = HTMLRenderer(options: .enhanced, typography: .documentation)
/// let (html, toc) = try renderer.renderWithTableOfContents(document)
/// ```
///
/// ## Error Handling
///
/// The renderer throws `HTMLRendererError` for invalid content:
///
/// ```swift
/// do {
///     let html = try renderer.render(document)
/// } catch HTMLRendererError.invalidLinkDestination {
///     print("Found a link without a destination")
/// } catch HTMLRendererError.missingImageSource {
///     print("Found an image without a source")
/// } catch {
///     print("Rendering failed: \(error)")
/// }
/// ```
public struct HTMLRenderer {

    // MARK: - Configuration

    /// Rendering options that control feature availability
    public let options: MarkdownRenderingOptions

    /// Typography configuration for styling
    public let typography: MarkdownTypography

    /// Generated HTML content
    public var html = ""

    /// Table of contents entries collected during rendering
    public var tableOfContentsEntries: [TableOfContentsEntry] = []

    /// Counter for generating unique IDs
    private var idCounter = 0

    /// Flag indicating whether we're currently processing a table head
    public var insideTableHead = false

    // MARK: - Data Structures

    /// Represents an entry in the table of contents
    public struct TableOfContentsEntry {
        public let level: Int
        public let text: String
        public let id: String
        public let children: [TableOfContentsEntry]

        public init(level: Int, text: String, id: String, children: [TableOfContentsEntry] = []) {
            self.level = level
            self.text = text
            self.id = id
            self.children = children
        }
    }

    /// Represents syntax highlighting information for a code block
    public struct SyntaxHighlightInfo {
        public let language: MarkdownRenderingOptions.SupportedLanguage?
        public let fileName: String?
        public let code: String
        public let highlightedHTML: String

        public init(language: MarkdownRenderingOptions.SupportedLanguage?, fileName: String?, code: String, highlightedHTML: String) {
            self.language = language
            self.fileName = fileName
            self.code = code
            self.highlightedHTML = highlightedHTML
        }
    }

    // MARK: - Initialization

    /// Initialize the HTML renderer with configuration options
    public init(
        options: MarkdownRenderingOptions,
        typography: MarkdownTypography
    ) {
        self.options = options
        self.typography = typography
    }

    // MARK: - Main Rendering Methods

    /// Renders a Markdown document into HTML.
    ///
    /// Traverses the entire document tree and converts each node into its corresponding HTML representation.
    ///
    /// - Parameter document: The Markdown document to render.
    /// - Returns: The generated HTML string.
    /// - Throws: `HTMLRendererError` if rendering encounters invalid content.
    public mutating func render(_ document: Markdown.Document) throws -> String {
        html = ""
        tableOfContentsEntries = []
        idCounter = 0

        // Add wrapper div with typography classes
        html += "<div class=\"markdown-content\">"

        try renderMarkup(document)

        html += "</div>"

        return html
    }

    /// Renders a Markdown document with table of contents.
    ///
    /// - Parameter document: The Markdown document to render.
    /// - Returns: A tuple containing the HTML content and table of contents HTML.
    /// - Throws: `HTMLRendererError` if rendering encounters invalid content.
    public mutating func renderWithTableOfContents(_ document: Markdown.Document) throws -> (html: String, tableOfContents: String) {
        let mainHTML = try render(document)
        let tocHTML = generateTableOfContentsHTML()
        return (mainHTML, tocHTML)
    }

    /// Renders a Markdown document into HTML with graceful error handling.
    ///
    /// This is a convenience method that handles errors gracefully by skipping problematic
    /// nodes and continuing with the rest of the document.
    ///
    /// - Parameter document: The Markdown document to render.
    /// - Returns: The generated HTML string. Problematic nodes are replaced with error messages.
    public mutating func renderSafely(_ document: Markdown.Document) -> String {
        html = ""
        do {
            try renderMarkup(document)
        } catch {
            html += "<!-- Rendering error: \(error.localizedDescription) -->"
        }
        return html
    }

    // MARK: - Markup Rendering

    /// Renders any markup node by dispatching to the appropriate visit method.
    ///
    /// - Parameter markup: The markup node to render.
    /// - Throws: `HTMLRendererError` if rendering encounters invalid content.
    private mutating func renderMarkup(_ markup: Markup) throws {
        switch markup {
        case let heading as Markdown.Heading:
            try visitHeading(heading)
        case let paragraph as Paragraph:
            try visitParagraph(paragraph)
        case let text as Markdown.Text:
            try visitText(text)
        case let link as Markdown.Link:
            try visitLink(link)
        case let emphasis as Markdown.Emphasis:
            try visitEmphasis(emphasis)
        case let strong as Markdown.Strong:
            try visitStrong(strong)
        case let codeBlock as CodeBlock:
            try visitCodeBlock(codeBlock)
        case let inlineCode as InlineCode:
            try visitInlineCode(inlineCode)
        case let listItem as ListItem:
            try visitListItem(listItem)
        case let unorderedList as UnorderedList:
            try visitUnorderedList(unorderedList)
        case let orderedList as OrderedList:
            try visitOrderedList(orderedList)
        case let blockQuote as BlockQuote:
            try visitBlockQuote(blockQuote)
        case let thematicBreak as ThematicBreak:
            try visitThematicBreak(thematicBreak)
        case let image as Markdown.Image:
            try visitImage(image)
        case let table as Table:
            try visitTable(table)
        case let tableHead as Table.Head:
            try visitTableHead(tableHead)
        case let tableRow as Table.Row:
            try visitTableRow(tableRow)
        case let tableBody as Table.Body:
            try visitTableBody(tableBody)
        case let tableCell as Table.Cell:
            try visitTableCell(tableCell)
        case let htmlBlock as Markdown.HTMLBlock:
            try visitHTMLBlock(htmlBlock)
        case let inlineHTML as Markdown.InlineHTML:
            try visitInlineHTML(inlineHTML)
        default:
            try defaultVisit(markup)
        }
    }

    /// Renders all child markup nodes of a container.
    ///
    /// - Parameter markup: The container markup node whose children should be rendered.
    /// - Throws: `HTMLRendererError` if rendering encounters invalid content.
    private mutating func renderChildren(_ markup: Markup) throws {
        for child in markup.children {
            try renderMarkup(child)
        }
    }

    // MARK: - Element Visitors

    /// Visits a heading node and generates HTML with optional ToC integration.
    public mutating func visitHeading(_ heading: Markdown.Heading) throws {
        let level = heading.level
        let headingText = heading.plainText

        // Generate heading ID if table of contents is enabled
        let headingId: String?
        if options.tableOfContents.isEnabled && options.tableOfContents.includeIds {
            headingId = generateHeadingId(from: headingText)

            // Add to table of contents if within max depth
            if level <= options.tableOfContents.maxDepth, let resolvedHeadingId = headingId {
                let entry = TableOfContentsEntry(level: level, text: headingText, id: resolvedHeadingId)
                tableOfContentsEntries.append(entry)
            }
        } else {
            headingId = nil
        }

        // Apply typography styling
        let headingLevel = MarkdownTypography.HeadingLevel(rawValue: level) ?? .h6
        let style = typography.style(for: headingLevel)
        let styleClass = style != nil ? " class=\"\(headingLevel.cssClassName)\"" : ""
        let idAttr = headingId.map { " id=\"\($0)\"" } ?? ""

        html += "<h\(level)\(idAttr)\(styleClass)>"
        try renderChildren(heading)
        html += "</h\(level)>"
    }

    /// Visits a paragraph node and generates HTML with typography styling.
    public mutating func visitParagraph(_ paragraph: Paragraph) throws {
        let style = typography.style(for: .paragraph)
        let styleClass = style != nil ? " class=\"\(MarkdownTypography.ElementType.paragraph.cssClassName)\"" : ""

        html += "<p\(styleClass)>"
        try renderChildren(paragraph)
        html += "</p>"
    }

    /// Visits a text node and generates escaped HTML content with math support.
    public mutating func visitText(_ text: Markdown.Text) throws {
        let textContent = text.string

        // Check for mathematical notation if enabled
        if options.mathSupport.isEnabled {
            let processedText = processMathematicalNotation(textContent)
            html += processedText
        } else {
            html += escapeHTML(textContent)
        }
    }

    /// Visits a link node and generates HTML with typography styling.
    ///
    /// - Throws: `HTMLRendererError.invalidLinkDestination` if the link has no destination.
    public mutating func visitLink(_ link: Markdown.Link) throws {
        guard let destination = link.destination, !destination.isEmpty else {
            throw HTMLRendererError.invalidLinkDestination(
                destination: link.destination,
                reason: "Link destination cannot be empty"
            )
        }

        let escapedDestination = escapeHTML(destination)
        let isExternal = escapedDestination.hasPrefix("http://") || escapedDestination.hasPrefix("https://")
        let targetAttr = isExternal ? " target=\"_blank\" rel=\"noopener noreferrer\"" : ""

        let style = typography.style(for: .link)
        let styleClass = style != nil ? " class=\"\(MarkdownTypography.ElementType.link.cssClassName)\"" : ""

        html += "<a href=\"\(escapedDestination)\"\(targetAttr)\(styleClass)>"
        try renderChildren(link)
        html += "</a>"
    }

    /// Visits an emphasis node and generates HTML with typography styling.
    public mutating func visitEmphasis(_ emphasis: Markdown.Emphasis) throws {
        let style = typography.style(for: .emphasis)
        let styleClass = style != nil ? " class=\"\(MarkdownTypography.ElementType.emphasis.cssClassName)\"" : ""

        html += "<em\(styleClass)>"
        try renderChildren(emphasis)
        html += "</em>"
    }

    /// Visits a strong node and generates HTML with typography styling.
    public mutating func visitStrong(_ strong: Markdown.Strong) throws {
        let style = typography.style(for: .strong)
        let styleClass = style != nil ? " class=\"\(MarkdownTypography.ElementType.strong.cssClassName)\"" : ""

        html += "<strong\(styleClass)>"
        try renderChildren(strong)
        html += "</strong>"
    }

    /// Visits a code block node and generates HTML with syntax highlighting and interactive features.
    ///
    /// - Parameter codeBlock: The code block node to render.
    /// - Throws: `HTMLRendererError.invalidCodeBlock` if the code block content is invalid.
    public mutating func visitCodeBlock(_ codeBlock: CodeBlock) throws {
        guard !codeBlock.code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw HTMLRendererError.invalidCodeBlock(
                language: codeBlock.language,
                contentLength: codeBlock.code.count
            )
        }

        let code = codeBlock.code
        let language = detectLanguage(from: codeBlock.language)
        let fileName = extractFileName(from: codeBlock.language)

        // Generate syntax highlighting if enabled
        let highlightInfo: SyntaxHighlightInfo
        if options.syntaxHighlighting.isEnabled,
            let detectedLanguage = language,
            options.syntaxHighlighting.supportedLanguages.contains(detectedLanguage)
        {
            let highlightedHTML = generateSyntaxHighlighting(code: code, language: detectedLanguage)
            highlightInfo = SyntaxHighlightInfo(
                language: detectedLanguage,
                fileName: fileName,
                code: code,
                highlightedHTML: highlightedHTML
            )
        } else {
            highlightInfo = SyntaxHighlightInfo(
                language: language,
                fileName: fileName,
                code: code,
                highlightedHTML: escapeHTML(code)
            )
        }

        html += generateCodeBlockHTML(highlightInfo: highlightInfo)
    }

    /// Visits an inline code node and generates HTML with typography styling.
    public mutating func visitInlineCode(_ inlineCode: InlineCode) throws {
        let style = typography.style(for: .inlineCode)
        let styleClass = style != nil ? " class=\"\(MarkdownTypography.ElementType.inlineCode.cssClassName)\"" : ""

        html += "<code\(styleClass)>"
        html += escapeHTML(inlineCode.code)
        html += "</code>"
    }

    /// Visits a block quote node and generates HTML with typography styling.
    public mutating func visitBlockQuote(_ blockQuote: BlockQuote) throws {
        let style = typography.style(for: .blockquote)
        let styleClass = style != nil ? " class=\"\(MarkdownTypography.ElementType.blockquote.cssClassName)\"" : ""

        html += "<blockquote\(styleClass)>"
        try renderChildren(blockQuote)
        html += "</blockquote>"
    }

    /// Visits a list item node and generates HTML with typography styling.
    public mutating func visitListItem(_ listItem: ListItem) throws {
        let style = typography.style(for: .listItem)
        let styleClass = style != nil ? " class=\"\(MarkdownTypography.ElementType.listItem.cssClassName)\"" : ""

        html += "<li\(styleClass)>"
        try renderChildren(listItem)
        html += "</li>"
    }

    /// Visits an unordered list node and generates HTML with typography styling.
    public mutating func visitUnorderedList(_ unorderedList: UnorderedList) throws {
        let style = typography.style(for: .unorderedList)
        let styleClass = style != nil ? " class=\"\(MarkdownTypography.ElementType.unorderedList.cssClassName)\"" : ""

        html += "<ul\(styleClass)>"
        try renderChildren(unorderedList)
        html += "</ul>"
    }

    /// Visits an ordered list node and generates HTML with typography styling.
    public mutating func visitOrderedList(_ orderedList: OrderedList) throws {
        let style = typography.style(for: .orderedList)
        let styleClass = style != nil ? " class=\"\(MarkdownTypography.ElementType.orderedList.cssClassName)\"" : ""

        html += "<ol\(styleClass)>"
        try renderChildren(orderedList)
        html += "</ol>"
    }

    /// Visits a thematic break node and generates HTML with typography styling.
    public mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) throws {
        let style = typography.style(for: .horizontalRule)
        let styleClass = style != nil ? " class=\"\(MarkdownTypography.ElementType.horizontalRule.cssClassName)\"" : ""

        html += "<hr\(styleClass) />"
    }

    /// Visits an image node and generates HTML with typography styling.
    ///
    /// - Throws: `HTMLRendererError.missingImageSource` if the image has no source.
    public mutating func visitImage(_ image: Markdown.Image) throws {
        guard let source = image.source, !source.isEmpty else {
            throw HTMLRendererError.missingImageSource(altText: image.plainText)
        }

        let altText = image.plainText
        let escapedSource = escapeHTML(source)
        let escapedAltText = escapeHTML(altText)

        let style = typography.style(for: .image)
        let styleClass = style != nil ? " class=\"\(MarkdownTypography.ElementType.image.cssClassName)\"" : ""

        html += "<img src=\"\(escapedSource)\" alt=\"\(escapedAltText)\"\(styleClass) />"
    }

    // MARK: - Table Visitors

    /// Visits a table node and generates HTML with typography styling.
    public mutating func visitTable(_ table: Table) throws {
        let style = typography.style(for: .table)
        let styleClass = style != nil ? " class=\"\(MarkdownTypography.ElementType.table.cssClassName)\"" : ""

        html += "<table\(styleClass)>"
        try renderChildren(table)
        html += "</table>"
    }

    /// Visits a table head node and generates HTML.
    public mutating func visitTableHead(_ tableHead: Table.Head) throws {
        html += "<thead><tr>"
        insideTableHead = true
        for child in tableHead.children {
            if let cell = child as? Table.Cell {
                try visitTableCell(cell)
            } else {
                try renderMarkup(child)
            }
        }
        insideTableHead = false
        html += "</tr></thead>"
    }

    /// Visits a table row node and generates HTML with typography styling.
    public mutating func visitTableRow(_ tableRow: Table.Row) throws {
        let style = typography.style(for: .tableRow)
        let styleClass = style != nil ? " class=\"\(MarkdownTypography.ElementType.tableRow.cssClassName)\"" : ""

        html += "<tr\(styleClass)>"
        for child in tableRow.children {
            if let cell = child as? Table.Cell {
                try visitTableCell(cell)
            } else {
                try renderMarkup(child)
            }
        }
        html += "</tr>"
    }

    /// Visits a table body node and generates HTML.
    public mutating func visitTableBody(_ tableBody: Table.Body) throws {
        html += "<tbody>"
        try renderChildren(tableBody)
        html += "</tbody>"
    }

    /// Visits a table cell node and generates HTML with typography styling.
    public mutating func visitTableCell(_ tableCell: Table.Cell) throws {
        let tag = insideTableHead ? "th" : "td"
        let elementType: MarkdownTypography.ElementType = insideTableHead ? .tableHeader : .tableCell
        let style = typography.style(for: elementType)
        let styleClass = style != nil ? " class=\"\(elementType.cssClassName)\"" : ""

        html += "<\(tag)\(styleClass)>"
        try renderChildren(tableCell)
        html += "</\(tag)>"
    }

    /// Visits a block of raw HTML and adds it to the output.
    public mutating func visitHTMLBlock(_ htmlBlock: Markdown.HTMLBlock) throws {
        html += htmlBlock.rawHTML
    }

    /// Visits inline raw HTML and adds it to the output.
    public mutating func visitInlineHTML(_ inlineHTML: Markdown.InlineHTML) throws {
        html += inlineHTML.rawHTML
    }

    /// A fallback method for visiting any unhandled markup nodes.
    public mutating func defaultVisit(_ markup: Markup) throws {
        try renderChildren(markup)
    }

    // MARK: - Utility Methods

    /// Generates a unique ID for a heading based on its text content
    private mutating func generateHeadingId(from text: String) -> String {
        let baseId =
            text
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "[^a-z0-9-]", with: "", options: .regularExpression)

        idCounter += 1
        return "\(baseId)-\(idCounter)"
    }

    /// Detects the programming language from a code block's language identifier
    private func detectLanguage(from languageString: String?) -> MarkdownRenderingOptions.SupportedLanguage? {
        guard let lang = languageString?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }

        // Handle common aliases
        switch lang {
        case "js": return .javascript
        case "ts": return .typescript
        case "sh": return .shell
        case "py": return .python
        case "rb": return .ruby
        case "cpp", "c++": return .cpp
        default:
            return MarkdownRenderingOptions.SupportedLanguage(rawValue: lang)
        }
    }

    /// Extracts a filename from the language string (e.g., "swift:MyFile.swift")
    private func extractFileName(from languageString: String?) -> String? {
        guard let lang = languageString, lang.contains(":") else {
            return nil
        }

        let components = lang.split(separator: ":", maxSplits: 1)
        return components.count > 1 ? String(components[1]).trimmingCharacters(in: .whitespacesAndNewlines) : nil
    }

    /// Generates syntax highlighting HTML for code
    private func generateSyntaxHighlighting(code: String, language: MarkdownRenderingOptions.SupportedLanguage) -> String {
        // This is a simplified syntax highlighter
        // In a real implementation, you might use a proper syntax highlighting library
        generateBasicSyntaxHighlighting(code: code, language: language)
    }

    /// Generates basic syntax highlighting using simple pattern matching
    private func generateBasicSyntaxHighlighting(code: String, language: MarkdownRenderingOptions.SupportedLanguage) -> String {
        let escapedCode = escapeHTML(code)

        switch language {
        case .swift:
            return highlightSwiftSyntax(escapedCode)
        case .javascript, .typescript:
            return highlightJavaScriptSyntax(escapedCode)
        case .html:
            return highlightHTMLSyntax(escapedCode)
        case .css:
            return highlightCSSSyntax(escapedCode)
        default:
            return escapedCode
        }
    }

    /// Configuration for syntax highlighting a specific language
    private struct SyntaxHighlightConfig {
        let keywords: [String]
        let patterns: [(regex: String, cssClass: String)]
    }

    /// Language-specific syntax highlighting configurations
    private static let highlightConfigs: [String: SyntaxHighlightConfig] = [
        "swift": SyntaxHighlightConfig(
            keywords: ["func", "var", "let", "class", "struct", "enum", "protocol", "import", "if", "else", "for", "while", "return", "public", "private", "internal"],
            patterns: [
                ("\"([^\"\\\\]|\\\\.)*\"", "string"),
                ("//.*$", "comment"),
            ]
        ),
        "javascript": SyntaxHighlightConfig(
            keywords: ["function", "var", "let", "const", "class", "if", "else", "for", "while", "return", "import", "export", "async", "await"],
            patterns: [
                ("('[^'\\\\]|\\\\.)*'|\"([^\"\\\\]|\\\\.)*\"|`([^`\\\\]|\\\\.)*`", "string")
            ]
        ),
        "html": SyntaxHighlightConfig(
            keywords: [],
            patterns: [
                ("</?[a-zA-Z][^>]*>", "tag")
            ]
        ),
        "css": SyntaxHighlightConfig(
            keywords: [],
            patterns: [
                ("([a-zA-Z][a-zA-Z0-9-]*|\\.[a-zA-Z][a-zA-Z0-9-]*|#[a-zA-Z][a-zA-Z0-9-]*)\\s*\\{", "selector"),
                ("([a-zA-Z-]+)\\s*:", "property"),
            ]
        ),
    ]

    /// Generic syntax highlighting using language configuration
    private func highlightWithConfig(_ code: String, language: String) -> String {
        guard let config = Self.highlightConfigs[language] else {
            return code
        }

        var highlighted = code

        // Apply keyword highlighting
        for keyword in config.keywords {
            highlighted = highlighted.replacingOccurrences(
                of: "\\b\(keyword)\\b",
                with: "<span class=\"keyword\">\(keyword)</span>",
                options: .regularExpression
            )
        }

        // Apply pattern-based highlighting
        for (regex, cssClass) in config.patterns {
            if cssClass == "selector" || cssClass == "property" {
                // Special handling for CSS patterns with capture groups
                highlighted = highlighted.replacingOccurrences(
                    of: regex,
                    with: "<span class=\"\(cssClass)\">$1</span>\(cssClass == "selector" ? " {" : ":")",
                    options: .regularExpression
                )
            } else {
                highlighted = highlighted.replacingOccurrences(
                    of: regex,
                    with: "<span class=\"\(cssClass)\">$0</span>",
                    options: .regularExpression
                )
            }
        }

        return highlighted
    }

    /// Basic Swift syntax highlighting
    private func highlightSwiftSyntax(_ code: String) -> String {
        highlightWithConfig(code, language: "swift")
    }

    /// Basic JavaScript syntax highlighting
    private func highlightJavaScriptSyntax(_ code: String) -> String {
        highlightWithConfig(code, language: "javascript")
    }

    /// Basic HTML syntax highlighting
    private func highlightHTMLSyntax(_ code: String) -> String {
        highlightWithConfig(code, language: "html")
    }

    /// Basic CSS syntax highlighting
    private func highlightCSSSyntax(_ code: String) -> String {
        highlightWithConfig(code, language: "css")
    }

    /// Generates enhanced HTML for code blocks with interactive features
    private func generateCodeBlockHTML(highlightInfo: SyntaxHighlightInfo) -> String {
        var html = ""

        // Start pre tag with appropriate classes
        var cssClasses = ["markdown-code-block"]
        if let language = highlightInfo.language {
            cssClasses.append(language.cssClassName)
        }
        if options.codeBlocks.wrapLines {
            cssClasses.append("wrap-lines")
        }

        let style = typography.style(for: .codeBlock)
        if style != nil {
            cssClasses.append(MarkdownTypography.ElementType.codeBlock.cssClassName)
        }

        html += "<pre class=\"\(cssClasses.joined(separator: " "))\">"

        // Add header with filename and controls if enabled
        if options.codeBlocks.showFileName || options.codeBlocks.copyButton || options.codeBlocks.runButton {
            html += "<div class=\"code-block-header\">"

            // Filename or language
            if options.codeBlocks.showFileName {
                if let fileName = highlightInfo.fileName {
                    html += "<span class=\"code-filename\">\(escapeHTML(fileName))</span>"
                } else if let language = highlightInfo.language {
                    html += "<span class=\"code-language\">\(language.displayName)</span>"
                }
            }

            // Controls
            html += "<div class=\"code-controls\">"

            if options.codeBlocks.copyButton {
                html += "<button class=\"copy-button\" type=\"button\" data-copy-text=\"\(escapeHTML(highlightInfo.code))\">"
                html += escapeHTML(options.codeBlocks.copyButtonText)
                html += "</button>"
            }

            if options.codeBlocks.runButton && highlightInfo.language == .swift {
                html += "<button class=\"run-button\" type=\"button\" data-run-code=\"\(escapeHTML(highlightInfo.code))\">"
                html += escapeHTML(options.codeBlocks.runButtonText)
                html += "</button>"
            }

            html += "</div>"
            html += "</div>"
        }

        // Code content
        if options.codeBlocks.lineNumbers {
            let lines = highlightInfo.highlightedHTML.components(separatedBy: .newlines)
            html += "<div class=\"code-content-with-lines\">"
            html += "<div class=\"line-numbers\">"
            for i in 1...lines.count {
                html += "<span class=\"line-number\">\(i)</span>"
            }
            html += "</div>"
            html += "<code class=\"code-content\">\(highlightInfo.highlightedHTML)</code>"
            html += "</div>"
        } else {
            html += "<code>\(highlightInfo.highlightedHTML)</code>"
        }

        html += "</pre>"

        return html
    }

    /// Processes mathematical notation in text content
    private func processMathematicalNotation(_ text: String) -> String {
        var processed = text

        // Process inline math ($...$)
        processed = processed.replacingOccurrences(
            of: "\\$([^$]+)\\$",
            with: "<span class=\"math-inline\">$1</span>",
            options: .regularExpression
        )

        // Process block math (```math...```)
        processed = processed.replacingOccurrences(
            of: "```math\\n([\\s\\S]*?)\\n```",
            with: "<div class=\"math-block\">$1</div>",
            options: .regularExpression
        )

        return escapeHTML(processed)
    }

    /// Generates table of contents HTML
    public func generateTableOfContentsHTML() -> String {
        guard !tableOfContentsEntries.isEmpty else {
            return ""
        }

        var html = "<aside id=\"table-of-contents\" class=\"markdown-toc\">"
        html += "<nav>"
        html += "<h2>Table of Contents</h2>"
        html += "<ul>"

        for entry in tableOfContentsEntries {
            html += "<li>"
            html += "<a href=\"#\(entry.id)\">\(escapeHTML(entry.text))</a>"
            // Note: Nested ToC structure could be added here for hierarchical headings
            html += "</li>"
        }

        html += "</ul>"
        html += "</nav>"
        html += "</aside>"

        return html
    }

    /// Escapes special HTML characters in a string to prevent injection.
    ///
    /// - Parameter string: The string to escape.
    /// - Returns: The escaped HTML string.
    public func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}

// MARK: - Error Types

/// Errors that can occur during WebUIMarkdown operations.
public enum WebUIMarkdownError: Error, LocalizedError, Equatable {
    /// Front matter delimiter is opened but not properly closed.
    case invalidFrontMatter
    /// No front matter found in the document.
    case noFrontMatter
    /// Front matter contains malformed key-value pairs.
    case malformedFrontMatter(line: String)
    /// Date parsing failed for a front matter value.
    case dateParsingFailed(key: String, value: String)
    /// Markdown content is empty or invalid.
    case emptyContent

    public var errorDescription: String? {
        switch self {
        case .invalidFrontMatter:
            return "Front matter is not properly closed with '---'"
        case .noFrontMatter:
            return "No front matter found in the document"
        case .malformedFrontMatter(let line):
            return "Malformed front matter line: '\(line)'"
        case .dateParsingFailed(let key, let value):
            return
                "Failed to parse date for key '\(key)' with value '\(value)'"
        case .emptyContent:
            return "Markdown content is empty or invalid"
        }
    }
}

/// Errors that can occur during HTML rendering from Markdown.
public enum HTMLRendererError: Error, LocalizedError {
    /// Link destination is missing or invalid.
    case invalidLinkDestination(destination: String?, reason: String)
    /// Image source is missing.
    case missingImageSource(altText: String?)
    /// Table structure is malformed.
    case malformedTable(reason: String)
    /// Code block contains invalid content.
    case invalidCodeBlock(language: String?, contentLength: Int)

    public var errorDescription: String? {
        switch self {
        case .invalidLinkDestination(let dest, let reason):
            let destStr = dest.map { "'\($0)'" } ?? "empty"
            return "Link destination is missing or invalid (\(destStr)): \(reason)"
        case .missingImageSource(let alt):
            let altStr = alt.map { "alt text: '\($0)'" } ?? "no alt text"
            return "Image source is required but missing (\(altStr))"
        case .malformedTable(let reason):
            return "Table structure is malformed: \(reason)"
        case .invalidCodeBlock(let lang, let length):
            let langStr = lang.map { " (language: \($0))" } ?? ""
            return "Code block contains invalid content\(langStr), content length: \(length)"
        }
    }
}
