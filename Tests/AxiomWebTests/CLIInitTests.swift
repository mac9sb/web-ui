import Foundation
import Testing
@testable import AxiomWebCLI

@Suite("CLI Init")
struct CLIInitTests {
    @Test("Initializes static project scaffold with agents file")
    func initializesStaticProjectScaffoldWithAgentsFile() throws {
        let root = FileManager.default.temporaryDirectory.appending(path: "axiomweb-init-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }

        let report = try AxiomWebCLI.initializeProject(
            configuration: .init(projectDirectory: root, projectType: .staticSite, agentsFilePath: "AGENTS.md")
        )

        #expect(report.createdDirectories.contains("Routes/pages"))
        #expect(report.createdDirectories.contains("Components"))
        #expect(report.createdDirectories.contains("Assets"))
        #expect(report.createdFiles.contains("Routes/pages/index.swift"))
        #expect(report.createdFiles.contains("Components/SiteHeader.swift"))
        #expect(report.createdFiles.contains("AGENTS.md"))
        #expect(report.createdFiles.contains("Routes/api/hello.swift") == false)

        let agentsPath = root.appending(path: "AGENTS.md")
        let agents = try String(contentsOf: agentsPath, encoding: .utf8)
        #expect(agents.contains("Axiom Project Rules"))
        #expect(agents.contains("typed"))
    }

    @Test("Initializes server project scaffold with example API and websocket routes")
    func initializesServerProjectScaffoldWithExampleRoutes() throws {
        let root = FileManager.default.temporaryDirectory.appending(path: "axiomweb-init-server-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }

        let report = try AxiomWebCLI.initializeProject(
            configuration: .init(projectDirectory: root, projectType: .server, agentsFilePath: nil)
        )

        #expect(report.createdDirectories.contains("Routes/pages"))
        #expect(report.createdDirectories.contains("Routes/api"))
        #expect(report.createdDirectories.contains("Routes/ws"))
        #expect(report.createdDirectories.contains("Components"))
        #expect(report.createdFiles.contains("Routes/pages/index.swift"))
        #expect(report.createdFiles.contains("Components/SiteHeader.swift"))
        #expect(report.createdFiles.contains("Routes/api/hello.swift"))
        #expect(report.createdFiles.contains("Routes/ws/echo.swift"))
    }

    @Test("Init fails when scaffold file exists without force")
    func initFailsWhenScaffoldFileExistsWithoutForce() throws {
        let root = FileManager.default.temporaryDirectory.appending(path: "axiomweb-init-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }

        _ = try AxiomWebCLI.initializeProject(
            configuration: .init(projectDirectory: root, projectType: .staticSite, agentsFilePath: "AGENTS.md")
        )

        #expect(throws: AxiomWebProjectInitError.self) {
            _ = try AxiomWebCLI.initializeProject(
                configuration: .init(projectDirectory: root, projectType: .staticSite, agentsFilePath: "AGENTS.md", overwriteExisting: false)
            )
        }
    }
}
