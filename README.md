# sad - Search Apple Docs

Apple Developer Documentation CLI for AI agents and humans. Markdown output by default, `--json` for structured data. Stateless - no config, no auth, no local database.

## Requirements

- macOS 13+
- Swift 6.0 (for building from source)

## Install

### Homebrew

```bash
brew tap krodak/tap
brew install sad-cli
```

### Mint

```bash
mint install krodak/sad-cli
```

### GitHub Releases

```bash
curl -L https://github.com/krodak/sad-cli/releases/latest/download/sad-macos-universal.tar.gz | tar xz
mv sad /usr/local/bin/
```

### Build from source

```bash
git clone https://github.com/krodak/sad-cli.git
cd sad-cli
swift build -c release
cp .build/release/sad /usr/local/bin/
```

## Commands

| Command | Description |
| --- | --- |
| `sad doc <path> [--json]` | Fetch documentation for a symbol or framework |
| `sad docc <url> [--json]` | Fetch external Swift-DocC documentation by URL |
| `sad search <query> [--limit N] [--json]` | Search Apple developer documentation |
| `sad frameworks [--filter TEXT] [--json]` | List Apple frameworks and technologies |
| `sad wwdc <input> [--json]` | WWDC session transcripts or documentation |
| `sad samples [query] [--framework TEXT] [--limit N] [--json]` | Search for Apple sample code |
| `sad related <path> [--json]` | Show related topics for a documentation page |
| `sad platform <path> [--json]` | Show platform availability for a symbol |
| `sad hig [topic] [--json]` | Apple Human Interface Guidelines |
| `sad wasm [slug] [--json]` | SwiftWasm book (18 pages) |
| `sad evolution [number] [--json]` | Swift Evolution proposals |

All commands output Markdown by default. Pass `--json` for structured JSON output. All commands support `--help`.

### `sad doc <path>`

```bash
sad doc swift/array
sad doc swiftui/view --json
```

### `sad docc <url>`

```bash
sad docc https://apple.github.io/swift-argument-parser/documentation/argumentparser
sad docc apple.github.io/swift-argument-parser/documentation/argumentparser --json
```

### `sad search <query>`

```bash
sad search "combine publisher"
sad search "swiftui navigation" --limit 5 --json
```

### `sad frameworks`

```bash
sad frameworks
sad frameworks --filter "swift" --json
```

### `sad wwdc <input>`

Session format: `YYYY/NNNNN`. Non-session input treated as a documentation topic.

```bash
sad wwdc 2024/10136
sad wwdc 2023/10187 --json
```

### `sad samples [query]`

```bash
sad samples "augmented reality"
sad samples --framework SwiftUI --json
```

### `sad related <path>`

```bash
sad related swift/array
sad related swiftui/navigationstack --json
```

### `sad platform <path>`

```bash
sad platform swiftui/navigationstack
sad platform swift/regex --json
```

### `sad hig [topic]`

```bash
sad hig
sad hig color --json
```

### `sad wasm [slug]`

```bash
sad wasm
sad wasm getting-started --json
```

### `sad evolution [number]`

Accepts `SE-0401`, `0401`, or `401`.

```bash
sad evolution
sad evolution SE-0401 --json
```

## For AI agents

Always use `--json` to get structured, parseable output.

```bash
sad doc swift/array --json | jq '.metadata.title'
sad search "async await" --json | jq '.[].title'
sad platform swiftui/view --json
sad wwdc 2024/10136 --json
sad hig color --json
sad evolution SE-0401 --json
sad docc https://apple.github.io/swift-argument-parser/documentation/argumentparser --json
```

No configuration, authentication, or local database required. Every invocation is a stateless HTTP request. Errors go to stderr with non-zero exit code.

## AI Agent Skill

A skill file is included at `skill/SKILL.md` that teaches AI agents how to use `sad`. Install it for your agent of choice:

### OpenCode

```bash
mkdir -p ~/.config/opencode/skills/apple-docs
cp skill/SKILL.md ~/.config/opencode/skills/apple-docs/SKILL.md
```

### Claude Code

```bash
mkdir -p ~/.claude/skills/apple-docs
cp skill/SKILL.md ~/.claude/skills/apple-docs/SKILL.md
```

### Codex

Copy the contents of `skill/SKILL.md` into your Codex system prompt or project instructions file.

### Other agents

The skill file is a standalone markdown document. Feed it to any agent that supports custom instructions or tool documentation.

## Why this exists

There are already a few tools for querying Apple docs programmatically. Here's how they compare and why `sad` takes a different approach.

| | sad | [apple-docs-mcp](https://github.com/nicklama/apple-docs-mcp) | [cupertino](https://github.com/nicklama/cupertino) | [sosumi.ai](https://sosumi.ai) |
|---|---|---|---|---|
| Type | CLI | MCP server | CLI + MCP | HTTP proxy + MCP |
| Language | Swift | TypeScript | Swift | TypeScript |
| Local storage | None | None | ~2-3 GB SQLite | None |
| Third-party service | None | None | None | sosumi.ai |
| Setup | `brew install` | npm + MCP config | clone + build + import | API endpoint config |
| Scope | Docs, HIG, WWDC, samples, Swift Evolution, SwiftWasm, external DocC | Docs, search | Docs, search, forums | Docs, HIG, WWDC |

The main difference is philosophical. Most existing tools are MCP servers - they plug into a specific AI agent protocol and require configuring that integration. `sad` is just a CLI. Any agent that can run shell commands can use it, no protocol adapter needed. Same goes for humans debugging something in a terminal.

`cupertino` is the closest in spirit (also Swift, also a CLI), but it imports Apple's documentation into a local SQLite database. That's a 2-3 GB download before you can run your first query. `sad` is stateless - it hits Apple's JSON APIs directly, so there's nothing to sync or store.

`sosumi.ai` is a hosted proxy that wraps Apple's documentation behind a third-party endpoint. Works fine until the service goes down or changes its API. `sad` talks to Apple directly and has zero runtime dependencies beyond the binary itself.

The other tools are probably more useful for most people. If you already have an MCP setup, `apple-docs-mcp` plugs right in. If you want offline access or full-text search, `cupertino`'s local database is hard to beat. `sad` fills a narrower niche - I wanted something with zero setup and zero state that works anywhere a shell does, and nothing else quite fit.

## Development

```bash
swift build                  # debug build
swift build -c release       # release build
swift test                   # run tests (76 tests)
swift run sad --help         # run from source
```

### Project structure

```
Sources/
  sad/                       # CLI entry point
  AppleDocsLib/              # Library: commands, models, networking
Tests/
  AppleDocsLibTests/         # Unit tests with fixture-based mocking
```

## License

MIT - see [LICENSE](LICENSE).
