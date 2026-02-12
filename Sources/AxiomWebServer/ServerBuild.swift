import Foundation
import Logging
import Metrics
import AxiomWebI18n
import AxiomWebRender
import AxiomWebTesting
import AxiomWebUI

public struct ObservabilityConfiguration: Sendable, Equatable {
    public var enabled: Bool

    public init(enabled: Bool = true) {
        self.enabled = enabled
    }
}

public struct BuildPerformanceAuditConfiguration: Sendable, Equatable {
    public var enabled: Bool
    public var enforceGate: Bool
    public var options: PerformanceAuditOptions
    public var gateOptions: PerformanceCIGateOptions
    public var reportFormat: PerformanceCIReportFormat
    public var writeReport: Bool
    public var reportFileName: String

    public init(
        enabled: Bool = true,
        enforceGate: Bool = true,
        options: PerformanceAuditOptions = .init(),
        gateOptions: PerformanceCIGateOptions = .init(),
        reportFormat: PerformanceCIReportFormat = .json,
        writeReport: Bool = true,
        reportFileName: String? = nil
    ) {
        self.enabled = enabled
        self.enforceGate = enforceGate
        self.options = options
        self.gateOptions = gateOptions
        self.reportFormat = reportFormat
        self.writeReport = writeReport
        if let reportFileName, !reportFileName.isEmpty {
            self.reportFileName = reportFileName
        } else {
            self.reportFileName = reportFormat == .json ? "performance-audit.json" : "performance-audit.md"
        }
    }
}

public struct BuildAccessibilityAuditConfiguration: Sendable, Equatable {
    public var enabled: Bool
    public var enforceGate: Bool
    public var options: AccessibilityAuditOptions
    public var gateOptions: AccessibilityCIGateOptions
    public var reportFormat: AccessibilityCIReportFormat
    public var writeReport: Bool
    public var reportFileName: String

    public init(
        enabled: Bool = true,
        enforceGate: Bool = true,
        options: AccessibilityAuditOptions = .init(),
        gateOptions: AccessibilityCIGateOptions = .init(),
        reportFormat: AccessibilityCIReportFormat = .json,
        writeReport: Bool = true,
        reportFileName: String? = nil
    ) {
        self.enabled = enabled
        self.enforceGate = enforceGate
        self.options = options
        self.gateOptions = gateOptions
        self.reportFormat = reportFormat
        self.writeReport = writeReport
        if let reportFileName, !reportFileName.isEmpty {
            self.reportFileName = reportFileName
        } else {
            self.reportFileName = reportFormat == .json ? "accessibility-audit.json" : "accessibility-audit.md"
        }
    }
}

public enum ApplicationBuildMode: Sendable, Equatable {
    case auto
    case staticSite
    case serverSide
}

public enum ResolvedApplicationBuildMode: String, Sendable, Equatable, Codable {
    case staticSite
    case serverSide
}

public enum RouteConflictPolicy: Sendable, Equatable {
    case failBuild
    case preferOverrides
}

public struct PageRouteOverride {
    public let path: String
    public let document: any Document

    public init(path: String, document: any Document) {
        self.path = path
        self.document = document
    }
}

public struct APIRouteOverride: Sendable, Equatable {
    public let path: String
    public let method: String

    public init(path: String, method: String = "GET") {
        self.path = path
        self.method = method.uppercased()
    }
}

public struct ServerBuildConfiguration {
    public var routesRoot: URL
    public var pagesDirectoryName: String
    public var apiDirectoryName: String
    public var outputDirectory: URL
    public var assetsSourceDirectory: URL
    public var publicAssetsDirectoryName: String
    public var website: (any Website)?
    public var pageOverrides: [PageRouteOverride]
    public var apiOverrides: [APIRouteOverride]
    public var apiContractOverrides: [AnyAPIRouteContract]
    public var defaultLocale: LocaleCode
    public var locales: [LocaleCode]
    public var baseURL: String?
    public var observability: ObservabilityConfiguration
    public var performanceAudit: BuildPerformanceAuditConfiguration
    public var accessibilityAudit: BuildAccessibilityAuditConfiguration
    public var buildMode: ApplicationBuildMode
    public var routeConflictPolicy: RouteConflictPolicy
    public var renderOptions: RenderOptions
    public var viewTransition: ViewTransitionConfiguration?

