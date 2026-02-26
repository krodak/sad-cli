import ArgumentParser
import Foundation

public struct FrameworksCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "frameworks",
        abstract: "List Apple frameworks and technologies"
    )

    @Option(name: .long, help: "Filter frameworks by name (case-insensitive)")
    var filter: String?

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public init() {}

    public func run() async throws {
        let api = AppleDocsAPI()
        var response = try await api.fetchTechnologies()

        if let filter = filter?.lowercased() {
            response = filterTechnologies(response, by: filter)
        }

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(response)
            print(String(data: data, encoding: .utf8)!)
        } else {
            let formatter = MarkdownFormatter()
            print(formatter.formatTechnologies(response))
        }
    }

    private func filterTechnologies(_ response: TechnologiesResponse, by filter: String) -> TechnologiesResponse {
        guard let refs = response.references else { return response }

        let matchingIDs = Set(refs.filter { _, ref in
            ref.title?.lowercased().contains(filter) == true
        }.keys)

        let filteredSections = response.topicSections?.compactMap { section -> TopicSection? in
            let filtered = section.identifiers?.filter { matchingIDs.contains($0) }
            guard let filtered, !filtered.isEmpty else { return nil }
            var s = section
            s.identifiers = filtered
            return s
        }

        var result = response
        result.topicSections = filteredSections
        return result
    }
}
