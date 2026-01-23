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

    /// Optional state machines for this document.
    ///
    /// State machines will be compiled to JavaScript and included in the page.
    var stateMachines: [String: StateMachine]? { get }

    /// Optional CSS class safelist for this document.
    ///
    /// Classes in this safelist will always be included in generated CSS, even if
    /// they don't appear in the rendered markup. This is useful for classes that
    /// appear only in JavaScript string literals or dynamic content.
    ///
    /// ## Example
    /// ```swift
    /// var cssSafelist: [String]? {
    ///     ["log-source", "log-message", "log-entry"]
    /// }
    /// ```
    var cssSafelist: [String]? { get }
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

    /// Default state machines implementation returns nil.
    public var stateMachines: [String: StateMachine]? { nil }

    /// Default CSS safelist implementation returns nil.
    public var cssSafelist: [String]? { nil }

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
        jsConfig: JSOutputConfig? = nil,
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

            // Add safelist classes if provided
            if let safelist = cssSafelist {
                ClassCollector.shared.addSafelistClasses(safelist)
            }

            _ = body.render()  // Re-render to collect classes

            let generatedCSS = ClassCollector.shared.generateCSS()
            try writer.writePageCSS(generatedCSS, slug: cssSlug)
            cssFiles = [writer.pageCSSPath(slug: cssSlug)]
        }

        // Handle JavaScript generation
        var jsFiles: [String] = []
        if let stateMachines = stateMachines, let jsConfig = jsConfig {
            let jsWriter = JSWriter(config: jsConfig)
            let jsSlug = slug ?? path ?? "index"

            switch jsConfig.mode {
            case .ssr:
                // Link to pre-generated JavaScript
                jsFiles = [
                    jsWriter.globalJSPath(),
                    jsWriter.pageJSPath(slug: jsSlug),
                ]

            case .staticSite:
                // Generate JavaScript on-the-fly
                let stateMachineArray = stateMachines.map { (id: $0.key, machine: $0.value) }
                let generatedJS = JSGenerator.generateStateMachines(stateMachineArray)
                try jsWriter.writePageJS(generatedJS, slug: jsSlug)
                jsFiles = [jsWriter.pageJSPath(slug: jsSlug)]
            }
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

        // Add generated JavaScript files to body
        if !jsFiles.isEmpty {
            for jsFile in jsFiles {
                let scriptTag = "<script src=\"\(jsFile)\"></script>"
                bodyTags.append(scriptTag)
            }
        }

        // Combine website stylesheets with document stylesheets + generated CSS
        // Deduplicate while preserving order (first occurrence wins)
        let allStylesheets = (websiteStylesheets ?? []) + (stylesheets ?? []) + cssFiles
        var seenStylesheets: Set<String> = []
        var uniqueStylesheets: [String] = []
        for stylesheet in allStylesheets {
            if !seenStylesheets.contains(stylesheet) {
                seenStylesheets.insert(stylesheet)
                uniqueStylesheets.append(stylesheet)
            }
        }

        if !uniqueStylesheets.isEmpty {
            let usePublicPrefix = (config.mode == .staticSite)
            for stylesheet in uniqueStylesheets {
                let href: String
                if stylesheet.hasPrefix("http://") || stylesheet.hasPrefix("https://") {
                    href = stylesheet
                } else {
                    let path = stylesheet.hasPrefix("/") ? stylesheet : "/\(stylesheet)"
                    if usePublicPrefix, !path.hasPrefix("/public") {
                        href = "/public" + (path == "/" ? "" : path)
                    } else {
                        href = path
                    }
                }
                optionalTags.append(
                    "<link rel=\"stylesheet\" href=\"\(href)\">"
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
