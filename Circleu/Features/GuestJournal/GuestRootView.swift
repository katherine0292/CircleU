import SwiftUI

/// Builds the guest journal's dependencies: the local store and on-device dictation, nothing else. It never constructs
/// Firebase, sync, backup or cloud services, and never reads legacy UserDefaults keys.
@MainActor
struct GuestComposition {
    var location: () throws -> GuestJournalLocation
    /// On-device speech-to-text for the Write screen (tests inject a fake).
    var dictationEngine: () -> any GuestDictationEngine = {
        #if DEBUG
        if let words = UserDefaults.standard.string(forKey: "CircleUScriptedDictation") {
            return ScriptedDictationEngine(words: words) // UI tests only; set by a launch argument.
        }
        #endif
        return SpeechDictationEngine()
    }
    /// Opt-in suggestions, on this iPhone only (tests inject a fake).
    var suggester: () -> any GuestSuggesting = {
        #if DEBUG
        // UI tests: predictable guided prompts instead of the on-device model.
        return LocalFirstSuggestionEngine(guidedOnly: UserDefaults.standard.bool(forKey: "CircleUGuidedSuggestions"))
        #else
        return LocalFirstSuggestionEngine()
        #endif
    }

    static var live: GuestComposition { GuestComposition(location: GuestJournalLocation.standard) }

    /// The live composition at another location (tests use a temporary folder).
    static func local(at location: GuestJournalLocation) -> GuestComposition {
        GuestComposition(location: { location })
    }

    func makeViewModel() async throws -> GuestJournalViewModel {
        try await makeSession().journal
    }

    /// The journal and Practice, sharing one local store.
    func makeSession() async throws -> (journal: GuestJournalViewModel, practice: GuestPracticeViewModel) {
        let location = try location()
        let store = try await SwiftDataGuestJournalStore.open(location: location)
        let viewModel = GuestJournalViewModel(store: store, drafts: FileGuestDraftStore(location: location))
        await viewModel.load()
        await viewModel.restoreDraft() // After load, so a leftover draft can be matched to saved entries.
        let practice = GuestPracticeViewModel(store: store, suggester: suggester())
        await practice.load()
        return (viewModel, practice)
    }
}

/// Composition root for the guest journal.
struct GuestRootView: View {
    private enum Phase {
        case opening
        case ready(GuestJournalViewModel, GuestPracticeViewModel)
        case failed(String)
    }

    @State private var phase: Phase = .opening
    private let composition: GuestComposition

    init(composition: GuestComposition? = nil) {
        self.composition = composition ?? .live
        GuestBrand.applyNavigationBarFonts() // Before any navigation bar appears.
    }

    var body: some View {
        switch phase {
        case .opening:
            ProgressView("Opening your journal…")
                .task { await open() }
        case .ready(let viewModel, let practice):
            GuestHomeView(journal: viewModel, practice: practice, makeDictationEngine: composition.dictationEngine,
                          suggester: composition.suggester())
        case .failed(let message):
            VStack(spacing: 16) {
                Text(message).multilineTextAlignment(.center)
                Button("Try again") { phase = .opening }
                    .buttonStyle(GuestBrandButtonStyle())
            }
            .padding(24)
        }
    }

    private func open() async {
        do {
            let session = try await composition.makeSession()
            phase = .ready(session.journal, session.practice)
        } catch {
            phase = .failed(GuestJournalViewModel.openFailureMessage(for: error))
        }
    }
}
