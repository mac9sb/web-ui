import Foundation

/// A module for rendering Typst content to HTML with styling support.
///
/// This module provides functionality to transform Typst markup into styled HTML,
/// leveraging the Typst CLI compiler for accurate rendering. It supports syntax
/// highlighting, code blocks, and comprehensive typography styling.
///
/// ## Basic Usage
///
/// ```swift
/// let typst = WebUITypst()
/// let content = """
/// = Hello World
///
/// This is a paragraph with **bold** and _italic_ text.
///
/// ```swift
/// let greeting = "Hello, World!"
/// print(greeting)
/// ```
/// """
///
/// let result = try await typst.render(content)
/// print(result.htmlContent)
/// print(result.css)
/// ```
///
/// ## Custom Styling
///
/// ```swift
/// let styles = TypstTypographyStyles()
///     .withCodeBlock(backgroundColor: "#1e1e1e")
///     .withHeadingColor("#3b82f6")
///
/// let typst = WebUITypst(typography: styles)
/// let result = try await typst.render(content)
/// ```
///
/// ## Error Handling
///
/// The module provides throwing and safe variants for robust error handling.
public struct WebUITypst: Sendable {

    // MARK: - Configuration

    /// Rendering configuration options
    public let options: WebUITypstOptions

    /// Typography styling configuration
    public let typography: TypstTypography

    // MARK: - Initialization

    /// Initialize with default configuration
    public init() {
        self.options = WebUITypstOptions()
        self.typography = TypstTypography()
    }

    /// Initialize with custom options
    public init(options: WebUITypstOptions) {
        self.options = options
        self.typography = TypstTypography()
    }

    /// Initialize with custom typography
    public init(typography: TypstTypography) {
        self.options = WebUITypstOptions()
        self.typography = typography
    }

    /// Initialize with custom options and typography
    public init(options: WebUITypstOptions, typography: TypstTypography) {
        self.options = options
        self.typography = typography
    }

    // MARK: - Result Types

    /// Represents the result of rendering Typst content to HTML.
    public struct RenderedTypst {
        /// The HTML content generated from the Typst markup.
        public let htmlContent: String

        /// The CSS styles for the rendered content.
        public let css: String

        /// The JavaScript for interactive elements (e.g., copy buttons).
        public let js: String

        /// The front matter extracted from the document, if present.
        public let frontMatter: [String: String]

        /// Initializes a rendered result.
        public init(htmlContent: String, css: String, js: String, frontMatter: [String: String] = [:]) {
            self.htmlContent = htmlContent
            self.css = css
            self.js = js
            self.frontMatter = frontMatter
        }
    }

    // MARK: - Rendering

    /// Renders Typst content to HTML with styling.
    ///
    /// This method compiles the provided Typst markup using the Typst CLI and applies
    /// the configured typography styles to the generated HTML.
    ///
    /// - Parameter content: The raw Typst markup to render.
    /// - Returns: A `RenderedTypst` instance containing styled HTML and CSS.
    /// - Throws: `WebUITypstError` if rendering fails.
    public func render(_ content: String) async throws -> RenderedTypst {
        let (frontMatter, typstContent) = try extractFrontMatter(from: content)

        let renderedHtml = try await renderTypst(typstContent)
        let styledHtml = typography.apply(to: renderedHtml)

        let combinedCss = typography.generateCSS()
        let copyJs = generateCopyButtonScript(classPrefix: typography.classPrefix)

        return RenderedTypst(
            htmlContent: styledHtml,
            css: combinedCss,
            js: copyJs,
            frontMatter: frontMatter
        )
    }

    /// Renders Typst content with safe error handling.
    ///
    /// This method wraps rendering in a try-catch, returning fallback content
    /// if rendering fails rather than throwing.
    ///
    /// - Parameter content: The raw Typst markup to render.
    /// - Returns: A `RenderedTypst` instance or fallback content on error.
    public func renderSafely(_ content: String) async -> RenderedTypst {
        do {
            return try await render(content)
        } catch {
            return RenderedTypst(
                htmlContent: "<div class=\"typst-error\">Failed to render content</div>",
                css: "",
                js: "",  // Empty JS on error
                frontMatter: [:]
            )
        }
    }

