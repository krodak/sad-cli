import Foundation
import Testing
@testable import AppleDocsLib

@Test func parsesMetadataTitle() throws {
    let data = try fixtureData(named: "swiftui-view")
    let doc = try JSONDecoder().decode(DocContent.self, from: data)
    #expect(doc.metadata?.title == "View")
}

@Test func parsesMetadataPlatforms() throws {
    let data = try fixtureData(named: "swiftui-view")
    let doc = try JSONDecoder().decode(DocContent.self, from: data)
    let platforms = try #require(doc.metadata?.platforms)
    #expect(!platforms.isEmpty)
    #expect(platforms.contains { $0.name == "iOS" })
}

@Test func parsesIdentifierURL() throws {
    let data = try fixtureData(named: "swiftui-view")
    let doc = try JSONDecoder().decode(DocContent.self, from: data)
    let url = try #require(doc.identifier?.url)
    #expect(url.contains("SwiftUI"))
}

@Test func parsesAbstract() throws {
    let data = try fixtureData(named: "swiftui-view")
    let doc = try JSONDecoder().decode(DocContent.self, from: data)
    let abstract = try #require(doc.abstract)
    #expect(!abstract.isEmpty)
    let text = abstract.map(\.plainText).joined()
    #expect(text.contains("user interface"))
}

@Test func parsesTopicSections() throws {
    let data = try fixtureData(named: "swiftui-view")
    let doc = try JSONDecoder().decode(DocContent.self, from: data)
    let sections = try #require(doc.topicSections)
    #expect(!sections.isEmpty)
    #expect(sections[0].title != nil)
    #expect(sections[0].identifiers != nil)
}

@Test func parsesPrimaryContentSections() throws {
    let data = try fixtureData(named: "swiftui-view")
    let doc = try JSONDecoder().decode(DocContent.self, from: data)
    let sections = try #require(doc.primaryContentSections)
    #expect(!sections.isEmpty)
    #expect(sections.contains { $0.kind == "declarations" })
}

@Test func parsesReferences() throws {
    let data = try fixtureData(named: "swiftui-view")
    let doc = try JSONDecoder().decode(DocContent.self, from: data)
    let refs = try #require(doc.references)
    #expect(!refs.isEmpty)
}

private func fixtureData(named name: String) throws -> Data {
    guard let url = Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures") else {
        throw FixtureError.notFound(name)
    }
    return try Data(contentsOf: url)
}

private enum FixtureError: Error {
    case notFound(String)
}
