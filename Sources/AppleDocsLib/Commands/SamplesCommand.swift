import ArgumentParser
import Foundation

public struct SamplesCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "samples",
        abstract: "Search for Apple sample code"
    )

    @Argument(help: "Search query for sample code")
    var query: String?

    @Option(name: .long, help: "Filter by framework name")
    var framework: String?

    @Option(name: .long, help: "Maximum number of results")
    var limit: Int = 10

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public init() {}

    public func run() async throws {
        var parts: [String] = []
        if let query { parts.append(query) }
        if let framework { parts.append(framework) }
        parts.append("sample code")
        let searchQuery = parts.joined(separator: " ")

        let api = AppleSearchAPI()
        let results = try await api.search(query: searchQuery)
        let limited = Array(results.prefix(limit))

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let codable = limited.map { CodableSearchResult(from: $0) }
            let data = try encoder.encode(codable)
            print(String(data: data, encoding: .utf8)!)
        } else {
            let formatter = MarkdownFormatter()
            print(formatter.formatSearchResults(limited))
        }
    }
}
