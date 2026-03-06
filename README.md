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

| | sad | [sosumi.ai](https://sosumi.ai) | [apple-docs-mcp](https://github.com/kimsungwhee/apple-docs-mcp) | [cupertino](https://github.com/mihaelamj/cupertino) |
|---|---|---|---|---|
| Type | CLI | HTTP proxy + MCP + CLI | MCP server | CLI + MCP |
| Language | Swift | TypeScript | TypeScript | Swift |
| Local storage | None | None | None | ~2-3 GB SQLite |
| Third-party service | None | sosumi.ai | None | None |
| Setup | `brew install` | npm/MCP config | npm + MCP config | clone + build + import |
| Docs | Yes | Yes | Yes | Yes |
| Search | Yes | Yes | Yes | Yes |
| HIG | Yes | Yes | No | No |
| WWDC transcripts | Yes | Yes | No | No |
| External DocC | Yes | Yes | No | No |
| Frameworks listing | Yes | No | No | No |
| Sample code | Yes | No | No | Yes |
| Platform availability | Yes | No | No | No |
| Related topics | Yes | No | No | No |
| Swift Evolution | Yes | No | No | No |
| SwiftWasm book | Yes | No | No | No |
| Offline access | No | No | No | Yes |

`sosumi.ai` is the most feature-complete alternative and recently added a CLI (`npx @nshipster/sosumi`). It covers docs, HIG, WWDC, external DocC, and search. The difference is architectural: sosumi routes everything through their hosted proxy at sosumi.ai. Their CLI also calls the proxy, not Apple directly. Works well, but you depend on their service staying up. `sad` talks to Apple's JSON APIs with no intermediary.

`cupertino` takes the opposite approach - it crawls Apple's docs into a local SQLite database (~2-3 GB). Great if you want offline access or full-text search across everything. Not great if you want to just install and run.

`apple-docs-mcp` is an MCP server for docs and search. Straightforward if you already have an MCP client configured.

All of these are solid tools. `sad` fills a narrower niche - I wanted something with zero setup, zero state, and no service dependency that works anywhere a shell does. The 11 commands cover more surface area than the alternatives, but it's a CLI, not an MCP server, so it works with any agent that can run shell commands rather than requiring protocol-specific integration.

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
