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

@Test func higPathProducesValidURL() {
    let path = HigCommand.higPath(for: "color")
    let url = SosumiAPI.docMarkdownURL(path: path)
    #expect(url == "https://sosumi.ai/design/human-interface-guidelines/color")
}
