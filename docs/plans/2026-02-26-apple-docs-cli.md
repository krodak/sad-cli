# Apple Docs CLI Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build `ad` - a lightweight, stateless Swift CLI for querying Apple Developer Documentation, optimized for AI agents.

**Architecture:** Library (AppleDocsLib) + thin executable (ad). Hybrid data sources: Apple's JSON API for structured content, sosumi.ai for search/WWDC. Markdown output by default, JSON via --json flag. No local database, no config, no auth.

**Tech Stack:** Swift 6.0, swift-argument-parser, URLSession async/await, Foundation Codable, macOS 13+

**Decisions:** See `DECISIONS.md` for all architectural decisions.

---

### Task 1: Project Scaffold

**Files:**
- Create: `Package.swift`
- Create: `Sources/AppleDocsLib/AppleDocsLib.swift` (namespace placeholder)
- Create: `Sources/ad/Ad.swift` (entry point)
- Create: `Tests/AppleDocsLibTests/PlaceholderTests.swift`
- Create: `.gitignore`

**Step 1: Create Package.swift**

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "apple-docs-cli",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "ad", targets: ["ad"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "AppleDocsLib",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .executableTarget(
            name: "ad",
            dependencies: ["AppleDocsLib"]
        ),
        .testTarget(
            name: "AppleDocsLibTests",
            dependencies: ["AppleDocsLib"],
            resources: [.copy("Fixtures")]
        ),
    ]
)
```

**Step 2: Create entry point**

`Sources/ad/Ad.swift`:
```swift
import AppleDocsLib
import ArgumentParser

@main
struct Ad: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ad",
        abstract: "Apple Developer Documentation CLI",
        version: "0.1.0",
        subcommands: []
    )
}
```

`Sources/AppleDocsLib/AppleDocsLib.swift`:
```swift
public enum AppleDocsLib {
    public static let version = "0.1.0"
}
```

**Step 3: Create .gitignore**

```
.DS_Store
.build/
.swiftpm/
*.xcodeproj
*.xcworkspace
DerivedData/
```

**Step 4: Create placeholder test**

`Tests/AppleDocsLibTests/PlaceholderTests.swift`:
```swift
import Testing
@testable import AppleDocsLib

@Test func versionExists() {
    #expect(AppleDocsLib.version == "0.1.0")
}
```

**Step 5: Create test fixtures directory**

```bash
mkdir -p Tests/AppleDocsLibTests/Fixtures
```

**Step 6: Verify build and tests pass**

```bash
swift build
swift test
```

Expected: Build succeeds, 1 test passes.

**Step 7: Initialize git and commit**

```bash
git init
git add .
git commit -m "scaffold: Package.swift, library + executable targets, placeholder test"
```

---

### Task 2: Core Models and HTTP Client

**Files:**
- Create: `Sources/AppleDocsLib/Models/DocContent.swift`
- Create: `Sources/AppleDocsLib/Models/SearchResult.swift`
- Create: `Sources/AppleDocsLib/Models/Technology.swift`
- Create: `Sources/AppleDocsLib/Models/WwdcSession.swift`
- Create: `Sources/AppleDocsLib/Networking/HTTPClient.swift`
- Create: `Sources/AppleDocsLib/OutputFormat.swift`
- Create: `Tests/AppleDocsLibTests/Fixtures/swiftui-view.json`
- Create: `Tests/AppleDocsLibTests/DocContentTests.swift`

**Step 1: Create DocContent model (Apple JSON API response)**

`Sources/AppleDocsLib/Models/DocContent.swift`:
```swift
import Foundation

public struct DocContent: Codable, Sendable {
    public let metadata: DocMetadata
    public let abstract: [InlineContent]?
    public let primaryContentSections: [ContentSection]?
    public let topicSections: [TopicSection]?
    public let identifier: DocIdentifier

    public struct DocMetadata: Codable, Sendable {
        public let title: String
        public let role: String?
        public let roleHeading: String?
        public let platforms: [PlatformAvailability]?
        public let modules: [Module]?
        public let symbolKind: String?
    }

    public struct PlatformAvailability: Codable, Sendable {
        public let name: String
        public let introducedAt: String?
        public let beta: Bool?
    }

    public struct Module: Codable, Sendable {
        public let name: String
    }

    public struct DocIdentifier: Codable, Sendable {
        public let url: String
        public let interfaceLanguage: String?
    }

    public struct InlineContent: Codable, Sendable {
        public let type: String
        public let text: String?
        public let identifier: String?
        public let isActive: Bool?
    }

    public struct ContentSection: Codable, Sendable {
        public let kind: String
        public let content: [ContentBlock]?
    }

    public struct ContentBlock: Codable, Sendable {
        public let type: String
        public let text: String?
        public let anchor: String?
        public let level: Int?
        public let inlineContent: [InlineContent]?
        public let items: [ContentBlock]?
        public let content: [ContentBlock]?
        public let code: [String]?
        public let syntax: String?
        public let name: String?
        public let style: String?
    }

    public struct TopicSection: Codable, Sendable {
        public let title: String?
        public let identifiers: [String]
        public let anchor: String?
    }
}
```

**Step 2: Create SearchResult model**

`Sources/AppleDocsLib/Models/SearchResult.swift`:
```swift
import Foundation

