import Combine
import Foundation

@MainActor
final class RecordingViewModel: ObservableObject {
    @Published var recorder: VoiceRecorder
    @Published var manualTranscript = ""
    @Published var showReflection = false
    @Published var showSaveConfirmation = false
    @Published var pendingEntry: JournalReflectionEntry?
    @Published var pendingSession: AIReflectionSession?
    @Published var savedEntry: JournalReflectionEntry?
    @Published var isAnalyzing = false
    @Published var analysisMessage: String?

    let engine: any ReflectionAnalyzing

    private var analysisTask: Task<Void, Never>?
    private var sessionRunner: ReflectionSessionRunner
    private var cancellables = Set<AnyCancellable>()

    convenience init() {
        self.init(
            recorder: VoiceRecorder(),
            engine: ReflectionEngineFactory.makeDefault(),
            sessionRunner: ReflectionSessionRunner()
        )
    }

    init(recorder: VoiceRecorder, engine: any ReflectionAnalyzing, sessionRunner: ReflectionSessionRunner) {
        self.recorder = recorder
        self.engine = engine
        self.sessionRunner = sessionRunner

        recorder.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    var subtitle: String {
        if isAnalyzing {
            return "Apple Intelligence is creating your reflection."
        }

        if recorder.isTypedFallbackAvailable {
            return "Voice is not ready, but typing works. Your reflection can still continue."
        }

        if let message = recorder.errorMessage {
            return message
        }

        if let message = engine.availabilityMessage {
            return message
        }

        return "Speak naturally. Your transcript stays on this device."
    }

    var effectiveTranscript: String {
        let liveTranscript = recorder.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        if !liveTranscript.isEmpty {
            return liveTranscript
        }

        return manualTranscript.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var transcriptQuality: TranscriptQuality {
        TranscriptQuality.evaluate(effectiveTranscript)
    }

    var canFinish: Bool {
        !isAnalyzing && transcriptQuality.isReady
    }

    var finishActionTitle: String {
        if isAnalyzing {
            return "WAIT"
        }

        return canFinish ? "FINISH" : "TYPE"
    }

    var formattedElapsedTime: String {
        formattedTime(recorder.elapsedSeconds)
    }

    func start() {
        recorder.start()
    }

    func stop() {
        analysisTask?.cancel()
        analysisTask = nil
        recorder.stop()
    }

    func togglePause() {
        recorder.togglePause()
    }

    func restartRecording() {
        analysisTask?.cancel()
        analysisTask = nil
        pendingEntry = nil
        pendingSession = nil
        savedEntry = nil
        analysisMessage = nil
        manualTranscript = ""
        showReflection = false
        showSaveConfirmation = false
        isAnalyzing = false
        recorder.resetSession()
        recorder.start()
    }

    func resetForAnotherRecording() {
        restartRecording()
    }

    func finishRecording() {
        guard canFinish else {
            analysisMessage = transcriptQuality.guidance
            return
        }

        analysisTask?.cancel()
        recorder.stop()
        analysisMessage = nil

        let transcript = effectiveTranscript
        let durationSeconds = recorder.elapsedSeconds
        let reflectionSource: AIReflectionSource = recorder.transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? .typedFallback
            : .recording

        analysisTask = Task { [weak self] in
            guard let self else { return }
            self.isAnalyzing = true

            let run = await self.sessionRunner.analyze(
                transcript: transcript,
                durationSeconds: durationSeconds,
                source: reflectionSource,
                engine: self.engine
            )
            guard !Task.isCancelled else { return }

            guard let result = run.result else {
                self.isAnalyzing = false
                self.analysisTask = nil
                self.analysisMessage = run.attempt.errorMessage ?? "AI analysis failed. Please try again."
                return
            }

            let entry = JournalReflectionEntry(
                createdAt: run.attempt.createdAt,
                durationSeconds: durationSeconds,
                transcript: transcript,
                engineName: run.attempt.engineName,
                result: result,
                sessionID: run.session.id
            )

            self.pendingSession = run.session
            self.pendingEntry = entry
            self.isAnalyzing = false
            self.analysisTask = nil
            self.showReflection = true
        }
    }

    func applySessionChange(_ session: AIReflectionSession?) {
        pendingSession = session
        if let selectedResult = session?.selectedResult,
           let selectedAttempt = session?.selectedAttempt,
           selectedAttempt.status == .succeeded {
            pendingEntry?.result = selectedResult
            pendingEntry?.engineName = selectedAttempt.engineName
            pendingEntry?.sessionID = session?.id
        }
    }

    func savePendingEntry(
        _ entry: JournalReflectionEntry,
        journalStore: ReflectionJournalStore,
        aiSessionStore: AIReflectionSessionStore
    ) {
        persistPendingSession(for: entry, aiSessionStore: aiSessionStore)
        journalStore.add(entry)
        savedEntry = entry
        pendingEntry = nil
        pendingSession = nil
        showReflection = false
    }

    func showConfirmationAfterSave() {
        showSaveConfirmation = true
    }

    func clearSaveConfirmation() {
        showSaveConfirmation = false
    }

    private func persistPendingSession(for entry: JournalReflectionEntry, aiSessionStore: AIReflectionSessionStore) {
        guard let sessionID = entry.sessionID else { return }

        if var session = pendingSession, session.id == sessionID {
            session.entryID = entry.id
            session.engineName = entry.engineName
            session.updatedAt = Date()
            aiSessionStore.upsert(session)
            return
        }

        aiSessionStore.link(sessionID: sessionID, to: entry.id)
    }

    private func formattedTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
