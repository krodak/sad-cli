public struct MarkdownFormatter: Sendable {

    public init() {}

    // MARK: - Full doc page

    public func formatDoc(_ doc: DocContent) -> String {
        var lines: [String] = []

        if let title = doc.metadata?.title {
            lines.append("# \(title)")
            lines.append("")
        }

        if let heading = doc.metadata?.roleHeading {
            lines.append("**\(heading)**")
        }

        if let moduleName = doc.metadata?.modules?.first?.name {
            lines.append("Framework: \(moduleName)")
        }

        if let platforms = doc.metadata?.platforms, !platforms.isEmpty {
            let available = platforms.compactMap { platform -> String? in
                guard let name = platform.name,
                      platform.unavailable != true else { return nil }
                let version = platform.introducedAt.map { "\($0)+" } ?? ""
                return "\(name) \(version)".trimmingCharacters(in: .whitespaces)
            }
            if !available.isEmpty {
                lines.append("")
                lines.append("**Availability:** \(available.joined(separator: " | "))")
            }
        }

        if let abstract = doc.abstract {
            let text = formatInlineContent(abstract)
            if !text.isEmpty {
                lines.append("")
                lines.append(text)
            }
        }

        if let sections = doc.primaryContentSections {
            for section in sections where section.kind == "content" {
                if let blocks = section.content {
                    let rendered = formatContentBlocks(blocks)
                    if !rendered.isEmpty {
                        lines.append("")
                        lines.append(rendered)
                    }
                }
            }
        }

        if let declarations = doc.primaryContentSections?.first(where: { $0.kind == "declarations" })?.declarations {
            let tokens = declarations.flatMap { $0.tokens ?? [] }
            let decl = tokens.compactMap(\.text).joined()
            if !decl.isEmpty {
                lines.append("")
                lines.append("```swift")
                lines.append(decl)
                lines.append("```")
            }
        }

        if let topicSections = doc.topicSections, !topicSections.isEmpty {
            lines.append("")
            lines.append("## Topics")
            for section in topicSections {
                if let title = section.title {
                    lines.append("")
                    lines.append("### \(title)")
                }
                if let ids = section.identifiers {
                    for id in ids {
                        let ref = doc.references?[id]
                        let name = ref?.title ?? lastPathComponent(id)
                        lines.append("- `\(name)`")
                    }
                }
            }
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Search results

    public func formatSearchResults(_ results: [SearchResult]) -> String {
        guard !results.isEmpty else { return "No results found." }

        var lines: [String] = ["# Search Results"]
        for (index, result) in results.enumerated() {
            lines.append("")
            lines.append("## \(index + 1). \(result.title)")
            if let desc = result.description {
                lines.append(desc)
            }
            lines.append("URL: \(result.url)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Technologies

    public func formatTechnologies(_ response: TechnologiesResponse) -> String {
        var lines: [String] = ["# Frameworks & Technologies"]

        guard let sections = response.topicSections, !sections.isEmpty else {
            return lines.joined(separator: "\n")
        }

        for section in sections {
            if let title = section.title {
                lines.append("")
                lines.append("## \(title)")
            }
            if let ids = section.identifiers, let refs = response.references {
                for id in ids {
                    if let ref = refs[id], let name = ref.title {
                        let desc = ref.abstract.map { formatInlineContent($0) } ?? ""
                        if desc.isEmpty {
                            lines.append("- **\(name)**")
                        } else {
                            lines.append("- **\(name)** - \(desc)")
                        }
                    }
                }
            }
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Platform availability

    public func formatPlatformAvailability(_ platforms: [DocContent.Platform]) -> String {
        guard !platforms.isEmpty else { return "No platform information available." }

        var lines: [String] = [
            "# Platform Availability",
            "",
            "| Platform | Version | Beta |",
            "|----------|---------|------|",
        ]

        for platform in platforms where platform.unavailable != true {
            let name = platform.name ?? "Unknown"
            let version = platform.introducedAt.map { "\($0)+" } ?? "-"
            let beta = platform.beta == true ? "Yes" : "No"
            lines.append("| \(name) | \(version) | \(beta) |")
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Inline content

    public func formatInlineContent(_ content: [InlineContent]) -> String {
        content.map { element -> String in
            switch element {
            case .text(let text):
                return text
            case .codeVoice(let code):
                return "`\(code)`"
            case .reference(let identifier):
                return "`\(lastPathComponent(identifier))`"
            case .image:
                return ""
            case .emphasis(let children):
                return "*\(formatInlineContent(children))*"
            case .strong(let children):
                return "**\(formatInlineContent(children))**"
            case .unknown:
                return ""
            }
        }.joined()
    }

    // MARK: - Content blocks

    public func formatContentBlocks(_ blocks: [ContentBlock]) -> String {
        var parts: [String] = []
        for block in blocks {
            switch block {
            case .heading(let text, let level, _):
                let prefix = String(repeating: "#", count: level)
                parts.append("\(prefix) \(text)")
            case .paragraph(let inline):
                let text = formatInlineContent(inline)
                if !text.isEmpty {
                    parts.append(text)
                }
            case .codeListing(let code, let syntax):
                let lang = syntax ?? ""
                parts.append("```\(lang)\n\(code.joined(separator: "\n"))\n```")
            case .unorderedList(let items):
                let listLines = items.map { itemBlocks -> String in
                    let text = formatContentBlocks(itemBlocks)
                    return "- \(text)"
                }
                parts.append(listLines.joined(separator: "\n"))
            case .aside(let style, let content):
                let label = style ?? "Note"
                let body = formatContentBlocks(content)
                let quoted = body.split(separator: "\n", omittingEmptySubsequences: false)
                    .map { "> \($0)" }
                    .joined(separator: "\n")
                parts.append("> **\(label):** \(quoted.dropFirst(2))")
            case .unknown:
                break
            }
        }
        return parts.joined(separator: "\n\n")
    }

    // MARK: - Helpers

    private func lastPathComponent(_ identifier: String) -> String {
        guard let last = identifier.split(separator: "/").last else {
            return identifier
        }
        return String(last)
    }
}
