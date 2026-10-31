import Combine
import SwiftUI

/// "Reflect on it" after saving: a tentative reflection on a saved entry that the person can edit,
/// remove or ignore. Their words are already saved as written and never change here.
@MainActor
final class GuestReflectionReviewViewModel: ObservableObject {
    enum State: Equatable { case loading, ready, failed }

    @Published private(set) var state: State = .loading
    @Published var summary = ""
    @Published var feeling = ""
    @Published var insight = ""
    /// Empty until the person adds the suggested step or writes their own: a step is never kept by default.
    @Published var nextStep = ""
    /// The suggested step, offered with "Add this step".
    @Published private(set) var suggestedNextStep = ""
    @Published private(set) var source: GuestSuggestionSource?
    @Published private(set) var isSaving = false
    @Published private(set) var saveError: String?
    private var generated = ("", "", "")

    static let failedMessage = "A suggestion couldn’t be made right now. Your entry is saved as it is."

    let entry: GuestJournalEntry
    let journal: GuestJournalViewModel
    private let suggester: any GuestSuggesting

    init(entry: GuestJournalEntry, journal: GuestJournalViewModel, suggester: any GuestSuggesting) {
        self.entry = entry
        self.journal = journal
        self.suggester = suggester
    }

    private static func trim(_ text: String) -> String { text.trimmingCharacters(in: .whitespacesAndNewlines) }

    func load() async {
        state = .loading
        do {
            let suggestion = try await suggester.reflection(for: entry.originalWords)
            summary = suggestion.summary
            feeling = suggestion.feeling
            insight = suggestion.insight
            generated = (suggestion.summary, suggestion.feeling, suggestion.insight)
            suggestedNextStep = suggestion.nextStep
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
                               basedOnWords: entry.originalWords)
    }

    /// The person changed the suggestion or added a step; leaving asks first.
    var hasEdits: Bool {
        state == .ready && ((summary, feeling, insight) != generated || !Self.trim(nextStep).isEmpty)
    }

    func addSuggestedStep() { nextStep = suggestedNextStep }

    var keptNextStep: String? {
        let step = Self.trim(nextStep)
        return state == .ready && !step.isEmpty ? step : nil
    }

    /// Something is left to add to the entry.
    var canSave: Bool { !isSaving && (keptReflection != nil || keptNextStep != nil) }

    /// Adds what's kept to the entry. False (with `saveError`) if it wasn't added.
    func save() async -> Bool {
        guard canSave else { return false }
        isSaving = true
        defer { isSaving = false }
        saveError = await journal.updateReflection(of: entry, reflection: keptReflection, nextStep: keptNextStep,
                                                   nextStepDone: false)
        if saveError == nil { journal.reflectionAdded(to: entry.id) }
        return saveError == nil
    }
}

struct GuestReflectionReviewView: View {
    @StateObject private var review: GuestReflectionReviewViewModel
    let onDone: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var confirmDiscard = false
    @Environment(\.dynamicTypeSize) private var typeSize

    init(entry: GuestJournalEntry, journal: GuestJournalViewModel, suggester: any GuestSuggesting,
         onDone: @escaping () -> Void) {
        _review = StateObject(wrappedValue: GuestReflectionReviewViewModel(entry: entry, journal: journal,
                                                                           suggester: suggester))
        self.onDone = onDone
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !typeSize.isAccessibilitySize {
                    GuestScene(.reflectionGarden).clipShape(RoundedRectangle(cornerRadius: 24))
                }
                Text("My words").font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.muted)
                Text(review.entry.originalWords)
                    .font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 18))
                suggestion
                if let error = review.saveError {
                    Label(error, systemImage: "exclamationmark.circle")
                        .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
                }
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            if review.state == .ready {
                Button(review.isSaving ? "Saving…" : "Save reflection") {
                    Task { if await review.save() { onDone() } }
                }
                .buttonStyle(GuestBrandButtonStyle())
                .disabled(!review.canSave)
                .padding(.horizontal, 24).padding(.vertical, 12)
                .background(GuestBrand.ice)
            }
        }
        .background(GuestBrand.ice.ignoresSafeArea())
        .navigationTitle("Reflection")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Back") { if review.hasEdits { confirmDiscard = true } else { dismiss() } }
                    .disabled(review.isSaving)
            }
        }
        .alert("Discard your changes to the suggestion?", isPresented: $confirmDiscard) {
            Button("Keep editing", role: .cancel) {}
            Button("Discard", role: .destructive) { dismiss() }
        } message: {
            Text("Your saved entry stays as it is.")
        }
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
                Label { Text("A suggestion") } icon: { GuestBrandIcon(asset: "GuestIconReflection", size: 30) }
                    .font(GuestBrand.font(.title3, .bold)).foregroundStyle(GuestBrand.ink)
                    .accessibilityAddTraits(.isHeader)
                if let source = review.source {
                    Text(source.label).font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                }
                field("What happened", text: $review.summary)
                field("A feeling that might fit", text: $review.feeling)
                field("Something to consider", text: $review.insight)
                Text("Clear any part you don’t want to keep.")
                    .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                if review.nextStep.isEmpty, !review.suggestedNextStep.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("A possible next step").font(GuestBrand.font(.subheadline, .semibold))
                            .foregroundStyle(GuestBrand.muted)
                        Text(review.suggestedNextStep).font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
                        Button { review.addSuggestedStep() } label: {
                            Text("Add this step").frame(minHeight: 44).contentShape(Rectangle())
                        }
                        .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.blue)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white, in: RoundedRectangle(cornerRadius: 16))
                }
                field("Your next step (optional)", text: $review.nextStep)
            }
            // Nothing can change while it saves, so what's saved is what's on screen.
            .disabled(review.isSaving)
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
