import Combine
import Foundation
import UIKit

@MainActor
final class JournalEntryDetailViewModel: ObservableObject {
    @Published var didCopy = false
    @Published var showCircleShareSheet = false
    @Published var showEditSheet = false

    func currentEntry(fallback entry: JournalReflectionEntry, journalStore: ReflectionJournalStore) -> JournalReflectionEntry {
        journalStore.entry(with: entry.id) ?? entry
    }

    func session(for entry: JournalReflectionEntry, aiSessionStore: AIReflectionSessionStore) -> AIReflectionSession? {
        aiSessionStore.session(for: entry)
    }

    func copyReflection(_ entry: JournalReflectionEntry, journalStore: ReflectionJournalStore) {
        UIPasteboard.general.string = journalStore.shareText(for: entry)
        didCopy = true
    }

    func delete(_ entry: JournalReflectionEntry, journalStore: ReflectionJournalStore, aiSessionStore: AIReflectionSessionStore) {
        journalStore.delete(entry, aiSessionStore: aiSessionStore)
    }

    func questStatusText(for entry: JournalReflectionEntry, questStore: QuestStore) -> String {
        guard let quest = questStore.quest(for: entry) else {
            return "Not added to next actions"
        }

        switch quest.status {
        case .active:
            return "Active next action"
        case .completed:
            return "Completed"
        case .skipped:
            return "Skipped"
        }
    }

    func complete(_ quest: Quest, questStore: QuestStore) {
        questStore.complete(quest)
    }

    func skip(_ quest: Quest, questStore: QuestStore) {
        questStore.skip(quest)
    }

    func activateSuggestedQuest(from entry: JournalReflectionEntry, questStore: QuestStore) {
        _ = questStore.activateSuggestedQuest(from: entry)
    }
}
