import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var selectedEntry: JournalReflectionEntry?

    let dailyPrompts = [
        "What feeling has been sitting with you today?",
        "What small moment changed your mood?",
        "What do you want to understand about yourself today?",
        "What would make tomorrow feel lighter?"
    ]

    func dailyPrompt(for profileStore: UserProfileStore) -> String {
        dailyPrompts[profileStore.dailyPromptIndex % dailyPrompts.count]
    }

    func greetingSubtitle(entries: [JournalReflectionEntry]) -> String {
        entries.isEmpty ? "Ready for your first check-in?" : "Your reflection space is ready."
    }

    func latestEmotionLabel(entries: [JournalReflectionEntry]) -> String {
        entries.first?.result.emotion ?? "Start"
    }

    func activeQuest(from questStore: QuestStore) -> Quest? {
        questStore.activeQuests.first
    }

    func activeQuestSupportText(activeQuest: Quest?) -> String {
        guard let activeQuest else {
            return "Save a reflection and Circleu will turn the insight into one small action."
        }

        return "Created \(relativeDateText(for: activeQuest.createdAt)). Complete it when the tips is done, or skip it if it no longer fits today."
    }

    func betaState(entries: [JournalReflectionEntry], quests: [Quest]) -> DailyReflectionBetaState {
        DailyReflectionBetaState.make(entries: entries, quests: quests)
    }

    func sourceEntry(for quest: Quest, entries: [JournalReflectionEntry]) -> JournalReflectionEntry? {
        guard let sourceEntryID = quest.sourceEntryID else { return nil }
        return entries.first { $0.id == sourceEntryID }
    }

    func progress(entries: [JournalReflectionEntry], quests: [Quest]) -> AppProgressSnapshot {
        ProgressEngine.snapshot(entries: entries, quests: quests)
    }

    func advanceDailyPrompt(profileStore: UserProfileStore) {
        profileStore.advanceDailyPrompt(totalPrompts: dailyPrompts.count)
    }

    func complete(_ quest: Quest, questStore: QuestStore) {
        questStore.complete(quest)
    }

    func skip(_ quest: Quest, questStore: QuestStore) {
        questStore.skip(quest)
    }

    private func relativeDateText(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