    /// Renders Typst content synchronously (blocking).
    ///
    /// Useful for contexts where async/await is not available, such as computed properties.
    ///
    /// - Parameter content: The raw Typst markup to render.
    /// - Returns: A `RenderedTypst` instance containing styled HTML and CSS.
    /// - Throws: `WebUITypstError` if rendering fails.
    public func renderSync(_ content: String) throws -> RenderedTypst {
        let (frontMatter, typstContent) = try extractFrontMatter(from: content)

        let renderedHtml = try renderTypstSync(typstContent)
        let styledHtml = typography.apply(to: renderedHtml)

        let combinedCss = typography.generateCSS()
        let copyJs = generateCopyButtonScript(classPrefix: typography.classPrefix)

        return RenderedTypst(
            htmlContent: styledHtml,
            css: combinedCss,
            js: copyJs,
            frontMatter: frontMatter
        )
    }

    // MARK: - Asset Generation

    /// Generates static assets (CSS and JS) in the specified directory.
    ///
    /// - Parameter directory: The directory URL where assets should be written.
    ///   Typically `Public/` or similar. Subdirectories `styles` and `scripts` will be created.
    public func generateAssets(in directory: URL) throws {
        let fileManager = FileManager.default
        let stylesDir = directory.appendingPathComponent("styles")
        let scriptsDir = directory.appendingPathComponent("scripts")

        if !fileManager.fileExists(atPath: stylesDir.path()) {
            try fileManager.createDirectory(at: stylesDir, withIntermediateDirectories: true)
        }
        if !fileManager.fileExists(atPath: scriptsDir.path()) {
            try fileManager.createDirectory(at: scriptsDir, withIntermediateDirectories: true)
        }

        let css = generateCSS()
        try css.write(to: stylesDir.appendingPathComponent("typst.css"), atomically: true, encoding: .utf8)

        let scriptTag = generateCopyButtonScript()
        let js =
            scriptTag
            .replacingOccurrences(of: "<script>", with: "")
            .replacingOccurrences(of: "</script>", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        try js.write(to: scriptsDir.appendingPathComponent("typst.js"), atomically: true, encoding: .utf8)
    }

    // MARK: - CSS Generation

    /// Generates CSS styles for the configured typography.
    ///
    /// - Returns: A CSS string containing styles for all typography elements.
    public func generateCSS() -> String {
        typography.generateCSS()
    }

    /// Generates CSS styles for TypstCodeBlock components.
    ///
    /// - Parameter classPrefix: The class prefix used in code blocks.
    /// - Returns: A CSS string containing styles for code blocks.
    public func generateCodeBlockCSS(classPrefix: String = "typst-") -> String {
        TypstCodeBlockStyles(classPrefix: classPrefix).generateCSS()
    }

    /// Generates JavaScript for copy button functionality.
    ///
    /// - Parameter classPrefix: The class prefix used in code blocks.
    /// - Returns: A JavaScript string for copy functionality.
    public func generateCopyButtonScript(classPrefix: String = "typst-") -> String {
        """
        <script>
        (function() {
            const copyButtonClass = '\(classPrefix)copy-btn';
            const copiedClass = 'copied';
            const wrapperClass = '\(classPrefix)code-wrapper';
            const svgCopy = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>';
            const svgCheck = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>';

            document.querySelectorAll('.' + copyButtonClass).forEach(function(btn) {
                btn.addEventListener('click', function(e) {
                    e.preventDefault();
                    const wrapper = this.closest('.' + wrapperClass);
                    const codeElement = wrapper.querySelector('code');
                    const text = codeElement.textContent || codeElement.innerText;

                    navigator.clipboard.writeText(text).then(function() {
                        btn.innerHTML = svgCheck;
                        btn.classList.add(copiedClass);
                        setTimeout(function() {
                            btn.innerHTML = svgCopy;
                            btn.classList.remove(copiedClass);
                        }, 2000);
                    }).catch(function(err) {
                        console.error('Copy failed:', err);
                    });
                });
            });
        })();
        </script>
        """
    }

    // MARK: - Configuration Methods

    /// Creates a new instance with modified options.
    public func withOptions(_ options: WebUITypstOptions) -> WebUITypst {
        WebUITypst(options: options, typography: typography)
    }

    /// Creates a new instance with modified typography.
    public func withTypography(_ typography: TypstTypography) -> WebUITypst {
        WebUITypst(options: options, typography: typography)
    }

    /// Creates a new instance with both options and typography modified.
    public func withConfiguration(options: WebUITypstOptions, typography: TypstTypography) -> WebUITypst {
        WebUITypst(options: options, typography: typography)
    }

    // MARK: - Front Matter

    /// Extracts front matter and Typst content from raw content.
    ///
    /// Front matter is enclosed in `---` delimiters.
    public func extractFrontMatter(from content: String) throws -> (
        [String: String], String
    ) {
        let lines = content.components(separatedBy: .newlines)
        var frontMatter: [String: String] = [:]
        var contentStartIndex = 0

        if lines.first?.trimmingCharacters(in: .whitespaces) == "---" {
            var frontMatterLines: [String] = []
            var foundEndDelimiter = false

            for (index, line) in lines.dropFirst().enumerated() {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed == "---" {
                    foundEndDelimiter = true
                    contentStartIndex = index + 2
                    break
                }
                frontMatterLines.append(line)
            }

            guard foundEndDelimiter else {
                throw WebUITypstError.invalidFrontMatter
            }

            frontMatter = parseFrontMatterLines(frontMatterLines)
        }

        let typstContent = lines[contentStartIndex...].joined(separator: "\n")
        return (frontMatter, typstContent)
    }

    private func parseFrontMatterLines(_ lines: [String]) -> [String: String] {
        var frontMatter: [String: String] = [:]

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }

            let components = trimmed.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
            guard components.count == 2 else { continue }

            let key = components[0].trimmingCharacters(in: .whitespaces).lowercased()
            let value = components[1].trimmingCharacters(in: .whitespaces)
            frontMatter[key] = value
        }

