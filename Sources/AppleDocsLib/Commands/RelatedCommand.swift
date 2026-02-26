import ArgumentParser
import Foundation

public struct RelatedCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "related",
        abstract: "Show related topics for a documentation page"
    )

    @Argument(help: "Documentation path (e.g. swift/array)")
    var path: String

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public init() {}

    public func run() async throws {
        let api = AppleDocsAPI()
        let doc = try await api.fetchDoc(path: path)
        let sections = doc.topicSections ?? []

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(sections)
            print(String(data: data, encoding: .utf8)!)
        } else {
            if sections.isEmpty {
                print("No related topics found.")
                return
            }

            var lines: [String] = ["# Related Topics"]
            for section in sections {
                if let title = section.title {
                    lines.append("")
                    lines.append("## \(title)")
                }
                if let ids = section.identifiers {
                    for id in ids {
                        let ref = doc.references?[id]
                        let name = ref?.title ?? id.split(separator: "/").last.map(String.init) ?? id
                        lines.append("- `\(name)`")
                    }
                }
            }
            print(lines.joined(separator: "\n"))
        }
    }
}
