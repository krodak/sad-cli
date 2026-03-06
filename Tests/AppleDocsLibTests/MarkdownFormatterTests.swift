import Testing
@testable import AppleDocsLib

private let formatter = MarkdownFormatter()

@Test func formatDocWithTitle() {
    var doc = DocContent()
    doc.metadata = DocContent.Metadata()
    doc.metadata?.title = "View"
    doc.metadata?.roleHeading = "Protocol"
    doc.metadata?.modules = [DocContent.Module(name: "SwiftUI")]
    doc.metadata?.platforms = [
        DocContent.Platform(name: "iOS", introducedAt: "13.0", deprecated: false, beta: false, unavailable: false),
        DocContent.Platform(name: "macOS", introducedAt: "10.15", deprecated: false, beta: false, unavailable: false),
    ]
    doc.abstract = [.text("A type that represents part of your app's user interface.")]

    let output = formatter.formatDoc(doc)
    #expect(output.contains("# View"))
    #expect(output.contains("Protocol"))
    #expect(output.contains("SwiftUI"))
    #expect(output.contains("iOS 13.0+"))
    #expect(output.contains("macOS 10.15+"))
    #expect(output.contains("user interface"))
}

@Test func formatSearchResultsList() {
    let results = [
        SearchResult(title: "View", url: "https://developer.apple.com/documentation/swiftui/view", description: "A protocol"),
        SearchResult(title: "Text", url: "https://developer.apple.com/documentation/swiftui/text", description: "A label"),
    ]
    let output = formatter.formatSearchResults(results)
    #expect(output.contains("# Search Results"))
    #expect(output.contains("View"))
    #expect(output.contains("Text"))
    #expect(output.contains("## 1."))
    #expect(output.contains("## 2."))
    #expect(output.contains("URL: https://developer.apple.com/documentation/swiftui/view"))
    #expect(!output.contains("apple.comhttps://"))
}

@Test func formatEmptySearchResults() {
    let output = formatter.formatSearchResults([])
    #expect(output == "No results found.")
}

@Test func formatPlatformAvailabilityTable() {
    let platforms: [DocContent.Platform] = [
        DocContent.Platform(name: "iOS", introducedAt: "16.0", deprecated: false, beta: false, unavailable: false),
        DocContent.Platform(name: "macOS", introducedAt: "13.0", deprecated: false, beta: true, unavailable: false),
    ]
    let output = formatter.formatPlatformAvailability(platforms)
    #expect(output.contains("# Platform Availability"))
    #expect(output.contains("| Platform | Version | Beta |"))
    #expect(output.contains("| iOS | 16.0+ | No |"))
    #expect(output.contains("| macOS | 13.0+ | Yes |"))
}

@Test func formatInlineContentWithCodeVoice() {
    let inline: [InlineContent] = [
        .text("Use "),
        .codeVoice("body"),
        .text(" to define content."),
    ]
    let output = formatter.formatInlineContent(inline)
    #expect(output == "Use `body` to define content.")
}

@Test func formatContentBlocksHeadingAndParagraph() {
    let blocks: [ContentBlock] = [
        .heading(text: "Overview", level: 2, anchor: nil),
        .paragraph([.text("This is a paragraph.")]),
    ]
    let output = formatter.formatContentBlocks(blocks)
    #expect(output.contains("## Overview"))
    #expect(output.contains("This is a paragraph."))
}

@Test func formatContentBlocksCodeListing() {
    let blocks: [ContentBlock] = [
        .codeListing(code: ["let x = 1", "print(x)"], syntax: "swift"),
    ]
    let output = formatter.formatContentBlocks(blocks)
    #expect(output.contains("```swift"))
    #expect(output.contains("let x = 1"))
    #expect(output.contains("```"))
}

@Test func formatDocWithTopicSections() {
    var doc = DocContent()
    doc.metadata = DocContent.Metadata()
    doc.metadata?.title = "View"
    doc.topicSections = [
        TopicSection(title: "Creating a View", identifiers: ["doc://SwiftUI/body"], anchor: nil, generated: false),
    ]
    doc.references = [
        "doc://SwiftUI/body": Reference(
            identifier: "doc://SwiftUI/body",
            title: "body",
            url: nil,
            kind: nil,
            role: nil,
            abstract: nil,
            type: nil,
            fragments: nil,
            navigatorTitle: nil,
            conformance: nil,
            deprecated: nil,
            beta: nil
        ),
    ]

    let output = formatter.formatDoc(doc)
    #expect(output.contains("## Topics"))
    #expect(output.contains("### Creating a View"))
    #expect(output.contains("- `body`"))
}

@Test func formatTechnologiesListing() {
    let response = TechnologiesResponse(
        sections: [
            TechnologiesSection(
                kind: "technologies",
                groups: [
                    TechnologyGroup(
                        name: "App Frameworks",
                        technologies: [
                            TechnologyEntry(
                                title: "SwiftUI",
                                destination: TechnologyDestination(
                                    identifier: "ref-swiftui",
                                    type: "reference",
                                    isActive: true
                                ),
                                tags: nil,
                                languages: nil
                            ),
                        ]
                    ),
                ]
            ),
        ],
        references: [
            "ref-swiftui": TechnologyReference(
                title: "SwiftUI",
                url: "/documentation/swiftui",
                abstract: [.text("Build user interfaces.")],
                kind: "technology",
                role: "collection"
            ),
        ]
    )
    let output = formatter.formatTechnologies(response)
    #expect(output.contains("# Frameworks & Technologies"))
    #expect(output.contains("## App Frameworks"))
    #expect(output.contains("**SwiftUI**"))
    #expect(output.contains("Build user interfaces."))
}
