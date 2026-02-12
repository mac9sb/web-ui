import Foundation
import Testing
@testable import AxiomWebServer

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
}
