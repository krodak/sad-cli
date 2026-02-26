public struct TechnologiesResponse: Codable, Sendable {
    public var topicSections: [TopicSection]?
    public var references: [String: TechnologyReference]?
}

public struct TechnologyReference: Codable, Sendable {
    public var title: String?
    public var url: String?
    public var abstract: [InlineContent]?
    public var kind: String?
    public var role: String?
}