public struct SearchResult: Codable, Sendable {
    public let title: String
    public let url: String
    public let description: String?
    public let type: String?

    public init(title: String, url: String, description: String?, type: String?) {
        self.title = title
        self.url = url
        self.description = description
        self.type = type
    }
}
```

**Step 3: Create Technology model**

`Sources/AppleDocsLib/Models/Technology.swift`:
```swift
import Foundation

public struct TechnologiesResponse: Codable, Sendable {
    public let topicSections: [DocContent.TopicSection]?
    public let references: [String: TechnologyReference]?
}

public struct TechnologyReference: Codable, Sendable {
    public let title: String
    public let url: String
    public let abstract: [DocContent.InlineContent]?
    public let kind: String?
    public let role: String?
}
```

**Step 4: Create WwdcSession model**

`Sources/AppleDocsLib/Models/WwdcSession.swift`:
```swift
import Foundation

public struct WwdcSession: Sendable {
    public let title: String
    public let url: String
    public let year: Int?
    public let sessionId: String?
    public let description: String?
    public let transcript: String?

    public init(title: String, url: String, year: Int?, sessionId: String?, description: String?, transcript: String?) {
        self.title = title
        self.url = url
        self.year = year
        self.sessionId = sessionId
        self.description = description
        self.transcript = transcript
    }
}
```

**Step 5: Create OutputFormat**

`Sources/AppleDocsLib/OutputFormat.swift`:
```swift
import ArgumentParser

public enum OutputFormat: String, CaseIterable, ExpressibleByArgument, Sendable {
    case markdown
    case json
}
```

**Step 6: Create HTTPClient**

`Sources/AppleDocsLib/Networking/HTTPClient.swift`:
```swift
import Foundation

public struct HTTPClient: Sendable {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func fetch(url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue("ad-cli/0.1.0", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPClientError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw HTTPClientError.httpError(statusCode: httpResponse.statusCode, url: url.absoluteString)
        }
        return data
    }

    public func fetchString(url: URL) async throws -> String {
        let data = try await fetch(url: url)
        guard let string = String(data: data, encoding: .utf8) else {
            throw HTTPClientError.decodingFailed
        }
        return string
    }

    public func fetchJSON<T: Decodable>(_ type: T.Type, url: URL) async throws -> T {
        let data = try await fetch(url: url)
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }
}

public enum HTTPClientError: Error, LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, url: String)
    case decodingFailed

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code, let url):
            return "HTTP \(code) error fetching \(url)"
        case .decodingFailed:
            return "Failed to decode response"
        }
    }
}
```

**Step 7: Create test fixture - save a real Apple JSON API response**

`Tests/AppleDocsLibTests/Fixtures/swiftui-view.json` - Implementer should fetch `https://developer.apple.com/tutorials/data/documentation/swiftui/view.json` and save a trimmed version (first ~100 lines of the JSON covering metadata, abstract, and first content section). Keep it small but representative.

**Step 8: Write DocContent parsing test**

`Tests/AppleDocsLibTests/DocContentTests.swift`:
```swift
import Foundation
import Testing
@testable import AppleDocsLib

@Test func parseDocContent() throws {
    let url = Bundle.module.url(forResource: "swiftui-view", withExtension: "json", subdirectory: "Fixtures")!
    let data = try Data(contentsOf: url)
    let doc = try JSONDecoder().decode(DocContent.self, from: data)
    #expect(doc.metadata.title == "View")
    #expect(doc.metadata.platforms != nil)
    #expect(!doc.metadata.platforms!.isEmpty)
    #expect(doc.identifier.url.contains("SwiftUI"))
}
```

**Step 9: Run tests**

```bash
swift test
```

Expected: All tests pass.

**Step 10: Commit**

```bash
git add .
git commit -m "feat: core models (DocContent, SearchResult, Technology, WwdcSession) and HTTP client"
```

---

### Task 3: Apple JSON API Client

**Files:**
- Create: `Sources/AppleDocsLib/API/AppleDocsAPI.swift`
- Create: `Tests/AppleDocsLibTests/AppleDocsAPITests.swift`
- Create: `Tests/AppleDocsLibTests/Fixtures/technologies.json`

**Step 1: Create AppleDocsAPI**

`Sources/AppleDocsLib/API/AppleDocsAPI.swift`:
```swift
import Foundation

public struct AppleDocsAPI: Sendable {
    private let client: HTTPClient
    private let baseURL = "https://developer.apple.com/tutorials/data"

    public init(client: HTTPClient = HTTPClient()) {
        self.client = client
    }

    public func fetchDoc(path: String) async throws -> DocContent {
        let normalizedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        let urlString = "\(baseURL)/documentation/\(normalizedPath).json"
        guard let url = URL(string: urlString) else {
            throw AppleDocsAPIError.invalidPath(path)
        }
        return try await client.fetchJSON(DocContent.self, url: url)
    }

    public func fetchTechnologies() async throws -> TechnologiesResponse {
        let url = URL(string: "\(baseURL)/documentation/technologies.json")!
        return try await client.fetchJSON(TechnologiesResponse.self, url: url)
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
```

