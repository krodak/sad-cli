import AppleDocsLib
import ArgumentParser

@main
struct Ad: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ad",
        abstract: "Apple Developer Documentation CLI",
        version: "0.1.0",
        subcommands: []
    )
}
