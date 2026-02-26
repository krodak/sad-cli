# Decisions

## D1: Language - Swift
Swift chosen over TypeScript for community fit. Apple docs CLI used by Apple developers who already have Swift/Xcode. Native binary, fast startup, no Node.js dependency.

## D2: Binary name - `sad`
Short for "Search Apple Docs". Memorable and playful. Usage: `sad search SwiftUI`, `sad doc SwiftUI/View`.

## D3: Package name - `sad-cli`
Matches the binary name. GitHub repo: `krodak/sad-cli`.

## D4: Architecture - Library + Executable
`AppleDocsLib` target contains all business logic (testable). `sad` executable target is a thin CLI wrapper. This allows unit testing without CLI overhead.

## D5: Swift version - 6.0, macOS 13+
Swift 6.0 for strict concurrency. macOS 13 (Ventura) as minimum - URLSession async/await is stable there. No need for older support since target audience has modern macOS.

## D6: Data sources - Direct Apple APIs + GitHub
- Apple JSON API (`developer.apple.com/tutorials/data/`) for doc content, technologies, HIG, metadata
- Apple HTML (`developer.apple.com/search/`, `developer.apple.com/videos/`) for search results and WWDC transcripts
- GitHub raw content for SwiftWasm book and Swift Evolution proposals
- No local database, no crawling, no third-party proxies - stateless on-demand API calls

## D7: Output format - Markdown default, --json flag
Markdown is more token-efficient for AI agents (primary audience). JSON available via `--json` flag for programmatic consumption. No interactive TTY mode (agent-first tool).

## D8: No configuration needed
Apple docs are public APIs, no auth required. No `init` command, no config file. Stateless by design.

## D9: Scope - 7 commands for v1
`search`, `doc`, `frameworks`, `wwdc`, `samples`, `related`, `platform`. Feature-rich from start per user request.

## D10: Search implementation
Apple's search endpoint (`developer.apple.com/search/`) returns HTML. We parse it with simple string matching (no heavy HTML parser dependency). Direct to Apple, no third-party proxy.

## D11: Testing strategy
Unit tests for: JSON parsing (with fixture files), markdown formatting, URL construction. Integration tests for: actual API calls (marked with a trait to skip in CI). No mocking of URLSession - test real parsing logic with fixture data.

## D12: Distribution
Homebrew tap (`krodak/tap`) and GitHub releases with pre-built universal binary. Same pattern as clickup-cli.

## D13: Skill file included
`skill/SKILL.md` bundled in repo, teaches AI agents how to use `sad` effectively. Same pattern as clickup-cli's `skill/SKILL.md`.

## D14: Dependencies - minimal
Only `swift-argument-parser` (Apple's own CLI framework). No other external dependencies. URLSession for HTTP, Foundation for JSON (Codable). Keep it lean.

## D15: SwiftWasm book as data source
Added the SwiftWasm book (18 pages, fetched from GitHub raw content) as a data source for WebAssembly development docs. Fills a gap - no other CLI tool provides offline-friendly SwiftWasm reference.

## D16: HIG via Apple JSON API
Apple HIG is served via the same JSON API as documentation (`developer.apple.com/tutorials/data/design/human-interface-guidelines/`). Reuses existing DocContent model and MarkdownFormatter. No third-party proxy needed.

## D17: Distribution - Homebrew tap, Mint, GitHub Releases, source
Four install paths: Homebrew tap (`krodak/tap`) as primary, Mint (works out of the box since Package.swift has executable product), universal binary from GitHub Releases (arm64+x86_64 built by GitHub Actions), and build from source. Covers the full spectrum from casual users to contributors.

## D18: swift-tools-version stays at 6.0
Keeping swift-tools-version at 6.0 for maximum compatibility. Swift 6.0 is the minimum that supports strict concurrency checking, which we rely on. No need to bump to 6.1+ yet.

## D19: Remove sosumi.ai dependency
Removed all sosumi.ai references. HIG now uses Apple's JSON API directly (same DocContent model). WWDC transcripts parsed from Apple's video pages (HTML with `<span data-start>` elements). Search already hit Apple directly. Benefits: zero third-party dependency, faster, no legal gray area, reuses existing parsers.

## D20: Swift Evolution proposals
Added `evolution` command fetching proposals from `swiftlang/swift-evolution` on GitHub. Uses GitHub contents API to resolve SE numbers to filenames, then fetches raw markdown. Same pattern as SwiftWasm book. Accepts flexible input: `SE-0401`, `0401`, `401`.

## D21: WWDC transcript parsing
WWDC session transcripts are parsed from the HTML video page at `developer.apple.com/videos/play/wwdc{year}/{sessionId}/`. Transcripts are embedded as `<span data-start="N.N">text</span>` elements inside `<section id="transcript-content">`. Grouped every 5 spans into a line for readability.

## D22: External Swift-DocC support
Added `docc` command for fetching documentation from any public Swift-DocC site. Swift-DocC sites serve the same JSON schema as Apple docs at `{base}/data/documentation/{path}.json`. The command transforms human-readable URLs (containing `/documentation/`) to JSON endpoints. No new API client needed - reuses HTTPClient + DocContent + MarkdownFormatter. Supports `http://` for local dev servers.
