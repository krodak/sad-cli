import ArgumentParser
import Foundation

public struct HigCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "hig",
        abstract: "Apple Human Interface Guidelines"
    )

    @Argument(help: "HIG topic (e.g., buttons, color, typography, navigation-bars). Omit for overview.")
    var topic: String?

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public init() {}

    public mutating func run() async throws {
        let api = SosumiAPI()
        let path = Self.higPath(for: topic)
        let content = try await api.fetchDocMarkdown(path: path)

        if json {
            let wrapper = HigWrapper(topic: topic ?? "overview", content: content)
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(wrapper)
            print(String(data: data, encoding: .utf8)!)
        } else {
            print(content)
        }
    }

    static func higPath(for topic: String?) -> String {
        if let topic = topic {
            return "/design/human-interface-guidelines/\(topic)"
        } else {
            return "/design/human-interface-guidelines/"
        }
    }
}

struct HigWrapper: Codable {
    var topic: String
    var content: String
}
