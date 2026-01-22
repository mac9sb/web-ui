import ArgumentParser

/// Root command for the `web-ui` CLI.
public struct WebUIRootCommand: ParsableCommand {
    public init() {}

    public static let configuration = CommandConfiguration(
        commandName: "web-ui",
        abstract: "WebUI – type-safe static sites and SSR",
        version: "0.1.0",
        subcommands: [
            InitCommand.self,
            BuildCommand.self,
            RunCommand.self,
            ServeCommand.self,
        ]
    )
}
