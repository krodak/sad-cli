import Foundation
import Testing
@testable import AppleDocsLib

@Test func parsesSearchResultsFromFixture() throws {
    let html = try fixtureString(named: "search-results", extension: "html")
    let api = SosumiAPI()
    let results = api.parseSearchHTML(html)

    #expect(results.count == 6)
}

@Test func parsesSearchResultTitles() throws {
    let html = try fixtureString(named: "search-results", extension: "html")
    let api = SosumiAPI()
    let results = api.parseSearchHTML(html)

    #expect(results[0].title == "NavigationStack")
    #expect(results[1].title == "navigationStack")
    #expect(results[2].title == "Understanding the navigation stack")
    #expect(results[3].title == "Navigation")
    #expect(results[4].title == "stack")
    #expect(results[5].title == "NavigationPath")
}

@Test func parsesSearchResultURLs() throws {
    let html = try fixtureString(named: "search-results", extension: "html")
    let api = SosumiAPI()
    let results = api.parseSearchHTML(html)

    #expect(results[0].url == "https://developer.apple.com/documentation/swiftui/navigationstack/")
    #expect(results[1].url == "https://developer.apple.com/documentation/swiftui/toolbarrole/navigationstack/")
    #expect(results[5].url == "https://developer.apple.com/documentation/swiftui/navigationpath/")
    for result in results {
        #expect(!result.url.hasPrefix("https://developer.apple.comhttps://"))
    }
}

@Test func parsesSearchResultDescriptions() throws {
    let html = try fixtureString(named: "search-results", extension: "html")
    let api = SosumiAPI()
    let results = api.parseSearchHTML(html)

    #expect(results[0].description == nil)
    #expect(results[2].description == "Learn about the navigation stack, links, and how to manage navigation types in your app\'s structure.")
    #expect(results[3].description == "Enable people to move between different parts of your app\'s view hierarchy within a scene.")
}

@Test func parsesSearchResultTypes() throws {
    let html = try fixtureString(named: "search-results", extension: "html")
    let api = SosumiAPI()
    let results = api.parseSearchHTML(html)

    for result in results {
        #expect(result.type == "documentation")
    }
}

@Test func parseSearchHTMLReturnsEmptyForGarbage() {
    let api = SosumiAPI()
    let results = api.parseSearchHTML("<html><body>No results</body></html>")
    #expect(results.isEmpty)
}

@Test func wwdcTranscriptURLConstruction() {
    let url = SosumiAPI.wwdcTranscriptURL(year: 2024, sessionId: "10143")
    #expect(url == "https://sosumi.ai/videos/play/wwdc2024/10143")
}

@Test func wwdcTranscriptURLCustomBase() {
    let url = SosumiAPI.wwdcTranscriptURL(baseURL: "https://example.com", year: 2023, sessionId: "101")
    #expect(url == "https://example.com/videos/play/wwdc2023/101")
}

@Test func docMarkdownURLNormalizesLeadingSlash() {
    let withSlash = SosumiAPI.docMarkdownURL(path: "/documentation/swiftui")
    let withoutSlash = SosumiAPI.docMarkdownURL(path: "documentation/swiftui")

    #expect(withSlash == "https://sosumi.ai/documentation/swiftui")
    #expect(withoutSlash == "https://sosumi.ai/documentation/swiftui")
}

private func fixtureString(named name: String, extension ext: String) throws -> String {
    guard let url = Bundle.module.url(forResource: name, withExtension: ext, subdirectory: "Fixtures") else {
        throw FixtureError.notFound(name)
    }
    return try String(contentsOf: url, encoding: .utf8)
}

private enum FixtureError: Error {
    case notFound(String)
}
