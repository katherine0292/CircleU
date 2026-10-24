import Foundation

/// Immutable design fixtures. These values never read or write the app's stores.
public enum PrototypeScreen: String, CaseIterable, Identifiable, Sendable {
    case today = "Today"
    case journal = "Journal"
    case practice = "Practice"

    public var id: String { rawValue }

    var nodeID: String {
        switch self {
        case .today: "11:100"
        case .journal: "11:104"
        case .practice: "11:107"
        }
    }

    var eyebrow: String { self == .today ? "CIRCLEU / TODAY" : rawValue.uppercased() }

    var title: String {
        switch self {
        case .today: "What’s on\nyour mind?"
        case .journal: "Your moments,\nready to revisit."
        case .practice: "Find words\nthat fit you."
        }
    }

    var introduction: String {
        switch self {
        case .today: "Work through a moment or find the words for a conversation."
        case .journal: "Open an entry to read your words, reflection and any linked practice."
        case .practice: "Start a message on its own. A journal entry is optional."
        }
    }

    var cardTitle: String {
        switch self {
        case .today: "Continue your draft"
        case .journal: "Group deadline"
        case .practice: "Recent practice"
        }
    }

    var cardBody: String {
        switch self {
        case .today: "Group deadline · your words are ready to review."
        case .journal: "Your saved moment · tap to open"
        case .practice: "Asking for a deadline update · tap to reopen"
        }
    }

    var actions: [PrototypeAction] {
        switch self {
        case .today: [
            .init(label: "New reflection", style: .primary),
            .init(label: "Resume draft", style: .secondary),
            .init(label: "Practice a message", style: .quiet),
            .init(label: "Privacy and data", style: .quiet)
        ]
        case .journal: [
            .init(label: "Open saved entry", style: .primary),
            .init(label: "New reflection", style: .secondary)
        ]
        case .practice: [
            .init(label: "Start a new practice", style: .primary),
            .init(label: "Open saved practice", style: .secondary)
        ]
        }
    }
}

struct PrototypeAction: Identifiable {
    enum Style { case primary, secondary, quiet }
    let label: String
    let style: Style
    var id: String { label }
}
