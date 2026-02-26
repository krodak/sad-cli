import Foundation
import Testing
@testable import AppleDocsLib

@Test func normalizeNumberWithSEPrefix() {
    #expect(SwiftEvolutionAPI.normalizeNumber("SE-0401") == "0401")
}

@Test func normalizeNumberWithLowercaseSEPrefix() {
    #expect(SwiftEvolutionAPI.normalizeNumber("se-0401") == "0401")
}

@Test func normalizeNumberAlreadyPadded() {
    #expect(SwiftEvolutionAPI.normalizeNumber("0401") == "0401")
}

@Test func normalizeNumberWithoutPadding() {
    #expect(SwiftEvolutionAPI.normalizeNumber("401") == "0401")
}

@Test func normalizeNumberSingleDigit() {
    #expect(SwiftEvolutionAPI.normalizeNumber("1") == "0001")
}

@Test func proposalURLConstruction() {
    let url = SwiftEvolutionAPI.proposalURL(filename: "0401-remove-property-wrapper-isolation.md")
    #expect(url == "https://raw.githubusercontent.com/swiftlang/swift-evolution/main/proposals/0401-remove-property-wrapper-isolation.md")
}

@Test func proposalURLWithCustomBase() {
    let url = SwiftEvolutionAPI.proposalURL(baseURL: "https://example.com", filename: "0001-test.md")
    #expect(url == "https://example.com/0001-test.md")
}

@Test func titleFromFilenameBasic() {
    let title = SwiftEvolutionAPI.titleFromFilename("0401-remove-property-wrapper-isolation.md")
    #expect(title == "Remove Property Wrapper Isolation")
}

@Test func titleFromFilenameSingleWord() {
    let title = SwiftEvolutionAPI.titleFromFilename("0001-keywords.md")
    #expect(title == "Keywords")
}

@Test func titleFromFilenameMultipleWords() {
    let title = SwiftEvolutionAPI.titleFromFilename("0302-concurrent-value-and-concurrent-closures.md")
    #expect(title == "Concurrent Value And Concurrent Closures")
}

@Test func errorDescriptionProposalNotFound() {
    let error = SwiftEvolutionAPIError.proposalNotFound("9999")
    let description = error.errorDescription!
    #expect(description.contains("9999"))
}

@Test func errorDescriptionInvalidNumber() {
    let error = SwiftEvolutionAPIError.invalidNumber("abc")
    let description = error.errorDescription!
    #expect(description.contains("abc"))
}
