import AppleDocsLib
import ArgumentParser

@main
struct Ad: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ad",
        abstract: "Apple Developer Documentation CLI",
        discussion: "Search, browse, and read Apple developer docs from the terminal. Optimized for AI agents.",
        version: "0.1.0",
        subcommands: [
            DocCommand.self,
            SearchCommand.self,
            FrameworksCommand.self,
            WwdcCommand.self,
            SamplesCommand.self,
            RelatedCommand.self,
            PlatformCommand.self,
            HigCommand.self,
            WasmCommand.self,
        ]
    )
}
