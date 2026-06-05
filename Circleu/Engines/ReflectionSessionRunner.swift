import Foundation

struct ReflectionSessionRunResult {
    var session: AIReflectionSession
    var attempt: AIReflectionAttempt

    var result: AIReflectionResult? { attempt.result }
}

struct ReflectionSessionRunner {
    func analyze(
        transcript: String,
        durationSeconds: Int,
        source: AIReflectionSource,
        engine: any ReflectionAnalyzing,
        existingSession: AIReflectionSession? = nil
    ) async -> ReflectionSessionRunResult {
        let cleanTranscript = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        var session = existingSession ?? AIReflectionSession(
            engineName: engine.displayName,
            source: source,
            transcript: cleanTranscript,
            durationSeconds: durationSeconds
        )

        session.engineName = engine.displayName
        session.source = source
        session.transcript = cleanTranscript
        session.durationSeconds = durationSeconds
        session.updatedAt = Date()

        let analysisStartedAt = Date()
        let startTime = ContinuousClock.now

        do {
            let result = try await engine.analyze(
                transcript: cleanTranscript,
                durationSeconds: durationSeconds
            )
            let attempt = AIReflectionAttempt(
                createdAt: analysisStartedAt,
                engineName: engine.displayName,
                status: .succeeded,
                result: result,
                elapsedMilliseconds: elapsedMilliseconds(since: startTime)
            )
            session.attempts.append(attempt)
            session.selectedAttemptID = attempt.id
            session.engineName = attempt.engineName
            session.updatedAt = Date()

            return ReflectionSessionRunResult(session: session, attempt: attempt)
        } catch {
            let status: AIReflectionAttemptStatus = error is CancellationError || Task.isCancelled
                ? .cancelled
                : .failed
            let attempt = AIReflectionAttempt(
                createdAt: analysisStartedAt,
                engineName: engine.displayName,
                status: status,
                errorMessage: status == .failed ? error.localizedDescription : nil,
                elapsedMilliseconds: elapsedMilliseconds(since: startTime)
            )
            session.attempts.append(attempt)
            preserveSelectedSuccessfulAttempt(in: &session)
            session.updatedAt = Date()

            return ReflectionSessionRunResult(session: session, attempt: attempt)
        }
    }

    private func preserveSelectedSuccessfulAttempt(in session: inout AIReflectionSession) {
        let selectedAttempt: AIReflectionAttempt?
        if let selectedAttemptID = session.selectedAttemptID,
           let currentSelection = session.attempts.first(where: { $0.id == selectedAttemptID && $0.status == .succeeded }) {
            selectedAttempt = currentSelection
        } else {
            selectedAttempt = session.attempts.last(where: { $0.status == .succeeded })
            session.selectedAttemptID = selectedAttempt?.id
        }

        if let selectedAttempt {
            session.engineName = selectedAttempt.engineName
        } else {
            session.selectedAttemptID = nil
        }
    }

    private func elapsedMilliseconds(since startTime: ContinuousClock.Instant) -> Int {
        let duration = startTime.duration(to: ContinuousClock.now)
        let components = duration.components
        return Int(components.seconds * 1_000 + components.attoseconds / 1_000_000_000_000_000)
    }
}