    public init(
        routesRoot: URL = URL(filePath: "Routes"),
        pagesDirectoryName: String = "pages",
        apiDirectoryName: String = "api",
        outputDirectory: URL = URL(filePath: ".output"),
        assetsSourceDirectory: URL = URL(filePath: "Assets"),
        publicAssetsDirectoryName: String = "public",
        website: (any Website)? = nil,
        pageOverrides: [PageRouteOverride] = [],
        apiOverrides: [APIRouteOverride] = [],
        apiContractOverrides: [AnyAPIRouteContract] = [],
        defaultLocale: LocaleCode = .en,
        locales: [LocaleCode] = [.en],
        baseURL: String? = nil,
        observability: ObservabilityConfiguration = .init(enabled: true),
        performanceAudit: BuildPerformanceAuditConfiguration = .init(),
        accessibilityAudit: BuildAccessibilityAuditConfiguration = .init(),
        buildMode: ApplicationBuildMode = .auto,
        routeConflictPolicy: RouteConflictPolicy = .preferOverrides,
        renderOptions: RenderOptions = .init(),
        viewTransition: ViewTransitionConfiguration? = nil
    ) {
        self.routesRoot = routesRoot
        self.pagesDirectoryName = pagesDirectoryName
        self.apiDirectoryName = apiDirectoryName
        self.outputDirectory = outputDirectory
        self.assetsSourceDirectory = assetsSourceDirectory
        self.publicAssetsDirectoryName = publicAssetsDirectoryName
        self.website = website
        self.pageOverrides = pageOverrides
        self.apiOverrides = apiOverrides
        self.apiContractOverrides = apiContractOverrides
        self.defaultLocale = defaultLocale
        self.locales = locales
        self.baseURL = baseURL
        self.observability = observability
        self.performanceAudit = performanceAudit
        self.accessibilityAudit = accessibilityAudit
        self.buildMode = buildMode
        self.routeConflictPolicy = routeConflictPolicy
        self.renderOptions = renderOptions
        self.viewTransition = viewTransition
    }

    public init(
        routesRoot: URL = URL(filePath: "Routes"),
        pagesDirectoryName: String = "pages",
        apiDirectoryName: String = "api",
        outputDirectory: URL = URL(filePath: ".output"),
        assetsSourceDirectory: URL = URL(filePath: "Assets"),
        publicAssetsDirectoryName: String = "public",
        website: (any Website)? = nil,
        overrides: RouteOverrides,
        defaultLocale: LocaleCode = .en,
        locales: [LocaleCode] = [.en],
        baseURL: String? = nil,
        observability: ObservabilityConfiguration = .init(enabled: true),
        performanceAudit: BuildPerformanceAuditConfiguration = .init(),
        accessibilityAudit: BuildAccessibilityAuditConfiguration = .init(),
        buildMode: ApplicationBuildMode = .auto,
        routeConflictPolicy: RouteConflictPolicy = .preferOverrides,
        renderOptions: RenderOptions = .init(),
        viewTransition: ViewTransitionConfiguration? = nil
    ) {
        self.init(
            routesRoot: routesRoot,
            pagesDirectoryName: pagesDirectoryName,
            apiDirectoryName: apiDirectoryName,
            outputDirectory: outputDirectory,
            assetsSourceDirectory: assetsSourceDirectory,
            publicAssetsDirectoryName: publicAssetsDirectoryName,
            website: website,
            pageOverrides: overrides.pageOverrides,
            apiOverrides: overrides.apiOverrides,
            apiContractOverrides: overrides.apiContracts,
            defaultLocale: defaultLocale,
            locales: locales,
            baseURL: baseURL,
            observability: observability,
            performanceAudit: performanceAudit,
            accessibilityAudit: accessibilityAudit,
            buildMode: buildMode,
            routeConflictPolicy: routeConflictPolicy,
            renderOptions: renderOptions,
            viewTransition: viewTransition
        )
    }
}

