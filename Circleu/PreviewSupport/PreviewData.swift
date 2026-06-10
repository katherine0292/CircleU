import Foundation

@MainActor
enum PreviewData {
    static let referenceDate = Date(timeIntervalSince1970: 1_780_588_800)

    static var journalEntry: JournalReflectionEntry {
        journalEntries[0]
    }

    static var journalEntries: [JournalReflectionEntry] {
        ReflectionJournalStore.demoEntries(referenceDate: referenceDate)
    }

    static var activeQuest: Quest {
        Quest(
            title: "Try this next",
            detail: "Practice one direct sentence before your next conversation.",
            sourceEntryID: journalEntry.id,
            createdAt: referenceDate,
            status: .active
        )
    }

    static var completedQuest: Quest {
        Quest(
            title: "Completed tip",
            detail: "Record a short check-in after class.",
            sourceEntryID: journalEntries.last?.id,
            createdAt: referenceDate.addingTimeInterval(-86_400),
            completedAt: referenceDate,
            status: .completed
        )
    }

    static var tipsSession: TipsPracticeSession {
        TipsPracticeSession(
            createdAt: referenceDate,
            updatedAt: referenceDate,
            originalMessage: "I need to ask my teammate for help without sounding frustrated.",
            scene: .workplace,
            tone: .diplomatic,
            situation: "We have a project deadline tomorrow and I want to be clear but kind.",
            turns: [
                TipsPracticeTurn(
                    role: .user,
                    label: "Your message",
                    text: "Can you please send your part tonight? I am worried about the deadline.",
                    createdAt: referenceDate
                ),
                TipsPracticeTurn(
                    role: .coach,
                    label: "Coach",
                    text: "Good start. Lead with the shared goal, then ask for one specific next step.",
                    createdAt: referenceDate.addingTimeInterval(30)
                ),
                TipsPracticeTurn(
                    role: .simulatedPerson,
                    label: "Their reply",
                    text: "I can send a draft, but I might need more time for the final version.",
                    createdAt: referenceDate.addingTimeInterval(60)
                )
            ],
            coachOutput: TipsCoachOutput(
                suggestedPhrasing: "I want us to finish strong. Could you send a draft tonight so I can plan the final section?",
                whyItWorks: "It keeps the focus on the shared outcome, makes the request specific, and avoids blaming the other person.",
                simulatedReply: "Yes, I can send the draft after dinner.",
                roomReading: "They may be under pressure too, so ask for the smallest useful next step first.",
                replyOptions: [
                    TipsCoachReplyOption(label: "CLEAR", text: "Could you send a rough draft tonight so I can plan around it?"),
                    TipsCoachReplyOption(label: "KIND", text: "I know it has been busy. What part can you send tonight?")
                ]
            )
        )
    }

    static func tipsSetupViewModel() -> TipsPracticeViewModel {
        let viewModel = TipsPracticeViewModel()
        viewModel.message = "I need to ask my teammate for help without sounding frustrated."
        viewModel.situation = "We have a deadline tomorrow and I want to stay respectful."
        viewModel.scene = .workplace
        viewModel.toneValue = TipsPracticeTone.diplomatic.sliderValue
        return viewModel
    }

    static func tipsLiveCoachViewModel() -> TipsPracticeViewModel {
        let viewModel = TipsPracticeViewModel()
        viewModel.activeSession = tipsSession
        viewModel.scene = tipsSession.scene
        viewModel.toneValue = tipsSession.tone.sliderValue
        viewModel.situation = tipsSession.situation
        viewModel.mode = .liveCoach
        return viewModel
    }

    static func journalStore() -> ReflectionJournalStore {
        let store = ReflectionJournalStore(userDefaults: previewDefaults())
        store.replaceAll(with: journalEntries)
        return store
    }

    static func questStore() -> QuestStore {
        let store = QuestStore(userDefaults: previewDefaults())
        store.replaceAll(with: [activeQuest, completedQuest])
        return store
    }

    static func circleStore() -> CircleStore {
        let store = CircleStore(userDefaults: previewDefaults(), seedStarterSpaces: false)
        store.seedDemoData(entries: journalEntries, referenceDate: referenceDate)
        return store
    }

    static func tipsPracticeStore() -> TipsPracticeStore {
        let store = TipsPracticeStore(userDefaults: previewDefaults())
        store.activate(tipsSession)
        return store
    }

    static func aiSessionStore() -> AIReflectionSessionStore {
        let store = AIReflectionSessionStore(userDefaults: previewDefaults())
        store.seedDemoData(entries: journalEntries)
        return store
    }

    static func userProfileStore() -> UserProfileStore {
        let store = UserProfileStore(userDefaults: previewDefaults())
        store.updateDisplayName("Mike")
        return store
    }

    private static func previewDefaults() -> UserDefaults {
        let suiteName = "circleu.preview.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
