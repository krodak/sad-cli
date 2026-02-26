public struct SearchResult: Sendable {
    public var title: String
    public var url: String
    public var description: String?
    public var type: String?

    public init(title: String, url: String, description: String? = nil, type: String? = nil) {
        self.title = title
        self.url = url
        self.description = description
        self.type = type
    }
}
