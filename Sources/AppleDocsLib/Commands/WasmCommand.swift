import ArgumentParser
import Foundation

public struct WasmCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "wasm",
        abstract: "SwiftWasm book - guides for Swift WebAssembly development"
    )

    @Argument(help: "Page slug (e.g., setup, browser-app, javascript-interop). Omit to list all pages.")
    var slug: String?

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public init() {}

    public func run() async throws {
        let api = SwiftWasmAPI()

        guard let slug = slug else {
            if json {
                let pages = SwiftWasmAPI.pages.map { ["slug": $0.slug, "title": $0.title] }
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                let data = try encoder.encode(pages)
                print(String(data: data, encoding: .utf8)!)
            } else {
                print(api.listPages())
            }
            return
        }

        let content = try await api.fetchPage(slug: slug)
        if json {
            let wrapper = ["slug": slug, "content": content]
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            let data = try encoder.encode(wrapper)
            print(String(data: data, encoding: .utf8)!)
        } else {
            print(content)
        }
    }
}
