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

// MARK: - Screen

struct GuestTalkScreen: View {
    @StateObject private var model: GuestTalkModel
    @ObservedObject var practice: GuestPracticeViewModel
    @ObservedObject var journal: GuestJournalViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool
    @State private var voice = false
    @State private var confirmDelete = false
    @State private var addingNote = false
    @State private var note = ""
    @AppStorage(GuestAvatars.storageKey) private var avatarID = GuestAvatars.defaultID

    init(route: GuestPracticeRoute, practice: GuestPracticeViewModel, journal: GuestJournalViewModel) {
        _model = StateObject(wrappedValue: GuestTalkModel(route: route, practice: practice, journal: journal))
        self.practice = practice
        self.journal = journal
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    setupPills
                    if model.items.isEmpty { empty }
                    ForEach(model.items) { item in
                        row(item).id(item.id).guestRiseIn()
                    }
                    if let error = model.saveError {
                        Label(error, systemImage: "exclamationmark.circle").font(GuestBrand.font(.footnote))
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: model.items.count) { _, _ in scrollToLast(proxy) }
            // A card that fills in after thinking (readings, reply ideas) grows in place, so follow it too.
            .onChange(of: model.isThinking) { _, thinking in if !thinking { scrollToLast(proxy) } }
        }
        .safeAreaInset(edge: .bottom) { composer }
        .background { GuestFlowingBackground() }
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Change the scene", systemImage: "slider.horizontal.3") { model.showsSetup = true }
                    Button("Add a note", systemImage: "note.text.badge.plus") { note = ""; addingNote = true }
                    if model.saved != nil {
                        Button("Delete conversation", systemImage: "trash", role: .destructive) { confirmDelete = true }
                    }
                } label: { Image(systemName: "ellipsis.circle") }
                .accessibilityLabel("More")
            }
        }
        .sheet(isPresented: $model.showsSetup) {
            GuestTalkSetupSheet(setup: $model.setup, avatarID: avatarID, fromJournal: model.sourceEntryID != nil,
                                isFirst: model.items.isEmpty && model.saved == nil) {
                model.showsSetup = false
                model.setupChanged()
                focused = true
            }
        }
        .sheet(isPresented: $voice) {
            GuestVoiceReviewSheet(engine: practice.makeDictationEngine()) { text in
                model.input = [model.input.trimmingCharacters(in: .whitespacesAndNewlines), text].filter { !$0.isEmpty }.joined(separator: " ")
            }
        }
        .alert("Delete this conversation?", isPresented: $confirmDelete) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    if let id = model.saved?.id, await practice.deleteMessage(id: id, journal: journal) == nil { dismiss() }
                }
            }
        }
        .alert("Add a note", isPresented: $addingNote) {
            TextField("Something that helps, like what happened next", text: $note)
            Button("Cancel", role: .cancel) {}
            Button("Add") { model.addNote(note) }
        } message: {
            Text("Notes stay with this conversation. They’re never sent.")
        }
        .onChange(of: model.input) { _, _ in model.inputChanged() }
        .onChange(of: practice.dataGeneration) { _, _ in dismiss() }
    }

    // MARK: Pieces

    private var setupPills: some View {
        GuestChipFlow(spacing: 6) {
            Button { model.showsSetup = true } label: {
                HStack(spacing: 4) {
                    Image(GuestTalkSetup.asset(for: model.setup.scene)).resizable().scaledToFit().frame(width: 22, height: 22)
                    Text(model.setup.scene)
                }
            }
            Button(model.setup.tone) { model.showsSetup = true }
            if !model.setup.hope.isEmpty { Button("Hope: \(model.setup.hope)") { model.showsSetup = true }.lineLimit(1) }
        }
        .buttonStyle(GuestChipButtonStyle())
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Scene and tone")
    }

    private var empty: some View {
        VStack(spacing: 8) {
            GuestLivingImage(asset: "GuestPinguWelcome", breathes: true).frame(height: 96)
                .guestWave()
            Text("What do you want to say?").font(GuestWarm.heading(.headline))
            Text("Write it your way. You’ll get it back in your tone.").font(GuestBrand.font(.footnote))
                .foregroundStyle(GuestBrand.muted)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity).padding(.vertical, 24)
    }

    @ViewBuilder private func row(_ item: GuestTalkItem) -> some View {
        switch item {
        case .message(let m): GuestTalkMessageRow(message: m, model: model, avatarID: avatarID)
        case .said(_, let text):
            GuestTalkSaidRow(text: text, avatarID: avatarID)
                .transition(.asymmetric(insertion: .scale(scale: 0.6, anchor: .bottomTrailing).combined(with: .opacity),
                                        removal: .opacity))
        case .context(_, let text):
            Label(text, systemImage: "note.text").font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                .padding(.horizontal, 12).padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityLabel("Note: \(text)")
        case .suggestion(let s):
            GuestTalkSuggestionCard(suggestion: s, live: model.isLive(s.id), model: model)
                .transition(.asymmetric(insertion: .opacity, removal: .scale(scale: 0.7, anchor: .trailing).combined(with: .opacity)))
        case .reading(let r): GuestTalkReadingCard(choice: r, live: model.isLive(r.id), model: model)
        case .thinking: GuestTalkThinking()
        }
    }

    /// Once the new card has its height, so it never sits under the composer.
    private func scrollToLast(_ proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { proxy.scrollTo(model.items.last?.id, anchor: .bottom) }
        }
    }

    private var composer: some View {
        VStack(spacing: 8) {
            if !model.hint.isEmpty {
                Text(model.hint).font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                    .multilineTextAlignment(.center).frame(maxWidth: .infinity)
            }
            GuestTalkModeSwitch(mode: $model.mode)
            HStack(alignment: .bottom, spacing: 8) {
                TextField(model.mode == .mine ? "What do you want to say?" : "Paste or type their reply…",
                          text: $model.input, axis: .vertical)
                    .lineLimit(1...4).focused($focused)
                    .padding(.vertical, 10)
                    .accessibilityLabel(model.mode == .mine ? "What you want to say" : "Their reply")
                Button { focused = false; voice = true } label: {
                    Image(systemName: "mic").font(.system(size: 17, weight: .semibold)).foregroundStyle(GuestWarm.sage)
                        .frame(width: 36, height: 36)
                }
                .accessibilityLabel("Speak instead")
                Button { focused = false; model.sendOrStop() } label: {
                    Image(systemName: model.isThinking ? "stop.fill" : "arrow.up")
                        .font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(model.canSend ? GuestWarm.cocoa : GuestWarm.muted.opacity(0.35), in: Circle())
                }
                .disabled(!model.canSend)
                .accessibilityLabel(model.isThinking ? "Stop" : "Send")
            }
            .padding(.leading, 14).padding(.trailing, 6).padding(.vertical, 4)
            .guestCard(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 8)
        .background { GuestBottomFade() } // Scrolled cards fade out instead of showing through the hint.
        .background { GuestBottomFade() }
    }
}

