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

// MARK: - Model

@MainActor
final class GuestTalkModel: ObservableObject {
    enum Mode { case mine, theirs }

    @Published var items: [GuestTalkItem] = []
    @Published var setup: GuestTalkSetup
    @Published var mode: Mode = .mine
    @Published var input = ""
    @Published var hint = ""
    @Published var showsSetup = false
    @Published var editingID: UUID?
    @Published private(set) var isThinking = false
    @Published private(set) var saveError: String?
    @Published private(set) var saved: GuestPracticeMessage?
    @Published private(set) var lastCopied = 0

    /// A note in their words or yours that isn't a message (kept as "Added context").
    func addNote(_ text: String) {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        items.append(.context(id: UUID(), text: text))
        Task { await persist() }
    }

    let sourceEntryID: UUID?
    let draftID: UUID
    /// The entry's opening words, when the conversation came from the journal.
    private let entryTitle: String?
    private let practice: GuestPracticeViewModel
    private let suggester: any GuestSuggesting
    private var outcomes: [GuestPracticeConversation.Turn] = []
    private var pending: Task<Void, Never>?

    init(route: GuestPracticeRoute, practice: GuestPracticeViewModel, journal: GuestJournalViewModel) {
        self.practice = practice
        suggester = practice.suggester ?? LocalFirstSuggestionEngine(guidedOnly: true)
        switch route {
        case .message(let id):
            let message = practice.message(id: id)
            saved = message
            sourceEntryID = message?.sourceEntryID
            entryTitle = Self.title(of: journal.entries.first { $0.id == message?.sourceEntryID })
            draftID = UUID()
            var setup = GuestTalkSetup()
            setup.situation = message?.situation ?? ""
            setup.hope = message?.goal ?? ""
            var loaded: [GuestTalkItem] = []
            var kept: [GuestPracticeConversation.Turn] = []
            if let conversation = message?.conversation {
                setup.scene = conversation.scene
                setup.tone = conversation.tone
                for turn in conversation.turns {
                    switch turn.kind {
                    case .wording: loaded.append(.said(id: turn.id, text: turn.text))
                    case .theirReply: loaded.append(.message(GuestTalkMessage(isMine: false, versions: [.init(text: turn.text, tail: [])])))
                    case .context: loaded.append(.context(id: turn.id, text: turn.text))
                    case .outcome: kept.append(turn)
                    }
                }
            } else if let wording = message?.wording, !wording.isEmpty {
                loaded.append(.said(id: UUID(), text: wording)) // An earlier single message.
            }
            self.setup = setup
            items = loaded
            outcomes = kept
            if case .said? = loaded.last { mode = .theirs; hint = "When they answer, add it here." }
        case .new(let entryID):
            sourceEntryID = entryID
            entryTitle = Self.title(of: journal.entries.first { $0.id == entryID })
            let kept = practice.keptDraft.flatMap { $0.sourceEntryID == entryID ? $0 : nil }
            draftID = kept?.id ?? UUID()
            var setup = GuestTalkSetup.from(journal.entries.first { $0.id == entryID })
            if let kept {
                if !kept.situation.isEmpty { setup.situation = kept.situation }
                if !kept.goal.isEmpty { setup.hope = kept.goal }
                if let c = kept.conversation { setup.scene = c.scene; setup.tone = c.tone }
            }
            self.setup = setup
            input = kept?.wording ?? ""
            showsSetup = true
            hint = "Write it your way. You’ll get it back in your tone."
        }
    }

    var title: String {
        if let entryTitle { return entryTitle }
        let s = setup.situation.trimmingCharacters(in: .whitespaces)
        return s.isEmpty ? "Conversation" : String(s.prefix(28)) + (s.count > 28 ? "…" : "")
    }

    private static func title(of entry: GuestJournalEntry?) -> String? {
        guard let entry else { return nil }
        let words = entry.originalWords.split(separator: " ").prefix(4).joined(separator: " ")
        return words.isEmpty ? nil : words + "…"
    }