public struct AssetManifestEntry: Sendable, Equatable, Codable {
    public let sourcePath: String
    public let outputPath: String
    public let fingerprint: String
    public let bytes: Int
    public let cacheControl: String

    public init(sourcePath: String, outputPath: String, fingerprint: String, bytes: Int, cacheControl: String) {
        self.sourcePath = sourcePath
        self.outputPath = outputPath
        self.fingerprint = fingerprint
        self.bytes = max(0, bytes)
        self.cacheControl = cacheControl
    }
}

public struct BuildPagePerformanceReport: Sendable, Equatable, Codable {
    public let routePath: String
    public let report: PerformanceAuditReport

    public init(routePath: String, report: PerformanceAuditReport) {
        self.routePath = routePath
        self.report = report
    }
}

public struct BuildPerformanceReport: Sendable, Equatable, Codable {
    public let pages: [BuildPagePerformanceReport]

    public init(pages: [BuildPagePerformanceReport]) {
        self.pages = pages
    }

    public var hasErrors: Bool {
        pages.contains { $0.report.hasErrors }
    }

    public var hasWarnings: Bool {
        pages.contains { $0.report.hasWarnings }
    }
}

public struct BuildPageAccessibilityReport: Sendable, Equatable, Codable {
    public let routePath: String
    public let report: AccessibilityAuditReport

    public init(routePath: String, report: AccessibilityAuditReport) {
        self.routePath = routePath
        self.report = report
    }
}

public struct BuildAccessibilityReport: Sendable, Equatable, Codable {
    public let pages: [BuildPageAccessibilityReport]

    public init(pages: [BuildPageAccessibilityReport]) {
        self.pages = pages
    }

    public var hasErrors: Bool {
        pages.contains { $0.report.hasErrors }
    }

    public var hasWarnings: Bool {
        pages.contains { $0.report.hasWarnings }
    }
}

public struct ServerBuildReport: Sendable, Equatable {
    public let buildMode: ResolvedApplicationBuildMode
    public let pageCount: Int
    public let localeCount: Int
    public let apiRouteCount: Int
    public let writtenHTMLFiles: [String]
    public let assetManifest: [AssetManifestEntry]
    public let sitemapPath: String?
    public let performanceReport: BuildPerformanceReport?
    public let performanceReportPath: String?
    public let accessibilityReport: BuildAccessibilityReport?
    public let accessibilityReportPath: String?

    public init(
        buildMode: ResolvedApplicationBuildMode,
        pageCount: Int,
        localeCount: Int,
        apiRouteCount: Int,
        writtenHTMLFiles: [String],
        assetManifest: [AssetManifestEntry],
        sitemapPath: String?,
        performanceReport: BuildPerformanceReport? = nil,
        performanceReportPath: String? = nil,
        accessibilityReport: BuildAccessibilityReport? = nil,
        accessibilityReportPath: String? = nil
    ) {
        self.buildMode = buildMode
        self.pageCount = pageCount
        self.localeCount = localeCount
        self.apiRouteCount = apiRouteCount
        self.writtenHTMLFiles = writtenHTMLFiles
        self.assetManifest = assetManifest
        self.sitemapPath = sitemapPath
        self.performanceReport = performanceReport
        self.performanceReportPath = performanceReportPath
        self.accessibilityReport = accessibilityReport
        self.accessibilityReportPath = accessibilityReportPath
    }
}