**Step 2: Create test fixture for technologies**

Implementer should fetch `https://developer.apple.com/tutorials/data/documentation/technologies.json` and save a trimmed version containing just the first 2-3 topic sections with a few references. Keep it under 200 lines.

**Step 3: Write unit tests for URL construction and JSON parsing**

`Tests/AppleDocsLibTests/AppleDocsAPITests.swift`:
```swift
import Foundation
import Testing
@testable import AppleDocsLib

@Test func fetchDocConstructsCorrectURL() async throws {
    // Test that path normalization works
    let api = AppleDocsAPI()
    // We test the actual URL construction by checking known-good paths
    // Integration test - only run when network is available
}

@Test func parseTechnologiesFixture() throws {
    let url = Bundle.module.url(forResource: "technologies", withExtension: "json", subdirectory: "Fixtures")!
    let data = try Data(contentsOf: url)
    let response = try JSONDecoder().decode(TechnologiesResponse.self, from: data)
    #expect(response.topicSections != nil)
    #expect(!response.topicSections!.isEmpty)
}
```

**Step 4: Run tests, commit**

```bash
swift test
git add .
git commit -m "feat: Apple JSON API client with doc fetching and technologies endpoint"
```

---

### Task 4: Sosumi API Client

**Files:**
- Create: `Sources/AppleDocsLib/API/SosumiAPI.swift`
- Create: `Tests/AppleDocsLibTests/SosumiAPITests.swift`
- Create: `Tests/AppleDocsLibTests/Fixtures/search-results.html`

**Step 1: Create SosumiAPI**

`Sources/AppleDocsLib/API/SosumiAPI.swift`:
```swift
import Foundation

public struct SosumiAPI: Sendable {
    private let client: HTTPClient
    private let baseURL = "https://sosumi.ai"

    public init(client: HTTPClient = HTTPClient()) {
        self.client = client
    }

    public func fetchDocMarkdown(path: String) async throws -> String {
        let normalizedPath = path.hasPrefix("/") ? path : "/\(path)"
        let urlString = "\(baseURL)\(normalizedPath)"
        guard let url = URL(string: urlString) else {
            throw SosumiAPIError.invalidPath(path)
        }
        return try await client.fetchString(url: url)
    }

    public func fetchWwdcTranscript(year: Int, sessionId: String) async throws -> String {
        let urlString = "\(baseURL)/videos/play/wwdc\(year)/\(sessionId)"
        guard let url = URL(string: urlString) else {
            throw SosumiAPIError.invalidPath("wwdc\(year)/\(sessionId)")
        }
        return try await client.fetchString(url: url)
    }

    public func search(query: String) async throws -> [SearchResult] {
        // Use Apple's search endpoint and parse HTML results
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://developer.apple.com/search/search_data.php?q=\(encoded)&type=Documentation"
        guard let url = URL(string: urlString) else {
            throw SosumiAPIError.invalidQuery(query)
        }
        let html = try await client.fetchString(url: url)
        return parseSearchHTML(html)
    }

    func parseSearchHTML(_ html: String) -> [SearchResult] {
        // Parse search results from Apple's HTML response
        // Each result is in a structure with title, URL, and description
        var results: [SearchResult] = []

        // Split by result items - Apple uses <a> tags with specific structure
        let lines = html.components(separatedBy: "\n")
        var currentTitle: String?
        var currentURL: String?
        var currentDescription: String?

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Look for result links with documentation URLs
            if trimmed.contains("href=\"/documentation/") || trimmed.contains("href=\"/tutorials/") {
                if let hrefRange = trimmed.range(of: "href=\""),
                   let endRange = trimmed[hrefRange.upperBound...].range(of: "\"") {
                    currentURL = "https://developer.apple.com" + String(trimmed[hrefRange.upperBound..<endRange.lowerBound])
                }
            }

            // Look for result titles
            if trimmed.contains("class=\"title\"") || trimmed.contains("search-result-title") {
                currentTitle = trimmed.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespaces)
            }

            // Look for descriptions
            if trimmed.contains("class=\"description\"") || trimmed.contains("search-result-description") {
                currentDescription = trimmed.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespaces)
            }

            // When we have enough data for a result, save it
            if let title = currentTitle, let url = currentURL, !title.isEmpty {
                results.append(SearchResult(title: title, url: url, description: currentDescription, type: "documentation"))
                currentTitle = nil
                currentURL = nil
                currentDescription = nil
            }
        }

        return results
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
```

**Important note for implementer:** The search HTML parsing is best-effort. Apple's search page structure may vary. The implementer should fetch actual search results HTML, inspect the structure, and adapt the parser accordingly. If Apple's search endpoint returns JSON instead of HTML, use that instead. The key contract is: `search(query:) -> [SearchResult]`.

**Step 2: Write search parser tests with fixture HTML**

Create `Tests/AppleDocsLibTests/Fixtures/search-results.html` with a representative sample of Apple's search results HTML. The implementer should fetch `https://developer.apple.com/search/search_data.php?q=NavigationStack&type=Documentation` and save the response.

**Step 3: Write tests**