// MARK: - Rows

private struct GuestTalkAvatar: View {
    let avatarID: String
    var body: some View {
        Image(avatarID).resizable().scaledToFit().padding(2).frame(width: 28, height: 28)
            .background(.white, in: Circle()).accessibilityHidden(true)
    }
}

private struct GuestTalkMessageRow: View {
    let message: GuestTalkMessage
    @ObservedObject var model: GuestTalkModel
    let avatarID: String
    @State private var draft = ""

    var body: some View {
        VStack(alignment: message.isMine ? .trailing : .leading, spacing: 3) {
            if model.editingID == message.id {
                VStack(alignment: .leading, spacing: 6) {
                    TextField("Edit", text: $draft, axis: .vertical).lineLimit(1...6)
                        .accessibilityLabel("Edit message")
                    HStack {
                        Text("Everything after this starts again.").font(GuestBrand.font(.caption)).foregroundStyle(GuestBrand.muted)
                        Spacer()
                        Button("Cancel") { model.editingID = nil }.font(GuestBrand.font(.footnote, .semibold))
                        Button("Send") { model.edit(message.id, to: draft) }
                            .font(GuestBrand.font(.footnote, .bold)).foregroundStyle(.white)
                            .padding(.horizontal, 12).frame(minHeight: 32).background(GuestWarm.cocoa, in: Capsule())
                    }
                }
                .padding(10)
                .background(.white, in: RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(GuestWarm.cocoa, lineWidth: 2))
                .onAppear { draft = message.text }
            } else {
                HStack(alignment: .bottom, spacing: 6) {
                    if message.isMine { Spacer(minLength: 40) }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(message.isMine ? "YOU WANT TO SAY" : "THEY REPLIED")
                            .font(GuestBrand.font(.caption2, .bold)).foregroundStyle(message.isMine ? GuestBrand.muted : GuestWarm.sage)
                        Text(message.text).foregroundStyle(message.isMine ? GuestBrand.muted : GuestBrand.ink)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(message.isMine ? GuestWarm.cream.opacity(0.92) : .white,
                                in: UnevenRoundedRectangle(topLeadingRadius: 18, bottomLeadingRadius: message.isMine ? 18 : 5,
                                                           bottomTrailingRadius: message.isMine ? 5 : 18, topTrailingRadius: 18))
                    .overlay {
                        if message.isMine {
                            UnevenRoundedRectangle(topLeadingRadius: 18, bottomLeadingRadius: 18, bottomTrailingRadius: 5, topTrailingRadius: 18)
                                .strokeBorder(GuestWarm.cocoa.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        }
                    }
                    .accessibilityElement(children: .combine)
                    if message.isMine { GuestTalkAvatar(avatarID: avatarID) } else { Spacer(minLength: 40) }
                }
                HStack(spacing: 2) {
                    if message.versions.count > 1 {
                        GuestTalkPager(index: message.v, count: message.versions.count, what: "version") { model.switchVersion(message.id, to: $0) }
                    }
                    if !model.isThinking {
                        Button("Edit", systemImage: "pencil") { model.editingID = message.id }
                            .labelStyle(.titleAndIcon).font(GuestBrand.font(.caption, .semibold)).foregroundStyle(GuestBrand.muted)
                            .frame(minHeight: 32)
                    }
                    if message.stopped {
                        Button("Retry") { model.retry(message.id) }.font(GuestBrand.font(.caption, .semibold))
                    }
                }
                .padding(.trailing, message.isMine ? 34 : 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isMine ? .trailing : .leading)
    }
}

private struct GuestTalkSaidRow: View {
    let text: String
    let avatarID: String
    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            Spacer(minLength: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text("YOU SAID ✓").font(GuestBrand.font(.caption2, .bold)).foregroundStyle(.white.opacity(0.8))
                Text(text).foregroundStyle(.white)
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(LinearGradient(colors: [GuestWarm.cocoaLight, GuestWarm.cocoa], startPoint: .top, endPoint: .bottom),
                        in: UnevenRoundedRectangle(topLeadingRadius: 18, bottomLeadingRadius: 18, bottomTrailingRadius: 5, topTrailingRadius: 18))
            .accessibilityElement(children: .combine)
            GuestTalkAvatar(avatarID: avatarID)
        }
    }
}

private struct GuestTalkPager: View {
    let index: Int
    let count: Int
    let what: String
    let go: (Int) -> Void
    var body: some View {
        HStack(spacing: 0) {
            Button { go(index - 1) } label: { Image(systemName: "chevron.left").frame(width: 28, height: 32) }
                .disabled(index == 0).accessibilityLabel("Previous \(what)")
            Text("\(index + 1)/\(count)").monospacedDigit()
            Button { go(index + 1) } label: { Image(systemName: "chevron.right").frame(width: 28, height: 32) }
                .disabled(index == count - 1).accessibilityLabel("Next \(what)")
        }
        .font(GuestBrand.font(.caption, .semibold)).foregroundStyle(GuestBrand.muted)
    }
}

private struct GuestTalkThinking: View {
    @State private var on = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3) { i in
                Circle().fill(GuestWarm.cocoa.opacity(0.5)).frame(width: 7, height: 7)
                    .offset(y: on && !reduceMotion ? -4 : 0)
                    .animation(.easeInOut(duration: 0.45).repeatForever().delay(Double(i) * 0.15), value: on)
            }
        }
        .padding(12).guestCard(in: Capsule())
        .onAppear { on = true }
        .accessibilityLabel("Making suggestions")
    }
}

