import ArgumentParser
import Foundation

public struct PlatformCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "platform",
        abstract: "Show platform availability for a symbol"
    )

    @Argument(help: "Documentation path (e.g. swift/array)")
    var path: String

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public init() {}

    public func run() async throws {
        let api = AppleDocsAPI()
        let doc = try await api.fetchDoc(path: path)
        let platforms = doc.metadata?.platforms ?? []

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(platforms)
            print(String(data: data, encoding: .utf8)!)
        } else {
            let formatter = MarkdownFormatter()
            print(formatter.formatPlatformAvailability(platforms))
        }
    }
}