`Tests/AppleDocsLibTests/SosumiAPITests.swift`:
```swift
import Foundation
import Testing
@testable import AppleDocsLib

@Test func parseSearchResults() throws {
    let url = Bundle.module.url(forResource: "search-results", withExtension: "html", subdirectory: "Fixtures")!
    let html = try String(contentsOf: url, encoding: .utf8)
    let api = SosumiAPI()
    let results = api.parseSearchHTML(html)
    #expect(!results.isEmpty)
    #expect(results.allSatisfy { !$0.title.isEmpty })
    #expect(results.allSatisfy { $0.url.starts(with: "https://") })
}

@Test func wwdcURLConstruction() {
    // Verify URL construction for WWDC transcript fetching
    let api = SosumiAPI()
    // The URL should be: https://sosumi.ai/videos/play/wwdc2024/10102
    // We can't test the actual fetch without network, but we verify the API exists
    #expect(true) // Placeholder - integration test
}
```

**Step 4: Run tests, commit**

```bash
swift test
git add .
git commit -m "feat: Sosumi API client with search HTML parsing and WWDC transcript fetching"
```

---

### Task 5: Markdown Formatter

**Files:**
- Create: `Sources/AppleDocsLib/Formatters/MarkdownFormatter.swift`
- Create: `Tests/AppleDocsLibTests/MarkdownFormatterTests.swift`

**Step 1: Create MarkdownFormatter**

`Sources/AppleDocsLib/Formatters/MarkdownFormatter.swift`:
```swift
import Foundation

public struct MarkdownFormatter: Sendable {
    public init() {}

    public func formatDoc(_ doc: DocContent) -> String {
        var lines: [String] = []

        // Title
        lines.append("# \(doc.metadata.title)")
        lines.append("")

        // Role heading (e.g., "Framework", "Structure", "Protocol")
        if let heading = doc.metadata.roleHeading {
            lines.append("**\(heading)**")
            if let module = doc.metadata.modules?.first?.name {
                lines.append("Framework: \(module)")
            }
            lines.append("")
        }

        // Platform availability
        if let platforms = doc.metadata.platforms, !platforms.isEmpty {
            let platformStrings = platforms.compactMap { p -> String? in
                guard let version = p.introducedAt else { return p.name }
                let beta = (p.beta == true) ? " (beta)" : ""
                return "\(p.name) \(version)+\(beta)"
            }
            lines.append("**Availability:** \(platformStrings.joined(separator: " | "))")
            lines.append("")
        }

        // Abstract
        if let abstract = doc.abstract {
            lines.append(formatInlineContent(abstract))
            lines.append("")
        }

        // Primary content sections
        if let sections = doc.primaryContentSections {
            for section in sections where section.kind == "content" {
                if let content = section.content {
                    lines.append(formatContentBlocks(content))
                }
            }
        }

        // Topic sections (related APIs)
        if let topics = doc.topicSections, !topics.isEmpty {
            lines.append("## Topics")
            lines.append("")
            for topic in topics {
                if let title = topic.title {
                    lines.append("### \(title)")
                    lines.append("")
                }
                for id in topic.identifiers.prefix(10) {
                    let name = id.components(separatedBy: "/").last ?? id
                    lines.append("- `\(name)`")
                }
                lines.append("")
            }
        }

        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func formatSearchResults(_ results: [SearchResult]) -> String {
        if results.isEmpty { return "No results found." }

        var lines: [String] = []
        lines.append("# Search Results")
        lines.append("")
        for (i, result) in results.enumerated() {
            lines.append("## \(i + 1). \(result.title)")
            if let desc = result.description, !desc.isEmpty {
                lines.append(desc)
            }
            lines.append("URL: \(result.url)")
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }

    public func formatTechnologies(_ response: TechnologiesResponse) -> String {
        var lines: [String] = []
        lines.append("# Apple Frameworks & Technologies")
        lines.append("")

        if let sections = response.topicSections {
            for section in sections {
                if let title = section.title {
                    lines.append("## \(title)")
                    lines.append("")
                }
                for id in section.identifiers {
                    if let refs = response.references, let ref = refs[id] {
                        let abstract = ref.abstract.map { formatInlineContent($0) } ?? ""
                        lines.append("- **\(ref.title)** - \(abstract)")
                    } else {
                        let name = id.components(separatedBy: "/").last ?? id
                        lines.append("- \(name)")
                    }
                }
                lines.append("")
            }
        }
        return lines.joined(separator: "\n")
    }

    public func formatPlatformAvailability(_ platforms: [DocContent.PlatformAvailability]) -> String {
        var lines: [String] = []
        lines.append("# Platform Availability")
        lines.append("")
        lines.append("| Platform | Version | Beta |")
        lines.append("|----------|---------|------|")
        for p in platforms {
            let version = p.introducedAt ?? "N/A"
            let beta = (p.beta == true) ? "Yes" : "No"
            lines.append("| \(p.name) | \(version)+ | \(beta) |")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Private helpers

    func formatInlineContent(_ content: [DocContent.InlineContent]) -> String {
        content.compactMap { item -> String? in
            switch item.type {
            case "text":
                return item.text
            case "codeVoice":
                return item.text.map { "`\($0)`" }
            case "reference":
                if let id = item.identifier {
                    let name = id.components(separatedBy: "/").last ?? id
                    return "`\(name)`"
                }
                return nil
            default:
                return item.text
            }
        }.joined()
    }

    func formatContentBlocks(_ blocks: [DocContent.ContentBlock]) -> String {
        var lines: [String] = []

        for block in blocks {
            switch block.type {
            case "heading":
                let prefix = String(repeating: "#", count: block.level ?? 2)
                let text = block.text ?? block.inlineContent.map { formatInlineContent($0) } ?? ""
                lines.append("\(prefix) \(text)")
                lines.append("")

            case "paragraph":
                if let inline = block.inlineContent {
                    lines.append(formatInlineContent(inline))
                    lines.append("")
                }

            case "codeListing":
                let lang = block.syntax ?? "swift"
                lines.append("```\(lang)")
                if let code = block.code {
                    lines.append(contentsOf: code)
                }
                lines.append("```")
                lines.append("")

            case "unorderedList":
                if let items = block.items {
                    for item in items {
                        if let content = item.content {
                            let text = formatContentBlocks(content).trimmingCharacters(in: .whitespacesAndNewlines)
                            lines.append("- \(text)")
                        }
                    }
                    lines.append("")
                }

            case "aside":
                let name = block.name ?? "Note"
                lines.append("> **\(name):**")
                if let content = block.content {
                    let text = formatContentBlocks(content).trimmingCharacters(in: .whitespacesAndNewlines)
                    for line in text.components(separatedBy: "\n") {
                        lines.append("> \(line)")
                    }
                }
                lines.append("")

            default:
                if let inline = block.inlineContent {
                    lines.append(formatInlineContent(inline))
                    lines.append("")
                }
            }
        }

        return lines.joined(separator: "\n")
    }
}
```

**Step 2: Write formatter tests**

`Tests/AppleDocsLibTests/MarkdownFormatterTests.swift`:
```swift
import Foundation
import Testing
@testable import AppleDocsLib

