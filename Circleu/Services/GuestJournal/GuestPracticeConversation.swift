import Foundation

/// Local practice history. Wording is prepared text, never a delivery receipt.
nonisolated struct GuestPracticeConversation: Codable, Equatable, Sendable {
    var scene = "Work"
    var tone = "Balanced"
    var originalWords = ""
    var turns: [Turn] = []
    var pendingReply = ""
    var pendingContext = ""

    struct Turn: Codable, Equatable, Identifiable, Sendable {
        enum Kind: String, Codable, Sendable {
            case wording, theirReply, context
            var label: String {
                switch self {
                case .wording: "Prepared wording"
                case .theirReply: "Their reply"
                case .context: "Added context"
                }
            }
        }
        var id = UUID()
        var kind: Kind
        var text: String
        var createdAt = Date()
    }

    var searchableText: String {
        ([scene, tone, originalWords, pendingReply, pendingContext] + turns.map(\.text)).joined(separator: "\n")
    }

    /// Attribution travels with every turn when asking for suggestions.
    var suggestionContext: String {
        (["Scene: \(scene)", "Tone: \(tone)"] + turns.map { "\($0.kind.label): \($0.text)" })
            .joined(separator: "\n")
    }
}

/// Extended persistence is explicit: an older/test store cannot silently drop conversation data.
nonisolated protocol GuestConversationStore: GuestPracticeStore {
    func createConversation(situation: String, goal: String, wording: String, sourceEntryID: UUID?,
                            draftID: UUID?, conversation: GuestPracticeConversation) async throws -> GuestPracticeMessage
    func updateConversation(id: UUID, situation: String, goal: String, wording: String,
                            expectedRevision: Int, conversation: GuestPracticeConversation) async throws -> GuestPracticeMessage
}
