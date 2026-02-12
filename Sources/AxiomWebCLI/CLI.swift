import Foundation
import ArgumentParser
import AxiomWebServer

public struct AxiomWebBuildCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "axiomweb-build",
        abstract: "Build a static AxiomWeb site from Routes and Assets"
    )

    @Option(help: "Output directory for generated static site")
    public var output: String = ".output"

    @Option(help: "Base URL for sitemap generation")
    public var baseURL: String?

    public init() {}

    public mutating func run() throws {
        let config = ServerBuildConfiguration(
            outputDirectory: URL(filePath: output),
            baseURL: baseURL
        )
        let report = try StaticSiteBuilder(configuration: config).build()
        print("Built \(report.pageCount) page routes across \(report.localeCount) locale(s)")
        print("API routes discovered: \(report.apiRouteCount)")
        if let sitemapPath = report.sitemapPath {
            print("Sitemap: \(sitemapPath)")
        }
    }
}

public enum AxiomWebCLI {
    public static func buildSite(_ config: ServerBuildConfiguration = .init()) throws -> ServerBuildReport {
        try StaticSiteBuilder(configuration: config).build()
    }
}
