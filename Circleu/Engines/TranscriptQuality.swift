import Foundation

struct TranscriptQuality: Equatable {
    let wordCount: Int
    let characterCount: Int
    let isReady: Bool
    let guidance: String

    static func evaluate(_ transcript: String) -> TranscriptQuality {
        let clean = cleanedTranscript(transcript)

        let words = clean.split(separator: " ")
        let wordCount = words.count
        let characterCount = clean.count

        if clean.isEmpty {
            return TranscriptQuality(
                wordCount: 0,
                characterCount: 0,
                isReady: false,
                guidance: "Add a few words before finishing."
            )
        }

        if isRoughLowSignal(clean) {
            return TranscriptQuality(
                wordCount: wordCount,
                characterCount: characterCount,
                isReady: false,
                guidance: "Try again with one real moment, one feeling, and words you would be comfortable saving."
            )
        }

        if wordCount < 8 || characterCount < 32 {
            return TranscriptQuality(
                wordCount: wordCount,
                characterCount: characterCount,
                isReady: false,
                guidance: "Add one feeling, one moment, and what you want to understand."
            )
        }

        return TranscriptQuality(
            wordCount: wordCount,
            characterCount: characterCount,
            isReady: true,
            guidance: "Ready for AI reflection."
        )
    }

    static func cleanedTranscript(_ transcript: String) -> String {
        transcript
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func isRoughLowSignal(_ transcript: String) -> Bool {
        let words = normalizedWords(transcript)
        guard words.count >= 5 else { return false }

        let roughWordCount = words.filter { roughWords.contains($0) }.count
        guard roughWordCount > 0 else { return false }

        let fillerCount = words.filter { fillerWords.contains($0) }.count
        let fillerRatio = Double(fillerCount) / Double(words.count)
        let roughRatio = Double(roughWordCount) / Double(words.count)

        return fillerRatio >= 0.35 || roughRatio >= 0.20
    }

    /// Fewest words, not counting filler or swearing, that a typed journal entry needs before a
    /// reflection is asked for. Lower than `evaluate`'s spoken-transcript bar: a short typed
    /// sentence such as "I felt stressed before the group meeting" is enough to reflect on.
    static let minimumReflectionWords = 3
    /// The same bar for writing without spaces between words (for example Chinese or Japanese).
    static let minimumUnspacedReflectionCharacters = 6

    /// Whether a typed entry has enough to reflect on. Empty text, punctuation, filler ("um hello
    /// test") and swearing on their own don't count, so they never reach a reflection engine.
    static func hasEnoughToReflect(_ text: String) -> Bool {
        let words = normalizedWords(text).filter { !fillerWords.contains($0) && !roughWords.contains($0) }
        if words.count >= minimumReflectionWords { return true }
        let unspacedLetters = words.filter { $0.count > 1 && $0.unicodeScalars.contains(where: isUnspacedScript) }
            .reduce(0) { $0 + $1.count }
        return unspacedLetters >= minimumUnspacedReflectionCharacters
    }

    private static func isUnspacedScript(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.value {
        case 0x3040...0x30FF, 0x3400...0x4DBF, 0x4E00...0x9FFF, 0xF900...0xFAFF, 0x0E00...0x0E7F: true
        default: false
        }
    }

    static func containsRoughLanguage(_ transcript: String) -> Bool {
        normalizedWords(transcript).contains { roughWords.contains($0) }
    }

    static func asksWhetherResponseIsTooHarsh(_ transcript: String) -> Bool {
        let text = cleanedTranscript(transcript).lowercased()
        let hasResponseQuestion = text.contains("should i tell")
            || text.contains("should i say")
            || text.contains("should i reply")
            || text.contains("should i respond")
            || text.contains("is it ok")
            || text.contains("is it okay")

        let hasHarshnessConcern = text.contains("too rough")
            || text.contains("too harsh")
            || text.contains("too much")
            || text.contains("disrespectful")
            || text.contains("crossed a line")

        return hasResponseQuestion && hasHarshnessConcern
    }

    static func mentionsRelationshipRepair(_ transcript: String) -> Bool {
        let text = cleanedTranscript(transcript).lowercased()
        let hasRelationship = text.contains("friend")
            || text.contains("partner")
            || text.contains("teammate")
            || text.contains("classmate")
            || text.contains("family")
            || text.contains("she ")
            || text.contains("he ")
            || text.contains("they ")

        let hasRepairLanguage = text.contains("make it worse")
            || text.contains("hurtful")
            || text.contains("apolog")
            || text.contains("repair")

        return hasRelationship && hasRepairLanguage
    }

    static func safePreview(_ transcript: String) -> String {
        let clean = cleanedTranscript(transcript)
        guard containsRoughLanguage(clean) else { return clean }

        if asksWhetherResponseIsTooHarsh(clean) || mentionsRelationshipRepair(clean) {
            return "You were deciding whether to respond to someone who upset you."
        }

        if isRoughLowSignal(clean) {
            return "This check-in needs one clearer real moment before Circleu can reflect on it."
        }

        return "You named a heated moment without needing to repeat the exact words."
    }

    private static func normalizedWords(_ transcript: String) -> [String] {
        cleanedTranscript(transcript)
            .lowercased()
            .split(separator: " ")
            .map { word in
                word.filter { $0.isLetter || $0.isNumber }
            }
            .filter { !$0.isEmpty }
    }

    private static let roughWords: Set<String> = [
        "fuck",
        "fucking",
        "fucked",
        "shit",
        "shitty",
        "bitch",
        "damn"
    ]

    private static let fillerWords: Set<String> = [
        "hello",
        "hi",
        "hey",
        "um",
        "uh",
        "yeah",
        "okay",
        "ok",
        "test",
        "testing"
    ]
}
