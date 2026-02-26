import ArgumentParser
import Foundation

public struct DoccCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "docc",
        abstract: "Fetch external Swift-DocC documentation"
    )

    @Argument(help: "Documentation URL (e.g., https://apple.github.io/swift-argument-parser/documentation/argumentparser)")
    var url: String

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public init() {}

    public mutating func run() async throws {
        let jsonURL = try Self.toJSONURL(url)
        let client = HTTPClient()
        let doc = try await client.fetchJSON(DocContent.self, url: jsonURL)

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

    static func toJSONURL(_ input: String) throws -> String {
        var normalized = input

        if !normalized.hasPrefix("https://") && !normalized.hasPrefix("http://") {
            normalized = "https://\(normalized)"
        }

        guard let range = normalized.range(of: "/documentation/") else {
            throw DoccCommandError.invalidURL(input)
        }

        let base = normalized[normalized.startIndex..<range.lowerBound]
        var path = String(normalized[range.upperBound...])

        if path.hasSuffix("/") {
            path = String(path.dropLast())
        }

        return "\(base)/data/documentation/\(path).json"
    }
}

public enum DoccCommandError: Error, LocalizedError {
    case invalidURL(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid DocC URL: '\(url)'. Expected a URL containing /documentation/ (e.g., https://apple.github.io/swift-argument-parser/documentation/argumentparser)"
        }
    }
}