public enum ServerBuildError: Error, Equatable {
    case routeConflict(path: String)
    case apiRouteConflict(path: String, method: String)
    case performanceBudgetExceeded(path: String, errorCount: Int, warningCount: Int)
    case accessibilityAuditFailed(path: String, errorCount: Int, warningCount: Int)
}

public struct StaticSiteBuilder {
    public let configuration: ServerBuildConfiguration

    public init(configuration: ServerBuildConfiguration = .init()) {
        self.configuration = configuration
    }

    public func build() throws -> ServerBuildReport {
        let logger = Logger(label: "AxiomWeb.ServerBuild")
        let pagesBuilt = Counter(label: "axiomweb.pages.built")

        if configuration.observability.enabled {
            logger.info("Building site")
        }

        let discovered = try RouteDiscovery.discover(
            routesRoot: configuration.routesRoot,
            pagesDirectory: configuration.pagesDirectoryName,
            apiDirectory: configuration.apiDirectoryName
        )

        let discoveredPages = discovered.filter { $0.kind == .page }
        let discoveredAPIs = discovered.filter { $0.kind == .api }

        let pageDocuments = try mergedPageDocuments(discoveredPages: discoveredPages)
        let apiRoutes = try mergedAPIRoutes(discoveredAPIs: discoveredAPIs)
        let locales = resolvedLocales()
        let resolvedBuildMode = resolveBuildMode(apiRoutes: apiRoutes)

        if configuration.observability.enabled {
            logger.info("Resolved mode=\(resolvedBuildMode.rawValue) pages=\(pageDocuments.count) locales=\(locales.count) apis=\(apiRoutes.count)")
        }

        guard resolvedBuildMode == .staticSite else {
            return ServerBuildReport(
                buildMode: resolvedBuildMode,
                pageCount: pageDocuments.count,
                localeCount: locales.count,
                apiRouteCount: apiRoutes.count,
                writtenHTMLFiles: [],
                assetManifest: [],
                sitemapPath: nil,
                performanceReport: nil,
                performanceReportPath: nil,
                accessibilityReport: nil,
                accessibilityReportPath: nil
            )
        }

        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: configuration.outputDirectory.path()) {
            try fileManager.removeItem(at: configuration.outputDirectory)
        }
        try fileManager.createDirectory(at: configuration.outputDirectory, withIntermediateDirectories: true)

        let siteViewTransition = resolvedSiteViewTransition()
        var writtenHTMLFiles: [String] = []
        var writtenPages: [(routePath: String, outputPath: String)] = []
        for locale in locales {
            for entry in pageDocuments.sorted(by: { $0.key < $1.key }) {
                let localizedPath = LocaleRouting.localizedPath(entry.key, locale: locale, defaultLocale: configuration.defaultLocale)
                let alternateURLs = buildAlternateURLs(for: entry.key, locales: locales)
                let canonicalURL = alternateURLs[locale]
                let pageMetadata = Metadata(
                    from: entry.value.metadata,
                    locale: locale,
                    canonicalURL: canonicalURL,
                    alternateURLs: alternateURLs
                )
                let rendered = try RenderEngine.render(
                    document: entry.value,
                    websiteMetadata: configuration.website?.metadata,
                    metadataOverride: pageMetadata,
                    locale: locale,
                    options: configuration.renderOptions,
                    viewTransition: resolvedViewTransition(for: entry.value, siteViewTransition: siteViewTransition)
                )
                let output = try writeHTML(rendered.html, forRoutePath: localizedPath)
                writtenHTMLFiles.append(output.path())
                writtenPages.append((routePath: localizedPath, outputPath: output.path()))
                if configuration.observability.enabled {
                    pagesBuilt.increment()
                }
            }
        }

