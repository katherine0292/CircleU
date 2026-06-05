import Foundation

struct DailyReflectionBetaState: Equatable {
    let hasCompletedToday: Bool
    let nextActionTitle: String
    let nextActionSubtitle: String
    let practiceProgressText: String

    static func make(
        entries: [JournalReflectionEntry],
        quests: [Quest],
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> DailyReflectionBetaState {
        let hasCompletedToday = entries.contains { calendar.isDate($0.createdAt, inSameDayAs: now) }
        let activePractice = quests.first { $0.status == .active }
        let completedCount = quests.filter { $0.status == .completed }.count

        if let activePractice {
            return DailyReflectionBetaState(
                hasCompletedToday: hasCompletedToday,
                nextActionTitle: "Continue today's practice",
                nextActionSubtitle: activePractice.detail,
                practiceProgressText: "\(completedCount) completed"
            )
        }

        if hasCompletedToday {
            return DailyReflectionBetaState(
                hasCompletedToday: true,
                nextActionTitle: "Reflect again if something changed",
                nextActionSubtitle: "You already saved a reflection today. Add another if a new moment needs attention.",
                practiceProgressText: "\(completedCount) completed"
            )
        }

        return DailyReflectionBetaState(
            hasCompletedToday: false,
            nextActionTitle: "Start today's reflection",
            nextActionSubtitle: "Record or type one honest check-in to create your next AI-guided practice.",
            practiceProgressText: "\(completedCount) completed"
        )
    }
}
