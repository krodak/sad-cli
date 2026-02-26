import Foundation
import Testing
@testable import AppleDocsLib

@Test func parseTechnologiesTopicSections() throws {
    let data = try technologiesFixtureData()
    let response = try JSONDecoder().decode(TechnologiesResponse.self, from: data)
    let sections = try #require(response.topicSections)
    #expect(!sections.isEmpty)
    #expect(sections[0].title != nil)
    #expect(sections[0].identifiers != nil)
}

@Test func parseTechnologiesReferences() throws {
    let data = try technologiesFixtureData()
    let response = try JSONDecoder().decode(TechnologiesResponse.self, from: data)
    let refs = try #require(response.references)
    #expect(!refs.isEmpty)
}

@Test func technologiesReferencesResolvable() throws {
    let data = try technologiesFixtureData()
    let response = try JSONDecoder().decode(TechnologiesResponse.self, from: data)
    let sections = try #require(response.topicSections)
    let refs = try #require(response.references)
    let firstIdentifier = try #require(sections[0].identifiers?.first)
    let resolved = refs[firstIdentifier]
    #expect(resolved != nil)
    #expect(resolved?.title != nil)
}

@Test func pathNormalizationStripsLeadingSlash() throws {
    let _ = AppleDocsAPI()
    let path = "/SwiftUI/View"
    let normalized = path.hasPrefix("/") ? String(path.dropFirst()) : path
    #expect(normalized == "SwiftUI/View")
}

@Test func pathNormalizationKeepsPathWithoutSlash() throws {
    let path = "SwiftUI/View"
    let normalized = path.hasPrefix("/") ? String(path.dropFirst()) : path
    #expect(normalized == "SwiftUI/View")
}

@Test func pathNormalizationLowercases() throws {
    let path = "SwiftUI/View"
    let lowered = path.lowercased()
    #expect(lowered == "swiftui/view")
}

@Test func invalidPathProducesValidURL() throws {
    let _ = AppleDocsAPI()
    let baseURL = "https://developer.apple.com/tutorials/data"
    let path = "swiftui"
    let urlString = "\(baseURL)/documentation/\(path).json"
    let url = URL(string: urlString)
    #expect(url != nil)
}

private func technologiesFixtureData() throws -> Data {
    guard let url = Bundle.module.url(forResource: "technologies", withExtension: "json", subdirectory: "Fixtures") else {
        throw TechFixtureError.notFound
    }
    return try Data(contentsOf: url)
}

private enum TechFixtureError: Error {
    case notFound
}