        let assetManifest = try buildAssets()
        let sitemapPath = try buildSitemap(pagePaths: pageDocuments.keys.sorted(), locales: locales)
        let performance = try buildPerformanceAudit(
            pages: writtenPages,
            assetManifest: assetManifest
        )
        let accessibility = try buildAccessibilityAudit(pages: writtenPages)

        if configuration.observability.enabled {
            logger.info("Build complete. pages=\(pageDocuments.count) locales=\(locales.count) apis=\(apiRoutes.count)")
            if let performanceReport = performance.report {
                logger.info("Performance audit complete. pages=\(performanceReport.pages.count) hasErrors=\(performanceReport.hasErrors) hasWarnings=\(performanceReport.hasWarnings)")
            }
            if let accessibilityReport = accessibility.report {
                logger.info("Accessibility audit complete. pages=\(accessibilityReport.pages.count) hasErrors=\(accessibilityReport.hasErrors) hasWarnings=\(accessibilityReport.hasWarnings)")
            }
        }

        return ServerBuildReport(
            buildMode: resolvedBuildMode,
            pageCount: pageDocuments.count,
            localeCount: locales.count,
            apiRouteCount: apiRoutes.count,
            writtenHTMLFiles: writtenHTMLFiles.sorted(),
            assetManifest: assetManifest,
            sitemapPath: sitemapPath,
            performanceReport: performance.report,
            performanceReportPath: performance.path,
            accessibilityReport: accessibility.report,
            accessibilityReportPath: accessibility.path
        )
    }

    private func resolvedLocales() -> [LocaleCode] {
        if let website = configuration.website {
            return Array(Set(website.locales + [website.defaultLocale])).sorted()
        }
        return Array(Set(configuration.locales + [configuration.defaultLocale])).sorted()
    }

    private func resolvedSiteViewTransition() -> ViewTransitionConfiguration? {
        if let configured = configuration.viewTransition {
            return configured
        }
        return (configuration.website as? any ViewTransitionProviding)?.viewTransition
    }

    private func resolvedViewTransition(
        for document: any Document,
        siteViewTransition: ViewTransitionConfiguration?
    ) -> ViewTransitionConfiguration? {
        if let documentViewTransition = (document as? any ViewTransitionProviding)?.viewTransition {
            return documentViewTransition
        }
        return siteViewTransition
    }

    private func mergedPageDocuments(discoveredPages: [DiscoveredRoute]) throws -> [String: any Document] {
        var routes: [String: any Document] = [:]

        for discovered in discoveredPages {
            let path = normalizePath(discovered.path)
            let document = PlaceholderDiscoveredDocument(path: path, source: discovered.source)
            try registerPageRoute(path: path, document: document, into: &routes, isOverride: false)
        }

        if let website = configuration.website {
            for document in try website.routes {
                try registerPageRoute(path: normalizePath(document.path), document: document, into: &routes, isOverride: true)
            }
        }

        for override in configuration.pageOverrides {
            try registerPageRoute(path: normalizePath(override.path), document: override.document, into: &routes, isOverride: true)
        }

        return routes
    }

    private func mergedAPIRoutes(discoveredAPIs: [DiscoveredRoute]) throws -> Set<ResolvedAPIRoute> {
        var routes: Set<ResolvedAPIRoute> = []

        for discovered in discoveredAPIs {
            let route = ResolvedAPIRoute(path: normalizePath(discovered.path), method: "GET")
            try registerAPIRoute(route, into: &routes, isOverride: false)
        }

        for override in configuration.apiOverrides {
            let route = ResolvedAPIRoute(path: normalizePath(override.path), method: override.method)
            try registerAPIRoute(route, into: &routes, isOverride: true)
        }

        for override in configuration.apiContractOverrides {
            let route = ResolvedAPIRoute(path: normalizePath(override.path), method: override.method.rawValue.uppercased())
            try registerAPIRoute(route, into: &routes, isOverride: true)
        }

        return routes
    }

    private func registerPageRoute(
        path: String,
        document: any Document,
        into routes: inout [String: any Document],
        isOverride: Bool
    ) throws {
        if routes[path] != nil {
            switch configuration.routeConflictPolicy {
            case .failBuild:
                throw ServerBuildError.routeConflict(path: path)
            case .preferOverrides:
                if !isOverride {
                    return
                }
            }
        }
        routes[path] = document
    }

    private func registerAPIRoute(
        _ route: ResolvedAPIRoute,
        into routes: inout Set<ResolvedAPIRoute>,
        isOverride: Bool
    ) throws {
        if routes.contains(route) {
            switch configuration.routeConflictPolicy {
            case .failBuild:
                throw ServerBuildError.apiRouteConflict(path: route.path, method: route.method)
            case .preferOverrides:
                if !isOverride {
                    return
                }
                routes.remove(route)
            }
        }
        routes.insert(route)
    }

    private func normalizePath(_ path: String) -> String {
        if path.isEmpty { return "/" }
        if path == "index" { return "/" }
        if path.hasPrefix("/") { return path }
        return "/\(path)"
    }

    private func writeHTML(_ html: String, forRoutePath routePath: String) throws -> URL {
        let normalized = normalizePath(routePath)
        let relativePath: String
        if normalized == "/" {
            relativePath = "index.html"
        } else {
            let clean = String(normalized.dropFirst())
            relativePath = "\(clean)/index.html"
        }

        let outputURL = configuration.outputDirectory.appending(path: relativePath)
        try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try html.data(using: .utf8)?.write(to: outputURL)
        return outputURL
    }

    private func buildAssets() throws -> [AssetManifestEntry] {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: configuration.assetsSourceDirectory.path()) else {
            return []
        }

        let publicRoot = configuration.outputDirectory.appending(path: configuration.publicAssetsDirectoryName)
        if fileManager.fileExists(atPath: publicRoot.path()) {
            try fileManager.removeItem(at: publicRoot)
        }
        try fileManager.createDirectory(at: publicRoot, withIntermediateDirectories: true)

        guard let enumerator = fileManager.enumerator(at: configuration.assetsSourceDirectory, includingPropertiesForKeys: [.isRegularFileKey]) else {
            return []
        }

        var manifest: [AssetManifestEntry] = []
        for case let sourceURL as URL in enumerator {
            guard sourceURL.pathExtension.lowercased() != "" || fileManager.fileExists(atPath: sourceURL.path()) else { continue }
            let values = try sourceURL.resourceValues(forKeys: [.isRegularFileKey])
            guard values.isRegularFile == true else { continue }

            let relativeComponents = sourceURL.standardizedFileURL.pathComponents.dropFirst(configuration.assetsSourceDirectory.standardizedFileURL.pathComponents.count)
            let relative = relativeComponents.joined(separator: "/")
            let destination = publicRoot.appending(path: relative)
            try fileManager.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try Data(contentsOf: sourceURL)
            try data.write(to: destination)

            let fingerprint = fnv1aHex(data)
            manifest.append(
                AssetManifestEntry(
                    sourcePath: relative,
                    outputPath: destination.path().replacingOccurrences(of: configuration.outputDirectory.path() + "/", with: ""),
                    fingerprint: fingerprint,
                    bytes: data.count,
                    cacheControl: "public, max-age=31536000, immutable"
                )
            )
        }

        let manifestURL = publicRoot.appending(path: "asset-manifest.json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        let payload = try encoder.encode(manifest)
        try payload.write(to: manifestURL)

        return manifest.sorted { $0.sourcePath < $1.sourcePath }
    }

    private func buildPerformanceAudit(
        pages: [(routePath: String, outputPath: String)],
        assetManifest: [AssetManifestEntry]
    ) throws -> (report: BuildPerformanceReport?, path: String?) {
        guard configuration.performanceAudit.enabled else {
            return (nil, nil)
        }

        let assets = assetManifest.map { entry in
            PerformanceAsset(
                path: normalizedPublicAssetPath(entry.outputPath),
                bytes: entry.bytes
            )
        }

        var pageReports: [BuildPagePerformanceReport] = []
        for page in pages.sorted(by: { $0.routePath < $1.routePath }) {
            let htmlData = try Data(contentsOf: URL(filePath: page.outputPath))
            let html = String(decoding: htmlData, as: UTF8.self)
            let report = PerformanceAuditRunner.auditReport(
                html: html,
                assets: assets,
                options: configuration.performanceAudit.options
            )
            pageReports.append(BuildPagePerformanceReport(routePath: page.routePath, report: report))

            if configuration.performanceAudit.enforceGate {
                do {
                    try PerformanceCIGate.validate(report, options: configuration.performanceAudit.gateOptions)
                } catch let PerformanceCIGateError.failed(errorCount, warningCount) {
                    throw ServerBuildError.performanceBudgetExceeded(
                        path: page.routePath,
                        errorCount: errorCount,
                        warningCount: warningCount
                    )
                }
            }
        }

        let aggregate = BuildPerformanceReport(pages: pageReports)
        guard configuration.performanceAudit.writeReport else {
            return (aggregate, nil)
        }

        let outputURL = configuration.outputDirectory.appending(path: configuration.performanceAudit.reportFileName)
        try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        switch configuration.performanceAudit.reportFormat {
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
            let payload = try encoder.encode(aggregate)
            try payload.write(to: outputURL)
        case .markdown:
            let payload = renderPerformanceMarkdown(aggregate)
            try payload.data(using: .utf8)?.write(to: outputURL)
        }
        return (aggregate, outputURL.path())
    }

    private func renderPerformanceMarkdown(_ report: BuildPerformanceReport) -> String {
        guard !report.pages.isEmpty else {
            return "## Performance Audit\n\nNo pages were audited."
        }

        var lines: [String] = []
        lines.append("# Build Performance Audit")
        lines.append("")
        lines.append("| Route | Findings | Passed |")
        lines.append("| --- | --- | --- |")
        for page in report.pages {
            lines.append("| \(page.routePath) | \(page.report.findings.count) | \(page.report.passed ? "true" : "false") |")
        }
        lines.append("")
        for page in report.pages {
            lines.append("## \(page.routePath)")
            lines.append("")
            lines.append(PerformanceCIReporter.render(page.report, format: .markdown))
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }

    private func buildAccessibilityAudit(
        pages: [(routePath: String, outputPath: String)]
    ) throws -> (report: BuildAccessibilityReport?, path: String?) {
        guard configuration.accessibilityAudit.enabled else {
            return (nil, nil)
        }

        var pageReports: [BuildPageAccessibilityReport] = []
        for page in pages.sorted(by: { $0.routePath < $1.routePath }) {
            let htmlData = try Data(contentsOf: URL(filePath: page.outputPath))
            let html = String(decoding: htmlData, as: UTF8.self)
            let report = AccessibilityAuditRunner.auditReport(
                html: html,
                options: configuration.accessibilityAudit.options
            )
            pageReports.append(BuildPageAccessibilityReport(routePath: page.routePath, report: report))

            if configuration.accessibilityAudit.enforceGate {
                do {
                    try AccessibilityCIGate.validate(report, options: configuration.accessibilityAudit.gateOptions)
                } catch let AccessibilityCIGateError.failed(errorCount, warningCount) {
                    throw ServerBuildError.accessibilityAuditFailed(
                        path: page.routePath,
                        errorCount: errorCount,
                        warningCount: warningCount
                    )
                }
            }
        }

        let aggregate = BuildAccessibilityReport(pages: pageReports)
        guard configuration.accessibilityAudit.writeReport else {
            return (aggregate, nil)
        }

        let outputURL = configuration.outputDirectory.appending(path: configuration.accessibilityAudit.reportFileName)
        try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        switch configuration.accessibilityAudit.reportFormat {
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
            let payload = try encoder.encode(aggregate)
            try payload.write(to: outputURL)
        case .markdown:
            let payload = renderAccessibilityMarkdown(aggregate)
            try payload.data(using: .utf8)?.write(to: outputURL)
        }
        return (aggregate, outputURL.path())
    }

    private func renderAccessibilityMarkdown(_ report: BuildAccessibilityReport) -> String {
        guard !report.pages.isEmpty else {
            return "## Accessibility Audit\n\nNo pages were audited."
        }

        var lines: [String] = []
        lines.append("# Build Accessibility Audit")
        lines.append("")
        lines.append("| Route | Findings | Passed |")
        lines.append("| --- | --- | --- |")
        for page in report.pages {
            lines.append("| \(page.routePath) | \(page.report.findings.count) | \(page.report.passed ? "true" : "false") |")
        }
        lines.append("")
        for page in report.pages {
            lines.append("## \(page.routePath)")
            lines.append("")
            lines.append(AccessibilityCIReporter.render(page.report, format: .markdown))
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }

    private func normalizedPublicAssetPath(_ path: String) -> String {
        if path.hasPrefix("/") {
            return path
        }
        return "/\(path)"
    }

    private func buildSitemap(pagePaths: [String], locales: [LocaleCode]) throws -> String? {
        guard let baseURL = configuration.baseURL else {
            return nil
        }

        var entries: [String] = []
        for path in pagePaths {
            for locale in locales {
                let fullURL = LocaleRouting.localizedURL(
                    baseURL: baseURL,
                    path: path,
                    locale: locale,
                    defaultLocale: configuration.defaultLocale
                )
                entries.append("<url><loc>\(fullURL)</loc><changefreq>weekly</changefreq></url>")
            }
        }

        let sitemap = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\(entries.joined())</urlset>"
        let sitemapURL = configuration.outputDirectory.appending(path: "sitemap.xml")
        try sitemap.data(using: .utf8)?.write(to: sitemapURL)
        return sitemapURL.path()
    }

    private func buildAlternateURLs(for pagePath: String, locales: [LocaleCode]) -> [LocaleCode: String] {
        var result: [LocaleCode: String] = [:]
        guard let baseURL = configuration.baseURL else {
            return result
        }
        for locale in locales {
            result[locale] = LocaleRouting.localizedURL(
                baseURL: baseURL,
                path: pagePath,
                locale: locale,
                defaultLocale: configuration.defaultLocale
            )
        }
        return result
    }

    private func fnv1aHex(_ data: Data) -> String {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in data {
            hash ^= UInt64(byte)
            hash &*= 0x100000001b3
        }
        return String(format: "%016llx", hash)
    }

    private func resolveBuildMode(apiRoutes: Set<ResolvedAPIRoute>) -> ResolvedApplicationBuildMode {
        switch configuration.buildMode {
        case .auto:
            return apiRoutes.isEmpty ? .staticSite : .serverSide
        case .staticSite:
            return .staticSite
        case .serverSide:
            return .serverSide
        }
    }
}

private struct ResolvedAPIRoute: Hashable {
    let path: String
    let method: String
}

private struct PlaceholderDiscoveredDocument: Document {
    let path: String
    let source: String

    var metadata: Metadata {
        Metadata(
            title: path == "/" ? "Home" : String(path.dropFirst()),
            description: "Route discovered from \(source)",
            structuredData: [
                .webPage(.init(
                    id: "urn:axiomweb:route:\(path)",
                    name: .init(path == "/" ? "Home" : String(path.dropFirst())),
                    url: path
                ))
            ]
        )
    }

    var body: some Markup {
        Main {
            Heading(.h1, metadata.title ?? "Page")
            Paragraph("Generated route for \(path)")
        }
    }
}
