import Foundation
import ArgumentParser
import AxiomWebServer
import AxiomWebTesting

public enum PerformanceReportFormatOption: String, ExpressibleByArgument {
    case json
    case markdown

    var reportFormat: PerformanceCIReportFormat {
        switch self {
        case .json:
            return .json
        case .markdown:
            return .markdown
        }
    }
}

public struct AxiomWebBuildCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "axiomweb-build",
        abstract: "Build a static AxiomWeb site from Routes and Assets"
    )

    @Option(help: "Output directory for generated static site")
    public var output: String = ".output"

    @Option(help: "Base URL for sitemap generation")
    public var baseURL: String?

    @Flag(help: "Enable static build performance audit and budget enforcement")
    public var performanceAudit: Bool = true

    @Flag(help: "Fail build when performance warnings are present")
    public var performanceFailOnWarnings: Bool = false

    @Flag(help: "Emit audit report only without failing build on budget violations")
    public var performanceReportOnly: Bool = false

    @Option(help: "Performance audit report format")
    public var performanceReportFormat: PerformanceReportFormatOption = .json

    @Option(help: "Custom performance report file path relative to output directory")
    public var performanceReportFile: String?

    @Option(help: "Maximum HTML bytes per page budget")
    public var performanceMaxHTMLBytes: Int?

    @Option(help: "Maximum CSS bytes per page budget")
    public var performanceMaxCSSBytes: Int?

    @Option(help: "Maximum JS bytes per page budget")
    public var performanceMaxJSBytes: Int?

    @Option(help: "Maximum total asset bytes budget")
    public var performanceMaxTotalAssetBytes: Int?

    public init() {}

    public mutating func run() throws {
        var budget = PerformanceBudget()
        if let performanceMaxHTMLBytes {
            budget.maxHTMLBytes = max(0, performanceMaxHTMLBytes)
        }
        if let performanceMaxCSSBytes {
            budget.maxCSSBytes = max(0, performanceMaxCSSBytes)
        }
        if let performanceMaxJSBytes {
            budget.maxJSBytes = max(0, performanceMaxJSBytes)
        }
        if let performanceMaxTotalAssetBytes {
            budget.maxTotalAssetBytes = max(0, performanceMaxTotalAssetBytes)
        }

        let config = ServerBuildConfiguration(
            outputDirectory: URL(filePath: output),
            baseURL: baseURL,
            performanceAudit: .init(
                enabled: performanceAudit,
                enforceGate: !performanceReportOnly,
                options: .init(budget: budget),
                gateOptions: .init(failOnWarnings: performanceFailOnWarnings),
                reportFormat: performanceReportFormat.reportFormat,
                writeReport: true,
                reportFileName: performanceReportFile
            )
        )
        let report = try StaticSiteBuilder(configuration: config).build()
        print("Built \(report.pageCount) page routes across \(report.localeCount) locale(s)")
        print("API routes discovered: \(report.apiRouteCount)")
        if let sitemapPath = report.sitemapPath {
            print("Sitemap: \(sitemapPath)")
        }
        if let performance = report.performanceReport {
            print("Performance audit pages: \(performance.pages.count)")
            print("Performance has errors: \(performance.hasErrors), warnings: \(performance.hasWarnings)")
        }
        if let performanceReportPath = report.performanceReportPath {
            print("Performance report: \(performanceReportPath)")
        }
    }
}

public enum AxiomWebCLI {
    public static func buildSite(_ config: ServerBuildConfiguration = .init()) throws -> ServerBuildReport {
        try StaticSiteBuilder(configuration: config).build()
    }
}
