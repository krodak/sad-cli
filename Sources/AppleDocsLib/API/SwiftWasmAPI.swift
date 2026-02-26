import Foundation

public struct SwiftWasmAPI: Sendable {
    private let client: HTTPClient
    private let baseURL = "https://raw.githubusercontent.com/swiftwasm/swiftwasm-book/main/src"

    public init(client: HTTPClient = HTTPClient()) {
        self.client = client
    }

    public static let pages: [(slug: String, title: String, path: String)] = [
        ("intro", "Introduction", "README.md"),
        ("getting-started", "Getting Started", "getting-started/index.md"),
        ("setup", "Installation", "getting-started/setup.md"),
        ("porting", "Porting Code", "getting-started/porting.md"),
        ("browser-app", "Creating a Browser App", "getting-started/browser-app.md"),
        ("javascript-interop", "JavaScript Interoperation", "getting-started/javascript-interop.md"),
        ("concurrency", "Concurrency", "getting-started/concurrency.md"),
        ("multithreading", "Multithreading", "getting-started/multithreading.md"),
        ("testing", "Testing Your App", "getting-started/testing.md"),
        ("vscode", "Visual Studio Code", "getting-started/vscode.md"),
        ("debugging", "Debugging", "getting-started/debugging.md"),
        ("troubleshooting", "Troubleshooting", "getting-started/troubleshooting.md"),
        ("examples", "Examples", "examples/index.md"),
        ("importing-function", "Importing Function", "examples/importing-function.md"),
        ("exporting-function", "Exporting Function", "examples/exporting-function.md"),
        ("example-projects", "Example Projects", "examples/example-projects.md"),
        ("contribution-guide", "Contribution Guide", "contribution-guide/index.md"),
        ("build-toolchain", "How to Build the Toolchain", "contribution-guide/how-to-build-toolchain.md"),
    ]

    public func fetchPage(slug: String) async throws -> String {
        guard let page = Self.pages.first(where: { $0.slug == slug }) else {
            throw SwiftWasmAPIError.unknownPage(slug, available: Self.pages.map(\.slug))
        }
        let url = "\(baseURL)/\(page.path)"
        return try await client.fetchString(url: url)
    }

    public func listPages() -> String {
        var lines: [String] = []
        lines.append("# SwiftWasm Book")
        lines.append("")
        lines.append("Available pages (use slug with `sad wasm <slug>`):")
        lines.append("")
        for page in Self.pages {
            lines.append("- **\(page.slug)** - \(page.title)")
        }
        lines.append("")
        lines.append("Source: https://book.swiftwasm.org")
        return lines.joined(separator: "\n")
    }
}

public enum SwiftWasmAPIError: Error, LocalizedError {
    case unknownPage(String, available: [String])

    public var errorDescription: String? {
        switch self {
        case .unknownPage(let slug, let available):
            return "Unknown page '\(slug)'. Available: \(available.joined(separator: ", "))"
        }
    }
}
