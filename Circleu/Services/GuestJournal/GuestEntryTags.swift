import Foundation

/// Explicit personal labels; never inferred from words or an AI reflection.
nonisolated enum GuestEntryContext: String, CaseIterable, Sendable {
    case study, work, friends, family
    var title: String { rawValue.capitalized }
}

nonisolated enum GuestEntryFeeling: String, CaseIterable, Sendable {
    case calm, worried, overloaded, happy, sad, frustrated
    var title: String { rawValue.capitalized }
}

nonisolated protocol GuestEntryTagStore: Sendable {
    func updateTags(id: UUID, context: GuestEntryContext?, feeling: GuestEntryFeeling?,
                    expectedRevision: Int) async throws -> GuestJournalEntry
}
