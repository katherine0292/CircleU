import Combine
import SwiftUI

/// "Get a suggestion" after Write: a tentative reflection the person can edit, remove or ignore.
/// Their own words are always saved as written, and saving without a suggestion stays one tap away.
@MainActor
final class GuestReflectionReviewViewModel: ObservableObject {
    enum State: Equatable { case loading, ready, failed }

    @Published private(set) var state: State = .loading
    @Published var summary = ""
    @Published var feeling = ""
    @Published var insight = ""
    @Published var nextStep = ""
    @Published private(set) var source: GuestSuggestionSource?
    /// The words the suggestion was made from.
    @Published private(set) var basedOnWords = ""

    static let failedMessage = "A suggestion couldn’t be made right now. Your words are safe, and you can still save them."

    let journal: GuestJournalViewModel
    private let suggester: any GuestSuggesting

    init(journal: GuestJournalViewModel, suggester: any GuestSuggesting) {
        self.journal = journal
        self.suggester = suggester
    }

    private static func trim(_ text: String) -> String { text.trimmingCharacters(in: .whitespacesAndNewlines) }

    /// The words changed after the suggestion was made.
    var isStale: Bool { state == .ready && Self.trim(journal.draft) != basedOnWords }

    func load() async {
        state = .loading
        let words = Self.trim(journal.draft)
        do {
            let suggestion = try await suggester.reflection(for: words)
            basedOnWords = words
            summary = suggestion.summary
            feeling = suggestion.feeling
            insight = suggestion.insight
            nextStep = suggestion.nextStep
            source = suggestion.source
            state = .ready
        } catch {
            state = .failed
        }
    }

    /// What's left after the person's edits; nil when they cleared every part.
    var keptReflection: GuestReflection? {
        guard state == .ready, let source else { return nil }
        let parts = (Self.trim(summary), Self.trim(feeling), Self.trim(insight))
        guard !(parts.0.isEmpty && parts.1.isEmpty && parts.2.isEmpty) else { return nil }
        return GuestReflection(summary: parts.0, feeling: parts.1, insight: parts.2, source: source,
                               basedOnWords: basedOnWords)
    }

    var keptNextStep: String? {
        let step = Self.trim(nextStep)
        return state == .ready && !step.isEmpty ? step : nil
    }

    func saveWithReflection() async -> Bool {
        await journal.saveDraft(reflection: keptReflection, nextStep: keptNextStep)
    }

    func saveWordsOnly() async -> Bool {
        await journal.saveDraft()
    }
}

struct GuestReflectionReviewView: View {
    @StateObject private var review: GuestReflectionReviewViewModel
    @ObservedObject private var journal: GuestJournalViewModel
    let onSaved: () -> Void

    init(journal: GuestJournalViewModel, suggester: any GuestSuggesting, onSaved: @escaping () -> Void) {
        _review = StateObject(wrappedValue: GuestReflectionReviewViewModel(journal: journal, suggester: suggester))
        self.journal = journal
        self.onSaved = onSaved
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("My words").font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.muted)
                Text(journal.draft.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 18))
                suggestion
                if let error = journal.saveError {
                    Label(error, systemImage: "exclamationmark.circle")
                        .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
                }
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 10) {
                if review.keptReflection != nil || review.keptNextStep != nil {
                    Button(journal.isSaving ? "Saving…" : "Save with reflection") {
                        Task { if await review.saveWithReflection() { onSaved() } }
                    }
                    .buttonStyle(GuestBrandButtonStyle())
                }
                Button("Save only my words") {
                    Task { if await review.saveWordsOnly() { onSaved() } }
                }
                .buttonStyle(GuestBrandButtonStyle(filled: review.keptReflection == nil && review.keptNextStep == nil))
            }
            .disabled(journal.isSaving)
            .padding(.horizontal, 24).padding(.vertical, 12)
            .background(GuestBrand.ice)
        }
        .background(GuestBrand.ice.ignoresSafeArea())
        .navigationTitle("Reflection")
        .navigationBarTitleDisplayMode(.inline)
        .task { if review.state == .loading { await review.load() } }
    }

    @ViewBuilder private var suggestion: some View {
        switch review.state {
        case .loading:
            HStack(spacing: 10) {
                ProgressView()
                Text("Making a suggestion…").foregroundStyle(GuestBrand.muted)
            }
        case .failed:
            VStack(alignment: .leading, spacing: 8) {
                Text(GuestReflectionReviewViewModel.failedMessage).foregroundStyle(GuestBrand.muted)
                Button("Try again") { Task { await review.load() } }
                    .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.blue)
            }
        case .ready:
            VStack(alignment: .leading, spacing: 14) {
                Text("A suggestion").font(GuestBrand.font(.title3, .bold)).foregroundStyle(GuestBrand.ink)
                    .accessibilityAddTraits(.isHeader)
                if let source = review.source {
                    Text(source.label).font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                }
                if review.isStale {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Based on an earlier version of your words.", systemImage: "clock.arrow.circlepath")
                            .font(GuestBrand.font(.footnote, .semibold)).foregroundStyle(GuestBrand.ink)
                        Button("Update suggestion") { Task { await review.load() } }
                            .font(GuestBrand.font(.footnote, .semibold)).foregroundStyle(GuestBrand.blue)
                    }
                }
                field("What happened", text: $review.summary)
                field("A feeling that might fit", text: $review.feeling)
                field("Something to consider", text: $review.insight)
                field("Next step (optional)", text: $review.nextStep)
                Text("Clear any part you don’t want to keep.")
                    .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
            }
        }
    }

    private func field(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.muted)
                Spacer()
                if !text.wrappedValue.isEmpty {
                    Button { text.wrappedValue = "" } label: {
                        Text("Clear").frame(minWidth: 44, minHeight: 44).contentShape(Rectangle())
                    }
                    .font(GuestBrand.font(.footnote, .semibold)).foregroundStyle(GuestBrand.blue)
                        .accessibilityLabel("Clear \(title)")
                }
            }
            TextField(title, text: text, axis: .vertical)
                .lineLimit(1...6)
                .padding(12)
                .background(.white, in: RoundedRectangle(cornerRadius: 14))
        }
    }
}
