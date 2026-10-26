import Combine
import Foundation

/// A question shown on Today, with the sentence starter it adds to the person's words. Only the
/// starter goes into their words, never the question, so the entry stays in their own voice.
struct GuestPrompt: Equatable, Hashable {
    let question: String
    let starter: String
}

/// Today's guided prompts: fixed templates, not a personal analysis, and nothing leaves the phone.
enum GuestTodayPrompts {
    /// Shown above the empty text box.
    static let starters: [GuestPrompt] = [
        GuestPrompt(question: "What happened?", starter: "What happened was "),
        GuestPrompt(question: "Who was it with?", starter: "I was with "),
        GuestPrompt(question: "What do you wish you’d said?", starter: "I wish I’d said "),
    ]

    /// "Need a nudge?" follow-ups while writing, one at a time.
    static let followUps: [GuestPrompt] = [
        GuestPrompt(question: "What did you want them to understand?", starter: "I wanted them to understand "),
        GuestPrompt(question: "How did you feel right after?", starter: "Right after, I felt "),
        GuestPrompt(question: "What matters most to you here?", starter: "What matters most to me is "),
        GuestPrompt(question: "What would a good outcome look like?", starter: "A good outcome would be "),
        GuestPrompt(question: "What could you say next time?", starter: "Next time, I could say "),
        GuestPrompt(question: "What do you think they were feeling?", starter: "I think they felt "),
    ]

    /// The nudge appears once there's something to build on.
    static let nudgeMinimumWords = 5

    /// The starter on its own when the words are empty, otherwise on a new line after them.
    static func inserting(_ starter: String, into words: String) -> String {
        let kept = words.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        return kept.isEmpty ? starter : kept + "\n" + starter
    }

    static func wordCount(_ text: String) -> Int {
        text.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count
    }
}

/// The "Need a nudge?" bubble on Today: one follow-up question at a time, hidden on request.
@MainActor
final class GuestNudgeModel: ObservableObject {
    @Published private(set) var index = 0
    @Published private(set) var isHidden = false
    private let prompts: [GuestPrompt]

    init(prompts: [GuestPrompt] = GuestTodayPrompts.followUps) { self.prompts = prompts }

    var prompt: GuestPrompt { prompts[index % prompts.count] }

    /// Shown while writing (not while dictating), until hidden for this entry.
    func isShown(for words: String, isDictating: Bool) -> Bool {
        !isHidden && !isDictating && GuestTodayPrompts.wordCount(words) >= GuestTodayPrompts.nudgeMinimumWords
    }

    func next() { index = (index + 1) % prompts.count }

    func hide() { isHidden = true }

    /// Adds the current starter to the words and moves on, so the same question doesn't repeat.
    func add(to words: String) -> String {
        let updated = GuestTodayPrompts.inserting(prompt.starter, into: words)
        next()
        return updated
    }

    /// A new entry (the words were cleared, for example by saving) starts fresh.
    func wordsChanged(to words: String) {
        if words.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { isHidden = false }
    }
}
