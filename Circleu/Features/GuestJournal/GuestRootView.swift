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
        #if targetEnvironment(simulator)
        if UserDefaults.standard.bool(forKey: "CircleUAssumeOnDeviceSpeech") {
            return SpeechDictationEngine(assumesOnDeviceSupport: true) // UI tests only: reach the real permission prompts.
        }
        #endif
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

    #if DEBUG
    /// Invented entries on three different days, with context and feeling tags, so poster and slide
    /// captures show a lived-in Journal. Uses the import path, which keeps the given dates.
    static func seedShowcase(into store: SwiftDataGuestJournalStore) async {
        let calendar = Calendar.current
        func at(daysAgo: Int, _ hour: Int, _ minute: Int) -> Date {
            let day = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
            return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
        }
        let seeds: [(words: String, date: Date, context: GuestEntryContext?, feeling: GuestEntryFeeling?)] = [
            ("A quiet walk helped me slow down before the group meeting.", at(daysAgo: 0, 8, 15), nil, .calm),
            ("I said no to the extra shift and felt okay about it.", at(daysAgo: 2, 18, 12), .work, .calm),
            ("Talked with my sister about our holiday plans.", at(daysAgo: 4, 20, 5), .family, nil),
        ]
        let imported = seeds.map {
            GuestImportedEntry(legacyID: UUID(), originalWords: $0.words, createdAt: $0.date, updatedAt: $0.date, reflection: nil)
        }
        guard (try? await store.importLegacy(entries: imported, messages: [])) != nil,
              let entries = try? await store.loadAll() else { return }
        for seed in seeds {
            guard let entry = entries.first(where: { $0.originalWords == seed.words }) else { continue }
            _ = try? await store.updateTags(id: entry.id, context: seed.context, feeling: seed.feeling,
                                            expectedRevision: entry.revision)
        }
    }
    #endif

    /// The live composition at another location (tests use a temporary folder).
    static func local(at location: GuestJournalLocation) -> GuestComposition {
        GuestComposition(location: { location })
    }

    func makeViewModel() async throws -> GuestJournalViewModel {
        try await makeSession().journal
    }

    /// The journal and Practice, sharing one local store.
    func makeSession() async throws -> (journal: GuestJournalViewModel, practice: GuestPracticeViewModel) {
        GuestSettingsViewModel.removeExports() // Never leave an export behind from an earlier run.
        #if DEBUG
        // UI tests only: realistic earlier-app data in this app's own defaults (launch argument).
        // "guest" or "signedIn"; written to its own suite, so the real keys are never touched.
        if let kind = UserDefaults.standard.string(forKey: "CircleUSeedLegacyFixture"),
           let fixture = UserDefaults(suiteName: GuestLegacyFixture.suiteName) {
            fixture.removePersistentDomain(forName: GuestLegacyFixture.suiteName)
            GuestLegacyFixture.write(to: fixture, signedIn: kind == "signedIn")
            GuestLegacyImport.source = fixture
            // UI tests of the (currently switched off) copy path only.
            GuestLegacyImport.allowsUnverifiedOnDeviceImport = UserDefaults.standard.bool(forKey: "CircleUAllowUnverifiedImport")
        }
        #endif
        let location = try location()
        let store = try await SwiftDataGuestJournalStore.open(location: location)
        #if DEBUG
        // UI tests only: three dated, tagged entries for showcase captures (launch argument), after a reset.
        if UserDefaults.standard.bool(forKey: "CircleUSeedShowcase") { await Self.seedShowcase(into: store) }
        #endif
        // Drafts live in the store; a draft kept in an older file is moved across once.
        let writeDrafts = StoreGuestDraftStore(store: store, slot: StoreGuestDraftStore.writeSlot)
        let practiceDrafts = StoreGuestDraftStore(store: store, slot: StoreGuestDraftStore.practiceSlot)
        let writeAdoption = await writeDrafts.adoptLegacyFile(FileGuestDraftStore(location: location), named: "Draft.json")
        let practiceAdoption = await practiceDrafts.adoptLegacyFile(
            FileGuestDraftStore(location: location, fileName: "PracticeDraft.json"), named: "PracticeDraft.json")
        let viewModel = GuestJournalViewModel(store: store, drafts: writeDrafts)
        await viewModel.load()
        await viewModel.restoreDraft() // After load, so a leftover draft can be matched to saved entries.
        if writeAdoption != .done { viewModel.noteUnreadableDraft() } // The older file is left untouched.
        let practice = GuestPracticeViewModel(store: store, suggester: suggester(), drafts: practiceDrafts)
        practice.makeDictationEngine = dictationEngine
        await practice.load()
        await practice.loadDraft()
        if practiceAdoption != .done { practice.noteUnreadableDraft() }
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
    /// First launch shows Welcome; a new key, separate from the earlier app's onboarding flag.
    @AppStorage("circleu.guest.welcomeSeen.v1") private var welcomeSeen = false
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
            if !welcomeSeen, let importer = practice.store as? any GuestImportStore {
                GuestWelcomeView(store: importer, journal: viewModel, practice: practice) { welcomeSeen = true }
            } else {
                GuestHomeView(journal: viewModel, practice: practice, makeDictationEngine: composition.dictationEngine,
                              suggester: composition.suggester())
            }
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
