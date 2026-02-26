import Foundation
import Testing
@testable import AppleDocsLib

@Test func pagesIsNotEmpty() {
    #expect(!SwiftWasmAPI.pages.isEmpty)
}

@Test func pagesContainsExpectedEntries() {
    let slugs = SwiftWasmAPI.pages.map(\.slug)
    #expect(slugs.contains("intro"))
    #expect(slugs.contains("setup"))
    #expect(slugs.contains("browser-app"))
    #expect(slugs.contains("javascript-interop"))
    #expect(slugs.contains("build-toolchain"))
}

@Test func listPagesContainsAllSlugs() {
    let api = SwiftWasmAPI()
    let output = api.listPages()
    for page in SwiftWasmAPI.pages {
        #expect(output.contains(page.slug))
    }
    #expect(output.contains("# SwiftWasm Book"))
    #expect(output.contains("https://book.swiftwasm.org"))
}

@Test func unknownPageErrorIncludesAvailableSlugs() {
    let error = SwiftWasmAPIError.unknownPage("nonexistent", available: ["intro", "setup"])
    let description = error.errorDescription!
    #expect(description.contains("nonexistent"))
    #expect(description.contains("intro"))
    #expect(description.contains("setup"))
}

@Test func urlConstructionMatchesExpectedPattern() {
    let baseURL = "https://raw.githubusercontent.com/swiftwasm/swiftwasm-book/main/src"
    guard let page = SwiftWasmAPI.pages.first(where: { $0.slug == "setup" }) else {
        Issue.record("setup page not found")
        return
    }
    let url = "\(baseURL)/\(page.path)"
    #expect(url == "https://raw.githubusercontent.com/swiftwasm/swiftwasm-book/main/src/getting-started/setup.md")
}

@Test func allSlugsAreUnique() {
    let slugs = SwiftWasmAPI.pages.map(\.slug)
    #expect(Set(slugs).count == slugs.count)
}