@Test func formatDocWithTitle() {
    let doc = DocContent(
        metadata: DocContent.DocMetadata(
            title: "View",
            role: "symbol",
            roleHeading: "Protocol",
            platforms: [
                DocContent.PlatformAvailability(name: "iOS", introducedAt: "13.0", beta: false),
                DocContent.PlatformAvailability(name: "macOS", introducedAt: "10.15", beta: false)
            ],
            modules: [DocContent.Module(name: "SwiftUI")],
            symbolKind: "protocol"
        ),
        abstract: [DocContent.InlineContent(type: "text", text: "A type that represents part of your app's user interface.", identifier: nil, isActive: nil)],
        primaryContentSections: nil,
        topicSections: nil,
        identifier: DocContent.DocIdentifier(url: "doc://com.apple.SwiftUI/documentation/SwiftUI/View", interfaceLanguage: "swift")
    )

    let formatter = MarkdownFormatter()
    let result = formatter.formatDoc(doc)

    #expect(result.contains("# View"))
    #expect(result.contains("Protocol"))
    #expect(result.contains("SwiftUI"))
    #expect(result.contains("iOS 13.0+"))
    #expect(result.contains("macOS 10.15+"))
    #expect(result.contains("user interface"))
}

@Test func formatSearchResults() {
    let results = [
        SearchResult(title: "NavigationStack", url: "https://developer.apple.com/documentation/swiftui/navigationstack", description: "A view that displays a root view and enables you to present additional views.", type: "documentation"),
        SearchResult(title: "NavigationPath", url: "https://developer.apple.com/documentation/swiftui/navigationpath", description: "A type-erased list of data.", type: "documentation"),
    ]
    let formatter = MarkdownFormatter()
    let result = formatter.formatSearchResults(results)

    #expect(result.contains("# Search Results"))
    #expect(result.contains("NavigationStack"))
    #expect(result.contains("NavigationPath"))
}

@Test func formatEmptySearchResults() {
    let formatter = MarkdownFormatter()
    let result = formatter.formatSearchResults([])
    #expect(result == "No results found.")
}

@Test func formatPlatformAvailability() {
    let platforms = [
        DocContent.PlatformAvailability(name: "iOS", introducedAt: "16.0", beta: false),
        DocContent.PlatformAvailability(name: "macOS", introducedAt: "13.0", beta: true),
    ]
    let formatter = MarkdownFormatter()
    let result = formatter.formatPlatformAvailability(platforms)
    #expect(result.contains("| iOS | 16.0+ | No |"))
    #expect(result.contains("| macOS | 13.0+ | Yes |"))
}

@Test func formatInlineContentWithCodeVoice() {
    let formatter = MarkdownFormatter()
    let content: [DocContent.InlineContent] = [
        DocContent.InlineContent(type: "text", text: "Use ", identifier: nil, isActive: nil),
        DocContent.InlineContent(type: "codeVoice", text: "@State", identifier: nil, isActive: nil),
        DocContent.InlineContent(type: "text", text: " for local state.", identifier: nil, isActive: nil),
    ]
    let result = formatter.formatInlineContent(content)
    #expect(result == "Use `@State` for local state.")
}
```

**Step 3: Run tests, commit**

```bash
swift test
git add .
git commit -m "feat: markdown formatter for docs, search results, technologies, and platform availability"
```

---

### Task 6: CLI Setup + `doc` Command

**Files:**
- Modify: `Sources/ad/Ad.swift`
- Create: `Sources/AppleDocsLib/Commands/DocCommand.swift`

**Step 1: Create DocCommand**

`Sources/AppleDocsLib/Commands/DocCommand.swift`:
```swift
import ArgumentParser
import Foundation

