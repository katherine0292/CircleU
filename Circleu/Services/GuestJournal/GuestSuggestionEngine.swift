import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

/// A reflection suggestion before the person accepts, edits or removes it.
nonisolated struct GuestReflectionSuggestion: Equatable, Sendable {
    var summary: String
    var feeling: String
    var insight: String
    var nextStep: String
    var source: GuestSuggestionSource
}

/// One wording option for Practice.
nonisolated struct GuestWordingOption: Equatable, Sendable, Identifiable {
    var id: String { tone }
    var tone: String
    var text: String
}

/// Up to three options and where they came from.
nonisolated struct GuestWordingSuggestions: Equatable, Sendable {
    var options: [GuestWordingOption]
    var source: GuestSuggestionSource
}

nonisolated enum GuestSuggestionError: Error, Equatable { case noWords }

/// Opt-in suggestions, made on this iPhone only. Injected so tests and UI tests are deterministic.
protocol GuestSuggesting {
    func reflection(for words: String) async throws -> GuestReflectionSuggestion
    func wordingOptions(situation: String, goal: String, draft: String) async throws -> GuestWordingSuggestions
}

extension GuestSuggestionSource {
    /// Said next to every suggestion, so guided prompts are never mistaken for a personal analysis.
    var label: String {
        switch self {
        case .onDevice: "Suggested on this iPhone by Apple Intelligence. Edit or remove anything."
        case .guided: "Guided prompts, not a personal analysis. Edit or remove anything."
        }
    }
}

/// Apple Intelligence's on-device model when this phone has it; otherwise the original app's
/// local reflection engine and built-in wording prompts. The original cloud (Gemini) path is not
/// used: nothing leaves the phone.
struct LocalFirstSuggestionEngine: GuestSuggesting {
    /// Debug UI tests set this to skip the model and get predictable results.
    var guidedOnly = false

    func reflection(for words: String) async throws -> GuestReflectionSuggestion {
        let clean = words.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { throw GuestSuggestionError.noWords }
        #if canImport(FoundationModels)
        if !guidedOnly, #available(iOS 26.0, *), case .available = SystemLanguageModel.default.availability,
           let result = try? await AppleIntelligenceReflectionEngine(fallback: NoFallbackEngine())
               .analyze(transcript: clean, durationSeconds: 0) {
            return Self.suggestion(from: result, source: .onDevice)
        }
        #endif
        return Self.suggestion(from: try await LocalReflectionEngine().analyze(transcript: clean, durationSeconds: 0),
                               source: .guided)
    }

    func wordingOptions(situation: String, goal: String, draft: String) async throws -> GuestWordingSuggestions {
        #if canImport(FoundationModels)
        if !guidedOnly, #available(iOS 26.0, *), case .available = SystemLanguageModel.default.availability,
           let options = try? await Self.modelWordingOptions(situation: situation, goal: goal, draft: draft),
           !options.isEmpty {
            return GuestWordingSuggestions(options: options, source: .onDevice)
        }
        #endif
        return GuestWordingSuggestions(options: Self.guidedWordingOptions(situation: situation, goal: goal, draft: draft),
                                       source: .guided)
    }

    private static func suggestion(from result: AIReflectionResult, source: GuestSuggestionSource)
        -> GuestReflectionSuggestion {
        GuestReflectionSuggestion(summary: result.summary, feeling: result.emotion, insight: result.insight,
                                  nextStep: result.suggestedQuest, source: source)
    }

    /// Three plain-language tones, built only from what the person typed.
    static func guidedWordingOptions(situation: String, goal: String, draft: String) -> [GuestWordingOption] {
        func trimmed(_ text: String) -> String {
            text.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: ".!?"))
        }
        func lowerFirst(_ text: String) -> String { text.prefix(1).lowercased() + text.dropFirst() }
        let topic = trimmed(situation).isEmpty ? "something that’s been on my mind" : lowerFirst(trimmed(situation))
        let ask = trimmed(goal).isEmpty ? "work out what would help" : lowerFirst(trimmed(goal))
        let core = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        let middle = core.isEmpty ? "" : " " + core
        return [
            GuestWordingOption(tone: "Gentle", text: "Hi, could we talk about \(topic)?\(middle) I’d really like to \(ask)."),
            GuestWordingOption(tone: "Clear", text: "I’d like to talk about \(topic).\(middle) What I’m hoping for is to \(ask). Does that work for you?"),
            GuestWordingOption(tone: "Firm", text: "I need to raise \(topic).\(middle) It matters to me that we \(ask). Can we agree on that?"),
        ]
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private static func modelWordingOptions(situation: String, goal: String, draft: String) async throws
        -> [GuestWordingOption] {
        let session = LanguageModelSession(instructions: """
            You help someone find their own words for a difficult conversation. Be warm, plain and brief. \
            Never invent facts, diagnose, or pressure. Return only valid JSON.
            """)
        let prompt = """
            Write three short message options the person could send, in these tones: Gentle, Clear, Firm.
            Use only the details below. Keep each under 60 words.
            Return exactly: [{"tone": "Gentle", "text": ""}, {"tone": "Clear", "text": ""}, {"tone": "Firm", "text": ""}]
            Situation: \(situation)
            Goal: \(goal)
            Their draft: \(draft)
            """
        let response = try await session.respond(to: prompt).content
        // Malformed output (for example "] … [") must never trap.
        guard let start = response.firstIndex(of: "["), let end = response.lastIndex(of: "]"), start < end,
              let data = String(response[start...end]).data(using: .utf8) else { return [] }
        struct Option: Decodable { let tone: String; let text: String }
        return try JSONDecoder().decode([Option].self, from: data)
            .filter { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .prefix(3)
            .map { GuestWordingOption(tone: $0.tone, text: $0.text) }
    }
    #endif
}

/// Makes the on-device engine report failure instead of falling back silently, so the source
/// label stays honest.
private struct NoFallbackEngine: ReflectionAnalyzing {
    let displayName = "None"
    let availabilityMessage: String? = nil
    func analyze(transcript: String, durationSeconds: Int) async throws -> AIReflectionResult {
        throw ReflectionEngineError.invalidModelResponse
    }
}
