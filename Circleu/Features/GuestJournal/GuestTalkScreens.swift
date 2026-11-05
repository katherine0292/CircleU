import Combine
import SwiftUI
import UIKit

// The Talk conversation (owner-approved direction, 6 November 2026): one thread instead of
// Prepare / Refine / Their reply pages. The person writes what they mean, gets it back in their tone,
// copies it, marks it said, adds what the other person replied, picks one of two readings and gets
// reply ideas. Suggestions can be regenerated (‹ › keeps every take) and earlier messages edited,
// which starts a new branch from there; the earlier branch stays one tap away.
//
// Saved data stays in the existing conversation format: said wording, their replies and added
// context become attributed turns, so earlier saves open here and history keeps working.

// MARK: - Setup

struct GuestTalkSetup: Equatable {
    var scene = "Other"
    var tone = "Balanced"
    var situation = ""
    var hope = ""

    static let scenes = ["Study", "Work", "Friends", "Family", "Relationship", "Other"]
    static let tones = ["Soft", "Balanced", "Firm"]

    static func asset(for scene: String) -> String {
        scene == "Other" ? "GuestPinguThoughtful" : "GuestPingu\(scene)Tag"
    }

    /// What a journal entry already says: its context as the scene, the kept reflection (or the
    /// first words) as the situation, and the next step as the hope. Tone is never guessed.
    static func from(_ entry: GuestJournalEntry?) -> GuestTalkSetup {
        guard let entry else { return GuestTalkSetup() }
        var setup = GuestTalkSetup()
        setup.scene = entry.context?.title ?? "Other"
        if let summary = entry.reflection?.summary.trimmingCharacters(in: .whitespacesAndNewlines), !summary.isEmpty {
            setup.situation = summary
        } else {
            let first = entry.originalWords.split(whereSeparator: { ".!?\n".contains($0) }).first.map(String.init) ?? ""
            setup.situation = String(first.prefix(90)).trimmingCharacters(in: .whitespaces)
        }
        setup.hope = entry.nextStep ?? ""
        return setup
    }
}

// MARK: - Styles and readings (made on this iPhone, no request)

/// Each suggestion arrives as a whole set: every tone, each as is and in three styles. Switching
/// style only changes what's shown; only ↻ asks again.
enum GuestTalkStyle: String, CaseIterable, Identifiable {
    case asIs = "As is", shorter = "Shorter", warmer = "Warmer", direct = "More direct"
    var id: String { rawValue }

    func apply(_ text: String) -> String {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        switch self {
        case .asIs: return text
        case .shorter:
            let sentences = Self.sentences(text)
            return sentences.count > 1 ? sentences.suffix(2).joined(separator: " ") : text
        case .warmer:
            return text.lowercased().contains("thank") ? text : "Thanks for hearing me out. " + text
        case .direct:
            let softeners = ["I hope this is okay to bring up. ", "just ", "maybe ", "a bit ", "really "]
            var out = text
            for word in softeners { out = out.replacingOccurrences(of: word, with: "", options: .caseInsensitive) }
            return out.replacingOccurrences(of: "  ", with: " ")
        }
    }

    private static func sentences(_ text: String) -> [String] {
        var result: [String] = []
        text.enumerateSubstrings(in: text.startIndex..., options: .bySentences) { sub, _, _, _ in
            if let sub = sub?.trimmingCharacters(in: .whitespaces), !sub.isEmpty { result.append(sub) }
        }
        return result
    }
}

/// Two possible readings of their reply, never one verdict: the person knows them better and picks.
/// A plain word check made on this iPhone; it explains wording, it doesn't judge the person.
struct GuestReplyReading: Equatable, Identifiable {
    enum Kind { case yes, polite, stretched, vague, hurt, moveOn }
    var id: String { title }
    let title: String
    let body: String
    let kind: Kind

