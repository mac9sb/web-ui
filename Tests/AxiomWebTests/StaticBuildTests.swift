import Foundation
import Testing
import HTTPTypes
@testable import AxiomWebServer
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
}
