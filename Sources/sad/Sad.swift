import AppleDocsLib
import ArgumentParser

@main
struct Sad: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "sad",
        abstract: "Search Apple Docs - Apple Developer Documentation CLI",
        discussion: "Search, browse, and read Apple developer docs from the terminal. Optimized for AI agents.",
        version: "0.1.0",
        subcommands: [
            DocCommand.self,
            DoccCommand.self,
            SearchCommand.self,
            FrameworksCommand.self,
            WwdcCommand.self,
            SamplesCommand.self,
            RelatedCommand.self,
            PlatformCommand.self,
            HigCommand.self,
            WasmCommand.self,
            EvolutionCommand.self,
        ]
    )
}
