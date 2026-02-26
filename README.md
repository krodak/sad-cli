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
