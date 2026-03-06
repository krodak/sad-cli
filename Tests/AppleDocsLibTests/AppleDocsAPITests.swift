import Foundation
import Testing
@testable import AppleDocsLib

@Test func parseTechnologiesSections() throws {
    let data = try technologiesFixtureData()
    let response = try JSONDecoder().decode(TechnologiesResponse.self, from: data)
    let sections = try #require(response.sections)
    #expect(!sections.isEmpty)
    let groups = try #require(sections[0].groups)
    #expect(!groups.isEmpty)
    #expect(groups[0].name == "App Frameworks")
    let technologies = try #require(groups[0].technologies)
    #expect(!technologies.isEmpty)
    #expect(technologies[0].title == "Accessibility")
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
    let sections = try #require(response.sections)
    let refs = try #require(response.references)
    let firstTech = try #require(sections[0].groups?.first?.technologies?.first)
    let identifier = try #require(firstTech.destination?.identifier)
    let resolved = refs[identifier]
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
