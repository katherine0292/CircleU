import Combine
import Foundation
import SwiftUI
import UIKit

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var showProfileEditor = false
    @Published var showQATools = false
    @Published var didCopySummary = false

    func progress(entries: [JournalReflectionEntry], quests: [Quest]) -> AppProgressSnapshot {
        ProgressEngine.snapshot(entries: entries, quests: quests)
    }

    func profileSummary(
        profileStore: UserProfileStore,
        progress: AppProgressSnapshot,
        circleCount: Int,
        supportPostCount: Int
    ) -> String {
        profileStore.summaryText(
            progress: progress,
            circleCount: circleCount,
            supportPostCount: supportPostCount
        )
    }

    func profileTitle(for progress: AppProgressSnapshot) -> String {
        if progress.level >= 5 { return "Steady Reflector" }
        if progress.entryCount >= 3 { return "Pattern Finder" }
        if progress.entryCount >= 1 { return "Voice Explorer" }
        return "New Voice Explorer"
    }

    func levelProgress(for progress: AppProgressSnapshot) -> CGFloat {
        let lowerBound = max(0, (progress.level - 1) * 100)
        let upperBound = max(progress.xpForNextLevel, lowerBound + 100)
        let value = CGFloat(progress.xp - lowerBound) / CGFloat(upperBound - lowerBound)
        return min(max(value, 0), 1)
    }

    func copySummary(_ summary: String) {
        UIPasteboard.general.string = summary
        didCopySummary = true
    }

    func complete(_ quest: Quest, questStore: QuestStore) {
        questStore.complete(quest)
    }

    func skip(_ quest: Quest, questStore: QuestStore) {
        questStore.skip(quest)
    }
}