    static func readings(for reply: String) -> [GuestReplyReading] {
        let text = reply.lowercased()
        func has(_ words: String...) -> Bool { words.contains { text.contains($0) } }
        if has("busy", "no promises", "later", "can't", "cannot", "maybe", "i'll try", "not sure") {
            return [.init(title: "Yes, but they’re stretched", body: "They want to help and are worried about their own time.", kind: .stretched),
                    .init(title: "They’d rather not commit", body: "Keeping it vague means they don’t have to say no.", kind: .vague)]
        }
        if has("always", "never", "whatever", "i guess", "seriously") {
            return [.init(title: "They’re still hurt", body: "This touched something that’s happened before.", kind: .hurt),
                    .init(title: "They want to move on", body: "They’d rather not talk more right now.", kind: .moveOn)]
        }
        return [.init(title: "A real yes", body: "It reads as open, with no catch.", kind: .yes),
                .init(title: "Yes, to be polite", body: "They may still need a clear time or a nudge.", kind: .polite)]
    }

    /// Reply ideas by tone when Apple Intelligence isn't used.
    static func replies(for kind: Kind?) -> [String: String] {
        switch kind {
        case .yes?: ["Soft": "Thank you, that really helps.", "Balanced": "Thanks! I’ll send the details tonight.", "Firm": "Great, thanks. Can we confirm by tomorrow?"]
        case .polite?: ["Soft": "Thanks! Is tomorrow still okay for you?", "Balanced": "Thanks. Could we pick a time so it’s settled?", "Firm": "Thanks. Let’s agree on a time now."]
        case .stretched?: ["Soft": "That’s okay, I know you’re busy. Would a smaller part help?", "Balanced": "I get it. Could you take just one part, so it isn’t all on me?", "Firm": "I understand you’re busy, but I need you to take one part."]
        case .vague?: ["Soft": "No worries. Could we pick one thing for you to do?", "Balanced": "Could we agree on one thing you’ll do this week?", "Firm": "I need a clear yes or no by tomorrow."]
        case .hurt?: ["Soft": "You’re right, it’s happened before. I’m sorry, and I want to do better.", "Balanced": "I know it’s happened before. I’m sorry it keeps hurting you.", "Firm": "That’s fair. I’ll show you with how I act from now on."]
        case .moveOn?: ["Soft": "Okay, we can leave it for now. I’m here when you want to talk.", "Balanced": "Okay. Can we come back to it this weekend?", "Firm": "Okay, but I’d like us to sort it this week."]
        case nil: ["Soft": "Thanks for telling me. Can I ask what would help most?", "Balanced": "Thanks for your reply. What would work for you?", "Firm": "Thanks. Let’s agree on the next step."]
        }
    }
}

// MARK: - Thread items

struct GuestTalkGeneration: Equatable {
    /// Tone → text, as returned once; styles are applied on top.
    var base: [String: String]
    func text(tone: String, style: GuestTalkStyle) -> String { style.apply(base[tone] ?? base.values.first ?? "") }
}

struct GuestTalkVersion { var text: String; var tail: [GuestTalkItem] }

struct GuestTalkMessage {
    let id = UUID()
    var isMine: Bool
    var versions: [GuestTalkVersion]
    var v = 0
    var stopped = false
    var text: String { versions[v].text }
}

struct GuestTalkSuggestion {
    let id = UUID()
    var isReply: Bool
    var readingTitle: String?
    /// Their message this replies to, so ↻ can ask again.
    var replyTo: String?
    var gens: [GuestTalkGeneration]
    var g = 0
    var tone: String
    var style: GuestTalkStyle = .asIs
    var copied = false
    var source: GuestSuggestionSource
    var fallbackReason: GuestFallbackReason?
    var why: String?
    var shown: String { gens[g].text(tone: tone, style: style) }
}

struct GuestTalkReadingChoice {
    let id = UUID()
    var readings: [GuestReplyReading]
    /// nil until chosen; -1 is "Neither fits".
    var pick: Int?
}

enum GuestTalkItem: Identifiable {
    case message(GuestTalkMessage)
    case said(id: UUID, text: String)
    case context(id: UUID, text: String)
    case suggestion(GuestTalkSuggestion)
    case reading(GuestTalkReadingChoice)
    case thinking(UUID)

    var id: UUID {
        switch self {
        case .message(let m): m.id
        case .said(let id, _), .context(let id, _), .thinking(let id): id
        case .suggestion(let s): s.id
        case .reading(let r): r.id
        }
    }
}
