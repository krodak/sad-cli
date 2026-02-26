---
name: apple-docs
description: 'Use when looking up Apple Developer Documentation, checking API availability, finding related APIs, searching sample code, reading WWDC session transcripts, consulting Apple Human Interface Guidelines, reading SwiftWasm book content, reading Swift Evolution proposals, or fetching external Swift-DocC documentation.'
---

# Search Apple Docs (`sad`)

Reference for AI agents using the `sad` command-line tool to query Apple Developer Documentation, HIG, WWDC transcripts, Swift Evolution proposals, SwiftWasm book, and external Swift-DocC sites.

Keywords: Apple, Swift, SwiftUI, UIKit, AppKit, Foundation, Combine, iOS, macOS, watchOS, tvOS, visionOS, WWDC, documentation, API, framework, platform availability, sample code, Human Interface Guidelines, HIG, WebAssembly, SwiftWasm, Wasm, Swift Evolution, SE proposal, DocC, Swift-DocC

## Commands

All commands output Markdown by default. Pass `--json` for structured JSON. All commands support `--help`.

| Command | What it returns |
| --- | --- |
| `sad doc <path> [--json]` | Documentation for a symbol or framework |
| `sad docc <url> [--json]` | External Swift-DocC documentation by URL |
| `sad search <query> [--limit N] [--json]` | Search results (default 20) |
| `sad frameworks [--filter TEXT] [--json]` | Apple frameworks grouped by category |
| `sad wwdc <YYYY/NNNNN> [--json]` | WWDC session transcript |
| `sad wwdc <topic> [--json]` | Documentation for a WWDC-related topic |
| `sad samples [query] [--framework TEXT] [--limit N] [--json]` | Sample code search (default 10) |
| `sad related <path> [--json]` | Related topics for a documentation page |
| `sad platform <path> [--json]` | Platform availability for a symbol |
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
- `--json` guarantees machine-readable output
- Errors go to stderr with exit code 1
- If a path returns an error, try `sad search` to find the correct path

## Agent workflow examples

```bash
sad doc swiftui/list --json

sad search "swiftui table multi selection" --json
sad doc swiftui/table --json

sad frameworks --filter swiftui --json
sad related swiftui --json

sad platform swiftui/navigationstack --json

sad samples "drag and drop" --framework SwiftUI --json

sad wwdc 2024/10136 --json

sad hig color --json

sad wasm getting-started --json

sad evolution SE-0401 --json

sad docc https://apple.github.io/swift-argument-parser/documentation/argumentparser --json
```
