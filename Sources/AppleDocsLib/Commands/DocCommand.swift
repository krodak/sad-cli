import ArgumentParser
import Foundation

public struct DocCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "doc",
        abstract: "Fetch and display Apple developer documentation"
    )

    @Argument(help: "Documentation path (e.g. swift/array)")
    var path: String

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public init() {}

    public func run() async throws {
        let api = AppleDocsAPI()
        let doc = try await api.fetchDoc(path: path)

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(doc)
            print(String(data: data, encoding: .utf8)!)
        } else {
            let formatter = MarkdownFormatter()
            print(formatter.formatDoc(doc))
        }
    }
}