    var canSend: Bool { isThinking || !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    private var latestSuggestionID: UUID? {
        guard case .suggestion(let s)? = items.last else { return nil }
        return s.id
    }
    func isLive(_ id: UUID) -> Bool { latestSuggestionID == id || isLatestReading(id) }
    private func isLatestReading(_ id: UUID) -> Bool { if case .reading(let r)? = items.last { return r.id == id }; return false }

    // MARK: Sending

    func sendOrStop() {
        if isThinking { stop(); return }
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        input = ""
        hint = ""
        let message = GuestTalkMessage(isMine: mode == .mine, versions: [.init(text: text, tail: [])])
        items.append(.message(message))
        respond(to: message.id)
        keepDraft()
        if mode == .theirs { Task { await persist() } }
    }

    private func respond(to messageID: UUID) {
        guard let index = index(of: messageID), case .message(let message) = items[index] else { return }
        let thinkingID = UUID()
        items.append(.thinking(thinkingID))
        isThinking = true
        pending = Task { [weak self] in
            guard let self else { return }
            if message.isMine {
                let result = try? await suggester.wordingOptions(situation: setup.situation, goal: setup.hope, draft: message.text)
                guard !Task.isCancelled else { return }
                finishThinking(thinkingID)
                let base = Self.byTone(result?.options ?? LocalFirstSuggestionEngine.guidedWordingOptions(
                    situation: setup.situation, goal: setup.hope, draft: message.text))
                items.append(.suggestion(GuestTalkSuggestion(
                    isReply: false, gens: [GuestTalkGeneration(base: base)], tone: setup.tone,
                    source: result?.source ?? .guided, fallbackReason: result?.fallbackReason,
                    why: setup.hope.isEmpty ? "Clear about what you want, and leaves room for them to answer."
                                            : "Keeps to what you hope for: \(setup.hope.lowercased())")))
                hint = "Try a tone or style, ↻ for another take, then Copy."
            } else {
                try? await Task.sleep(for: .milliseconds(600))
                guard !Task.isCancelled else { return }
                finishThinking(thinkingID)
                items.append(.reading(GuestTalkReadingChoice(readings: GuestReplyReading.readings(for: message.text))))
                hint = "Which reading fits better?"
            }
        }
    }

    private func finishThinking(_ id: UUID) {
        items.removeAll { $0.id == id }
        isThinking = false
        pending = nil
    }

    func stop() {
        pending?.cancel()
        pending = nil
        isThinking = false
        items.removeAll { if case .thinking = $0 { return true }; return false }
        if case .message(var m)? = items.last { m.stopped = true; items[items.count - 1] = .message(m) }
        hint = "Stopped. Tap Retry when you’re ready."
    }

    func retry(_ messageID: UUID) {
        guard let i = index(of: messageID), case .message(var m) = items[i] else { return }
        m.stopped = false
        items[i] = .message(m)
        respond(to: messageID)
    }

    /// Their reply, read one of two ways (or neither): then reply ideas in every tone.
    func pick(_ readingID: UUID, _ choice: Int) {
        guard let i = index(of: readingID), case .reading(var r) = items[i] else { return }
        r.pick = choice
        items[i] = .reading(r)
        let reading = choice >= 0 ? r.readings[choice] : nil
        let thinkingID = UUID()
        items.append(.thinking(thinkingID))
        isThinking = true
        pending = Task { [weak self] in
            guard let self else { return }
            let theirs = latestTheirText(before: i) ?? ""
            let result = try? await suggester.replyOptions(situation: setup.situation, hope: setup.hope, theirReply: theirs,
                                                           reading: reading.map { "\($0.title). \($0.body)" },
                                                           conversation: conversation())
            guard !Task.isCancelled else { return }
            finishThinking(thinkingID)
            let base: [String: String]
            if let result, result.source == .onDevice, !result.options.isEmpty { base = Self.byTone(result.options) }
            else { base = GuestReplyReading.replies(for: reading?.kind) }
            items.append(.suggestion(GuestTalkSuggestion(
                isReply: true, readingTitle: reading?.title, replyTo: theirs, gens: [GuestTalkGeneration(base: base)], tone: setup.tone,
                source: result?.source ?? .guided, fallbackReason: result?.fallbackReason,
                why: reading == nil ? "Kept neutral, since neither reading fit." : nil)))
            hint = "Pick a tone, then Copy."
        }
    }

    // MARK: Suggestions

    func update(_ id: UUID, _ change: (inout GuestTalkSuggestion) -> Void) {
        guard let i = index(of: id), case .suggestion(var s) = items[i] else { return }
        change(&s)
        items[i] = .suggestion(s)
    }

    /// ↻: one more request, one more page in ‹ ›. A guided result that comes back the same is
    /// varied on this iPhone, so a new page is never a copy.
    func regenerate(_ id: UUID) {
        guard let i = index(of: id), case .suggestion(let s) = items[i], !isThinking else { return }
        isThinking = true
        pending = Task { [weak self] in
            guard let self else { return }
            var base: [String: String]?
            if !s.isReply, let source = latestMineText(before: i),
               let result = try? await suggester.wordingOptions(situation: setup.situation, goal: setup.hope, draft: source),
               result.source == .onDevice {
                base = Self.byTone(result.options)
            } else if s.isReply, let theirs = s.replyTo,
                      let result = try? await suggester.replyOptions(situation: setup.situation, hope: setup.hope, theirReply: theirs,
                                                                     reading: s.readingTitle, conversation: conversation()),
                      result.source == .onDevice, !result.options.isEmpty {
                base = Self.byTone(result.options)
            }
            guard !Task.isCancelled else { return }
            isThinking = false
            pending = nil
            let fresh = base ?? Self.anotherTake(s.gens[0].base, n: s.gens.count)
            update(id) { $0.gens.append(GuestTalkGeneration(base: fresh)); $0.g = $0.gens.count - 1; $0.style = .asIs; $0.copied = false }
        }
    }

    func copy(_ id: UUID) {
        guard let i = index(of: id), case .suggestion(let s) = items[i] else { return }
        UIPasteboard.general.string = s.shown
        update(id) { $0.copied = true }
        hint = "Said it or sent it? Tap “I said it”."
        lastCopied += 1
    }

    func markSaid(_ id: UUID) {
        guard let i = index(of: id), case .suggestion(let s) = items[i] else { return }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) { items[i] = .said(id: s.id, text: s.shown) }
        mode = .theirs
        hint = "When they answer, add it here."
        Task { await persist() }
    }

