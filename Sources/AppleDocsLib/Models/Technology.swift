public struct TechnologiesResponse: Codable, Sendable {
    public var sections: [TechnologiesSection]?
    public var references: [String: TechnologyReference]?
}

public struct TechnologiesSection: Codable, Sendable {
    public var kind: String?
    public var groups: [TechnologyGroup]?
}

public struct TechnologyGroup: Codable, Sendable {
    public var name: String?
    public var technologies: [TechnologyEntry]?
}

public struct TechnologyEntry: Codable, Sendable {
    public var title: String?
    public var destination: TechnologyDestination?
    public var tags: [String]?
    public var languages: [String]?
}

public struct TechnologyDestination: Codable, Sendable {
    public var identifier: String?
    public var type: String?
    public var isActive: Bool?
}

public struct TechnologyReference: Codable, Sendable {
    public var title: String?
    public var url: String?
    public var abstract: [InlineContent]?
    public var kind: String?
    public var role: String?
}
