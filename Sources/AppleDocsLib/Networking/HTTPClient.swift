import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum HTTPClientError: Error, Sendable {
    case invalidResponse
    case httpError(statusCode: Int, url: String)
    case decodingFailed(underlying: Error)
}

public struct HTTPClient: Sendable {
    private static let userAgent = "sad-cli/0.1.0"

    public init() {}

    public func fetch(url: String) async throws -> Data {
        guard let requestURL = URL(string: url) else {
            throw HTTPClientError.invalidResponse
        }

        var request = URLRequest(url: requestURL)
        request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPClientError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw HTTPClientError.httpError(statusCode: httpResponse.statusCode, url: url)
        }

        return data
    }

    public func fetchString(url: String) async throws -> String {
        let data = try await fetch(url: url)
        guard let string = String(data: data, encoding: .utf8) else {
            throw HTTPClientError.invalidResponse
        }
        return string
    }

    public func fetchJSON<T: Decodable>(_ type: T.Type, url: String) async throws -> T {
        let data = try await fetch(url: url)
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw HTTPClientError.decodingFailed(underlying: error)
        }
    }
}