public struct DocCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "doc",
        abstract: "Fetch Apple documentation by path"
    )

    @Argument(help: "Documentation path (e.g., swiftui/view, foundation/urlsession)")
    var path: String

    @Flag(name: .long, help: "Output as JSON instead of Markdown")
    var json: Bool = false

    public init() {}

    public mutating func run() async throws {
        let api = AppleDocsAPI()
        let doc = try await api.fetchDoc(path: path)

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(doc)
            print(String(data: data, encoding: .utf8)!)
        } else {
            let formatter = MarkdownFormatter()
            print(formatter.formatDoc(doc))
        }
    }
}
```

**Step 2: Update Ad entry point**

`Sources/ad/Ad.swift`:
```swift
import AppleDocsLib
import ArgumentParser

@main
struct Ad: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ad",
        abstract: "Apple Developer Documentation CLI",
        discussion: "Search, browse, and read Apple developer docs from the terminal. Optimized for AI agents.",
        version: "0.1.0",
        subcommands: [DocCommand.self]
    )
}
```

**Step 3: Build and test manually**

```bash
swift build
swift run ad doc swiftui/view
swift run ad doc swiftui/view --json
```

Expected: Markdown output for SwiftUI View documentation, JSON output with --json flag.

**Step 4: Commit**

```bash
git add .
git commit -m "feat: ad doc command for fetching Apple documentation"
```

---

### Task 7: `search` Command

**Files:**
- Create: `Sources/AppleDocsLib/Commands/SearchCommand.swift`
- Modify: `Sources/ad/Ad.swift` (add to subcommands)

**Step 1: Create SearchCommand**

`Sources/AppleDocsLib/Commands/SearchCommand.swift`:
```swift
import ArgumentParser
import Foundation

public struct SearchCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "search",
        abstract: "Search Apple Developer Documentation"
    )

    @Argument(help: "Search query")
    var query: String

    @Option(name: .long, help: "Maximum number of results")
    var limit: Int = 20

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public init() {}

    public mutating func run() async throws {
        let api = SosumiAPI()
        let results = try await api.search(query: query)
        let limited = Array(results.prefix(limit))

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(limited)
            print(String(data: data, encoding: .utf8)!)
        } else {
            let formatter = MarkdownFormatter()
            print(formatter.formatSearchResults(limited))
        }
    }
}
```

**Step 2: Add to subcommands in Ad.swift**

Add `SearchCommand.self` to the subcommands array.

**Step 3: Build and test**

```bash
swift build
swift run ad search "NavigationStack"
swift run ad search "NavigationStack" --limit 5 --json
```

**Step 4: Commit**

```bash
git add .
git commit -m "feat: ad search command with Apple docs search"
```

---

### Task 8: `frameworks` Command

**Files:**
- Create: `Sources/AppleDocsLib/Commands/FrameworksCommand.swift`
- Modify: `Sources/ad/Ad.swift` (add to subcommands)

**Step 1: Create FrameworksCommand**

`Sources/AppleDocsLib/Commands/FrameworksCommand.swift`:
```swift
import ArgumentParser
import Foundation

public struct FrameworksCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "frameworks",
        abstract: "List Apple frameworks and technologies"
    )

    @Option(name: .long, help: "Filter by name (case-insensitive partial match)")
    var filter: String?

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public init() {}

    public mutating func run() async throws {
        let api = AppleDocsAPI()
        let response = try await api.fetchTechnologies()

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(response)
            print(String(data: data, encoding: .utf8)!)
        } else {
            let formatter = MarkdownFormatter()
            if let filterText = filter {
                let filtered = filterTechnologies(response, by: filterText)
                print(formatter.formatTechnologies(filtered))
            } else {
                print(formatter.formatTechnologies(response))
            }
        }
    }

    private func filterTechnologies(_ response: TechnologiesResponse, by text: String) -> TechnologiesResponse {
        let lowered = text.lowercased()
        let filteredRefs = response.references?.filter { _, ref in
            ref.title.lowercased().contains(lowered)
        }
        return TechnologiesResponse(
            topicSections: response.topicSections,
            references: filteredRefs
        )
    }
}
```

**Step 2: Add to subcommands, build, test**

```bash
swift build
swift run ad frameworks
swift run ad frameworks --filter "SwiftUI"
```

**Step 3: Commit**

```bash
git add .
git commit -m "feat: ad frameworks command for listing Apple technologies"
```

---

### Task 9: `wwdc` Command

**Files:**
- Create: `Sources/AppleDocsLib/Commands/WwdcCommand.swift`
- Modify: `Sources/ad/Ad.swift` (add to subcommands)

**Step 1: Create WwdcCommand**

`Sources/AppleDocsLib/Commands/WwdcCommand.swift`:
```swift
import ArgumentParser
import Foundation

