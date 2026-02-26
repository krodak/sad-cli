import Testing
@testable import AppleDocsLib

@Test func versionExists() {
    #expect(AppleDocsLib.version == "0.1.0")
}
