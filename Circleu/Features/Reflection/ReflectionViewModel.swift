import Combine
import Foundation

@MainActor
final class ReflectionViewModel: ObservableObject {
    @Published var hasSaved = false
    @Published var draftEntry: JournalReflectionEntry?
    @Published var draftSession: AIReflectionSession?
    @Published var isRegenerating = false
    @Published var regenerateMessage: String?

    let engine: any ReflectionAnalyzing
    var onSave: ((JournalReflectionEntry, ReflectionSaveDestination) -> Void)?
    var onSessionChange: ((AIReflectionSession?) -> Void)?

    private var sessionRunner: ReflectionSessionRunner
    private var regenerateTask: Task<Void, Never>?

    convenience init(
        entry: JournalReflectionEntry? = nil,
        session: AIReflectionSession? = nil,
        onSessionChange: ((AIReflectionSession?) -> Void)? = nil,
        onSave: ((JournalReflectionEntry, ReflectionSaveDestination) -> Void)? = nil
    ) {
        self.init(
            entry: entry,
            session: session,
            engine: ReflectionEngineFactory.makeDefault(),
            sessionRunner: ReflectionSessionRunner(),
            onSessionChange: onSessionChange,
            onSave: onSave
        )
    }

    init(
        entry: JournalReflectionEntry?,
        session: AIReflectionSession?,
        engine: any ReflectionAnalyzing,
        sessionRunner: ReflectionSessionRunner,
        onSessionChange: ((AIReflectionSession?) -> Void)? = nil,
        onSave: ((JournalReflectionEntry, ReflectionSaveDestination) -> Void)? = nil
    ) {
        draftEntry = entry
        draftSession = session
        self.engine = engine
        self.sessionRunner = sessionRunner
        self.onSessionChange = onSessionChange
        self.onSave = onSave
    }

    var reflection: AIReflectionResult? {
        draftEntry?.result
    }

    var canEdit: Bool {
        !hasSaved && draftEntry != nil && !isRegenerating
    }

    var shareText: String {
        guard let reflection else {
            return "Circleu Reflection\n\nNo reflection is available yet."
        }

        return """
        Circleu Reflection

        \(reflection.title)
        Emotion: \(reflection.emotion)

        \(reflection.insight)

        "\(reflection.quote)"
        """
    }

    func saveEntry(to destination: ReflectionSaveDestination, questStore: QuestStore, onMissingEntry: () -> Void) {
        guard !hasSaved else { return }
        guard let draftEntry else {
            onMissingEntry()
            return
        }

        hasSaved = true
        questStore.addSuggestedQuest(from: draftEntry)
        
        let properties: [String: String] = [
            "destination": destination == .confirmation ? "confirmation" : "tips",
            "duration_seconds": "\(draftEntry.durationSeconds)",
            "engine_name": draftEntry.engineName,
            "confidence_score": String(format: "%.2f", draftEntry.result.confidenceScore)
        ]
        AnalyticsService.shared.track(event: "reflection_saved", properties: properties)
        
        onSave?(draftEntry, destination)
    }

    func regenerateReflection() {
        guard !hasSaved, let draftEntry, !isRegenerating else { return }

        regenerateTask?.cancel()
        isRegenerating = true
        regenerateMessage = nil

        regenerateTask = Task { [weak self] in
            guard let self else { return }
            let run = await self.sessionRunner.analyze(
                transcript: draftEntry.transcript,
                durationSeconds: draftEntry.durationSeconds,
                source: .journalRegeneration,
                engine: self.engine,
                existingSession: self.draftSession
            )
            guard !Task.isCancelled else { return }

            self.draftSession = run.session
            self.onSessionChange?(run.session)
            self.isRegenerating = false
            self.regenerateTask = nil

            if let result = run.result {
                self.draftEntry?.result = result
                self.draftEntry?.engineName = run.attempt.engineName
                self.draftEntry?.sessionID = run.session.id
                self.regenerateMessage = "Generated attempt \(run.session.attempts.count) with \(run.attempt.engineName)."
                
                AnalyticsService.shared.track(
                    event: "ai_reflection_regenerated",
                    properties: [
                        "engine_name": run.attempt.engineName,
                        "attempt_number": "\(run.session.attempts.count)",
                        "duration_seconds": "\(draftEntry.durationSeconds)",
                        "confidence_score": String(format: "%.2f", result.confidenceScore)
                    ]
                )
            } else {
                self.regenerateMessage = run.attempt.errorMessage ?? "AI regeneration failed. Please try again."
            }
        }
    }

    func cancelRegeneration() {
        regenerateTask?.cancel()
        regenerateTask = nil
    }
}
