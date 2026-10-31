import Combine
import Foundation

/// Speech is reviewed separately. Only the view's explicit Use text action changes a practice field.
@MainActor
final class GuestVoiceReviewModel: ObservableObject {
    enum State { case idle, requesting, listening, finishing, review }
    @Published private(set) var state: State = .idle
    @Published var transcript = ""
    @Published private(set) var error: String?
    @Published private(set) var needsSettings = false
    private let engine: any GuestDictationEngine
    private var generation = 0
    private var task: Task<Void, Never>?
    var isActive: Bool { state == .requesting || state == .listening || state == .finishing }
    var canUse: Bool { !isActive && !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    init(engine: any GuestDictationEngine) { self.engine = engine }

    func start() async {
        guard !isActive else { return }
        generation += 1
        let current = generation
        error = nil
        needsSettings = false
        state = .requesting
        let access = await engine.requestAccess()
        guard generation == current else { return }
        guard access == .granted else {
            state = .review
            needsSettings = access == .speechDenied || access == .microphoneDenied
            error = needsSettings ? "Allow microphone and speech access in Settings, or type instead."
                : "Voice isn’t available on this phone in this language. You can type instead."
            return
        }
        do {
            let stream = try engine.start()
            let prefix = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
            state = .listening
            task = Task { [weak self] in
                for await event in stream {
                    guard let self, self.generation == current, !Task.isCancelled else { return }
                    switch event {
                    case .transcript(let words, let final):
                        self.transcript = [prefix, words].filter { !$0.isEmpty }.joined(separator: "\n")
                        if final { self.state = .review }
                    case .interrupted:
                        self.error = "Recording stopped. Review your words or keep typing."
                        self.state = .review
                    case .failed:
                        self.error = "Voice stopped working. Review your words or keep typing."
                        self.state = .review
                    }
                }
                guard let self, self.generation == current else { return }
                self.state = .review
            }
        } catch {
            engine.cancel()
            state = .review
            self.error = "Voice couldn’t start. Try again or type instead."
        }
    }

    func stop() {
        guard state == .listening else { return }
        state = .finishing
        engine.finish()
    }

    /// Backgrounding cancels the microphone but keeps partial words for review.
    func interrupt() {
        guard isActive else { return }
        cancel()
        error = "Recording stopped. Review your words or keep typing."
    }

    func cancel() {
        generation += 1
        task?.cancel()
        task = nil
        engine.cancel()
        state = .review
    }
}