    // MARK: Editing and branches

    func edit(_ messageID: UUID, to text: String) {
        guard let i = index(of: messageID), case .message(var m) = items[i] else { return }
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        editingID = nil
        guard !text.isEmpty, text != m.text else { return }
        m.versions[m.v].tail = Array(items[(i + 1)...])
        m.versions.append(.init(text: text, tail: []))
        m.v = m.versions.count - 1
        m.stopped = false
        items = Array(items[..<i]) + [.message(m)]
        hint = "New version. The earlier one is under ‹ ›."
        respond(to: messageID)
        Task { await persist() }
    }

    func switchVersion(_ messageID: UUID, to k: Int) {
        guard !isThinking, let i = index(of: messageID), case .message(var m) = items[i], m.versions.indices.contains(k) else { return }
        m.versions[m.v].tail = Array(items[(i + 1)...])
        m.v = k
        items = Array(items[..<i]) + [.message(m)] + m.versions[k].tail
        Task { await persist() }
    }

    // MARK: Saving

    /// The visible branch, as attributed turns. Outcomes ("How it went") are kept as they are.
    func conversation() -> GuestPracticeConversation {
        var c = GuestPracticeConversation()
        c.scene = setup.scene
        c.tone = setup.tone
        for item in items {
            switch item {
            case .said(let id, let text): c.turns.append(.init(id: id, kind: .wording, text: text))
            case .message(let m) where !m.isMine: c.turns.append(.init(kind: .theirReply, text: m.text))
            case .context(let id, let text): c.turns.append(.init(id: id, kind: .context, text: text))
            default: break
            }
        }
        c.originalWords = c.turns.first { $0.kind == .wording }?.text ?? ""
        c.turns += outcomes
        return c
    }

