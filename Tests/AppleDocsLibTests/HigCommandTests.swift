import Foundation
import Testing
@testable import AppleDocsLib

@Test func higPathWithTopic() {
    let path = HigCommand.higPath(for: "buttons")
    #expect(path == "/design/human-interface-guidelines/buttons")
}

@Test func higPathWithoutTopic() {
    let path = HigCommand.higPath(for: nil)
    #expect(path == "/design/human-interface-guidelines/")
}

@Test func higPathWithHyphenatedTopic() {
    let path = HigCommand.higPath(for: "navigation-bars")
    #expect(path == "/design/human-interface-guidelines/navigation-bars")
}

@Test func higURLWithTopic() {
    let url = AppleDocsAPI.higURL(topic: "color")
    #expect(url == "https://developer.apple.com/tutorials/data/design/human-interface-guidelines/color.json")
}

@Test func higURLWithoutTopic() {
    let url = AppleDocsAPI.higURL(topic: nil)
    #expect(url == "https://developer.apple.com/tutorials/data/design/human-interface-guidelines.json")
}

@Test func higURLWithCustomBaseURL() {
    let url = AppleDocsAPI.higURL(baseURL: "https://example.com/data", topic: "buttons")
    #expect(url == "https://example.com/data/design/human-interface-guidelines/buttons.json")
}
