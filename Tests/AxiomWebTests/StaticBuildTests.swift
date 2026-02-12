import Foundation
import Testing
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
}
