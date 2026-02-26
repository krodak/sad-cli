import Foundation
import Testing
@testable import AppleDocsLib

@Test func parseSessionRefValidInput() {
    let result = WwdcCommand.parseSessionRef("2024/10143")
    #expect(result?.0 == 2024)
    #expect(result?.1 == "10143")
}

@Test func parseSessionRefMinYear() {
    let result = WwdcCommand.parseSessionRef("1990/100")
    #expect(result?.0 == 1990)
    #expect(result?.1 == "100")
}

@Test func parseSessionRefMaxYear() {
    let result = WwdcCommand.parseSessionRef("2100/999")
    #expect(result?.0 == 2100)
    #expect(result?.1 == "999")
}

@Test func parseSessionRefRejectsYearOutOfRange() {
    #expect(WwdcCommand.parseSessionRef("1989/100") == nil)
    #expect(WwdcCommand.parseSessionRef("2101/100") == nil)
}

@Test func parseSessionRefRejectsNonNumericYear() {
    #expect(WwdcCommand.parseSessionRef("abcd/10143") == nil)
}

@Test func parseSessionRefRejectsSingleComponent() {
    #expect(WwdcCommand.parseSessionRef("swift-charts") == nil)
}

@Test func parseSessionRefRejectsThreeComponents() {
    #expect(WwdcCommand.parseSessionRef("2024/101/extra") == nil)
}

@Test func wwdcTranscriptURLConstruction() {
    let url = AppleDocsAPI.wwdcTranscriptURL(year: 2024, sessionId: "10143")
    #expect(url == "https://developer.apple.com/videos/play/wwdc2024/10143/")
}

@Test func wwdcTranscriptURLDifferentYear() {
    let url = AppleDocsAPI.wwdcTranscriptURL(year: 2023, sessionId: "101")
    #expect(url == "https://developer.apple.com/videos/play/wwdc2023/101/")
}

@Test func parseTranscriptHTMLBasic() {
    let html = """
    <html><body>
    <section id="transcript-content"><span data-start="0.0">Hello world.</span><span data-start="3.0">Welcome.</span></section>
    </body></html>
    """
    let api = AppleDocsAPI()
    let result = api.parseTranscriptHTML(html)
    #expect(result.contains("Hello world."))
    #expect(result.contains("Welcome."))
}

@Test func parseTranscriptHTMLGroupsSpans() {
    let html = """
    <section id="transcript-content">\
    <span data-start="0.0">One.</span>\
    <span data-start="1.0">Two.</span>\
    <span data-start="2.0">Three.</span>\
    <span data-start="3.0">Four.</span>\
    <span data-start="4.0">Five.</span>\
    <span data-start="5.0">Six.</span>\
    </section>
    """
    let api = AppleDocsAPI()
    let result = api.parseTranscriptHTML(html)
    let lines = result.split(separator: "\n")
    #expect(lines.count == 2)
    #expect(lines[0] == "One. Two. Three. Four. Five.")
    #expect(lines[1] == "Six.")
}

@Test func parseTranscriptHTMLStripsNestedTags() {
    let html = """
    <section id="transcript-content"><span data-start="0.0">Hello <em>world</em>.</span></section>
    """
    let api = AppleDocsAPI()
    let result = api.parseTranscriptHTML(html)
    #expect(result == "Hello world.")
}

@Test func parseTranscriptHTMLReturnsEmptyForMissingSection() {
    let html = "<html><body><p>No transcript here</p></body></html>"
    let api = AppleDocsAPI()
    let result = api.parseTranscriptHTML(html)
    #expect(result.isEmpty)
}

@Test func parseTranscriptHTMLReturnsEmptyForEmptySection() {
    let html = """
    <section id="transcript-content"></section>
    """
    let api = AppleDocsAPI()
    let result = api.parseTranscriptHTML(html)
    #expect(result.isEmpty)
}

@Test func parseTranscriptHTMLReturnsEmptyForNoSpans() {
    let html = """
    <section id="transcript-content"><p>Some other content</p></section>
    """
    let api = AppleDocsAPI()
    let result = api.parseTranscriptHTML(html)
    #expect(result.isEmpty)
}
