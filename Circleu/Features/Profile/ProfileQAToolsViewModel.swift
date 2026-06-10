import Combine
import Foundation
import UIKit

@MainActor
final class ProfileQAToolsViewModel: ObservableObject {
    @Published var showAILab = false
    @Published var showResetConfirmation = false
    @Published var statusMessage = "Ready for local phone testing."

    func qaExport(
        hasCompletedOnboarding: Bool,
        journalStore: ReflectionJournalStore,
        profileStore: UserProfileStore,
        circleStore: CircleStore,
        questStore: QuestStore,
        tipsPracticeStore: TipsPracticeStore,
        aiSessionStore: AIReflectionSessionStore
    ) -> String {
        """
        Circleu QA Export

        \(profileSummary(journalStore: journalStore, profileStore: profileStore, circleStore: circleStore, questStore: questStore))

        Local State
        Onboarding complete: \(hasCompletedOnboarding)
        Total AI sessions: \(aiSessionStore.sessions.count)
        Total quests: \(questStore.quests.count)
        Active quests: \(questStore.activeQuests.count)
        Total tips practice sessions: \(tipsPracticeStore.recentSessions.count)
        Total circles: \(circleStore.circles.count)
        Total posts: \(circleStore.posts.count)

        \(journalStore.exportText(includePrivateMetadata: true))

        \(aiSessionStore.exportText())
        """
    }

    func currentProgress(journalStore: ReflectionJournalStore, questStore: QuestStore) -> AppProgressSnapshot {
        ProgressEngine.snapshot(entries: journalStore.entries, quests: questStore.quests)
    }

    func profileSummary(
        journalStore: ReflectionJournalStore,
        profileStore: UserProfileStore,
        circleStore: CircleStore,
        questStore: QuestStore
    ) -> String {
        profileStore.summaryText(
            progress: currentProgress(journalStore: journalStore, questStore: questStore),
            circleCount: circleStore.circles.count,
            supportPostCount: circleStore.posts.count
        )
    }

    func copyQAExport(_ export: String) {
        UIPasteboard.general.string = export
        statusMessage = "Copied QA export to clipboard."
    }

    func seedDemoData(
        hasCompletedOnboarding: inout Bool,
        journalStore: ReflectionJournalStore,
        profileStore: UserProfileStore,
        circleStore: CircleStore,
        questStore: QuestStore,
        tipsPracticeStore: TipsPracticeStore,
        rewardsStore: RewardsStore,
        aiSessionStore: AIReflectionSessionStore
    ) {
        let referenceDate = Date()
        let entries = ReflectionJournalStore.demoEntries(referenceDate: referenceDate)
        profileStore.seedDemoProfile()
        journalStore.replaceAll(with: entries)
        aiSessionStore.seedDemoData(entries: entries)
        questStore.seedDemoData(entries: entries, referenceDate: referenceDate)
        circleStore.seedDemoData(entries: entries, referenceDate: referenceDate)
        tipsPracticeStore.resetAll()
        rewardsStore.resetToSeed()
        hasCompletedOnboarding = true
        statusMessage = "Seeded repeatable demo data for phone testing."
    }

    func resetLocalData(
        hasCompletedOnboarding: inout Bool,
        journalStore: ReflectionJournalStore,
        profileStore: UserProfileStore,
        circleStore: CircleStore,
        questStore: QuestStore,
        tipsPracticeStore: TipsPracticeStore,
        rewardsStore: RewardsStore,
        aiSessionStore: AIReflectionSessionStore
    ) {
        profileStore.reset()
        journalStore.reset()
        aiSessionStore.reset()
        questStore.reset()
        tipsPracticeStore.resetAll()
        rewardsStore.reset()
        circleStore.reset(seedStarterSpaces: false)
        hasCompletedOnboarding = false
        statusMessage = "Cleared local data. Relaunch or close this sheet to see onboarding."
    }

    var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ??
        "Circleu"
    }

    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1"
    }

    var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "Unknown"
    }
}
