import Foundation

/// A protocol for defining website pages with a SwiftUI-like pattern.
///
/// The `Document` protocol allows you to define website pages using a
/// declarative syntax similar to SwiftUI. Pages specify their metadata and
/// content through computed properties, making the code more readable and
/// maintainable.
///
/// ## Example
/// ```swift
/// struct Home: Document {
///   var metadata {
///     Metadata(from: Portfolio.metadata, title: "Home")
///   }
///
///   var body: some Markup {
///     Card(title: "Hello, world")
///   }
/// }
/// ```
public protocol Document {
    /// The type of markup content this document produces.
    associatedtype Body: Markup

    /// The metadata configuration for this document.
    ///
    /// Defines the page title, description, and other metadata that will
    /// appear in the HTML head section.
    var metadata: Metadata { get }

    /// The main content of the document.
    ///
    /// This property returns the markup content that will be rendered as the
    /// body of the page.
    var body: Body { get }

    /// The URL path for this document.
    ///
    /// If not provided, the path will be derived from the metadata title.  Use
    /// "/" or "index" for the root page, or specify custom paths like "about"
    /// or "blog/post".
    var path: String? { get }

    /// Optional JavaScript sources specific to this document.
    var scripts: [Script]? { get }

    /// Optional stylesheet URLs specific to this document.
    var stylesheets: [String]? { get }

    /// Optional theme configuration specific to this document.
    var theme: Theme? { get }

    /// Optional custom markup to append to this document's head section.
    var head: String? { get }
}

// MARK: - Default Implementations

extension Document {
    /// Default path implementation derives from metadata title.
    public var path: String? { metadata.title?.pathFormatted() }

    /// Default scripts implementation returns nil.
    public var scripts: [Script]? { nil }

    /// Default stylesheets implementation returns nil.
    public var stylesheets: [String]? { nil }

    /// Default theme implementation returns nil.
    public var theme: Theme? { nil }

    /// Default head implementation returns nil.
    public var head: String? { nil }

    /// Creates a concrete Document instance for rendering.
    public func render() throws -> String {
        try render(websiteScripts: nil, websiteStylesheets: nil, websiteHead: nil, cssConfig: nil)
    }

    /// Creates a concrete Document instance for rendering with website-level configuration.
    public func render(
        websiteScripts: [Script]?,
        websiteStylesheets: [String]?,
        websiteHead: String?,
        cssConfig: CSSOutputConfig? = nil,
        slug: String? = nil
    ) throws -> String {
        // Render body
        let renderedBody = body.render()

        // Get CSS paths based on rendering mode
        let config = cssConfig ?? .staticDefault
        let writer = CSSWriter(config: config)
        let cssSlug = slug ?? path ?? "index"

        // In SSR mode, CSS is pre-generated - just link to the files
        // In static mode, generate CSS on-the-fly
        var cssFiles: [String] = []

        switch config.mode {
        case .ssr:
            // Link to pre-generated global + page CSS
            cssFiles = [
                writer.globalCSSPath(),
                writer.pageCSSPath(slug: cssSlug),
            ]

        case .staticSite:
            // Generate CSS on-the-fly for static site generation
            ClassCollector.shared.clear()
            _ = body.render()  // Re-render to collect classes

            let generatedCSS = ClassCollector.shared.generateCSS()
            try writer.writePageCSS(generatedCSS, slug: cssSlug)
            cssFiles = [writer.pageCSSPath(slug: cssSlug)]
        }

        var optionalTags: [String] = metadata.tags + []
        var bodyTags: [String] = []

        // Combine website scripts with document scripts
        let allScripts = (websiteScripts ?? []) + (scripts ?? [])
        if !allScripts.isEmpty {
            for script in allScripts {
                let scriptTag = script.render()
                script.placement == .head
                    ? optionalTags.append(scriptTag)
                    : bodyTags.append(scriptTag)
            }
        }

        // Combine website stylesheets with document stylesheets + generated CSS
        let allStylesheets = (websiteStylesheets ?? []) + (stylesheets ?? []) + cssFiles
        if !allStylesheets.isEmpty {
            for stylesheet in allStylesheets {
                optionalTags.append(
                    "<link rel=\"stylesheet\" href=\"\(stylesheet)\">"
                )
            }
        }

        // Build final HTML
        let html = """
            <!DOCTYPE html>
            <html lang="\(metadata.locale.rawValue)">
              <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>\(metadata.pageTitle)</title>
                \(optionalTags.joined(separator: "\n"))
                <meta name="generator" content="WebUI" />
                \(websiteHead ?? "")\(head ?? "")
              </head>
              <body>
                \(renderedBody)
                \(bodyTags.joined(separator: "\n"))
              </body>
            </html>
            """
        return HTMLMinifier.minify(html)
    }
}
