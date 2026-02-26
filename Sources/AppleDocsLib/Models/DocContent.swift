import Foundation

public struct DocContent: Codable, Sendable {
    public var schemaVersion: SchemaVersion?
    public var kind: String?
    public var identifier: Identifier?
    public var metadata: Metadata?
    public var abstract: [InlineContent]?
    public var hierarchy: Hierarchy?
    public var primaryContentSections: [ContentSection]?
    public var topicSections: [TopicSection]?
    public var relationshipsSections: [RelationshipsSection]?
    public var seeAlsoSections: [TopicSection]?
    public var references: [String: Reference]?
    public var sections: [ContentSection]?
    public var legalNotices: LegalNotices?
}

// MARK: - Identifier

public extension DocContent {
    struct Identifier: Codable, Sendable {
        public var url: String?
        public var interfaceLanguage: String?
    }
}

// MARK: - Schema

public extension DocContent {
    struct SchemaVersion: Codable, Sendable {
        public var major: Int?
        public var minor: Int?
        public var patch: Int?
    }
}

// MARK: - Metadata

public extension DocContent {
    struct Metadata: Codable, Sendable {
        public var title: String?
        public var role: String?
        public var roleHeading: String?
        public var platforms: [Platform]?
        public var modules: [Module]?
        public var symbolKind: String?
        public var fragments: [Fragment]?
        public var navigatorTitle: [Fragment]?
        public var externalID: String?
    }

    struct Platform: Codable, Sendable {
        public var name: String?
        public var introducedAt: String?
        public var deprecated: Bool?
        public var beta: Bool?
        public var unavailable: Bool?
    }

    struct Module: Codable, Sendable {
        public var name: String?
    }

    struct Fragment: Codable, Sendable {
        public var kind: String?
        public var text: String?
    }
}

// MARK: - Hierarchy

public extension DocContent {
    struct Hierarchy: Codable, Sendable {
        public var paths: [[String]]?
    }
}

// MARK: - Inline Content

public enum InlineContent: Codable, Sendable {
    case text(String)
    case codeVoice(String)
    case reference(identifier: String)
    case image(identifier: String)
    case emphasis([InlineContent])
    case strong([InlineContent])
    case unknown

    private enum CodingKeys: String, CodingKey {
        case type, text, code, identifier, inlineContent
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(String.self, forKey: .type)

        switch type {
        case "text":
            let text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
            self = .text(text)
        case "codeVoice":
            let code = try container.decodeIfPresent(String.self, forKey: .code) ?? ""
            self = .codeVoice(code)
        case "reference":
            let id = try container.decodeIfPresent(String.self, forKey: .identifier) ?? ""
            self = .reference(identifier: id)
        case "image":
            let id = try container.decodeIfPresent(String.self, forKey: .identifier) ?? ""
            self = .image(identifier: id)
        case "emphasis":
            let children = try container.decodeIfPresent([InlineContent].self, forKey: .inlineContent) ?? []
            self = .emphasis(children)
        case "strong":
            let children = try container.decodeIfPresent([InlineContent].self, forKey: .inlineContent) ?? []
            self = .strong(children)
        default:
            self = .unknown
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .text)
        case .codeVoice(let code):
            try container.encode("codeVoice", forKey: .type)
            try container.encode(code, forKey: .code)
        case .reference(let id):
            try container.encode("reference", forKey: .type)
            try container.encode(id, forKey: .identifier)
        case .image(let id):
            try container.encode("image", forKey: .type)
            try container.encode(id, forKey: .identifier)
        case .emphasis(let children):
            try container.encode("emphasis", forKey: .type)
            try container.encode(children, forKey: .inlineContent)
        case .strong(let children):
            try container.encode("strong", forKey: .type)
            try container.encode(children, forKey: .inlineContent)
        case .unknown:
            try container.encode("unknown", forKey: .type)
        }
    }

    public var plainText: String {
        switch self {
        case .text(let text): return text
        case .codeVoice(let code): return "`\(code)`"
        case .reference: return ""
        case .image: return ""
        case .emphasis(let children): return children.map(\.plainText).joined()
        case .strong(let children): return children.map(\.plainText).joined()
        case .unknown: return ""
        }
    }
}

// MARK: - Content Blocks

