import Combine
import Foundation

@MainActor
final class TipsViewModel: ObservableObject {
    func sourceEntry(for quest: Quest, journalStore: ReflectionJournalStore) -> JournalReflectionEntry? {
        guard let sourceEntryID = quest.sourceEntryID else { return nil }
        return journalStore.entry(with: sourceEntryID)
    }

    func complete(_ quest: Quest, questStore: QuestStore) {
        questStore.complete(quest)
    }

    func restart(_ quest: Quest, questStore: QuestStore) {
        questStore.reactivate(quest)
    }
}
