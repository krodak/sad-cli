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

    public func fetchTechnologies() async throws -> TechnologiesResponse {
        let urlString = "\(baseURL)/documentation/technologies.json"
        return try await client.fetchJSON(TechnologiesResponse.self, url: urlString)
    }
}

public enum AppleDocsAPIError: Error, LocalizedError {
    case invalidPath(String)

    public var errorDescription: String? {
        switch self {
        case .invalidPath(let path):
            return "Invalid documentation path: \(path)"
        }
    }
}