        return frontMatter
    }

    // MARK: - Private Implementation

    private func renderTypst(_ content: String) async throws -> String {
        try renderTypstSync(content)
    }

    private func renderTypstSync(_ content: String) throws -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let inputFile = tempDir.appendingPathComponent(UUID().uuidString + ".typ")
        let outputFile = tempDir.appendingPathComponent(UUID().uuidString + ".html")

        defer {
            try? FileManager.default.removeItem(at: inputFile)
            try? FileManager.default.removeItem(at: outputFile)
        }

        try content.write(to: inputFile, atomically: true, encoding: .utf8)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: options.typstPath)
        process.arguments = [
            "compile", "--format", "html",
            "--features", "html",
            inputFile.path,
            outputFile.path,
        ]

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
            throw WebUITypstError.compilationFailed(errorOutput)
        }

        let fullHtml = try String(contentsOf: outputFile, encoding: .utf8)
        let stripped = stripHtmlWrapper(from: fullHtml)
        return rewriteTypstCodeSpans(stripped)
    }

    private func rewriteTypstCodeSpans(_ html: String) -> String {
        var result = html
        let colorToClass: [(String, String)] = [
            ("#d73948", "kw"),  // keyword
            ("#4b69c6", "typ"),  // type
            ("#198810", "str"),  // string
            ("#b60157", "num"),  // number
            ("#74747c", "com"),  // comment
        ]
        for (color, cls) in colorToClass {
            let pattern = "<span style=\"color: \(color)\">(.*?)</span>"
            let regex = try! NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
            let range = NSRange(result.startIndex..<result.endIndex, in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "<span class=\"\(cls)\">$1</span>")
        }
        return result
    }

    private func stripHtmlWrapper(from html: String) -> String {
        var result = html

        if let doctypeRange = result.range(of: "<!DOCTYPE html>") {
            result.removeSubrange(result.startIndex..<doctypeRange.upperBound)
        }

        if let htmlStart = result.range(of: "<html>") {
            result.removeSubrange(result.startIndex..<htmlStart.upperBound)
        }

        if let headStart = result.range(of: "<head>") {
            if let headEnd = result.range(of: "</head>") {
                result.removeSubrange(headStart.lowerBound..<headEnd.upperBound)
            }
        }

        if let bodyStart = result.range(of: "<body>") {
            result.removeSubrange(result.startIndex..<bodyStart.upperBound)
        }

        if let bodyEnd = result.range(of: "</body>") {
            result.removeSubrange(bodyEnd.lowerBound..<result.endIndex)
        }

        if let htmlEnd = result.range(of: "</html>") {
            result.removeSubrange(htmlEnd.lowerBound..<result.endIndex)
        }

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