    private var lastSaid: String {
        for item in items.reversed() { if case .said(_, let text) = item { return text } }
        return ""
    }

    /// Saved once something is said or they've replied; nothing is ever sent to anyone.
    func persist() async {
        let c = conversation()
        guard c.turns.contains(where: { $0.kind != .outcome }) else { return }
        guard let store = practice.store as? any GuestConversationStore else { return }
        do {
            if let saved {
                self.saved = try await store.updateConversation(id: saved.id, situation: setup.situation, goal: setup.hope,
                                                               wording: lastSaid, expectedRevision: saved.revision, conversation: c)
            } else {
                saved = try await store.createConversation(situation: setup.situation, goal: setup.hope, wording: lastSaid,
                                                           sourceEntryID: sourceEntryID, draftID: draftID, conversation: c)
                practice.clearDraft(id: draftID)
            }
            saveError = nil
        } catch GuestJournalError.savedButUnprotected {
            saveError = GuestJournalViewModel.savedButUnprotectedMessage
        } catch {
            saveError = "Couldn’t save this conversation. It’s still here; try again."
        }
        await practice.load()
    }

    func setupChanged() {
        keepDraft()
        if saved != nil { Task { await persist() } }
    }

    /// Typing before anything is said is kept as a draft, as Practice always did.
    func inputChanged() { if mode == .mine { keepDraft() } }

    /// Before anything is saved, the setup and first words are kept as a draft on this iPhone.
    private func keepDraft() {
        guard saved == nil else { return }
        var c = GuestPracticeConversation()
        c.scene = setup.scene
        c.tone = setup.tone
        let typed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let words = typed.isEmpty ? (latestMineText(before: items.count) ?? "") : input
        practice.keepDraft(GuestPracticeDraft(id: draftID, situation: setup.situation, goal: setup.hope, wording: words,
                                              sourceEntryID: sourceEntryID, conversation: c))
    }

    // MARK: Helpers

    func index(of id: UUID) -> Int? { items.firstIndex { $0.id == id } }

    private func latestTheirText(before index: Int) -> String? {
        for item in items[..<min(index, items.count)].reversed() { if case .message(let m) = item, !m.isMine { return m.text } }
        return nil
    }

    private func latestMineText(before index: Int) -> String? {
        for item in items[..<min(index, items.count)].reversed() { if case .message(let m) = item, m.isMine { return m.text } }
        return nil
    }

    static func byTone(_ options: [GuestWordingOption]) -> [String: String] {
        var out: [String: String] = [:]
        for option in options {
            let tone = option.tone == "Gentle" ? "Soft" : option.tone == "Clear" ? "Balanced" : option.tone
            out[tone] = option.text
        }
        for tone in GuestTalkSetup.tones where out[tone] == nil { out[tone] = options.first?.text ?? "" }
        return out
    }

    static func anotherTake(_ base: [String: String], n: Int) -> [String: String] {
        let openings = ["Soft": ["Hey, ", "Hi there, ", "Sorry to bother you, "], "Balanced": ["Hey, ", "Quick one: ", ""], "Firm": ["", "Just to be clear, ", "I want to be upfront: "]]
        let closings = ["Soft": [" No pressure.", " Thanks for hearing me out.", " Let me know what you think."], "Balanced": [" What do you think?", " Does that sound fair?", ""], "Firm": [" Can we agree on that?", "", " I need an answer soon."]]
        var out: [String: String] = [:]
        for (tone, text) in base {
            var core = text
            for o in (openings[tone] ?? []) where !o.isEmpty && core.hasPrefix(o) { core.removeFirst(o.count) }
            for c in (closings[tone] ?? []) where !c.isEmpty && core.hasSuffix(c) { core.removeLast(c.count) }
            for h in ["Hi, ", "Hey, "] where core.hasPrefix(h) { core.removeFirst(h.count) }
            let open = openings[tone]?[n % 3] ?? ""
            let body = open.isEmpty ? core.prefix(1).uppercased() + core.dropFirst() : core.prefix(1).lowercased() + core.dropFirst()
            out[tone] = open + body + (closings[tone]?[(n + 1) % 3] ?? "")
        }
        return out
    }
}