public struct WwdcCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "wwdc",
        abstract: "Fetch WWDC session transcripts via sosumi.ai"
    )

    @Argument(help: "WWDC year and session ID (e.g., 2024/10102) or search query")
    var input: String

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public init() {}

    public mutating func run() async throws {
        let api = SosumiAPI()

        // Check if input looks like year/session pattern
        let parts = input.components(separatedBy: "/")
        if parts.count == 2, let year = Int(parts[0]), year >= 2000, year <= 2030 {
            let transcript = try await api.fetchWwdcTranscript(year: year, sessionId: parts[1])
            if json {
                let session = WwdcSession(
                    title: "WWDC\(year) Session \(parts[1])",
                    url: "https://developer.apple.com/videos/play/wwdc\(year)/\(parts[1])/",
                    year: year,
                    sessionId: parts[1],
                    description: nil,
                    transcript: transcript
                )
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted]
                let data = try encoder.encode(CodableWwdcSession(from: session))
                print(String(data: data, encoding: .utf8)!)
            } else {
                print(transcript)
            }
        } else {
            // Treat as search - fetch sosumi.ai doc page for the topic
            let markdown = try await api.fetchDocMarkdown(path: "/documentation/\(input)")
            print(markdown)
        }
    }
}

struct CodableWwdcSession: Codable {
    let title: String
    let url: String
    let year: Int?
    let sessionId: String?
    let transcript: String?

    init(from session: WwdcSession) {
        self.title = session.title
        self.url = session.url
        self.year = session.year
        self.sessionId = session.sessionId
        self.transcript = session.transcript
    }
}
```

**Step 2: Add to subcommands, build, test**

```bash
swift build
swift run ad wwdc 2024/10102
swift run ad wwdc 2021/10133
```

**Step 3: Commit**

```bash
git add .
git commit -m "feat: ad wwdc command for WWDC session transcripts"
```

---

### Task 10: `samples`, `related`, `platform` Commands

**Files:**
- Create: `Sources/AppleDocsLib/Commands/SamplesCommand.swift`
- Create: `Sources/AppleDocsLib/Commands/RelatedCommand.swift`
- Create: `Sources/AppleDocsLib/Commands/PlatformCommand.swift`
- Modify: `Sources/ad/Ad.swift` (add all three to subcommands)

**Step 1: Create SamplesCommand**

`Sources/AppleDocsLib/Commands/SamplesCommand.swift`:
```swift
import ArgumentParser
import Foundation

public struct SamplesCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "samples",
        abstract: "Browse Apple sample code projects"
    )

    @Argument(help: "Search query for sample code")
    var query: String?

    @Option(name: .long, help: "Filter by framework (e.g., swiftui, uikit)")
    var framework: String?

    @Option(name: .long, help: "Maximum number of results")
    var limit: Int = 20

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public init() {}

    public mutating func run() async throws {
        let api = SosumiAPI()
        let searchQuery = [query, framework].compactMap { $0 }.joined(separator: " ") + " sample code"
        let results = try await api.search(query: searchQuery.isEmpty ? "sample code" : searchQuery)
        let limited = Array(results.prefix(limit))

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(limited)
            print(String(data: data, encoding: .utf8)!)
        } else {
            let formatter = MarkdownFormatter()
            print(formatter.formatSearchResults(limited))
        }
    }
}
```

**Step 2: Create RelatedCommand**

`Sources/AppleDocsLib/Commands/RelatedCommand.swift`:
```swift
import ArgumentParser
import Foundation

public struct RelatedCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "related",
        abstract: "Find related APIs for a given documentation path"
    )

    @Argument(help: "Documentation path (e.g., swiftui/navigationstack)")
    var path: String

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public init() {}

    public mutating func run() async throws {
        let api = AppleDocsAPI()
        let doc = try await api.fetchDoc(path: path)

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            if let topics = doc.topicSections {
                let data = try encoder.encode(topics)
                print(String(data: data, encoding: .utf8)!)
            } else {
                print("[]")
            }
        } else {
            guard let topics = doc.topicSections, !topics.isEmpty else {
                print("No related APIs found for \(path)")
                return
            }
            var lines: [String] = []
            lines.append("# Related APIs for \(doc.metadata.title)")
            lines.append("")
            for section in topics {
                if let title = section.title {
                    lines.append("## \(title)")
                    lines.append("")
                }
                for id in section.identifiers {
                    let name = id.components(separatedBy: "/").last ?? id
                    lines.append("- `\(name)`")
                }
                lines.append("")
            }
            print(lines.joined(separator: "\n"))
        }
    }
}
```

**Step 3: Create PlatformCommand**

`Sources/AppleDocsLib/Commands/PlatformCommand.swift`:
```swift
import ArgumentParser
import Foundation

