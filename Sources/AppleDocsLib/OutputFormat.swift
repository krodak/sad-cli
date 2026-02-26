import ArgumentParser

public enum OutputFormat: String, CaseIterable, ExpressibleByArgument, Sendable {
    case markdown
    case json
}
