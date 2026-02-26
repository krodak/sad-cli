# ad - Apple Docs CLI

A lightweight, stateless Apple Developer Documentation CLI. Search, browse, and read Apple docs from the terminal. Optimized for AI agents.

## Requirements

- macOS 13+
- Swift 6.0 (for building from source)

## Install

### Build from source

```bash
git clone https://github.com/krodak/apple-docs-cli.git
cd apple-docs-cli
swift build -c release
cp .build/release/ad /usr/local/bin/ad
```

### Homebrew

Coming soon.

## Commands

| Command    | Description                                  |
| ---------- | -------------------------------------------- |
| `doc`      | Fetch and display documentation for a symbol |
| `search`   | Search Apple developer documentation         |
| `frameworks` | List Apple frameworks and technologies     |
| `wwdc`     | Fetch WWDC session transcripts               |
| `samples`  | Search for Apple sample code                 |
| `related`  | Show related topics for a documentation page |
| `platform` | Show platform availability for a symbol      |

All commands output Markdown by default. Pass `--json` for structured JSON output.

### `ad doc <path>`

Fetch documentation for a symbol or framework.

```bash
ad doc swift/array
ad doc uikit/uiviewcontroller
ad doc swift/array --json
```

### `ad search <query>`

Search Apple developer documentation.

```bash
ad search "combine publisher"
ad search "swiftui navigation" --limit 5
ad search "core data" --json
```

### `ad frameworks`

List Apple frameworks and technologies.

```bash
ad frameworks
ad frameworks --filter "swift"
ad frameworks --json
```

### `ad wwdc <year/sessionid>`

Fetch WWDC session transcripts or documentation.

```bash
ad wwdc 2024/10136
ad wwdc 2023/10187 --json
```

### `ad samples [query]`

Search for Apple sample code.

```bash
ad samples "augmented reality"
ad samples --framework SwiftUI
ad samples "navigation" --limit 5 --json
```

### `ad related <path>`

Show related topics for a documentation page.

```bash
ad related swift/array
ad related uikit/uiviewcontroller --json
```

### `ad platform <path>`

Show platform availability for a symbol.

```bash
ad platform swift/array
ad platform swiftui/view --json
```

## For AI Agents

Always use the `--json` flag to get structured, parseable output.

```bash
# Look up a specific API
ad doc swift/array --json | jq '.abstract'

# Find relevant APIs
ad search "concurrency async" --json | jq '.[].path'

# Check platform support before recommending an API
ad platform swiftui/view --json

# Get WWDC session content for context
ad wwdc 2024/10136 --json
```

No configuration, authentication, or local database required. Every invocation is a stateless HTTP request to Apple's public JSON API.

## AI Agent Skill

A skill file is included at `skill/SKILL.md` that teaches AI agents how to use `ad`. Install it for your agent of choice:

### Claude Code

```bash
mkdir -p ~/.claude/skills/apple-docs
cp skill/SKILL.md ~/.claude/skills/apple-docs/SKILL.md
```

Then reference it in your `CLAUDE.md` or project instructions.

### OpenCode

```bash
mkdir -p ~/.config/opencode/skills/apple-docs
cp skill/SKILL.md ~/.config/opencode/skills/apple-docs/SKILL.md
```

### Codex

Copy the contents of `skill/SKILL.md` into your Codex system prompt or project instructions file.

### Other agents

The skill file is a standalone markdown document. Feed it to any agent that supports custom instructions or tool documentation.

## Why `ad`

| Feature             | ad             | cupertino         | apple-docs-mcp | sosumi.ai    |
| ------------------- | -------------- | ----------------- | --------------- | ------------ |
| Install             | Single binary  | Ruby gem + deps   | MCP server      | Web only     |
| Auth/config         | None           | Apple ID login    | None            | None         |
| Local database      | No             | Yes (SQLite)      | No              | No           |
| AI agent friendly   | Yes (--json)   | No                | MCP only        | API only     |
| WWDC transcripts    | Yes            | No                | Yes             | Yes          |
| Sample code search  | Yes            | No                | Limited         | Limited      |
| Offline             | No             | Partial           | No              | No           |
| Dependencies        | 1 (arg parser) | 20+               | Node + MCP      | None (SaaS)  |

## Development

```bash
swift build                  # debug build
swift build -c release       # release build
swift test                   # run tests
swift run ad --help          # run from source
```

### Project structure

```
Sources/
  ad/                        # CLI entry point
  AppleDocsLib/              # Library: commands, models, networking
Tests/
  AppleDocsLibTests/         # Unit tests with fixture-based mocking
```

## License

MIT - see [LICENSE](LICENSE).
