import Foundation

public struct SosumiAPI: Sendable {
    private let client: HTTPClient
    private let baseURL = "https://sosumi.ai"
    private let searchBaseURL = "https://developer.apple.com/search/"

    public init(client: HTTPClient = HTTPClient()) {
        self.client = client
    }

    public func fetchDocMarkdown(path: String) async throws -> String {
        let normalizedPath = path.hasPrefix("/") ? path : "/\(path)"
        let urlString = "\(baseURL)\(normalizedPath)"
        guard URL(string: urlString) != nil else {
            throw SosumiAPIError.invalidPath(path)
        }
        return try await client.fetchString(url: urlString)
    }

    public func fetchWwdcTranscript(year: Int, sessionId: String) async throws -> String {
        let urlString = "\(baseURL)/videos/play/wwdc\(year)/\(sessionId)"
        guard URL(string: urlString) != nil else {
            throw SosumiAPIError.invalidPath("wwdc\(year)/\(sessionId)")
        }
        return try await client.fetchString(url: urlString)
    }

    public func search(query: String) async throws -> [SearchResult] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(searchBaseURL)?q=\(encoded)"
        guard URL(string: urlString) != nil else {
            throw SosumiAPIError.invalidQuery(query)
        }
        let html = try await client.fetchString(url: urlString)
        return parseSearchHTML(html)
    }

    func parseSearchHTML(_ html: String) -> [SearchResult] {
        var results: [SearchResult] = []

        let resultBlocks = html.components(separatedBy: "<li class=\"search-result")
            .dropFirst()

        for block in resultBlocks {
            guard let result = parseResultBlock(block) else { continue }
            results.append(result)
        }

        return results
    }

    private func parseResultBlock(_ block: String) -> SearchResult? {
        guard let title = extractTitle(from: block) else { return nil }
        guard let path = extractHref(from: block) else { return nil }

        let url = "https://developer.apple.com\(path)"
        let description = extractDescription(from: block)
        let type = extractResultType(from: block)

        return SearchResult(
            title: title,
            url: url,
            description: description,
            type: type
        )
    }

    private func extractTitle(from block: String) -> String? {
        guard let anchorStart = block.range(of: "click-analytics-result") else { return nil }
        let afterAnchor = block[anchorStart.upperBound...]
        guard let tagClose = afterAnchor.range(of: ">") else { return nil }
        let afterTag = afterAnchor[tagClose.upperBound...]
        guard let endAnchor = afterTag.range(of: "</a>") else { return nil }
        let raw = String(afterTag[..<endAnchor.lowerBound])
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func extractHref(from block: String) -> String? {
        guard let hrefStart = block.range(of: "href=\"") else { return nil }
        let afterHref = block[hrefStart.upperBound...]
        guard let hrefEnd = afterHref.range(of: "\"") else { return nil }
        let path = String(afterHref[..<hrefEnd.lowerBound])
        return path.hasPrefix("/") ? path : nil
    }

    private func extractDescription(from block: String) -> String? {
        guard let descStart = block.range(of: "result-description") else { return nil }
        let afterClass = block[descStart.upperBound...]
        guard let tagClose = afterClass.range(of: ">") else { return nil }
        let afterTag = afterClass[tagClose.upperBound...]
        guard let endTag = afterTag.range(of: "</p>") else { return nil }
        let raw = String(afterTag[..<endTag.lowerBound])
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func extractResultType(from block: String) -> String? {
        guard let typeStart = block.range(of: "data-result-type=\"") else { return nil }
        let afterType = block[typeStart.upperBound...]
        guard let typeEnd = afterType.range(of: "\"") else { return nil }
        let raw = String(afterType[..<typeEnd.lowerBound])
        return raw.isEmpty ? nil : raw
    }

    static func wwdcTranscriptURL(baseURL: String = "https://sosumi.ai", year: Int, sessionId: String) -> String {
        "\(baseURL)/videos/play/wwdc\(year)/\(sessionId)"
    }

    static func docMarkdownURL(baseURL: String = "https://sosumi.ai", path: String) -> String {
        let normalizedPath = path.hasPrefix("/") ? path : "/\(path)"
        return "\(baseURL)\(normalizedPath)"
    }
}

public enum SosumiAPIError: Error, LocalizedError {
    case invalidPath(String)
    case invalidQuery(String)

    public var errorDescription: String? {
        switch self {
        case .invalidPath(let path):
            return "Invalid path: \(path)"
        case .invalidQuery(let query):
            return "Invalid search query: \(query)"
        }
    }
}
