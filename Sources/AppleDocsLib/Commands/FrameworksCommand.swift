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
        let filteredSections = response.sections?.compactMap { section -> TechnologiesSection? in
            let filteredGroups = section.groups?.compactMap { group -> TechnologyGroup? in
                let filtered = group.technologies?.filter { tech in
                    tech.title?.lowercased().contains(filter) == true
                }
                guard let filtered, !filtered.isEmpty else { return nil }
                var g = group
                g.technologies = filtered
                return g
            }
            guard let filteredGroups, !filteredGroups.isEmpty else { return nil }
            var s = section
            s.groups = filteredGroups
            return s
        }

        var result = response
        result.sections = filteredSections
        return result
    }
}
