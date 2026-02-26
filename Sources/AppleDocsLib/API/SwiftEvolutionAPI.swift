import Foundation

public struct SwiftEvolutionAPI: Sendable {
    private let client: HTTPClient
    private let contentsURL = "https://api.github.com/repos/swiftlang/swift-evolution/contents/proposals"
    private let rawBaseURL = "https://raw.githubusercontent.com/swiftlang/swift-evolution/main/proposals"

    public init(client: HTTPClient = HTTPClient()) {
        self.client = client
    }

    public func fetchProposal(number: String) async throws -> String {
        let normalized = Self.normalizeNumber(number)
        let filename = try await findProposalFilename(number: normalized)
        let url = Self.proposalURL(baseURL: rawBaseURL, filename: filename)
        return try await client.fetchString(url: url)
    }

    public static func normalizeNumber(_ input: String) -> String {
        var stripped = input
        if stripped.lowercased().hasPrefix("se-") {
            stripped = String(stripped.dropFirst(3))
        }
        let digits = stripped.trimmingCharacters(in: .whitespaces)
        guard let num = Int(digits) else {
            return digits
        }
        return String(format: "%04d", num)
    }

    func findProposalFilename(number: String) async throws -> String {
        let entries = try await client.fetchJSON([GitHubFileEntry].self, url: contentsURL)
        guard let match = entries.first(where: { $0.name.hasPrefix(number) }) else {
            throw SwiftEvolutionAPIError.proposalNotFound(number)
        }
        return match.name
    }

    public func listProposals() async throws -> [(number: String, title: String)] {
        let entries = try await client.fetchJSON([GitHubFileEntry].self, url: contentsURL)
        var results: [(number: String, title: String)] = []
        for entry in entries {
            let name = entry.name
            guard name.hasSuffix(".md") else { continue }
            let prefix = String(name.prefix(4))
            guard Int(prefix) != nil else { continue }
            let title = Self.titleFromFilename(name)
            results.append((number: prefix, title: title))
        }
        results.sort { $0.number > $1.number }
        return Array(results.prefix(50))
    }

    public static func titleFromFilename(_ filename: String) -> String {
        var name = filename
        if name.hasSuffix(".md") {
            name = String(name.dropLast(3))
        }
        if name.count > 4 && name[name.index(name.startIndex, offsetBy: 4)] == "-" {
            name = String(name.dropFirst(5))
        }
        return name
            .split(separator: "-")
            .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
            .joined(separator: " ")
    }

    public static func proposalURL(
        baseURL: String = "https://raw.githubusercontent.com/swiftlang/swift-evolution/main/proposals",
        filename: String
    ) -> String {
        "\(baseURL)/\(filename)"
    }
}

struct GitHubFileEntry: Codable, Sendable {
    var name: String
}

public enum SwiftEvolutionAPIError: Error, LocalizedError {
    case proposalNotFound(String)
    case invalidNumber(String)

    public var errorDescription: String? {
        switch self {
        case .proposalNotFound(let number):
            return "No proposal found matching SE-\(number)"
        case .invalidNumber(let input):
            return "Invalid proposal number: '\(input)'"
        }
    }
}
