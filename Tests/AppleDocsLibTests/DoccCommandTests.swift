import Foundation
import Testing
@testable import AppleDocsLib

@Test func toJSONURLBasic() throws {
    let result = try DoccCommand.toJSONURL("https://apple.github.io/swift-argument-parser/documentation/argumentparser")
    #expect(result == "https://apple.github.io/swift-argument-parser/data/documentation/argumentparser.json")
}

@Test func toJSONURLTrailingSlash() throws {
    let result = try DoccCommand.toJSONURL("https://apple.github.io/swift-argument-parser/documentation/argumentparser/")
    #expect(result == "https://apple.github.io/swift-argument-parser/data/documentation/argumentparser.json")
}

@Test func toJSONURLNestedPath() throws {
    let result = try DoccCommand.toJSONURL("https://example.com/docs/documentation/mylib/mytype")
    #expect(result == "https://example.com/docs/data/documentation/mylib/mytype.json")
}

@Test func toJSONURLWithHttpsPrefix() throws {
    let result = try DoccCommand.toJSONURL("https://apple.github.io/swift-argument-parser/documentation/argumentparser")
    #expect(result.hasPrefix("https://"))
}

@Test func toJSONURLWithoutScheme() throws {
    let result = try DoccCommand.toJSONURL("apple.github.io/swift-argument-parser/documentation/argumentparser")
    #expect(result == "https://apple.github.io/swift-argument-parser/data/documentation/argumentparser.json")
}

@Test func toJSONURLInvalidThrows() {
    #expect(throws: DoccCommandError.self) {
        try DoccCommand.toJSONURL("https://example.com/some/other/path")
    }
}

@Test func toJSONURLHttpLocalhost() throws {
    let result = try DoccCommand.toJSONURL("http://localhost:8080/documentation/mylib")
    #expect(result == "http://localhost:8080/data/documentation/mylib.json")
}
