# Decisions

## D1: Language - Swift
Swift chosen over TypeScript for community fit. Apple docs CLI used by Apple developers who already have Swift/Xcode. Native binary, fast startup, no Node.js dependency.

## D2: Binary name - `ad`
Short, memorable, follows the `cu` pattern from clickup-cli. Usage: `ad search SwiftUI`, `ad doc SwiftUI/View`.

## D3: Package name - `apple-docs-cli`
npm-style naming convention for consistency. GitHub repo: `krodak/apple-docs-cli`.

## D4: Architecture - Library + Executable
`AppleDocsLib` target contains all business logic (testable). `ad` executable target is a thin CLI wrapper. This allows unit testing without CLI overhead.

## D5: Swift version - 6.0, macOS 13+
Swift 6.0 for strict concurrency. macOS 13 (Ventura) as minimum - URLSession async/await is stable there. No need for older support since target audience has modern macOS.

## D6: Data sources - Hybrid approach
- Apple JSON API (`developer.apple.com/tutorials/data/`) for doc content, technologies, metadata
- Sosumi.ai HTTP proxy for search results and WWDC transcripts
- No local database, no crawling - stateless on-demand API calls

## D7: Output format - Markdown default, --json flag
Markdown is more token-efficient for AI agents (primary audience). JSON available via `--json` flag for programmatic consumption. No interactive TTY mode (agent-first tool).

## D8: No configuration needed
Apple docs are public APIs, no auth required. No `init` command, no config file. Stateless by design.

## D9: Scope - 7 commands for v1
`search`, `doc`, `frameworks`, `wwdc`, `samples`, `related`, `platform`. Feature-rich from start per user request.

## D10: Search implementation
Apple's search endpoint returns HTML. We parse it with simple string matching (no heavy HTML parser dependency). Sosumi.ai used as fallback for search when Apple's endpoint is unreliable.

## D11: Testing strategy
Unit tests for: JSON parsing (with fixture files), markdown formatting, URL construction. Integration tests for: actual API calls (marked with a trait to skip in CI). No mocking of URLSession - test real parsing logic with fixture data.

## D12: Distribution
Homebrew tap (`krodak/tap`) and GitHub releases with pre-built universal binary. Same pattern as clickup-cli.

## D13: Skill file included
`skill/SKILL.md` bundled in repo, teaches AI agents how to use `ad` effectively. Same pattern as clickup-cli's `skill/SKILL.md`.

## D14: Dependencies - minimal
Only `swift-argument-parser` (Apple's own CLI framework). No other external dependencies. URLSession for HTTP, Foundation for JSON (Codable). Keep it lean.

## D15: SwiftWasm book as data source
Added the SwiftWasm book (18 pages, fetched from GitHub raw content) as a data source for WebAssembly development docs. Fills a gap - no other CLI tool provides offline-friendly SwiftWasm reference.

## D16: HIG via sosumi.ai proxy
Added Apple Human Interface Guidelines via the sosumi.ai proxy, same pattern as WWDC transcripts. Gives agents access to HIG design guidance without scraping Apple's site.

## D17: Distribution - Homebrew tap, Mint, GitHub Releases, source
Four install paths: Homebrew tap (`krodak/tap`) as primary, Mint (works out of the box since Package.swift has executable product), universal binary from GitHub Releases (arm64+x86_64 built by GitHub Actions), and build from source. Covers the full spectrum from casual users to contributors.

## D18: swift-tools-version stays at 6.0
Keeping swift-tools-version at 6.0 for maximum compatibility. Swift 6.0 is the minimum that supports strict concurrency checking, which we rely on. No need to bump to 6.1+ yet.
