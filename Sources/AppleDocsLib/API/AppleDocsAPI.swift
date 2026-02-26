import Foundation

public struct AppleDocsAPI: Sendable {
    private let client: HTTPClient
    private let baseURL = "https://developer.apple.com/tutorials/data"

    public init(client: HTTPClient = HTTPClient()) {
        self.client = client
    }

    public func fetchDoc(path: String) async throws -> DocContent {
        let normalizedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        let lowered = normalizedPath.lowercased()
        let urlString = "\(baseURL)/documentation/\(lowered).json"
        guard URL(string: urlString) != nil else {
            throw AppleDocsAPIError.invalidPath(path)
        }
        return try await client.fetchJSON(DocContent.self, url: urlString)
    }

    public func fetchHig(topic: String?) async throws -> DocContent {
        let urlString = Self.higURL(baseURL: baseURL, topic: topic)
        guard URL(string: urlString) != nil else {
            throw AppleDocsAPIError.invalidPath(topic ?? "overview")
        }
        return try await client.fetchJSON(DocContent.self, url: urlString)
    }

    public static func higURL(baseURL: String = "https://developer.apple.com/tutorials/data", topic: String?) -> String {
        if let topic = topic {
            return "\(baseURL)/design/human-interface-guidelines/\(topic).json"
        } else {
            return "\(baseURL)/design/human-interface-guidelines.json"
        }
    }

    public func fetchWwdcTranscript(year: Int, sessionId: String) async throws -> String {
        let urlString = Self.wwdcTranscriptURL(year: year, sessionId: sessionId)
        guard URL(string: urlString) != nil else {
            throw AppleDocsAPIError.invalidPath("wwdc\(year)/\(sessionId)")
        }
        let html = try await client.fetchString(url: urlString)
        let transcript = parseTranscriptHTML(html)
        guard !transcript.isEmpty else {
            throw AppleDocsAPIError.noTranscript(year: year, sessionId: sessionId)
        }
        return transcript
    }

    public static func wwdcTranscriptURL(year: Int, sessionId: String) -> String {
        "https://developer.apple.com/videos/play/wwdc\(year)/\(sessionId)/"
    }

    func parseTranscriptHTML(_ html: String) -> String {
        guard let sectionStart = html.range(of: "<section id=\"transcript-content\">") else {
            return ""
        }
        let afterSection = html[sectionStart.upperBound...]
        guard let sectionEnd = afterSection.range(of: "</section>") else {
            return ""
        }
        let sectionContent = String(afterSection[..<sectionEnd.lowerBound])

        var spans: [String] = []
        var remaining = sectionContent[...]
        while let spanStart = remaining.range(of: "<span data-start=\"") {
            let afterAttr = remaining[spanStart.upperBound...]
            guard let attrEnd = afterAttr.range(of: "\">") else { break }
            let afterTag = afterAttr[attrEnd.upperBound...]
            guard let spanClose = afterTag.range(of: "</span>") else { break }
            let rawContent = String(afterTag[..<spanClose.lowerBound])
            let text = Self.stripHTMLTags(rawContent)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                spans.append(text)
            }
            remaining = afterTag[spanClose.upperBound...]
        }

        guard !spans.isEmpty else { return "" }

        var lines: [String] = []
        var currentLine: [String] = []
        for (index, span) in spans.enumerated() {
            currentLine.append(span)
            if currentLine.count >= 5 || index == spans.count - 1 {
                lines.append(currentLine.joined(separator: " "))
                currentLine = []
            }
        }
        return lines.joined(separator: "\n")
    }

    private static func stripHTMLTags(_ string: String) -> String {
        var result = ""
        var inTag = false
        for char in string {
            if char == "<" {
                inTag = true
            } else if char == ">" {
                inTag = false
            } else if !inTag {
                result.append(char)
            }
        }
        return result
    }

    public func fetchTechnologies() async throws -> TechnologiesResponse {
        let urlString = "\(baseURL)/documentation/technologies.json"
        return try await client.fetchJSON(TechnologiesResponse.self, url: urlString)
    }
}

public enum AppleDocsAPIError: Error, LocalizedError {
    case invalidPath(String)
    case noTranscript(year: Int, sessionId: String)

    public var errorDescription: String? {
        switch self {
        case .invalidPath(let path):
            return "Invalid documentation path: \(path)"
        case .noTranscript(let year, let sessionId):
            return "No transcript found for WWDC\(year) session \(sessionId)"
        }
    }
}