private struct GuestTalkSuggestionCard: View {
    let suggestion: GuestTalkSuggestion
    let live: Bool
    @ObservedObject var model: GuestTalkModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let reading = suggestion.readingTitle {
                Text("You read it as: \(reading.lowercased())").font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
            }
            Text(suggestion.isReply ? "YOU COULD REPLY" : "SAY IT LIKE THIS")
                .font(GuestBrand.font(.caption2, .bold)).foregroundStyle(GuestBrand.muted)
            if live {
                HStack(spacing: 6) {
                    ForEach(GuestTalkSetup.tones, id: \.self) { tone in
                        Button(tone) { model.update(suggestion.id) { $0.tone = tone; $0.copied = false } }
                            .font(GuestBrand.font(.caption, .semibold))
                            .foregroundStyle(suggestion.tone == tone ? .white : GuestBrand.ink)
                            .padding(.horizontal, 12).frame(minHeight: 32)
                            .guestPill(in: Capsule(), selected: suggestion.tone == tone)
                            .guestSquish(on: suggestion.tone == tone)
                            .accessibilityAddTraits(suggestion.tone == tone ? .isSelected : [])
                    }
                }
            }
            Text(suggestion.shown).font(GuestBrand.font(.body, .semibold)).foregroundStyle(GuestBrand.ink)
                .fixedSize(horizontal: false, vertical: true)
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.25), value: suggestion.shown)
            if live {
                GuestChipFlow(spacing: 6) {
                    ForEach(GuestTalkStyle.allCases) { style in
                        Button(style.rawValue) { model.update(suggestion.id) { $0.style = style; $0.copied = false } }
                            .font(GuestBrand.font(.caption, .semibold))
                            .foregroundStyle(suggestion.style == style ? .white : GuestBrand.ink)
                            .padding(.horizontal, 10).frame(minHeight: 30)
                            .background(suggestion.style == style ? GuestWarm.sage : GuestWarm.cream, in: Capsule())
                            .overlay(Capsule().strokeBorder(suggestion.style == style ? .clear : GuestWarm.cocoa.opacity(0.18)))
                            .accessibilityAddTraits(suggestion.style == style ? .isSelected : [])
                    }
                }
                if let why = suggestion.why {
                    Text(why).font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                }
                Text(suggestion.source.label).font(GuestBrand.font(.caption)).foregroundStyle(GuestBrand.muted)
                if let reason = suggestion.fallbackReason {
                    Label(reason.line, systemImage: "info.circle").font(GuestBrand.font(.caption)).foregroundStyle(GuestBrand.muted)
                }
                HStack(spacing: 8) {
                    Button(suggestion.copied ? "Copied" : "Copy") { model.copy(suggestion.id) }
                        .buttonStyle(GuestSmallCocoaStyle())
                        .sensoryFeedback(.success, trigger: suggestion.copied)
                    // Said out loud without copying counts too.
                    Button("I said it ✓") { model.markSaid(suggestion.id) }
                        .font(GuestBrand.font(.subheadline, .bold)).foregroundStyle(GuestWarm.cocoa)
                        .padding(.horizontal, 14).frame(minHeight: 40)
                        .guestPill(in: Capsule())
                        .guestSquish(on: suggestion.copied)
                    Spacer(minLength: 0)
                    if suggestion.gens.count > 1 {
                        GuestTalkPager(index: suggestion.g, count: suggestion.gens.count, what: "suggestion") { k in
                            model.update(suggestion.id) { $0.g = k; $0.style = .asIs; $0.copied = false }
                        }
                    }
                    Button { model.regenerate(suggestion.id) } label: {
                        Image(systemName: "arrow.clockwise").font(.system(size: 15, weight: .bold)).foregroundStyle(GuestWarm.cocoa)
                            .frame(width: 40, height: 40).guestPill(in: Circle())
                    }
                    .buttonStyle(GuestSpringPressStyle())
                    .disabled(model.isThinking)
                    .accessibilityLabel("Regenerate")
                }
            } else {
                Button("Copy") { UIPasteboard.general.string = suggestion.shown }
                    .font(GuestBrand.font(.caption, .semibold)).foregroundStyle(GuestBrand.muted)
            }
        }
        .padding(14)
        .guestCard(in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .opacity(live ? 1 : 0.85)
    }
}

