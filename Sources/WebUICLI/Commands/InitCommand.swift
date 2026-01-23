import ArgumentParser
import Foundation
import Noora

struct InitCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Initialize a new WebUI project"
    )

    @Argument(help: "Project name (optional, defaults to current directory name)")
    var projectName: String?

    @Option(name: .shortAndLong, help: "Directory to initialize project in")
    var directory: String?

    func run() throws {
        let targetDir: String
        if let directory = directory {
            targetDir = (directory as NSString).expandingTildeInPath
        } else {
            targetDir = FileManager.default.currentDirectoryPath
        }

        let name = projectName ?? (targetDir as NSString).lastPathComponent
        let projectNameSanitized = sanitizeProjectName(name)
        let moduleName = projectNameToModuleName(projectNameSanitized)
        let siteTitle = moduleNameToSiteTitle(moduleName)

        Noora().info("Initializing WebUI project: \(projectNameSanitized)")
        Noora().info("Target directory: \(targetDir)")

        if FileManager.default.fileExists(atPath: targetDir) {
            let contents = try? FileManager.default.contentsOfDirectory(atPath: targetDir)
            if let contents = contents, !contents.isEmpty {
                Noora().error("Directory is not empty: \(targetDir)")
                throw WebUIInitError.directoryNotEmpty
            }
        }

        try createDirectoryStructure(in: targetDir, moduleName: moduleName)
        try generateFiles(in: targetDir, projectName: projectNameSanitized, moduleName: moduleName, siteTitle: siteTitle)

        Noora().success(
            .alert(
                "Project initialized successfully!",
                takeaways: [
                    "cd \(targetDir)",
                    "web-ui build   # build static site to .output",
                    "web-ui run     # build and serve",
                ]
            )
        )
    }

    private func createDirectoryStructure(in baseDir: String, moduleName: String) throws {
        let fm = FileManager.default
        let sourcesDir = (baseDir as NSString).appendingPathComponent("Sources")
        let moduleDir = (sourcesDir as NSString).appendingPathComponent(moduleName)
        let pagesDir = (moduleDir as NSString).appendingPathComponent("Pages")
        let publicDir = (baseDir as NSString).appendingPathComponent("Public")
        try fm.createDirectory(atPath: pagesDir, withIntermediateDirectories: true)
        try fm.createDirectory(atPath: publicDir, withIntermediateDirectories: true)
    }

    private func generateFiles(in baseDir: String, projectName: String, moduleName: String, siteTitle: String) throws {
        let resourcesPath = getResourcesPath()
        let replacements: [String: String] = [
            "{{PROJECT_NAME}}": projectName,
            "{{MODULE_NAME}}": moduleName,
            "{{SITE_TITLE}}": siteTitle,
        ]

        let templates: [(String, String)] = [
            ("Package.swift.template", "Package.swift"),
            ("Application.swift.template", "Sources/\(moduleName)/Application.swift"),
            ("Home.swift.template", "Sources/\(moduleName)/Pages/Home.swift"),
        ]

        for (templateName, destRelative) in templates {
            let templatePath = (resourcesPath as NSString).appendingPathComponent(templateName)
            var content = try String(contentsOfFile: templatePath, encoding: .utf8)
            for (key, value) in replacements {
                content = content.replacingOccurrences(of: key, with: value)
            }
            let destPath = (baseDir as NSString).appendingPathComponent(destRelative)
            let destDir = (destPath as NSString).deletingLastPathComponent
            try FileManager.default.createDirectory(atPath: destDir, withIntermediateDirectories: true)
            try content.write(toFile: destPath, atomically: true, encoding: .utf8)
        }
    }

    private func sanitizeProjectName(_ name: String) -> String {
        let s =
            name
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "_", with: "-")
            .lowercased()
        return s.isEmpty ? "webui-site" : s
    }

    private func projectNameToModuleName(_ projectName: String) -> String {
        projectName
            .split(separator: "-")
            .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
            .joined()
    }

    private func moduleNameToSiteTitle(_ moduleName: String) -> String {
        moduleName
            .unicodeScalars
            .reduce("") { acc, c in
                if CharacterSet.uppercaseLetters.contains(c), !acc.isEmpty {
                    return acc + " " + String(c)
                }
                return acc + String(c)
            }
    }

    private func getResourcesPath() -> String {
        if let path = Bundle.module.resourcePath {
            return path
        }
        let executablePath = ProcessInfo.processInfo.arguments[0]
        let executableURL = URL(fileURLWithPath: executablePath)
        var resourcesURL = executableURL.deletingLastPathComponent().appendingPathComponent("Resources")
        if !FileManager.default.fileExists(atPath: resourcesURL.path) {
            let currentFile = #file
            let currentFileURL = URL(fileURLWithPath: currentFile)
            resourcesURL =
                currentFileURL
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appendingPathComponent("Resources")
        }
        return resourcesURL.path
    }
}

enum WebUIInitError: Error {
    case directoryNotEmpty
    case templateNotFound
    case fileWriteFailed
}

extension WebUIInitError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .directoryNotEmpty:
            return "Directory is not empty. Use an empty directory or specify a different location."
        case .templateNotFound:
            return "Template file not found."
        case .fileWriteFailed:
            return "Failed to write file."
        }
    }
}
