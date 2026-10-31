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
    func conversationOptions(situation: String, goal: String, draft: String,
                             conversation: GuestPracticeConversation) async throws -> GuestWordingSuggestions
}

extension GuestSuggesting {
    func conversationOptions(situation: String, goal: String, draft: String,
                             conversation: GuestPracticeConversation) async throws -> GuestWordingSuggestions {
        try await wordingOptions(situation: situation, goal: goal, draft: draft)
    }
}

extension GuestSuggestionSource {
    /// Said next to every suggestion, so guided prompts are never mistaken for a personal analysis.
    var label: String {
        switch self {
        case .onDevice: "Suggested on this iPhone by Apple Intelligence. Edit or remove anything."
        case .guided: "Guided prompts, not a personal analysis. Edit or remove anything."
        case .imported: "From the earlier CircleU app. Edit or remove anything."
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

    func conversationOptions(situation: String, goal: String, draft: String,
                             conversation: GuestPracticeConversation) async throws -> GuestWordingSuggestions {
        #if canImport(FoundationModels)
        if !guidedOnly, #available(iOS 26.0, *), case .available = SystemLanguageModel.default.availability,
           let options = try? await Self.modelWordingOptions(
            situation: situation + "\n" + conversation.suggestionContext,
            goal: goal, draft: draft), !options.isEmpty {
            return GuestWordingSuggestions(options: options, source: .onDevice)
        }
        #endif
        // Guided wording never interpolates someone else's reply or model metadata as the user's voice.
        let options: [GuestWordingOption]
        let latestAdditions = conversation.turns.reversed().prefix { $0.kind != .wording }
        let hasReply = latestAdditions.contains { $0.kind == .theirReply }
        if !hasReply {
            options = Self.guidedWordingOptions(situation: situation, goal: goal, draft: draft)
        } else {
            let core = draft.trimmingCharacters(in: .whitespacesAndNewlines)
            let middle = core.isEmpty ? "Could we agree on the next step?" : core
            options = [
                .init(tone: "Gentle", text: "Thanks for getting back to me. \(middle)"),
                .init(tone: "Clear", text: "Thanks for your reply. \(middle)"),
                .init(tone: "Firm", text: "I’d like us to be clear about this. \(middle)")
            ]
        }
        let preferred = conversation.tone == "Soft" ? "Gentle" : conversation.tone == "Firm" ? "Firm" : "Clear"
        return GuestWordingSuggestions(options: options.filter { $0.tone == preferred }
            + options.filter { $0.tone != preferred }, source: .guided)
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
        return validatedOptions(try JSONDecoder().decode([Option].self, from: data).map { ($0.tone, $0.text) })
    }
    #endif

    /// The tones the app asks for, in the order it shows them.
    static let supportedTones = ["Gentle", "Clear", "Firm"]
    static let maximumOptionWords = 60

    /// Model output is only used when it keeps the contract: a known tone (any case), each tone at
    /// most once, non-empty text within the word limit. Anything else is dropped; nothing is left
    /// for the engine's guided fallback when none survive. Option identity stays the tone, which
    /// this guarantees to be unique.
    static func validatedOptions(_ raw: [(tone: String, text: String)]) -> [GuestWordingOption] {
        var seen: Set<String> = []
        var options: [GuestWordingOption] = []
        for (rawTone, rawText) in raw {
            let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let tone = supportedTones.first(where: { $0.caseInsensitiveCompare(rawTone.trimmingCharacters(in: .whitespacesAndNewlines)) == .orderedSame }),
                  !seen.contains(tone), !text.isEmpty,
                  text.split { $0.isWhitespace }.count <= maximumOptionWords else { continue }
            seen.insert(tone)
            options.append(GuestWordingOption(tone: tone, text: text))
        }
        return options
    }
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
