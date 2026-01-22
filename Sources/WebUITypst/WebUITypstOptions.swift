import Foundation

/// Configuration options for Typst rendering.
///
/// This structure controls various aspects of the rendering process including
/// the path to the Typst CLI and output format preferences.
public struct WebUITypstOptions: Sendable {

    /// The filesystem path to the Typst CLI executable.
    ///
    /// Defaults to `/opt/homebrew/bin/typst` which is the typical location
    /// when installed via Homebrew on Apple Silicon Macs.
    public var typstPath: String

    /// The output format for rendering.
    ///
    /// Currently only HTML is fully supported. Future versions may support
    /// SVG, PDF, and PNG output formats.
    public var outputFormat: OutputFormat

    /// Whether to include the HTML document wrapper in output.
    ///
    /// When `true`, the rendered output includes `<!DOCTYPE html>`, `<html>`,
    /// `<head>`, and `<body>` tags. When `false`, only the body content is returned.
    public var includeDocumentWrapper: Bool

    /// Custom font paths to pass to the Typst compiler.
    ///
    /// These paths are added via `--font-path` arguments to typst compile.
    public var fontPaths: [String]

    /// Additional compiler arguments to pass to typst.
    ///
    /// These arguments are appended directly to the typst compile command.
    public var extraCompilerArgs: [String]

    /// Supported output formats for Typst rendering.
    public enum OutputFormat: String, Sendable, CaseIterable {
        /// HTML output with typst's native markup.
        case html = "html"
        /// Scalable vector graphics.
        case svg = "svg"
        /// PDF document format.
        case pdf = "pdf"
        /// Raster image in PNG format.
        case png = "png"

        var typstCLIValue: String { rawValue }
    }

    /// Creates a default configuration.
    public init() {
        self.typstPath = "/opt/homebrew/bin/typst"
        self.outputFormat = .html
        self.includeDocumentWrapper = true
        self.fontPaths = []
        self.extraCompilerArgs = []
    }

    /// Creates a configuration with a custom Typst CLI path.
    public init(typstPath: String) {
        self.typstPath = typstPath
        self.outputFormat = .html
        self.includeDocumentWrapper = true
        self.fontPaths = []
        self.extraCompilerArgs = []
    }

    /// Creates a configuration with all options specified.
    public init(
        typstPath: String = "/opt/homebrew/bin/typst",
        outputFormat: OutputFormat = .html,
        includeDocumentWrapper: Bool = true,
        fontPaths: [String] = [],
        extraCompilerArgs: [String] = []
    ) {
        self.typstPath = typstPath
        self.outputFormat = outputFormat
        self.includeDocumentWrapper = includeDocumentWrapper
        self.fontPaths = fontPaths
        self.extraCompilerArgs = extraCompilerArgs
    }

    /// Returns a new configuration with a different Typst CLI path.
    public func withTypstPath(_ path: String) -> WebUITypstOptions {
        var config = self
        config.typstPath = path
        return config
    }

    /// Returns a new configuration with a different output format.
    public func withOutputFormat(_ format: OutputFormat) -> WebUITypstOptions {
        var config = self
        config.outputFormat = format
        return config
    }

    /// Returns a new configuration with document wrapper setting modified.
    public func withDocumentWrapper(_ include: Bool) -> WebUITypstOptions {
        var config = self
        config.includeDocumentWrapper = include
        return config
    }

    /// Returns a new configuration with additional font paths.
    public func withFontPaths(_ paths: [String]) -> WebUITypstOptions {
        var config = self
        config.fontPaths = paths
        return config
    }

    /// Returns a new configuration with extra compiler arguments.
    public func withExtraCompilerArgs(_ args: [String]) -> WebUITypstOptions {
        var config = self
        config.extraCompilerArgs = args
        return config
    }
}

/// Errors that can occur during Typst rendering.
public enum WebUITypstError: Error, Sendable {
    /// The Typst CLI executable was not found at the specified path.
    case typstNotFound(String)

    /// The Typst compilation process failed.
    case compilationFailed(String)

    /// Front matter was not properly closed with `---`.
    case invalidFrontMatter

    /// The rendered output was empty or invalid.
    case invalidOutput

    /// A filesystem operation failed during rendering.
    case filesystemError(String)
}