private struct GuestTalkReadingCard: View {
    let choice: GuestTalkReadingChoice
    let live: Bool
    @ObservedObject var model: GuestTalkModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TWO WAYS TO READ THIS").font(GuestBrand.font(.caption2, .bold)).foregroundStyle(GuestBrand.muted)
            if choice.pick == nil {
                Text("A guess from their words. You know them better, so pick the one that fits.")
                    .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                ForEach(Array(choice.readings.enumerated()), id: \.element.id) { index, reading in
                    Button { withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) { model.pick(choice.id, index) } } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(reading.title).font(GuestBrand.font(.subheadline, .bold)).foregroundStyle(GuestBrand.ink)
                            Text(reading.body).font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading).padding(12)
                        .background(.white, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(GuestWarm.cocoa.opacity(0.15)))
                    }
                    .buttonStyle(GuestSpringPressStyle())
                    .sensoryFeedback(.selection, trigger: choice.pick)
                    .disabled(model.isThinking)
                }
                Button("Neither fits") { withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) { model.pick(choice.id, -1) } }
                    .font(GuestBrand.font(.footnote, .semibold)).foregroundStyle(GuestWarm.cocoa).frame(minHeight: 36)
                    .disabled(model.isThinking)
            } else if let pick = choice.pick, pick >= 0 {
                Label(choice.readings[pick].title, systemImage: "checkmark.circle.fill")
                    .font(GuestBrand.font(.subheadline, .bold)).foregroundStyle(GuestBrand.ink)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            } else {
                Text("Neither reading fit.").font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
            }
        }
        .padding(14)
        .guestCard(in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

/// "I want to say / They replied": one switch, a glass knob that slides between them.
private struct GuestTalkModeSwitch: View {
    @Binding var mode: GuestTalkModel.Mode
    @Namespace private var knob
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 0) {
            option("I want to say", .mine)
            option("They replied", .theirs)
        }
        .padding(3)
        .guestGlass(in: Capsule())
    }

    private func option(_ title: String, _ value: GuestTalkModel.Mode) -> some View {
        Button {
            withAnimation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.75)) { mode = value }
        } label: {
            Text(title).font(GuestBrand.font(.subheadline, .bold))
                .foregroundStyle(mode == value ? GuestWarm.cocoa : GuestBrand.muted)
                .frame(maxWidth: .infinity, minHeight: 36)
                .background {
                    if mode == value {
                        Capsule().fill(.white).shadow(color: GuestWarm.ink.opacity(0.12), radius: 4, y: 1)
                            .matchedGeometryEffect(id: "knob", in: knob)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(mode == value ? .isSelected : [])
    }
}

/// A compact cocoa capsule for an action inside a card (Copy).
struct GuestSmallCocoaStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(GuestBrand.font(.subheadline, .bold)).foregroundStyle(.white)
            .padding(.horizontal, 18).frame(minHeight: 40)
            .background(LinearGradient(colors: [GuestWarm.cocoaLight, GuestWarm.cocoa], startPoint: .top, endPoint: .bottom), in: Capsule())
            .shadow(color: GuestWarm.cocoa.opacity(0.25), radius: 6, y: 3)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.95 : 1)
            .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.55), value: configuration.isPressed)
    }
}

