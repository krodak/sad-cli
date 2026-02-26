---
name: apple-docs
description: Use when looking up Apple Developer Documentation, checking API availability, finding related APIs, searching sample code, reading WWDC session transcripts, consulting Apple Human Interface Guidelines, or reading SwiftWasm book content. Also use when the user asks about any Apple framework, Swift standard library type, SwiftUI view, UIKit class, platform compatibility, HIG design guidance, or WebAssembly development with Swift.
---

# Apple Docs CLI (`ad`)

Reference for AI agents using the `ad` command-line tool to query Apple Developer Documentation.

Keywords: Apple, Swift, SwiftUI, UIKit, AppKit, Foundation, Combine, iOS, macOS, watchOS, tvOS, visionOS, WWDC, documentation, API, framework, platform availability, sample code, Human Interface Guidelines, HIG, WebAssembly, SwiftWasm, Wasm

## When to Use

- Looking up API documentation for any Apple framework
- Checking platform availability (iOS, macOS, watchOS, tvOS, visionOS)
- Finding related or similar APIs
- Searching for sample code
- Reading WWDC session transcripts
- Browsing available Apple frameworks and technologies
- Consulting Apple Human Interface Guidelines (color, typography, layout, components)
- Looking up SwiftWasm / WebAssembly development with Swift

## Commands

All commands output Markdown by default. Pass `--json` for structured JSON output. All commands support `--help`.

### doc - Fetch documentation

```bash
ad doc <path> [--json]
```

| Example | What it returns |
|---------|-----------------|
| `ad doc swift/array` | Array documentation |
| `ad doc swiftui/view` | SwiftUI View protocol docs |
| `ad doc uikit/uiviewcontroller` | UIViewController docs |
| `ad doc foundation/urlsession` | URLSession docs |
| `ad doc swift/array/append(_:) --json` | Array.append method as JSON |

### search - Search documentation

```bash
ad search <query> [--limit N] [--json]
```

- Default limit: 20 results

| Example | What it returns |
|---------|-----------------|
| `ad search "async await"` | Results about Swift concurrency |
| `ad search "navigation" --limit 5` | Top 5 navigation-related results |
| `ad search "combine publisher" --json` | Combine publisher results as JSON |

### frameworks - List frameworks

```bash
ad frameworks [--filter TEXT] [--json]
```

- `--filter` is case-insensitive partial match on framework name

| Example | What it returns |
|---------|-----------------|
| `ad frameworks` | All Apple frameworks grouped by category |
| `ad frameworks --filter swift` | Frameworks with "swift" in the name |
| `ad frameworks --filter ui --json` | UI-related frameworks as JSON |

### wwdc - WWDC session transcripts

```bash
ad wwdc <input> [--json]
```

- Session format: `YYYY/NNNNN` (e.g. `2024/10136`)
- Non-session input is treated as a documentation topic

| Example | What it returns |
|---------|-----------------|
| `ad wwdc 2024/10136` | Transcript for WWDC24 session 10136 |
| `ad wwdc 2023/10164` | Transcript for WWDC23 session 10164 |
| `ad wwdc swift-concurrency --json` | Doc content for topic as JSON |

### samples - Search sample code

```bash
ad samples [query] [--framework TEXT] [--limit N] [--json]
```

- Default limit: 10 results
- Appends "sample code" to the search automatically

| Example | What it returns |
|---------|-----------------|
| `ad samples "navigation"` | Sample code about navigation |
| `ad samples --framework SwiftUI` | SwiftUI sample code |
| `ad samples "camera" --framework AVFoundation --limit 5` | Top 5 AVFoundation camera samples |

### related - Find related APIs

```bash
ad related <path> [--json]
```

| Example | What it returns |
|---------|-----------------|
| `ad related swift/array` | Topics related to Array |
| `ad related swiftui/navigationstack` | APIs related to NavigationStack |

### platform - Platform availability

```bash
ad platform <path> [--json]
```

| Example | What it returns |
|---------|-----------------|
| `ad platform swiftui/navigationstack` | Which OS versions support NavigationStack |
| `ad platform uikit/uiviewcontroller` | UIViewController platform availability |
| `ad platform swift/regex --json` | Regex availability as JSON |

### hig - Apple Human Interface Guidelines

```bash
ad hig [topic] [--json]
```

- With no topic: lists all available HIG topics
- With a topic: fetches HIG guidance for that topic

| Example | What it returns |
|---------|-----------------|
| `ad hig` | List of all HIG topics |
| `ad hig color` | HIG guidance on color usage |
| `ad hig typography` | HIG typography recommendations |
| `ad hig layout --json` | Layout guidelines as JSON |
| `ad hig accessibility` | Accessibility design guidance |

### wasm - SwiftWasm book

```bash
ad wasm [slug] [--json]
```

- With no slug: lists all 18 pages/chapters
- With a slug: fetches the content of that page

| Example | What it returns |
|---------|-----------------|
| `ad wasm` | Table of contents (18 pages) |
| `ad wasm getting-started` | Getting started with SwiftWasm |
| `ad wasm browser-apps` | Building browser apps with Swift |
| `ad wasm wasi --json` | WASI chapter as JSON |

## Path Format

Paths mirror the Apple documentation URL structure, minus the `/documentation/` prefix.

| URL | Path argument |
|-----|---------------|
| `developer.apple.com/documentation/swift/array` | `swift/array` |
| `developer.apple.com/documentation/swiftui/view` | `swiftui/view` |
| `developer.apple.com/documentation/uikit/uiviewcontroller` | `uikit/uiviewcontroller` |
| `developer.apple.com/documentation/foundation/urlsession` | `foundation/urlsession` |
| `developer.apple.com/documentation/swift/array/append(_:)` | `swift/array/append(_:)` |

**Pattern:** `framework/type` or `framework/type/member`

Paths are case-insensitive. `swift/Array` and `swift/array` both work.

## Workflows

### Look up an API you know the name of

```bash
ad doc swiftui/list
```

### Find an API you don't know the name of

```bash
ad search "swiftui table multi selection"
# pick a result path, then:
ad doc swiftui/table
```

### Explore a framework

```bash
ad frameworks --filter swiftui
ad doc swiftui
ad related swiftui
```

### Check if an API is available on your target platform

```bash
ad platform swiftui/navigationstack
```

### Find sample code for a feature

```bash
ad samples "drag and drop" --framework SwiftUI
```

### Research a WWDC topic

```bash
ad search "swift concurrency wwdc"
ad wwdc 2024/10136
```

### Get HIG guidance for a design decision

```bash
ad hig color
ad hig typography
ad hig accessibility
```

### Research SwiftWasm for a WebAssembly project

```bash
ad wasm                        # see what's available
ad wasm getting-started        # start here
ad wasm browser-apps           # if building for the browser
```

## Output

- **Default:** Markdown - readable in terminal, suitable for direct use in responses
- **`--json`:** Structured JSON - use when you need to parse or filter results programmatically
- Errors go to stderr with non-zero exit code

## Notes

- No configuration or API keys needed
- Requires internet access (queries Apple's documentation servers)
- Paths are case-insensitive
- If a path returns an error, try `ad search` to find the correct path
- WWDC session IDs are 5-digit numbers; find them via `ad search "wwdc YYYY topic"`
- HIG topics are lowercase slugs (e.g. `color`, `typography`, `layout`)
- SwiftWasm slugs match book chapter URLs; run `ad wasm` with no args to list them