public enum ContentBlock: Codable, Sendable {
    case heading(text: String, level: Int, anchor: String?)
    case paragraph([InlineContent])
    case codeListing(code: [String], syntax: String?)
    case unorderedList([[ContentBlock]])
    case aside(style: String?, content: [ContentBlock])
    case unknown

    private enum CodingKeys: String, CodingKey {
        case type, text, level, anchor, inlineContent, code, syntax, items, content, style, name
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(String.self, forKey: .type)

        switch type {
        case "heading":
            let text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
            let level = try container.decodeIfPresent(Int.self, forKey: .level) ?? 2
            let anchor = try container.decodeIfPresent(String.self, forKey: .anchor)
            self = .heading(text: text, level: level, anchor: anchor)
        case "paragraph":
            let inline = try container.decodeIfPresent([InlineContent].self, forKey: .inlineContent) ?? []
            self = .paragraph(inline)
        case "codeListing":
            let code = try container.decodeIfPresent([String].self, forKey: .code) ?? []
            let syntax = try container.decodeIfPresent(String.self, forKey: .syntax)
            self = .codeListing(code: code, syntax: syntax)
        case "unorderedList":
            let items = try container.decodeIfPresent([ListItem].self, forKey: .items) ?? []
            self = .unorderedList(items.map(\.content))
        case "aside":
            let style = try container.decodeIfPresent(String.self, forKey: .style)
                ?? container.decodeIfPresent(String.self, forKey: .name)
            let content = try container.decodeIfPresent([ContentBlock].self, forKey: .content) ?? []
            self = .aside(style: style, content: content)
        default:
            self = .unknown
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .heading(let text, let level, let anchor):
            try container.encode("heading", forKey: .type)
            try container.encode(text, forKey: .text)
            try container.encode(level, forKey: .level)
            try container.encodeIfPresent(anchor, forKey: .anchor)
        case .paragraph(let inline):
            try container.encode("paragraph", forKey: .type)
            try container.encode(inline, forKey: .inlineContent)
        case .codeListing(let code, let syntax):
            try container.encode("codeListing", forKey: .type)
            try container.encode(code, forKey: .code)
            try container.encodeIfPresent(syntax, forKey: .syntax)
        case .unorderedList(let items):
            try container.encode("unorderedList", forKey: .type)
            try container.encode(items.map { ListItem(content: $0) }, forKey: .items)
        case .aside(let style, let content):
            try container.encode("aside", forKey: .type)
            try container.encodeIfPresent(style, forKey: .style)
            try container.encode(content, forKey: .content)
        case .unknown:
            try container.encode("unknown", forKey: .type)
        }
    }
}

struct ListItem: Codable, Sendable {
    var content: [ContentBlock]
}

// MARK: - Content Section

public struct ContentSection: Codable, Sendable {
    public var kind: String?
    public var content: [ContentBlock]?
    public var declarations: [Declaration]?
    public var mentions: [String]?
}

public struct Declaration: Codable, Sendable {
    public var platforms: [String]?
    public var languages: [String]?
    public var tokens: [Token]?
}

public struct Token: Codable, Sendable {
    public var kind: String?
    public var text: String?
    public var identifier: String?
    public var preciseIdentifier: String?
}

// MARK: - Topic Section

public struct TopicSection: Codable, Sendable {
    public var title: String?
    public var identifiers: [String]?
    public var anchor: String?
    public var generated: Bool?
}

// MARK: - Relationships Section

public struct RelationshipsSection: Codable, Sendable {
    public var kind: String?
    public var type: String?
    public var title: String?
    public var identifiers: [String]?
}

// MARK: - Reference

public struct Reference: Codable, Sendable {
    public var identifier: String?
    public var title: String?
    public var url: String?
    public var kind: String?
    public var role: String?
    public var abstract: [InlineContent]?
    public var type: String?
    public var fragments: [DocContent.Fragment]?
    public var navigatorTitle: [DocContent.Fragment]?
    public var conformance: Conformance?
    public var deprecated: Bool?
    public var beta: Bool?

    public struct Conformance: Codable, Sendable {
        public var availabilityPrefix: [InlineContent]?
        public var conformancePrefix: [InlineContent]?
        public var constraints: [InlineContent]?
    }
}

// MARK: - Legal Notices

public extension DocContent {
    struct LegalNotices: Codable, Sendable {
        public var copyright: String?
        public var termsOfUse: String?
    }
}
