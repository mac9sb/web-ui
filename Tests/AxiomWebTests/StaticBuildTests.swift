import Foundation
import Testing
import HTTPTypes
@testable import AxiomWebI18n
@testable import AxiomWebServer
@testable import AxiomWebTesting
@testable import AxiomWebUI

@Suite("Static Build")
struct StaticBuildTests {
    @Test("Builds HTML, public assets, and sitemap")
    func buildsSiteArtifacts() throws {
        let tempRoot = FileManager.default.temporaryDirectory.appending(path: "axiomweb-build-\(UUID().uuidString)")
        let routesRoot = tempRoot.appending(path: "Routes")
        let pagesRoot = routesRoot.appending(path: "pages")
        let assetsRoot = tempRoot.appending(path: "Assets")
        let outputRoot = tempRoot.appending(path: "Output")

        try FileManager.default.createDirectory(at: pagesRoot.appending(path: "path"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: assetsRoot, withIntermediateDirectories: true)

        FileManager.default.createFile(atPath: pagesRoot.appending(path: "index.swift").path(), contents: Data())
        FileManager.default.createFile(atPath: pagesRoot.appending(path: "path/goodbye.swift").path(), contents: Data())
        FileManager.default.createFile(atPath: assetsRoot.appending(path: "logo.txt").path(), contents: Data("logo".utf8))

        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let report = try StaticSiteBuilder(
            configuration: .init(
                routesRoot: routesRoot,
                outputDirectory: outputRoot,
                assetsSourceDirectory: assetsRoot,
                baseURL: "https://example.com"
            )
        ).build()

        #expect(report.buildMode == .staticSite)
        #expect(report.pageCount == 2)
        #expect(report.localeCount == 1)
        #expect(report.assetManifest.count == 1)
        #expect(report.sitemapPath != nil)

        #expect(FileManager.default.fileExists(atPath: outputRoot.appending(path: "index.html").path()))
        #expect(FileManager.default.fileExists(atPath: outputRoot.appending(path: "path/goodbye/index.html").path()))
        #expect(FileManager.default.fileExists(atPath: outputRoot.appending(path: "public/logo.txt").path()))
        #expect(FileManager.default.fileExists(atPath: outputRoot.appending(path: "public/asset-manifest.json").path()))
        #expect(FileManager.default.fileExists(atPath: outputRoot.appending(path: "sitemap.xml").path()))
    }

    @Test("Fails on page route conflict in strict conflict mode")
    func failsOnPageRouteConflict() throws {
        struct OverrideDoc: Document {
            var metadata: Metadata { Metadata(title: "Override") }
            var path: String { "/" }
            var body: some Markup { Main { Text("override") } }
        }

        let tempRoot = FileManager.default.temporaryDirectory.appending(path: "axiomweb-conflict-\(UUID().uuidString)")
        let routesRoot = tempRoot.appending(path: "Routes")
        let pagesRoot = routesRoot.appending(path: "pages")
        let assetsRoot = tempRoot.appending(path: "Assets")
        let outputRoot = tempRoot.appending(path: "Output")

        try FileManager.default.createDirectory(at: pagesRoot, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: assetsRoot, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: pagesRoot.appending(path: "index.swift").path(), contents: Data())

        defer { try? FileManager.default.removeItem(at: tempRoot) }

        do {
            _ = try StaticSiteBuilder(
                configuration: .init(
                    routesRoot: routesRoot,
                    outputDirectory: outputRoot,
                    assetsSourceDirectory: assetsRoot,
                    pageOverrides: [.init(path: "/", document: OverrideDoc())],
                    routeConflictPolicy: .failBuild
                )
            ).build()
            #expect(Bool(false), "Expected route conflict failure")
        } catch let error as ServerBuildError {
            #expect(error == .routeConflict(path: "/"))
        }
    }

    @Test("Fails on API route conflict in strict conflict mode")
    func failsOnAPIRouteConflict() throws {
        let tempRoot = FileManager.default.temporaryDirectory.appending(path: "axiomweb-api-conflict-\(UUID().uuidString)")
        let routesRoot = tempRoot.appending(path: "Routes")
        let apiRoot = routesRoot.appending(path: "api")
        let assetsRoot = tempRoot.appending(path: "Assets")
        let outputRoot = tempRoot.appending(path: "Output")

        try FileManager.default.createDirectory(at: apiRoot, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: assetsRoot, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: apiRoot.appending(path: "hello.swift").path(), contents: Data())

        defer { try? FileManager.default.removeItem(at: tempRoot) }

        do {
            _ = try StaticSiteBuilder(
                configuration: .init(
                    routesRoot: routesRoot,
                    outputDirectory: outputRoot,
                    assetsSourceDirectory: assetsRoot,
                    apiOverrides: [.init(path: "/api/hello", method: "GET")],
                    routeConflictPolicy: .failBuild
                )
            ).build()
            #expect(Bool(false), "Expected API route conflict failure")
        } catch let error as ServerBuildError {
            #expect(error == .apiRouteConflict(path: "/api/hello", method: "GET"))
        }
    }

    @Test("Counts typed API contract overrides in build report")
    func countsTypedAPIContractOverrides() throws {
        struct HelloContract: APIRouteContract {
            static var method: HTTPRequest.Method { .get }
            static var path: String { "/api/hello" }

            func handle(request: EmptyAPIRequest, context: APIRequestContext) async throws -> APIResponse<Bool> {
                APIResponse(body: true)
            }
        }

        let tempRoot = FileManager.default.temporaryDirectory.appending(path: "axiomweb-contract-count-\(UUID().uuidString)")
        let routesRoot = tempRoot.appending(path: "Routes")
        let pagesRoot = routesRoot.appending(path: "pages")
        let assetsRoot = tempRoot.appending(path: "Assets")
        let outputRoot = tempRoot.appending(path: "Output")

        try FileManager.default.createDirectory(at: pagesRoot, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: assetsRoot, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: pagesRoot.appending(path: "index.swift").path(), contents: Data())
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        var overrides = RouteOverrides()
        overrides.api(HelloContract())

        let report = try StaticSiteBuilder(
            configuration: .init(
                routesRoot: routesRoot,
                outputDirectory: outputRoot,
                assetsSourceDirectory: assetsRoot,
                overrides: overrides
            )
        ).build()

        #expect(report.buildMode == .serverSide)
        #expect(report.apiRouteCount == 1)
        #expect(report.writtenHTMLFiles.isEmpty)
        #expect(report.assetManifest.isEmpty)
        #expect(report.sitemapPath == nil)
    }

    @Test("Auto mode defaults to full-stack when API routes exist")
    func autoModeDefaultsToFullStackWithAPI() throws {
        let tempRoot = FileManager.default.temporaryDirectory.appending(path: "axiomweb-auto-fullstack-\(UUID().uuidString)")
        let routesRoot = tempRoot.appending(path: "Routes")
        let pagesRoot = routesRoot.appending(path: "pages")
        let apiRoot = routesRoot.appending(path: "api")
        let assetsRoot = tempRoot.appending(path: "Assets")
        let outputRoot = tempRoot.appending(path: "Output")

        try FileManager.default.createDirectory(at: pagesRoot, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: apiRoot, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: assetsRoot, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: pagesRoot.appending(path: "index.swift").path(), contents: Data())
        FileManager.default.createFile(atPath: apiRoot.appending(path: "hello.swift").path(), contents: Data())
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let report = try StaticSiteBuilder(
            configuration: .init(
                routesRoot: routesRoot,
                outputDirectory: outputRoot,
                assetsSourceDirectory: assetsRoot
            )
        ).build()

        #expect(report.buildMode == .serverSide)
        #expect(report.writtenHTMLFiles.isEmpty)
        #expect(FileManager.default.fileExists(atPath: outputRoot.path()) == false)
    }

    @Test("Explicit static mode still emits static output even with API routes")
    func explicitStaticModeWithAPI() throws {
        let tempRoot = FileManager.default.temporaryDirectory.appending(path: "axiomweb-explicit-static-\(UUID().uuidString)")
        let routesRoot = tempRoot.appending(path: "Routes")
        let pagesRoot = routesRoot.appending(path: "pages")
        let apiRoot = routesRoot.appending(path: "api")
        let assetsRoot = tempRoot.appending(path: "Assets")
        let outputRoot = tempRoot.appending(path: "Output")

        try FileManager.default.createDirectory(at: pagesRoot, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: apiRoot, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: assetsRoot, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: pagesRoot.appending(path: "index.swift").path(), contents: Data())
        FileManager.default.createFile(atPath: apiRoot.appending(path: "hello.swift").path(), contents: Data())
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let report = try StaticSiteBuilder(
            configuration: .init(
                routesRoot: routesRoot,
                outputDirectory: outputRoot,
                assetsSourceDirectory: assetsRoot,
                buildMode: .staticSite
            )
        ).build()

        #expect(report.buildMode == .staticSite)
        #expect(FileManager.default.fileExists(atPath: outputRoot.appending(path: "index.html").path()))
    }

    @Test("Explicit full-stack mode skips static output")
    func explicitFullStackModeSkipsStaticOutput() throws {
        let tempRoot = FileManager.default.temporaryDirectory.appending(path: "axiomweb-explicit-fullstack-\(UUID().uuidString)")
        let routesRoot = tempRoot.appending(path: "Routes")
        let pagesRoot = routesRoot.appending(path: "pages")
        let assetsRoot = tempRoot.appending(path: "Assets")
        let outputRoot = tempRoot.appending(path: "Output")

        try FileManager.default.createDirectory(at: pagesRoot, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: assetsRoot, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: pagesRoot.appending(path: "index.swift").path(), contents: Data())
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let report = try StaticSiteBuilder(
            configuration: .init(
                routesRoot: routesRoot,
                outputDirectory: outputRoot,
                assetsSourceDirectory: assetsRoot,
                buildMode: .serverSide
            )
        ).build()

        #expect(report.buildMode == .serverSide)
        #expect(report.writtenHTMLFiles.isEmpty)
        #expect(FileManager.default.fileExists(atPath: outputRoot.path()) == false)
    }

    @Test("Auto mode defaults to server-side when websocket routes exist")
    func autoModeDefaultsToServerSideWithWebSockets() throws {
        let tempRoot = FileManager.default.temporaryDirectory.appending(path: "axiomweb-auto-websocket-\(UUID().uuidString)")
        let routesRoot = tempRoot.appending(path: "Routes")
        let pagesRoot = routesRoot.appending(path: "pages")
        let wsRoot = routesRoot.appending(path: "ws")
        let assetsRoot = tempRoot.appending(path: "Assets")
        let outputRoot = tempRoot.appending(path: "Output")

        try FileManager.default.createDirectory(at: pagesRoot, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: wsRoot, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: assetsRoot, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: pagesRoot.appending(path: "index.swift").path(), contents: Data())
        FileManager.default.createFile(atPath: wsRoot.appending(path: "events.swift").path(), contents: Data())
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let report = try StaticSiteBuilder(
            configuration: .init(
                routesRoot: routesRoot,
                outputDirectory: outputRoot,
                assetsSourceDirectory: assetsRoot
            )
        ).build()

        #expect(report.buildMode == .serverSide)
        #expect(report.websocketRouteCount == 1)
        #expect(report.writtenHTMLFiles.isEmpty)
        #expect(FileManager.default.fileExists(atPath: outputRoot.path()) == false)
    }

    @Test("Page source inference uses filename by default and var path as override")
    func pageSourceInferenceUsesFilenameAndHonorsPathOverride() throws {
        struct ContactDoc: Document {
            var metadata: Metadata { Metadata(title: "Contact") }
            var body: some Markup { Main { Text("contact") } }
        }

        struct SupportDoc: Document {
            var metadata: Metadata { Metadata(title: "Support") }
            var path: String { "/support" }
            var body: some Markup { Main { Text("support") } }
        }

        let tempRoot = FileManager.default.temporaryDirectory.appending(path: "axiomweb-page-source-inference-\(UUID().uuidString)")
        let routesRoot = tempRoot.appending(path: "Routes")
        let assetsRoot = tempRoot.appending(path: "Assets")
        let outputRoot = tempRoot.appending(path: "Output")
        try FileManager.default.createDirectory(at: assetsRoot, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        var overrides = RouteOverrides()
        overrides.page(from: "contact.swift", document: ContactDoc())
        overrides.page(from: "help.swift", document: SupportDoc())

        let report = try StaticSiteBuilder(
            configuration: .init(
                routesRoot: routesRoot,
                outputDirectory: outputRoot,
                assetsSourceDirectory: assetsRoot,
                overrides: overrides,
                buildMode: .staticSite
            )
        ).build()

        #expect(report.pageCount == 2)
        #expect(FileManager.default.fileExists(atPath: outputRoot.appending(path: "contact/index.html").path()))
        #expect(FileManager.default.fileExists(atPath: outputRoot.appending(path: "support/index.html").path()))
    }

    @Test("Build runs performance audit and writes report")
    func buildRunsPerformanceAuditAndWritesReport() throws {
        let tempRoot = FileManager.default.temporaryDirectory.appending(path: "axiomweb-performance-audit-\(UUID().uuidString)")
        let routesRoot = tempRoot.appending(path: "Routes")
        let pagesRoot = routesRoot.appending(path: "pages")
        let assetsRoot = tempRoot.appending(path: "Assets")
        let outputRoot = tempRoot.appending(path: "Output")

        try FileManager.default.createDirectory(at: pagesRoot, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: assetsRoot, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: pagesRoot.appending(path: "index.swift").path(), contents: Data())
        FileManager.default.createFile(atPath: assetsRoot.appending(path: "site.css").path(), contents: Data("body{margin:0}".utf8))
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let report = try StaticSiteBuilder(
            configuration: .init(
                routesRoot: routesRoot,
                outputDirectory: outputRoot,
                assetsSourceDirectory: assetsRoot,
                performanceAudit: .init(
                    enabled: true,
                    enforceGate: true,
                    options: .init(
                        budget: .init(
                            maxHTMLBytes: 10_000,
                            maxCSSBytes: 10_000,
                            maxJSBytes: 10_000,
                            maxTotalAssetBytes: 10_000
                        )
                    ),
                    gateOptions: .init(failOnWarnings: false),
                    reportFormat: .json
                )
            )
        ).build()

        #expect(report.performanceReport != nil)
        #expect(report.performanceReport?.pages.count == 1)
        #expect(report.performanceReportPath != nil)
        if let performanceReportPath = report.performanceReportPath {
            #expect(FileManager.default.fileExists(atPath: performanceReportPath))
        }
    }

    @Test("Build fails when performance budget is exceeded")
    func buildFailsWhenPerformanceBudgetExceeded() throws {
        let tempRoot = FileManager.default.temporaryDirectory.appending(path: "axiomweb-performance-budget-fail-\(UUID().uuidString)")
        let routesRoot = tempRoot.appending(path: "Routes")
        let pagesRoot = routesRoot.appending(path: "pages")
        let assetsRoot = tempRoot.appending(path: "Assets")
        let outputRoot = tempRoot.appending(path: "Output")

        try FileManager.default.createDirectory(at: pagesRoot, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: assetsRoot, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: pagesRoot.appending(path: "index.swift").path(), contents: Data())
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        do {
            _ = try StaticSiteBuilder(
                configuration: .init(
                    routesRoot: routesRoot,
                    outputDirectory: outputRoot,
                    assetsSourceDirectory: assetsRoot,
                    performanceAudit: .init(
                        enabled: true,
                        enforceGate: true,
                        options: .init(
                            budget: .init(
                                maxHTMLBytes: 1,
                                maxCSSBytes: 10_000,
                                maxJSBytes: 10_000,
                                maxTotalAssetBytes: 10_000
                            )
                        ),
                        gateOptions: .init(failOnWarnings: false),
                        reportFormat: .json
                    )
                )
            ).build()
            #expect(Bool(false), "Expected performance budget failure")
        } catch let error as ServerBuildError {
            if case let .performanceBudgetExceeded(path, errorCount, warningCount) = error {
                #expect(path == "/")
                #expect(errorCount > 0)
                #expect(warningCount >= 0)
            } else {
                #expect(Bool(false), "Expected .performanceBudgetExceeded")
            }
        }
    }

    @Test("Build runs accessibility audit and writes report")
    func buildRunsAccessibilityAuditAndWritesReport() throws {
        let tempRoot = FileManager.default.temporaryDirectory.appending(path: "axiomweb-accessibility-audit-\(UUID().uuidString)")
        let routesRoot = tempRoot.appending(path: "Routes")
        let pagesRoot = routesRoot.appending(path: "pages")
        let assetsRoot = tempRoot.appending(path: "Assets")
        let outputRoot = tempRoot.appending(path: "Output")

        try FileManager.default.createDirectory(at: pagesRoot, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: assetsRoot, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: pagesRoot.appending(path: "index.swift").path(), contents: Data())
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let report = try StaticSiteBuilder(
            configuration: .init(
                routesRoot: routesRoot,
                outputDirectory: outputRoot,
                assetsSourceDirectory: assetsRoot,
                accessibilityAudit: .init(
                    enabled: true,
                    enforceGate: true,
                    options: .init(
                        checkImageAlt: true,
                        checkInputLabels: true,
                        checkMainLandmark: true,
                        checkButtonNames: true,
                        checkHTMLLang: true
                    ),
                    gateOptions: .init(failOnWarnings: false),
                    reportFormat: .json
                )
            )
        ).build()

        #expect(report.accessibilityReport != nil)
        #expect(report.accessibilityReport?.pages.count == 1)
        #expect(report.accessibilityReportPath != nil)
        if let accessibilityReportPath = report.accessibilityReportPath {
            #expect(FileManager.default.fileExists(atPath: accessibilityReportPath))
        }
    }

    @Test("Build fails when accessibility audit finds errors")
    func buildFailsWhenAccessibilityAuditFindsErrors() throws {
        struct InaccessibleDoc: Document {
            var metadata: Metadata { Metadata(title: "Inaccessible") }
            var path: String { "/" }

            var body: some Markup {
                Main {
                    Form {
                        Input(name: "email", type: "email")
                    }
                }
            }
        }

        let tempRoot = FileManager.default.temporaryDirectory.appending(path: "axiomweb-accessibility-fail-\(UUID().uuidString)")
        let routesRoot = tempRoot.appending(path: "Routes")
        let assetsRoot = tempRoot.appending(path: "Assets")
        let outputRoot = tempRoot.appending(path: "Output")

        try FileManager.default.createDirectory(at: assetsRoot, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        do {
            _ = try StaticSiteBuilder(
                configuration: .init(
                    routesRoot: routesRoot,
                    outputDirectory: outputRoot,
                    assetsSourceDirectory: assetsRoot,
                    pageOverrides: [.init(path: "/", document: InaccessibleDoc())],
                    accessibilityAudit: .init(
                        enabled: true,
                        enforceGate: true,
                        gateOptions: .init(failOnWarnings: false),
                        reportFormat: .json
                    ),
                    buildMode: .staticSite
                )
            ).build()
            #expect(Bool(false), "Expected accessibility audit failure")
        } catch let error as ServerBuildError {
            if case let .accessibilityAuditFailed(path, errorCount, warningCount) = error {
                #expect(path == "/")
                #expect(errorCount > 0)
                #expect(warningCount >= 0)
            } else {
                #expect(Bool(false), "Expected .accessibilityAuditFailed")
            }
        }
    }

    @Test("Build emits localized pages with hreflang and localized structured data")
    func buildEmitsLocalizedPagesAndMetadata() throws {
        struct LocalizedHomeDoc: Document {
            let table: LocalizedStringTable

            var metadata: Metadata {
                Metadata(
                    title: "Home",
                    structuredData: [
                        .webPage(
                            .init(
                                id: "urn:axiomweb:test:home",
                                name: .init([
                                    .en: "Home Graph",
                                    "fr": "Accueil Graph",
                                ]),
                                url: "/"
                            )
                        )
                    ]
                )
            }

            var path: String { "/" }

            var body: some Markup {
                Main {
                    Paragraph {
                        LocalizedText("home.greeting", from: table)
                    }
                }
            }
        }

        let table = LocalizedStringTable([
            "home.greeting": .init([
                .en: "Welcome",
                "fr": "Bonjour",
            ])
        ])

        let tempRoot = FileManager.default.temporaryDirectory.appending(path: "axiomweb-localized-build-\(UUID().uuidString)")
        let routesRoot = tempRoot.appending(path: "Routes")
        let assetsRoot = tempRoot.appending(path: "Assets")
        let outputRoot = tempRoot.appending(path: "Output")
        try FileManager.default.createDirectory(at: assetsRoot, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let report = try StaticSiteBuilder(
            configuration: .init(
                routesRoot: routesRoot,
                outputDirectory: outputRoot,
                assetsSourceDirectory: assetsRoot,
                pageOverrides: [.init(path: "/", document: LocalizedHomeDoc(table: table))],
                defaultLocale: .en,
                locales: ["fr"],
                baseURL: "https://example.com",
                buildMode: .staticSite
            )
        ).build()

        #expect(report.localeCount == 2)

        let enPath = outputRoot.appending(path: "index.html").path()
        let frPath = outputRoot.appending(path: "fr/index.html").path()
        #expect(FileManager.default.fileExists(atPath: enPath))
        #expect(FileManager.default.fileExists(atPath: frPath))

        let enHTML = try String(contentsOfFile: enPath, encoding: .utf8)
        let frHTML = try String(contentsOfFile: frPath, encoding: .utf8)

        #expect(enHTML.contains("Welcome"))
        #expect(frHTML.contains("Bonjour"))
        #expect(enHTML.contains("Home Graph"))
        #expect(frHTML.contains("Accueil Graph"))
        #expect(enHTML.contains("hreflang=\"fr\""))
        #expect(frHTML.contains("hreflang=\"en\""))
        #expect(enHTML.contains("rel=\"canonical\" href=\"https://example.com/\""))
        #expect(frHTML.contains("rel=\"canonical\" href=\"https://example.com/fr\""))
        #expect(frHTML.contains("<html lang=\"fr\">"))
    }

    @Test("Strict route contracts fail when discovered page file has no typed document")
    func strictRouteContractsFailForUnregisteredPageFile() throws {
        let tempRoot = FileManager.default.temporaryDirectory.appending(path: "axiomweb-strict-page-\(UUID().uuidString)")
        let routesRoot = tempRoot.appending(path: "Routes")
        let pagesRoot = routesRoot.appending(path: "pages")
        let assetsRoot = tempRoot.appending(path: "Assets")
        let outputRoot = tempRoot.appending(path: "Output")

        try FileManager.default.createDirectory(at: pagesRoot, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: assetsRoot, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: pagesRoot.appending(path: "index.swift").path(), contents: Data())
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        do {
            _ = try StaticSiteBuilder(
                configuration: .init(
                    routesRoot: routesRoot,
                    outputDirectory: outputRoot,
                    assetsSourceDirectory: assetsRoot,
                    strictRouteContracts: true
                )
            ).build()
            #expect(Bool(false), "Expected strict page route contract failure")
        } catch let error as ServerBuildError {
            #expect(error == .missingPageDocument(path: "/", source: "index.swift"))
        }
    }

    @Test("Strict route contracts fail when discovered API file has no handler")
    func strictRouteContractsFailForUnregisteredAPIFile() throws {
        struct HomeDoc: Document {
            var metadata: Metadata { Metadata(title: "Home") }
            var path: String { "/" }
            var body: some Markup { Main { Text("home") } }
        }

        let tempRoot = FileManager.default.temporaryDirectory.appending(path: "axiomweb-strict-api-\(UUID().uuidString)")
        let routesRoot = tempRoot.appending(path: "Routes")
        let apiRoot = routesRoot.appending(path: "api")
        let assetsRoot = tempRoot.appending(path: "Assets")
        let outputRoot = tempRoot.appending(path: "Output")

        try FileManager.default.createDirectory(at: apiRoot, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: assetsRoot, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: apiRoot.appending(path: "hello.swift").path(), contents: Data())
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        do {
            _ = try StaticSiteBuilder(
                configuration: .init(
                    routesRoot: routesRoot,
                    outputDirectory: outputRoot,
                    assetsSourceDirectory: assetsRoot,
                    pageOverrides: [.init(path: "/", document: HomeDoc())],
                    strictRouteContracts: true
                )
            ).build()
            #expect(Bool(false), "Expected strict API route contract failure")
        } catch let error as ServerBuildError {
            #expect(error == .missingAPIHandler(path: "/api/hello", source: "hello.swift"))
        }
    }

    @Test("Strict route contracts fail when discovered websocket file has no handler")
    func strictRouteContractsFailForUnregisteredWebSocketFile() throws {
        struct HomeDoc: Document {
            var metadata: Metadata { Metadata(title: "Home") }
            var path: String { "/" }
            var body: some Markup { Main { Text("home") } }
        }

        let tempRoot = FileManager.default.temporaryDirectory.appending(path: "axiomweb-strict-websocket-\(UUID().uuidString)")
        let routesRoot = tempRoot.appending(path: "Routes")
        let wsRoot = routesRoot.appending(path: "ws")
        let assetsRoot = tempRoot.appending(path: "Assets")
        let outputRoot = tempRoot.appending(path: "Output")

        try FileManager.default.createDirectory(at: wsRoot, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: assetsRoot, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: wsRoot.appending(path: "events.swift").path(), contents: Data())
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        do {
            _ = try StaticSiteBuilder(
                configuration: .init(
                    routesRoot: routesRoot,
                    outputDirectory: outputRoot,
                    assetsSourceDirectory: assetsRoot,
                    pageOverrides: [.init(path: "/", document: HomeDoc())],
                    strictRouteContracts: true
                )
            ).build()
            #expect(Bool(false), "Expected strict websocket route contract failure")
        } catch let error as ServerBuildError {
            #expect(error == .missingWebSocketHandler(path: "/ws/events", source: "events.swift"))
        }
    }
}
