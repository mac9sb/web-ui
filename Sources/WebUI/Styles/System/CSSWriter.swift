import Foundation

/// Configuration for CSS file output.
///
/// Defines where generated CSS files should be written for different rendering modes.
public struct CSSOutputConfig: Sendable {
    /// Output directory for static site generation
    public let staticOutputDir: String

    /// Output directory for server-side rendering
    public let ssrOutputDir: String

    /// Rendering mode (static or SSR)
    public let mode: RenderingMode

    /// Rendering mode for CSS output
    public enum RenderingMode: Sendable {
        /// Static site generation - outputs to `.output/public`
        case staticSite

        /// Server-side rendering - outputs to `Public/`
        case ssr
    }

    /// Default configuration for static site generation
    public static let staticDefault = CSSOutputConfig(
        staticOutputDir: ".output/public",
        ssrOutputDir: "Public/",
        mode: .staticSite
    )

    /// Default configuration for server-side rendering
    public static let ssrDefault = CSSOutputConfig(
        staticOutputDir: ".output/public",
        ssrOutputDir: "Public/",
        mode: .ssr
    )

    /// Creates a new CSS output configuration.
    ///
    /// - Parameters:
    ///   - staticOutputDir: Directory for static output (default: ".output/public")
    ///   - ssrOutputDir: Directory for SSR output (default: "Public/")
    ///   - mode: Rendering mode (default: .staticSite)
    public init(
        staticOutputDir: String = ".output/public",
        ssrOutputDir: String = "Public/",
        mode: RenderingMode = .staticSite
    ) {
        self.staticOutputDir = staticOutputDir
        self.ssrOutputDir = ssrOutputDir
        self.mode = mode
    }

    /// Returns the appropriate output directory for the current mode.
    public var outputDirectory: String {
        switch mode {
        case .staticSite: return staticOutputDir
        case .ssr: return ssrOutputDir
        }
    }
}

/// Writes generated CSS to disk for static or SSR rendering.
///
/// CSSWriter handles the file I/O for CSS generation, supporting both global
/// (site-wide) and page-specific CSS files.
///
/// ## Architecture
///
/// - **Global CSS**: `styles/global.css` - contains CSS used across all pages
/// - **Page CSS**: `styles/page-{slug}.css` - contains CSS specific to one page
///
/// ## Usage
///
/// ```swift
/// let writer = CSSWriter(config: .staticDefault)
///
/// // Write global CSS
/// try writer.writeGlobalCSS(css: globalCSS)
///
/// // Write page-specific CSS
/// try writer.writePageCSS(css: pageCSS, slug: "about")
/// ```
///
/// - SeeAlso: ``CSSOutputConfig``, ``CSSGenerator``
public struct CSSWriter {
    /// Output configuration
    public let config: CSSOutputConfig

    /// Creates a new CSS writer with the specified configuration.
    ///
    /// - Parameter config: Output configuration
    public init(config: CSSOutputConfig = .staticDefault) {
        self.config = config
    }

    /// Writes global CSS to disk.
    ///
    /// - Parameter css: CSS content to write
    /// - Throws: File I/O errors
    public func writeGlobalCSS(_ css: String) throws {
        let stylesDir = "\(config.outputDirectory)/styles"
        try createDirectoryIfNeeded(stylesDir)

        let filePath = "\(stylesDir)/global.css"
        try css.write(toFile: filePath, atomically: true, encoding: .utf8)
    }

    /// Writes page-specific CSS to disk.
    ///
    /// - Parameters:
    ///   - css: CSS content to write
    ///   - slug: Page slug (e.g., "about", "contact", "logs/post-name")
    /// - Throws: File I/O errors
    public func writePageCSS(_ css: String, slug: String) throws {
        let stylesDir = "\(config.outputDirectory)/styles"
        let filePath = "\(stylesDir)/page-\(slug).css"

        // Create intermediate directories if slug contains path components
        let fileURL = URL(fileURLWithPath: filePath)
        let parentDir = fileURL.deletingLastPathComponent().path
        try createDirectoryIfNeeded(parentDir)

        try css.write(toFile: filePath, atomically: true, encoding: .utf8)
    }

    /// Creates a directory if it doesn't exist.
    ///
    /// - Parameter path: Directory path
    /// - Throws: File I/O errors
    private func createDirectoryIfNeeded(_ path: String) throws {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            try fileManager.createDirectory(
                atPath: path,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }

    /// Returns the URL path for global CSS (for use in <link> tags).
    ///
    /// - Returns: URL path (e.g., "/styles/global.css")
    public func globalCSSPath() -> String {
        "/styles/global.css"
    }

    /// Returns the URL path for page-specific CSS (for use in <link> tags).
    ///
    /// - Parameter slug: Page slug
    /// - Returns: URL path (e.g., "/styles/page-about.css")
    public func pageCSSPath(slug: String) -> String {
        "/styles/page-\(slug).css"
    }
}
