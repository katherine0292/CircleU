import Combine
import Foundation

/// The Write screen's microphone. Dictated words go into the editable draft after anything already
/// typed; nothing is saved until the person taps Save. Typing stays available whatever happens.
@MainActor
final class GuestDictationViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case requestingAccess
        case listening
        /// Stop was tapped; waiting for the recogniser's final words.
        case finishing
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var message: String?
    /// Access was refused; the screen offers a link to Settings.
    @Published private(set) var needsSettings = false

    static let deniedMessage = "Dictation needs microphone and speech recognition access. Turn them on in Settings, or keep typing."
    static let onDeviceUnavailableMessage = "On-device dictation isn’t available for your language on this iPhone. You can keep typing."
    static let couldNotStartMessage = "Dictation couldn’t start. You can keep typing."
    static let interruptedMessage = "Dictation stopped. Your words so far are kept."
    static let failedMessage = "Dictation stopped unexpectedly. Your words so far are kept."

    private let journal: GuestJournalViewModel
    private let engine: any GuestDictationEngine
    /// The draft before this dictation started, restored by Cancel.
    private var textBefore = ""
    /// `textBefore` plus a space when needed; dictated words follow it.
    private var prefix = ""
    /// Ignores events from a dictation that was cancelled or replaced.
    private var generation = 0

    init(journal: GuestJournalViewModel, engine: any GuestDictationEngine) {
        self.journal = journal
        self.engine = engine
    }

    /// While dictating, the editor is read-only so spoken and typed words can't interleave.
    var isActive: Bool { state != .idle }

    func toggle() async {
        if state == .idle { await start() } else { stop() }
    }

    func start() async {
        guard state == .idle else { return }
        message = nil
        needsSettings = false
        state = .requestingAccess
        generation += 1
        let current = generation
        let access = await engine.requestAccess()
        guard generation == current, state == .requestingAccess else { return } // Cancelled meanwhile.
        switch access {
        case .granted:
            break
        case .speechDenied, .microphoneDenied:
            end(with: Self.deniedMessage)
            needsSettings = true
            return
        case .onDeviceUnavailable:
            end(with: Self.onDeviceUnavailableMessage)
            return
        }
        let events: AsyncStream<GuestDictationEvent>
        do {
            events = try engine.start()
        } catch {
            end(with: Self.couldNotStartMessage)
            return
        }
        textBefore = journal.draft
        let needsSpace = !textBefore.isEmpty && !(textBefore.last?.isWhitespace ?? true)
        prefix = textBefore + (needsSpace ? " " : "")
        state = .listening
        Task { [weak self] in
            for await event in events {
                guard let self, self.generation == current else { return }
                self.handle(event)
            }
            guard let self, self.generation == current else { return }
            self.state = .idle
        }
    }

    /// Stop: keep what was said and wait briefly for the final words.
    func stop() {
        switch state {
        case .listening:
            state = .finishing
            engine.finish()
        case .requestingAccess:
            generation += 1
            state = .idle
        case .idle, .finishing:
            break
        }
    }

    /// Cancel: discard this dictation's words and keep what was typed before it.
    func cancel() {
        guard state != .idle else { return }
        let wasDictating = state == .listening || state == .finishing
        generation += 1
        engine.cancel()
        if wasDictating { journal.draft = textBefore }
        state = .idle
    }

    /// The app left the foreground or the screen closed: stop at once, keeping the words so far.
    func interrupt() {
        guard state != .idle else { return }
        let wasListening = state == .listening
        generation += 1
        engine.cancel()
        state = .idle
        if wasListening { message = Self.interruptedMessage }
    }

    func dismissMessage() {
        message = nil
        needsSettings = false
    }

    private func handle(_ event: GuestDictationEvent) {
        switch event {
        case .transcript(let words, _):
            if !words.isEmpty { journal.draft = prefix + words }
        case .interrupted:
            message = Self.interruptedMessage
        case .failed:
            message = Self.failedMessage
        }
    }

    private func end(with message: String) {
        self.message = message
        state = .idle
    }
}
