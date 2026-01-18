import Foundation

/// Configuration for JavaScript file output.
///
/// Defines where generated JavaScript files should be written for different rendering modes.
public struct JSOutputConfig: Sendable {
    /// Output directory for static site generation
    public let staticOutputDir: String

    /// Output directory for server-side rendering
    public let ssrOutputDir: String

    /// Rendering mode (static or SSR)
    public let mode: RenderingMode

    /// Rendering mode for JS output
    public enum RenderingMode: Sendable {
        /// Static site generation - outputs to `.output/public`
        case staticSite

        /// Server-side rendering - outputs to `Public/`
        case ssr
    }

    /// Default configuration for static site generation
    public static let staticDefault = JSOutputConfig(
        staticOutputDir: ".output/public",
        ssrOutputDir: "Public/",
        mode: .staticSite
    )

    /// Default configuration for server-side rendering
    public static let ssrDefault = JSOutputConfig(
        staticOutputDir: ".output/public",
        ssrOutputDir: "Public/",
        mode: .ssr
    )

    /// Creates a new JS output configuration.
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

/// Writes generated JavaScript to disk for static or SSR rendering.
///
/// JSWriter handles the file I/O for JavaScript generation, supporting both global
/// (site-wide) and page-specific JavaScript files.
public struct JSWriter {
    /// Output configuration
    public let config: JSOutputConfig

    /// Creates a new JS writer with the specified configuration.
    ///
    /// - Parameter config: Output configuration
    public init(config: JSOutputConfig = .staticDefault) {
        self.config = config
    }

    /// Writes global JavaScript to disk.
    ///
    /// - Parameter js: JavaScript content to write
    /// - Throws: File I/O errors
    public func writeGlobalJS(_ js: String) throws {
        let jsDir = "\(config.outputDirectory)/js"
        try createDirectoryIfNeeded(jsDir)

        let filePath = "\(jsDir)/global.js"
        try js.write(toFile: filePath, atomically: true, encoding: .utf8)
    }

    /// Writes page-specific JavaScript to disk.
    ///
    /// - Parameters:
    ///   - js: JavaScript content to write
    ///   - slug: Page slug (e.g., "about", "contact", "logs/post-name")
    /// - Throws: File I/O errors
    public func writePageJS(_ js: String, slug: String) throws {
        let jsDir = "\(config.outputDirectory)/js"
        let filePath = "\(jsDir)/page-\(slug).js"

        // Create intermediate directories if slug contains path components
        let fileURL = URL(fileURLWithPath: filePath)
        let parentDir = fileURL.deletingLastPathComponent().path
        try createDirectoryIfNeeded(parentDir)

        try js.write(toFile: filePath, atomically: true, encoding: .utf8)
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

    /// Returns the URL path for global JavaScript (for use in <script> tags).
    ///
    /// - Returns: URL path (e.g., "/js/global.js")
    public func globalJSPath() -> String {
        "/js/global.js"
    }

    /// Returns the URL path for page-specific JavaScript (for use in <script> tags).
    ///
    /// - Parameter slug: Page slug
    /// - Returns: URL path (e.g., "/js/page-about.js")
    public func pageJSPath(slug: String) -> String {
        "/js/page-\(slug).js"
    }
}
