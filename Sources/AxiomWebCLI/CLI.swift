import Foundation
import ArgumentParser
import AxiomWebI18n
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

public enum AccessibilityReportFormatOption: String, ExpressibleByArgument {
    case json
    case markdown

    var reportFormat: AccessibilityCIReportFormat {
        switch self {
        case .json:
            return .json
        case .markdown:
            return .markdown
        }
    }
}

public enum BuildModeOption: String, ExpressibleByArgument {
    case auto
    case staticSite
    case serverSide

    var buildMode: ApplicationBuildMode {
        switch self {
        case .auto:
            return .auto
        case .staticSite:
            return .staticSite
        case .serverSide:
            return .serverSide
        }
    }
}

public struct AxiomWebBuildCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Build a static AxiomWeb site from Routes and Assets",
        aliases: ["axiomweb-build"]
    )

    @Option(help: "Output directory for generated static site")
    public var output: String = ".output"

    @Option(help: "Build mode: auto, staticSite, or serverSide")
    public var buildMode: BuildModeOption = .auto

    @Option(help: "Base URL for sitemap generation")
    public var baseURL: String?

    @Option(help: "Default locale code used for non-prefixed routes")
    public var defaultLocale: String = LocaleCode.en.rawValue

    @Option(parsing: .upToNextOption, help: "Locales to generate (example: --locales en fr)")
    public var locales: [String] = []

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

    @Flag(help: "Enable static build accessibility audit and gate enforcement")
    public var accessibilityAudit: Bool = true

    @Flag(help: "Fail build when accessibility warnings are present")
    public var accessibilityFailOnWarnings: Bool = false

    @Flag(help: "Emit accessibility report only without failing build on accessibility findings")
    public var accessibilityReportOnly: Bool = false

    @Option(help: "Accessibility audit report format")
    public var accessibilityReportFormat: AccessibilityReportFormatOption = .json

    @Option(help: "Custom accessibility report file path relative to output directory")
    public var accessibilityReportFile: String?

    @Flag(help: "Fail build when discovered page/API route files are missing typed contracts/handlers")
    public var strictRouteContracts: Bool = false

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

        let defaultLocaleCode = LocaleCode(defaultLocale)
        let localeCodes = locales.map { LocaleCode($0) }
        let resolvedLocales = localeCodes.isEmpty ? [defaultLocaleCode] : localeCodes

        let config = ServerBuildConfiguration(
            outputDirectory: URL(filePath: output),
            defaultLocale: defaultLocaleCode,
            locales: resolvedLocales,
            baseURL: baseURL,
            performanceAudit: .init(
                enabled: performanceAudit,
                enforceGate: !performanceReportOnly,
                options: .init(budget: budget),
                gateOptions: .init(failOnWarnings: performanceFailOnWarnings),
                reportFormat: performanceReportFormat.reportFormat,
                writeReport: true,
                reportFileName: performanceReportFile
            ),
            accessibilityAudit: .init(
                enabled: accessibilityAudit,
                enforceGate: !accessibilityReportOnly,
                gateOptions: .init(failOnWarnings: accessibilityFailOnWarnings),
                reportFormat: accessibilityReportFormat.reportFormat,
                writeReport: true,
                reportFileName: accessibilityReportFile
            ),
            buildMode: buildMode.buildMode,
            strictRouteContracts: strictRouteContracts
        )
        let report = try StaticSiteBuilder(configuration: config).build()
        print("Built \(report.pageCount) page routes across \(report.localeCount) locale(s)")
        print("API routes discovered: \(report.apiRouteCount)")
        print("WebSocket routes discovered: \(report.websocketRouteCount)")
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
        if let accessibility = report.accessibilityReport {
            print("Accessibility audit pages: \(accessibility.pages.count)")
            print("Accessibility has errors: \(accessibility.hasErrors), warnings: \(accessibility.hasWarnings)")
        }
        if let accessibilityReportPath = report.accessibilityReportPath {
            print("Accessibility report: \(accessibilityReportPath)")
        }
    }
}

public enum AxiomWebCLI {
    public static func buildSite(_ config: ServerBuildConfiguration = .init()) throws -> ServerBuildReport {
        try StaticSiteBuilder(configuration: config).build()
    }
}

public struct AxiomWebCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "axiomweb",
        abstract: "AxiomWeb build and project tooling",
        subcommands: [
            AxiomWebBuildCommand.self,
            AxiomWebInitCommand.self,
        ],
        defaultSubcommand: AxiomWebBuildCommand.self
    )

    public init() {}
}
