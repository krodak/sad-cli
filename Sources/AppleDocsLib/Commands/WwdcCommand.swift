import ArgumentParser
import Foundation

public struct WwdcCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "wwdc",
        abstract: "Fetch WWDC session transcripts or documentation"
    )

    @Argument(help: "Session reference (YYYY/NNNNN for transcript) or documentation topic")
    var input: String

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public init() {}

    public func run() async throws {
        let api = AppleDocsAPI()

        if let (year, sessionId) = Self.parseSessionRef(input) {
            let transcript = try await api.fetchWwdcTranscript(year: year, sessionId: sessionId)
            if json {
                let wrapper = TranscriptWrapper(year: year, sessionId: sessionId, transcript: transcript)
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                let data = try encoder.encode(wrapper)
                print(String(data: data, encoding: .utf8)!)
            } else {
                print(transcript)
            }
        } else {
            let doc = try await api.fetchDoc(path: input)
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

    static func parseSessionRef(_ input: String) -> (Int, String)? {
        let parts = input.split(separator: "/")
        guard parts.count == 2,
              let year = Int(parts[0]),
              year >= 1990 && year <= 2100 else { return nil }
        return (year, String(parts[1]))
    }
}

struct TranscriptWrapper: Codable {
    var year: Int
    var sessionId: String
    var transcript: String
}
