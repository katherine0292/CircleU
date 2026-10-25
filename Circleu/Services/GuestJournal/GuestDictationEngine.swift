import AVFoundation
import Foundation
import Speech

/// What the recogniser reports while listening. The stream finishes after a final transcript,
/// an interruption or a failure.
enum GuestDictationEvent: Equatable, Sendable {
    case transcript(String, isFinal: Bool)
    /// A call, Siri, another app or a route change took the microphone.
    case interrupted
    case failed
}

enum GuestDictationAccess: Equatable, Sendable {
    case granted
    case speechDenied
    case microphoneDenied
    /// This phone can't recognise the current language on-device, so dictation is off.
    case onDeviceUnavailable
}

enum GuestDictationError: Error { case unavailable }

/// Speech-to-text for the Write screen. Injected so the view model can be tested without audio.
@MainActor
protocol GuestDictationEngine: AnyObject {
    func requestAccess() async -> GuestDictationAccess
    /// Starts listening. Transcripts arrive on the returned stream until it finishes.
    func start() throws -> AsyncStream<GuestDictationEvent>
    /// Stops listening and lets the recogniser deliver its final text, then finishes the stream.
    func finish()
    /// Stops at once; the stream finishes without a final text.
    func cancel()
}

/// On-device dictation with Apple's Speech framework, adapted from the original `VoiceRecorder`.
/// Audio goes from the microphone straight to the recogniser: it is never written to a file, and
/// `requiresOnDeviceRecognition` keeps it from being sent to Apple's servers. Nothing here
/// touches Firebase or any CircleU service.
final class SpeechDictationEngine: GuestDictationEngine {
    private let recognizer: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var continuation: AsyncStream<GuestDictationEvent>.Continuation?
    private var observers: [NSObjectProtocol] = []
    private var isFinishing = false
    private var finishDeadline: Task<Void, Never>?

    init(locale: Locale = .current) {
        recognizer = SFSpeechRecognizer(locale: locale)
    }

    func requestAccess() async -> GuestDictationAccess {
        guard recognizer?.supportsOnDeviceRecognition == true else { return .onDeviceUnavailable }
        guard await Self.requestSpeechAuthorization() == .authorized else { return .speechDenied }
        return await AVAudioApplication.requestRecordPermission() ? .granted : .microphoneDenied
    }

    func start() throws -> AsyncStream<GuestDictationEvent> {
        guard continuation == nil, let recognizer, recognizer.supportsOnDeviceRecognition,
              recognizer.isAvailable else { throw GuestDictationError.unavailable }
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.requiresOnDeviceRecognition = true // Never fall back to server recognition.
        request.shouldReportPartialResults = true
        request.addsPunctuation = true

        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else {
            Self.deactivate(session)
            throw GuestDictationError.unavailable
        }
        input.installTap(onBus: 0, bufferSize: 1024, format: format, block: Self.tap(feeding: request))
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            input.removeTap(onBus: 0)
            Self.deactivate(session)
            throw error
        }

        let (stream, continuation) = AsyncStream.makeStream(of: GuestDictationEvent.self)
        self.continuation = continuation
        self.request = request
        isFinishing = false
        task = recognizer.recognitionTask(with: request,
                                          resultHandler: Self.resultHandler { [weak self] in self?.receive($0) })
        observeInterruptions()
        return stream
    }

    func finish() {
        guard continuation != nil, !isFinishing else { return }
        isFinishing = true
        stopAudio()
        request?.endAudio()
        // The final result normally arrives within a second; don't wait for ever.
        finishDeadline = Task { [weak self] in
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            self?.task?.cancel()
            self?.tearDown()
        }
    }

    func cancel() {
        task?.cancel()
        tearDown()
    }

    private func receive(_ event: GuestDictationEvent) {
        guard let continuation else { return } // Late callbacks after teardown.
        switch event {
        case .transcript(let text, let isFinal):
            continuation.yield(.transcript(text, isFinal: isFinal))
            if isFinal { tearDown() }
        case .failed where isFinishing:
            tearDown() // e.g. "no speech detected" after Stop: not a failure.
        case .failed, .interrupted:
            continuation.yield(event)
            task?.cancel()
            tearDown()
        }
    }

    private func observeInterruptions() {
        let center = NotificationCenter.default
        let interrupted: @Sendable (Notification) -> Void = { [weak self] _ in
            MainActor.assumeIsolated { self?.receive(.interrupted) }
        }
        observers = [
            center.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main,
                               using: interrupted),
            center.addObserver(forName: AVAudioSession.mediaServicesWereResetNotification, object: nil,
                               queue: .main, using: interrupted),
            center.addObserver(forName: .AVAudioEngineConfigurationChange, object: audioEngine, queue: .main,
                               using: interrupted),
        ]
    }

    private func stopAudio() {
        if audioEngine.isRunning { audioEngine.stop() }
        audioEngine.inputNode.removeTap(onBus: 0)
    }

    private func tearDown() {
        finishDeadline?.cancel()
        finishDeadline = nil
        stopAudio()
        observers.forEach(NotificationCenter.default.removeObserver)
        observers = []
        request = nil
        task = nil
        isFinishing = false
        continuation?.finish()
        continuation = nil
        Self.deactivate(AVAudioSession.sharedInstance())
    }

    private static func deactivate(_ session: AVAudioSession) {
        try? session.setActive(false, options: .notifyOthersOnDeactivation)
    }

    // The callbacks below run on audio and Speech framework queues, so they're built outside
    // the main actor and hop back to it in order.

    private nonisolated static func requestSpeechAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0) }
        }
    }

    private nonisolated static func tap(feeding request: SFSpeechAudioBufferRecognitionRequest) -> AVAudioNodeTapBlock {
        { buffer, _ in request.append(buffer) }
    }

    private nonisolated static func resultHandler(
        _ deliver: @escaping @MainActor (GuestDictationEvent) -> Void
    ) -> @Sendable (SFSpeechRecognitionResult?, Error?) -> Void {
        { result, error in
            let event: GuestDictationEvent? = if let result {
                .transcript(result.bestTranscription.formattedString, isFinal: result.isFinal)
            } else if error != nil {
                .failed
            } else {
                nil
            }
            guard let event else { return }
            DispatchQueue.main.async { MainActor.assumeIsolated { deliver(event) } }
        }
    }
}
