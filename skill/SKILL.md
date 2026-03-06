---
name: apple-docs
description: 'Use when looking up Apple Developer Documentation, checking API availability, finding related APIs, searching sample code, reading WWDC session transcripts, consulting Apple Human Interface Guidelines, reading SwiftWasm book content, reading Swift Evolution proposals, or fetching external Swift-DocC documentation.'
---

# Search Apple Docs (`sad`)

Reference for AI agents using the `sad` CLI to query Apple Developer Documentation, HIG, WWDC transcripts, Swift Evolution proposals, SwiftWasm book, and external Swift-DocC sites.

Keywords: Apple, Swift, SwiftUI, UIKit, AppKit, Foundation, Combine, iOS, macOS, watchOS, tvOS, visionOS, WWDC, documentation, API, framework, platform availability, sample code, Human Interface Guidelines, HIG, WebAssembly, SwiftWasm, Wasm, Swift Evolution, SE proposal, DocC, Swift-DocC

## Two-step workflow

Most lookups follow a discover-then-fetch pattern. Discovery commands (`search`, `frameworks`, `related`, `samples`) return titles, descriptions, and paths. Fetch commands (`doc`, `docc`, `hig`, `wwdc`, `wasm`, `evolution`) return full content.

**Use `--json` for all commands** to get structured, parseable output.

```
search/frameworks/related/samples → find the right path
                                   ↓
             doc/docc/platform/hig/wwdc/wasm/evolution → get full content
```

Example: user asks "how does SwiftUI List selection work?"

```bash
sad search "swiftui list selection" --json    # step 1: find relevant pages
sad doc swiftui/list --json                   # step 2: get full documentation
```

Example: user asks "what frameworks does Apple offer for ML?"

```bash
sad frameworks --filter "learn" --json        # step 1: find ML frameworks
sad doc coreml --json                         # step 2: get CoreML docs
```

Example: user asks "what's the availability of NavigationStack?"

```bash
sad platform swiftui/navigationstack --json   # single step: direct lookup
```

Not every lookup needs two steps. If you already know the path, go straight to `doc`. If you don't know the path, start with `search` or `frameworks`.

## Commands

All commands output Markdown by default. Pass `--json` for structured JSON. All commands support `--help`.

### Discovery commands

| Command | What it returns |
| --- | --- |
| `sad search <query> [--limit N] [--json]` | Titles, descriptions, and URLs (default 20) |
| `sad frameworks [--filter TEXT] [--json]` | Apple frameworks grouped by category |
| `sad related <path> [--json]` | Related topics for a documentation page |
| `sad samples [query] [--framework TEXT] [--limit N] [--json]` | Sample code results (default 10) |

### Fetch commands

| Command | What it returns |
| --- | --- |
| `sad doc <path> [--json]` | Full documentation for a symbol or framework |
| `sad docc <url> [--json]` | External Swift-DocC documentation by URL |
| `sad wwdc <YYYY/NNNNN> [--json]` | WWDC session transcript |
| `sad platform <path> [--json]` | Platform availability table |
| `sad hig [topic] [--json]` | HIG guidance (omit topic for overview) |
| `sad wasm [slug] [--json]` | SwiftWasm book page (omit slug for TOC) |
| `sad evolution [number] [--json]` | Swift Evolution proposal (omit for recent list) |

## Path format

Paths mirror Apple documentation URLs minus the `/documentation/` prefix. Case-insensitive.

| URL | Path |
| --- | --- |
| `developer.apple.com/documentation/swift/array` | `swift/array` |
| `developer.apple.com/documentation/swiftui/view` | `swiftui/view` |
| `developer.apple.com/documentation/swift/array/append(_:)` | `swift/array/append(_:)` |

Pattern: `framework/type` or `framework/type/member`

## Key facts

- No configuration or API keys needed
- Requires internet access
- Paths are case-insensitive (`swift/Array` and `swift/array` both work)
- WWDC session format: `YYYY/NNNNN` (e.g. `2024/10136`)
- HIG topics are lowercase slugs (e.g. `color`, `typography`, `layout`)
- Swift Evolution accepts `SE-0401`, `0401`, or `401`
- SwiftWasm slugs match book chapter URLs; run `sad wasm` to list them
- DocC URLs must contain `/documentation/`; scheme optional (defaults to `https://`)
- Errors go to stderr with exit code 1
- If a path returns an error, try `sad search` to find the correct path