// MARK: - Setup sheet

struct GuestTalkSetupSheet: View {
    @Binding var setup: GuestTalkSetup
    let avatarID: String
    let fromJournal: Bool
    let isFirst: Bool
    let done: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        Image(avatarID).resizable().scaledToFit().padding(4).frame(width: 52, height: 52)
                            .background(.white, in: Circle()).accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Your conversation").font(GuestBrand.font(.caption, .semibold)).foregroundStyle(GuestBrand.muted)
                            Text(isFirst ? "Set the scene" : "Change the scene").font(GuestWarm.heading(.title3))
                                .accessibilityAddTraits(.isHeader)
                        }
                    }
                    if fromJournal && isFirst {
                        Label("Filled in from your journal. Change anything.", systemImage: "checkmark.circle")
                            .font(GuestBrand.font(.footnote, .semibold)).foregroundStyle(GuestWarm.sage)
                    }
                    Text("Where is this?").font(GuestBrand.font(.subheadline, .semibold))
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: typeSize.isAccessibilitySize ? 200 : 92))], spacing: 10) {
                        ForEach(GuestTalkSetup.scenes, id: \.self) { scene in
                            Button { setup.scene = scene } label: {
                                VStack(spacing: 4) {
                                    Image(GuestTalkSetup.asset(for: scene)).resizable().scaledToFit().frame(height: 56)
                                        .accessibilityHidden(true)
                                    Text(scene).font(GuestBrand.font(.caption, .semibold))
                                }
                                .padding(8).frame(maxWidth: .infinity, minHeight: 92)
                                .guestCard(in: RoundedRectangle(cornerRadius: 18), fill: setup.scene == scene ? GuestBrand.wash : nil)
                                .overlay(RoundedRectangle(cornerRadius: 18).stroke(setup.scene == scene ? GuestBrand.blue : .clear, lineWidth: 2))
                                .guestSquish(on: setup.scene == scene)
                            }
                            .buttonStyle(.plain).accessibilityLabel(scene)
                            .accessibilityAddTraits(setup.scene == scene ? .isSelected : [])
                        }
                    }
                    Text("How do you want to sound?").font(GuestBrand.font(.subheadline, .semibold))
                    HStack(spacing: 8) {
                        ForEach(GuestTalkSetup.tones, id: \.self) { tone in
                            Button(tone) { setup.tone = tone }
                                .font(GuestBrand.font(.subheadline, .semibold))
                                .foregroundStyle(setup.tone == tone ? .white : GuestBrand.ink)
                                .padding(.horizontal, 16).frame(minHeight: 44)
                                .guestPill(in: Capsule(), selected: setup.tone == tone)
                                .guestSquish(on: setup.tone == tone)
                                .accessibilityAddTraits(setup.tone == tone ? .isSelected : [])
                        }
                    }
                    .buttonStyle(.plain)
                    field("What’s going on? · optional", text: $setup.situation, prompt: "First day at a new job")
                    field("What do you hope for? · optional", text: $setup.hope, prompt: "Come across friendly")
                }
                .padding(20)
            }
            .background { GuestFlowingBackground() }
            .safeAreaInset(edge: .bottom) {
                Button(isFirst ? "Start" : "Done", action: done)
                    .buttonStyle(GuestBrandButtonStyle())
                    .padding(.horizontal, 20).padding(.vertical, 12)
                    .background { GuestBottomFade() }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink).tint(GuestBrand.blue)
    }

    private func field(_ title: String, text: Binding<String>, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(GuestBrand.font(.subheadline, .semibold))
            TextField(prompt, text: text, axis: .vertical).lineLimit(1...3)
                .padding(12).guestCard(in: RoundedRectangle(cornerRadius: 14))
                .accessibilityLabel(title)
        }
    }
}

