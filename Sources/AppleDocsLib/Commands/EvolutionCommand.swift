import ArgumentParser
import Foundation

public struct EvolutionCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "evolution",
        abstract: "Swift Evolution proposals"
    )

    @Argument(help: "SE proposal number (e.g., SE-0401, 0401, 401). Omit to list recent proposals.")
    var number: String?

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public init() {}

    public mutating func run() async throws {
        let api = SwiftEvolutionAPI()

        if let number = number {
            let markdown = try await api.fetchProposal(number: number)
            if json {
                let wrapper = ProposalWrapper(
                    number: SwiftEvolutionAPI.normalizeNumber(number),
                    content: markdown
                )
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                let data = try encoder.encode(wrapper)
                print(String(data: data, encoding: .utf8)!)
            } else {
                print(markdown)
            }
        } else {
            let proposals = try await api.listProposals()
            if json {
                let codable = proposals.map { CodableProposalEntry(number: $0.number, title: $0.title) }
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                let data = try encoder.encode(codable)
                print(String(data: data, encoding: .utf8)!)
            } else {
                var lines: [String] = ["# Swift Evolution Proposals", ""]
                lines.append("Recent proposals (use `sad evolution <number>` to read):")
                lines.append("")
                for p in proposals {
                    lines.append("- **SE-\(p.number)** \(p.title)")
                }
                print(lines.joined(separator: "\n"))
            }
        }
    }
}

struct ProposalWrapper: Codable {
    var number: String
    var content: String
}

struct CodableProposalEntry: Codable {
    var number: String
    var title: String
}