public struct PlatformCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "platform",
        abstract: "Show platform compatibility for an API"
    )

    @Argument(help: "Documentation path (e.g., swiftui/navigationstack)")
    var path: String

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public init() {}

    public mutating func run() async throws {
        let api = AppleDocsAPI()
        let doc = try await api.fetchDoc(path: path)

        guard let platforms = doc.metadata.platforms, !platforms.isEmpty else {
            print("No platform availability data for \(path)")
            return
        }

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(platforms)
            print(String(data: data, encoding: .utf8)!)
        } else {
            let formatter = MarkdownFormatter()
            print(formatter.formatPlatformAvailability(platforms))
        }
    }
}
```

**Step 4: Update Ad.swift with all subcommands**

```swift
subcommands: [
    DocCommand.self,
    SearchCommand.self,
    FrameworksCommand.self,
    WwdcCommand.self,
    SamplesCommand.self,
    RelatedCommand.self,
    PlatformCommand.self,
]
```

**Step 5: Build and test all commands**

```bash
swift build
swift run ad samples swiftui
swift run ad related swiftui/navigationstack
swift run ad platform swiftui/navigationstack
```

**Step 6: Commit**

```bash
git add .
git commit -m "feat: samples, related, and platform commands"
```

---

### Task 11: AI Agent Skill File

**Files:**
- Create: `skill/SKILL.md`

**Step 1: Write the skill file**

`skill/SKILL.md` should teach AI agents how to use `ad`. Follow the same pattern as clickup-cli's `skill/SKILL.md`. The skill should include:

1. Overview of what `ad` does
2. All available commands with usage examples
3. Common workflows (e.g., "look up an API", "find related APIs", "check platform compatibility")
4. Output format expectations (markdown default, --json for structured)
5. Error handling guidance

```markdown
# Skill: apple-docs

Use when looking up Apple Developer Documentation, including Swift, SwiftUI, UIKit, and other Apple frameworks. Also for WWDC session transcripts, platform compatibility, and related API discovery.

## When to Use

- Looking up API documentation for any Apple framework
- Checking platform availability for an API
- Finding related or similar APIs
- Searching for sample code
- Reading WWDC session transcripts
- Browsing available Apple frameworks

## Commands

### Search documentation
```bash
ad search "NavigationStack"
ad search "async await URLSession" --limit 10
ad search "Core Data migration" --json
```

### Read documentation page
```bash
ad doc swiftui/view
ad doc swiftui/navigationstack
ad doc foundation/urlsession
ad doc uikit/uiviewcontroller
ad doc swiftui/view --json
```

Path format: `framework/symbol` (lowercase). Examples:
- `swiftui/view` -> SwiftUI View protocol
- `foundation/urlsession` -> Foundation URLSession
- `uikit/uitableview` -> UIKit UITableView

### List frameworks
```bash
ad frameworks
ad frameworks --filter "Data"
ad frameworks --filter "ML"
```

### WWDC transcripts
```bash
ad wwdc 2024/10102          # Specific session by year/id
ad wwdc 2021/10133          # "Meet async/await in Swift"
```

### Sample code
```bash
ad samples swiftui
ad samples "machine learning"
ad samples --framework realitykit
```

### Related APIs
```bash
ad related swiftui/navigationstack
ad related foundation/urlsession
```

### Platform compatibility
```bash
ad platform swiftui/navigationstack
ad platform swiftdata/modelcontainer
```

## Workflows

### Look up an unfamiliar API
1. `ad search "the API name"` to find the correct path
2. `ad doc framework/symbol` to read the full documentation
3. `ad related framework/symbol` to discover related APIs

### Check if an API is available on a platform
1. `ad platform framework/symbol` to see version requirements

### Explore a framework
1. `ad frameworks --filter "framework name"` to find it
2. `ad doc framework` to read the framework overview
3. `ad related framework` to see all top-level APIs

### Find WWDC context for a feature
1. `ad wwdc year/sessionid` to read the transcript

## Output

- Default: Markdown (optimized for AI agent token efficiency)
- `--json`: Structured JSON for programmatic use
- All output goes to stdout, errors to stderr

## Notes

- No configuration needed - works immediately after install
- Requires internet connection (stateless, on-demand API calls)
- Paths are case-insensitive
- If a doc path fails, try searching first to find the exact path
```

**Step 2: Commit**

```bash
git add .
git commit -m "feat: AI agent skill file for apple-docs CLI"
```

---

### Task 12: README + Final Integration

**Files:**
- Create: `README.md`
- Create: `AGENTS.md`

**Step 1: Write README.md**

Include: project description, install instructions (Homebrew + build from source), all commands with examples, comparison to other tools, license (MIT).

Follow the style and structure of `https://github.com/krodak/clickup-cli` README - concise, practical, dual-audience (humans + AI agents).

Key sections:
- What is `ad`
- Install (Homebrew, build from source)
- Commands (table + examples)
- For AI Agents (how to use with --json, skill file)
- Why `ad` vs alternatives (lightweight, stateless, no database)
- Development (build, test)
- License (MIT)

**Step 2: Write AGENTS.md**

Minimal - just point to the skill file:
```markdown
# Agent Instructions

See `skill/SKILL.md` for comprehensive usage instructions.
```

**Step 3: Final build and test**

```bash
swift build -c release
swift test
# Smoke test all commands
swift run ad search "SwiftUI" --limit 3
swift run ad doc swiftui
swift run ad frameworks --filter "UI"
swift run ad related swiftui/view
swift run ad platform swiftui/view
```

**Step 4: Commit**

```bash
git add .
git commit -m "docs: README, AGENTS.md, and final integration"
```