// MARK: - How did it go?

/// After something was said, the entry asks how it went; the answer stays with this moment.
struct GuestOutcomeCard: View {
    let message: GuestPracticeMessage
    @ObservedObject var practice: GuestPracticeViewModel
    @State private var text = ""
    @State private var feeling: GuestEntryFeeling?
    @State private var error: String?
    @State private var isSaving = false
    @State private var saved = 0

    private var outcomes: [GuestPracticeConversation.Turn] { message.conversation?.turns.filter { $0.kind == .outcome } ?? [] }
    private var hasSaid: Bool { message.conversation?.turns.contains { $0.kind == .wording } ?? !message.wording.isEmpty }

    var body: some View {
        if !outcomes.isEmpty {
            ForEach(outcomes) { outcome in
                VStack(alignment: .leading, spacing: 6) {
                    Text("HOW IT WENT · \(outcome.createdAt.formatted(.dateTime.day().month(.abbreviated)))")
                        .font(GuestBrand.font(.caption2, .bold)).foregroundStyle(GuestBrand.muted)
                    if !outcome.text.isEmpty { Text(outcome.text) }
                    if let raw = outcome.feeling, let f = GuestEntryFeeling(rawValue: raw) {
                        Label { Text(f.title) } icon: { Image(f.asset).resizable().scaledToFit().frame(width: 24, height: 24) }
                            .font(GuestBrand.font(.caption, .semibold))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading).padding(14)
                .guestCard(in: RoundedRectangle(cornerRadius: 18))
                .guestRiseIn()
            }
            .sensoryFeedback(.success, trigger: saved)
        } else if hasSaid {
            VStack(alignment: .leading, spacing: 10) {
                Text("You said it. Pick how it felt, add a line if you like.")
                    .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(GuestEntryFeeling.allCases, id: \.self) { f in
                            Button { feeling = feeling == f ? nil : f } label: {
                                VStack(spacing: 2) {
                                    Image(f.asset).resizable().scaledToFit().frame(width: 34, height: 34).accessibilityHidden(true)
                                    Text(f.title).font(GuestBrand.font(.caption2, .semibold))
                                }
                                .padding(6).frame(minWidth: 60)
                                .guestCard(in: RoundedRectangle(cornerRadius: 14), fill: feeling == f ? GuestBrand.wash : nil)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(feeling == f ? GuestBrand.blue : .clear, lineWidth: 2))
                                .guestSquish(on: feeling == f)
                            }
                            .buttonStyle(.plain).accessibilityLabel(f.title)
                            .accessibilityAddTraits(feeling == f ? .isSelected : [])
                        }
                    }
                }
                // Save sits beside the words, so the keyboard never covers it.
                HStack(alignment: .bottom, spacing: 8) {
                    TextField("What happened? Optional", text: $text, axis: .vertical).lineLimit(1...5)
                        .submitLabel(.done)
                        .onSubmit { Task { await save() } }
                        .padding(12).background(.white, in: RoundedRectangle(cornerRadius: 14))
                        .accessibilityLabel("How it went")
                    Button(isSaving ? "Saving…" : "Save") { Task { await save() } }
                        .buttonStyle(GuestSmallCocoaStyle())
                        .disabled(!canSave)
                }
                if let error { Text(error).font(GuestBrand.font(.footnote)) }
            }
            .padding(14)
            .guestCard(in: RoundedRectangle(cornerRadius: 20))
        }
    }

    /// Words, a feeling, or both: either is enough to remember how it went.
    private var canSave: Bool { (!text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || feeling != nil) && !isSaving }

    private func save() async {
        guard canSave else { return }
        guard let store = practice.store as? any GuestConversationStore else {
            error = "Couldn’t save. Try again."
            return
        }
        isSaving = true
        defer { isSaving = false }
        var c = message.conversation ?? GuestPracticeConversation()
        if message.conversation == nil, !message.wording.isEmpty { c.turns.append(.init(kind: .wording, text: message.wording)) }
        c.turns.append(.init(kind: .outcome, text: text.trimmingCharacters(in: .whitespacesAndNewlines), feeling: feeling?.rawValue))
        do {
            _ = try await store.updateConversation(id: message.id, situation: message.situation, goal: message.goal,
                                                   wording: message.wording, expectedRevision: message.revision, conversation: c)
            error = nil
            saved += 1
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        } catch GuestJournalError.savedButUnprotected {
            error = GuestJournalViewModel.savedButUnprotectedMessage
        } catch GuestJournalError.staleRevision {
            self.error = "This conversation changed. Try again."
        } catch {
            self.error = "Couldn’t save. Try again."
        }
        await practice.load()
    }
}
