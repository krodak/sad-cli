public struct WwdcSession: Sendable {
    public var title: String
    public var url: String
    public var year: Int?
    public var sessionId: String?
    public var description: String?
    public var transcript: String?

    public init(
        title: String,
        url: String,
        year: Int? = nil,
        sessionId: String? = nil,
        description: String? = nil,
        transcript: String? = nil
    ) {
        self.title = title
        self.url = url
        self.year = year
        self.sessionId = sessionId
        self.description = description
        self.transcript = transcript
    }
}
