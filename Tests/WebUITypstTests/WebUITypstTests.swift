import Testing

@testable import WebUITypst

struct WebUITypstTests {

    // MARK: - Initialization Tests

    @Test func defaultInitialization() {
        let typst = WebUITypst()

        #expect(typst.options.typstPath == "/opt/homebrew/bin/typst")
        #expect(typst.options.outputFormat == .html)
    }

    @Test func customOptionsInitialization() {
        let options = WebUITypstOptions()
            .withTypstPath("/usr/local/bin/typst")
            .withOutputFormat(.pdf)

        let typst = WebUITypst(options: options)

        #expect(typst.options.typstPath == "/usr/local/bin/typst")
        #expect(typst.options.outputFormat == .pdf)
    }

    // MARK: - Rendering Tests

    @Test func renderSimpleContent() async throws {
        let typst = WebUITypst()
        let content = """
            = Heading

            This is a paragraph.
            """

        let result = try await typst.render(content)

        #expect(!result.htmlContent.isEmpty)
        #expect(result.htmlContent.contains("Heading"))
        #expect(!result.css.isEmpty)
    }

    @Test func renderWithCodeBlock() async throws {
        let typst = WebUITypst()
        let content = """
            ```swift
            let x = 42
            ```
            """

        let result = try await typst.render(content)

        #expect(result.htmlContent.contains("let x = 42"))
        #expect(result.css.contains("code-block"))
    }

    @Test func renderWithFrontMatter() async throws {
        let typst = WebUITypst()
        let content = """
            ---
            title: Test Post
            date: January 1, 2024
            ---

            # Content
            """

        let result = try await typst.render(content)

        #expect(result.frontMatter["title"] == "Test Post")
        #expect(result.frontMatter["date"] == "January 1, 2024")
    }

    @Test func renderSafelyFallback() async {
        let typst = WebUITypst()

        let result = await typst.renderSafely("invalid content")

        #expect(result.htmlContent.contains("typst-error"))
    }

    // MARK: - CSS Generation Tests

    @Test func generateCSS() {
        let typst = WebUITypst()
        let css = typst.generateCSS()

        #expect(!css.isEmpty)
        #expect(css.contains(".typst-h1"))
        #expect(css.contains(".typst-code-block"))
        #expect(css.contains(".typst-p"))
    }

    @Test func customTypographyGeneratesCSS() {
        var typography = TypstTypography()
        typography = typography.withCodeBlock { codeBlock in
            codeBlock.backgroundColor = "#1e1e2e"
        }

        let css = typography.generateCSS()

        #expect(css.contains("#1e1e2e"))
    }

    // MARK: - Typography Configuration Tests

    @Test func defaultTypographyValues() {
        let typography = TypstTypography()

        #expect(typography.headings.fontFamily.contains("system-ui"))
        #expect(typography.codeBlocks.fontFamily.contains("monospace"))
        #expect(typography.syntaxHighlighting.keyword == "#f472b6")
    }

    @Test func typographyWithCustomHeadings() {
        let typography = TypstTypography().withHeadings { headings in
            headings.fontWeight = "800"
        }

        #expect(typography.headings.fontWeight == "800")
    }

    @Test func typographyWithSyntaxHighlighting() {
        let typography = TypstTypography().withSyntaxHighlighting { syntax in
            syntax.keyword = "#ff79c6"
            syntax.string = "#50fa7b"
        }

        #expect(typography.syntaxHighlighting.keyword == "#ff79c6")
        #expect(typography.syntaxHighlighting.string == "#50fa7b")
    }

    // MARK: - Configuration Method Tests

    @Test func withOptionsMethod() {
        let original = WebUITypst()
        let modified = original.withOptions(
            WebUITypstOptions().withTypstPath("/custom/path")
        )

        #expect(original.options.typstPath == "/opt/homebrew/bin/typst")
        #expect(modified.options.typstPath == "/custom/path")
    }

    @Test func withTypographyMethod() {
        let original = WebUITypst()
        let modified = original.withTypography(
            TypstTypography().withClassPrefix("custom-")
        )

        #expect(original.typography.classPrefix == "typst-")
        #expect(modified.typography.classPrefix == "custom-")
    }

    // MARK: - Options Tests

    @Test func optionsWithFontPaths() {
        let options = WebUITypstOptions()
            .withFontPaths(["/fonts", "/usr/share/fonts"])

        #expect(options.fontPaths.count == 2)
        #expect(options.fontPaths.contains("/fonts"))
    }

    @Test func optionsOutputFormatCases() {
        #expect(WebUITypstOptions.OutputFormat.html.typstCLIValue == "html")
        #expect(WebUITypstOptions.OutputFormat.svg.typstCLIValue == "svg")
        #expect(WebUITypstOptions.OutputFormat.pdf.typstCLIValue == "pdf")
        #expect(WebUITypstOptions.OutputFormat.png.typstCLIValue == "png")
    }
}
