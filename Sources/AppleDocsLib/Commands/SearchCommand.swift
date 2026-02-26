import ArgumentParser
import Foundation

public struct SearchCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "search",
        abstract: "Search Apple developer documentation"
    )

    @Argument(help: "Search query")
    var query: String

    @Option(name: .long, help: "Maximum number of results")
    var limit: Int = 20

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public init() {}

    public func run() async throws {
        let api = AppleSearchAPI()
        let results = try await api.search(query: query)
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

struct CodableSearchResult: Codable {
    var title: String
    var url: String
    var description: String?
    var type: String?

    init(from result: SearchResult) {
        self.title = result.title
        self.url = result.url
        self.description = result.description
        self.type = result.type
    }
}
