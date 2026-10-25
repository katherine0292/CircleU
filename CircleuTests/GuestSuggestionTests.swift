import Foundation
import SwiftData
import XCTest
@testable import Circleu

/// Returns fixed suggestions, or fails, so tests don't depend on the model or templates.
private struct FakeSuggester: GuestSuggesting {
    var fail = false
    var source: GuestSuggestionSource = .onDevice

    func reflection(for words: String) async throws -> GuestReflectionSuggestion {
        if fail { throw GuestSuggestionError.noWords }
        return GuestReflectionSuggestion(summary: "Summary of: \(words)", feeling: "Frustrated",
                                         insight: "Fairness matters to you.", nextStep: "Ask for a check-in.",
                                         source: source)
    }

    func wordingOptions(situation: String, goal: String, draft: String) async throws -> GuestWordingSuggestions {
        if fail { throw GuestSuggestionError.noWords }
        return GuestWordingSuggestions(options: [GuestWordingOption(tone: "Gentle", text: "Gentle option"),
                                                 GuestWordingOption(tone: "Clear", text: "Clear option")],
                                       source: source)
    }
}

/// Fails saves on demand inside the real store.
private final class SaveSwitch: @unchecked Sendable {
    private let lock = NSLock()
    private var value = false
    var fail: Bool {
        get { lock.withLock { value } }
        set { lock.withLock { value = newValue } }
    }
    var faults: GuestJournalFaults {
        GuestJournalFaults(beforeSave: { [self] in if fail { throw CocoaError(.fileWriteOutOfSpace) } })
    }
}

final class GuestReflectionStoreTests: XCTestCase {
    private var root: URL!
    private var location: GuestJournalLocation!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("GuestReflectionTests-\(UUID())")
        location = GuestJournalLocation(directory: root.appendingPathComponent("Journal"),
                                        setupMarker: root.appendingPathComponent("Setup/initialized"))
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: root)
    }

    private func open() async throws -> SwiftDataGuestJournalStore {
        try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in })
    }

    private let reflection = GuestReflection(summary: "A missed deadline", feeling: "Let down",
                                             insight: "Reliability matters to you.", source: .guided,
                                             basedOnWords: "My groupmate missed it")

    func testReflectionAndNextStepAreSavedWithTheWordsAndSurviveReopen() async throws {
        var store: SwiftDataGuestJournalStore? = try await open()
        let created = try await store!.create(originalWords: "My groupmate missed it", draftID: UUID(),
                                              reflection: reflection, nextStep: "Message them tonight")
        XCTAssertEqual(created.reflection, reflection)
        store = nil

        let reopened = try await open()
        let entry = try await reopened.loadAll().first
        XCTAssertEqual(entry?.originalWords, "My groupmate missed it", "own words kept as written")
        XCTAssertEqual(entry?.reflection, reflection)
        XCTAssertEqual(entry?.nextStep, "Message them tonight")
        XCTAssertEqual(entry?.nextStepDone, false)
        XCTAssertEqual(entry?.isReflectionStale, false)
    }

    func testNextStepCanBeDoneUndoneAndRemovedWithRevisions() async throws {
        let store = try await open()
        let created = try await store.create(originalWords: "Words", draftID: nil, reflection: nil, nextStep: "Step")
        let done = try await store.updateReflection(id: created.id, reflection: nil, nextStep: "Step",
                                                    nextStepDone: true, expectedRevision: 0)
        XCTAssertTrue(done.nextStepDone)
        let undone = try await store.updateReflection(id: created.id, reflection: nil, nextStep: "Step",
                                                      nextStepDone: false, expectedRevision: 1)
        XCTAssertFalse(undone.nextStepDone, "reversible")
        let removed = try await store.updateReflection(id: created.id, reflection: nil, nextStep: nil,
                                                       nextStepDone: false, expectedRevision: 2)
        XCTAssertNil(removed.nextStep)
        do {
            _ = try await store.updateReflection(id: created.id, reflection: nil, nextStep: "Old", nextStepDone: false,
                                                 expectedRevision: 0)
            XCTFail("stale")
        } catch {
            XCTAssertEqual(error as? GuestJournalError, .staleRevision(current: 3, expected: 0))
        }
    }

    func testEditingTheWordsMarksTheReflectionAsEarlierAndRemovingItKeepsTheWords() async throws {
        let store = try await open()
        let created = try await store.create(originalWords: "My groupmate missed it", draftID: nil,
                                             reflection: reflection, nextStep: nil)
        let edited = try await store.update(id: created.id, originalWords: "My groupmate missed it again",
                                            expectedRevision: 0)
        XCTAssertTrue(edited.isReflectionStale)
        let removed = try await store.updateReflection(id: created.id, reflection: nil, nextStep: nil,
                                                       nextStepDone: false, expectedRevision: 1)
        XCTAssertNil(removed.reflection)
        XCTAssertEqual(removed.originalWords, "My groupmate missed it again")
    }

    func testVersionTwoStoreMigratesWithEntriesAndPractice() async throws {
        let entryID = UUID()
        let messageID = UUID()
        let draftID = UUID()
        let created = Date(timeIntervalSince1970: 1_800_000_000)
        try FileManager.default.createDirectory(at: location.directory, withIntermediateDirectories: true)
        do {
            let container = try ModelContainer(for: Schema(versionedSchema: GuestJournalSchemaV2.self),
                                               configurations: ModelConfiguration(url: location.storeURL,
                                                                                  cloudKitDatabase: .none))
            let context = ModelContext(container)
            let now = created
            context.insert(GuestJournalSchemaV2.Entry(id: entryID, originalWords: "Before suggestions", revision: 1,
                                                      createdAt: now, updatedAt: now))
            context.insert(GuestJournalSchemaV2.SavedDraft(id: draftID, savedAt: now))
            context.insert(GuestJournalSchemaV2.PracticeMessage(id: messageID, situation: "Rent", goal: "Fair split", wording: "Hi",
                                                                sourceEntryID: entryID, revision: 0,
                                                                createdAt: now, updatedAt: now))
            try context.save()
        }
        try FileManager.default.createDirectory(at: location.setupMarker.deletingLastPathComponent(),
                                                withIntermediateDirectories: true)
        try Data().write(to: location.setupMarker)

        let store = try await open()
        let entries = try await store.loadAll()
        let messages = try await store.loadPractice()
        XCTAssertEqual(entries.map(\.id), [entryID])
        XCTAssertEqual(entries.first?.revision, 1)
        XCTAssertNil(entries.first?.reflection, "no reflection invented by the migration")
        XCTAssertNil(entries.first?.nextStep)
        XCTAssertEqual(messages.map(\.id), [messageID])
        XCTAssertEqual(messages.first?.sourceEntryID, entryID)
        XCTAssertEqual(entries.first?.originalWords, "Before suggestions")
        XCTAssertEqual(entries.first?.createdAt.timeIntervalSince1970 ?? 0, created.timeIntervalSince1970, accuracy: 0.001)
        XCTAssertEqual(messages.first?.situation, "Rent")
        XCTAssertEqual(messages.first?.goal, "Fair split")
        XCTAssertEqual(messages.first?.wording, "Hi")
        let receiptKept = try await store.isDraftSaved(draftID)
        XCTAssertTrue(receiptKept, "saved-draft receipts survive")
    }

    func testVersionThreeStoreMigratesWithReflectionsStepsLinksAndReceipts() async throws {
        let entryID = UUID(), messageID = UUID(), draftID = UUID()
        let created = Date(timeIntervalSince1970: 1_800_000_000)
        try FileManager.default.createDirectory(at: location.directory, withIntermediateDirectories: true)
        do {
            let container = try ModelContainer(for: Schema(versionedSchema: GuestJournalSchemaV3.self),
                                               configurations: ModelConfiguration(url: location.storeURL,
                                                                                  cloudKitDatabase: .none))
            let context = ModelContext(container)
            let entry = GuestJournalSchemaV3.Entry(id: entryID, originalWords: "Before drafts moved", revision: 2,
                                                   createdAt: created, updatedAt: created)
            entry.reflectionSummary = "Summary"
            entry.reflectionFeeling = "Calm"
            entry.reflectionInsight = "Insight"
            entry.reflectionSource = GuestSuggestionSource.guided.rawValue
            entry.reflectionBasedOn = "Before drafts moved"
            entry.nextStep = "Step"
            entry.nextStepDoneAt = created
            context.insert(entry)
            context.insert(GuestJournalSchemaV3.SavedDraft(id: draftID, savedAt: created))
            context.insert(GuestJournalSchemaV3.PracticeMessage(id: messageID, situation: "S", goal: "G", wording: "W",
                                                                sourceEntryID: entryID, revision: 1,
                                                                createdAt: created, updatedAt: created))
            try context.save()
        }
        try FileManager.default.createDirectory(at: location.setupMarker.deletingLastPathComponent(),
                                                withIntermediateDirectories: true)
        try Data().write(to: location.setupMarker)

        let store = try await open()
        let entries = try await store.loadAll()
        let entry = try XCTUnwrap(entries.first)
        XCTAssertEqual(entry.id, entryID)
        XCTAssertEqual(entry.revision, 2)
        XCTAssertEqual(entry.reflection, GuestReflection(summary: "Summary", feeling: "Calm", insight: "Insight",
                                                         source: .guided, basedOnWords: "Before drafts moved"))
        XCTAssertEqual(entry.nextStep, "Step")
        XCTAssertTrue(entry.nextStepDone)
        let messages = try await store.loadPractice()
        let message = try XCTUnwrap(messages.first)
        XCTAssertEqual(message.id, messageID)
        XCTAssertEqual(message.sourceEntryID, entryID)
        XCTAssertEqual(message.revision, 1)
        let receipt = try await store.isDraftSaved(draftID)
        XCTAssertTrue(receipt)
        let draft = try await store.keptDraft(slot: StoreGuestDraftStore.writeSlot)
        XCTAssertNil(draft, "no draft invented")
    }

    func testFailedReflectionUpdateKeepsTheEntryAsItWas() async throws {
        let faults = SaveSwitch()
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in },
                                                              faults: faults.faults)
        let created = try await store.create(originalWords: "Words", draftID: nil, reflection: reflection,
                                             nextStep: "Step")
        faults.fail = true
        do {
            _ = try await store.updateReflection(id: created.id, reflection: nil, nextStep: nil, nextStepDone: false,
                                                 expectedRevision: 0)
            XCTFail("expected saveFailed")
        } catch {
            guard case .saveFailed = error as? GuestJournalError else { return XCTFail("got \(error)") }
        }
        faults.fail = false
        let entry = try await store.loadAll().first
        XCTAssertEqual(entry?.reflection, reflection, "rolled back")
        XCTAssertEqual(entry?.nextStep, "Step")
        XCTAssertEqual(entry?.revision, 0)
    }
}

@MainActor
final class GuestSuggestionViewModelTests: XCTestCase {
    private var root: URL!

    override func setUp() {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("GuestSuggestionVM-\(UUID())")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: root)
    }

    private func session() async throws -> (journal: GuestJournalViewModel, practice: GuestPracticeViewModel) {
        let location = GuestJournalLocation(directory: root.appendingPathComponent("Journal"),
                                            setupMarker: root.appendingPathComponent("Setup/initialized"))
        return try await GuestComposition.local(at: location).makeSession()
    }

    func testEditedSuggestionIsSavedApartFromTheWords() async throws {
        let (journal, _) = try await session()
        journal.draft = "My groupmate missed the deadline"
        let review = GuestReflectionReviewViewModel(journal: journal, suggester: FakeSuggester())
        await review.load()
        XCTAssertEqual(review.state, .ready)
        review.feeling = "Disappointed"
        review.insight = ""
        XCTAssertEqual(review.nextStep, "", "a next step is never kept by default")
        XCTAssertEqual(review.suggestedNextStep, "Ask for a check-in.")
        review.addSuggestedStep()
        XCTAssertTrue(review.hasEdits, "leaving now asks first")
        let saved = await review.saveWithReflection()
        XCTAssertTrue(saved)
        let entry = journal.entries.first
        XCTAssertEqual(entry?.originalWords, "My groupmate missed the deadline")
        XCTAssertEqual(entry?.reflection?.feeling, "Disappointed", "the person's edit is kept")
        XCTAssertEqual(entry?.reflection?.insight, "")
        XCTAssertEqual(entry?.reflection?.source, .onDevice)
        XCTAssertEqual(entry?.nextStep, "Ask for a check-in.")
        XCTAssertEqual(journal.draft, "")
    }

    func testSuggestedStepIsNotSavedUnlessAdded() async throws {
        let (journal, _) = try await session()
        journal.draft = "Words"
        let review = GuestReflectionReviewViewModel(journal: journal, suggester: FakeSuggester())
        await review.load()
        XCTAssertFalse(review.hasEdits, "an untouched suggestion can be left without asking")
        _ = await review.saveWithReflection()
        XCTAssertNotNil(journal.entries.first?.reflection)
        XCTAssertNil(journal.entries.first?.nextStep)
    }

    func testReflectionOnWordsAlreadySavedKeepsTheReviewOpen() async throws {
        let location = GuestJournalLocation(directory: root.appendingPathComponent("Journal"),
                                            setupMarker: root.appendingPathComponent("Setup/initialized"))
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in })
        let drafts = FileGuestDraftStore(location: location, protection: .init { _ in })
        let journal = GuestJournalViewModel(store: store, drafts: drafts)
        journal.draft = "Saved once"
        await journal.flushDraft()
        let kept = try await drafts.load()
        // The same draft version was saved earlier (its cleanup didn't finish).
        _ = try await store.create(originalWords: "Saved once", draftID: kept?.id)
        let review = GuestReflectionReviewViewModel(journal: journal, suggester: FakeSuggester())
        await review.load()
        let saved = await review.saveWithReflection()
        XCTAssertFalse(saved, "the review stays open; the reflection wasn't stored")
        XCTAssertEqual(journal.saveError, GuestJournalViewModel.reflectionNotAddedMessage)
        XCTAssertEqual(journal.draft, "Saved once")
    }

    func testPracticeSuggestionsBecomeStaleWhenTheirInputsChange() async throws {
        let (_, practice) = try await session()
        let composer = GuestPracticeComposerViewModel(store: practice.store, sourceEntryID: nil,
                                                      suggester: FakeSuggester())
        composer.situation = "Rent"
        await composer.suggest()
        XCTAssertFalse(composer.suggestionsAreStale)
        composer.situation = "Rent and chores"
        XCTAssertTrue(composer.suggestionsAreStale)
        composer.situation = "Rent"
        XCTAssertFalse(composer.suggestionsAreStale)
        composer.use(composer.suggestions!.options[0])
        XCTAssertFalse(composer.suggestionsAreStale, "using an option isn't a change of inputs")
        composer.wording = "My own rewrite"
        XCTAssertTrue(composer.suggestionsAreStale, "a manual rewrite is")
        composer.undoSuggestion()
        XCTAssertFalse(composer.suggestionsAreStale)
    }

    func testClearingEverythingSavesOnlyTheWords() async throws {
        let (journal, _) = try await session()
        journal.draft = "Just my words"
        let review = GuestReflectionReviewViewModel(journal: journal, suggester: FakeSuggester())
        await review.load()
        review.summary = ""; review.feeling = " "; review.insight = ""; review.nextStep = ""
        XCTAssertNil(review.keptReflection)
        XCTAssertNil(review.keptNextStep)
        let saved = await review.saveWithReflection()
        XCTAssertTrue(saved)
        XCTAssertNil(journal.entries.first?.reflection)
        XCTAssertNil(journal.entries.first?.nextStep)
    }

    func testFailedSuggestionStillLetsTheWordsBeSaved() async throws {
        let (journal, _) = try await session()
        journal.draft = "Words to keep"
        let review = GuestReflectionReviewViewModel(journal: journal, suggester: FakeSuggester(fail: true))
        await review.load()
        XCTAssertEqual(review.state, .failed)
        XCTAssertNil(review.keptReflection)
        let saved = await review.saveWordsOnly()
        XCTAssertTrue(saved)
        XCTAssertEqual(journal.entries.map(\.originalWords), ["Words to keep"])
    }

    func testChangedWordsMarkTheSuggestionStale() async throws {
        let (journal, _) = try await session()
        journal.draft = "First words"
        let review = GuestReflectionReviewViewModel(journal: journal, suggester: FakeSuggester())
        await review.load()
        XCTAssertFalse(review.isStale)
        journal.draft = "First words, changed"
        XCTAssertTrue(review.isStale)
        await review.load()
        XCTAssertFalse(review.isStale, "updated")
    }

    func testNextStepIsVoluntaryAndReversibleFromTheEntry() async throws {
        let (journal, _) = try await session()
        journal.draft = "Words"
        let review = GuestReflectionReviewViewModel(journal: journal, suggester: FakeSuggester())
        await review.load()
        review.addSuggestedStep()
        _ = await review.saveWithReflection()
        var entry = try XCTUnwrap(journal.entries.first)
        var error = await journal.updateReflection(of: entry, reflection: entry.reflection, nextStep: entry.nextStep,
                                                   nextStepDone: true)
        XCTAssertNil(error)
        entry = try XCTUnwrap(journal.entries.first)
        XCTAssertTrue(entry.nextStepDone)
        error = await journal.updateReflection(of: entry, reflection: nil, nextStep: entry.nextStep,
                                               nextStepDone: false)
        XCTAssertNil(error)
        entry = try XCTUnwrap(journal.entries.first)
        XCTAssertNil(entry.reflection, "reflection removed")
        XCTAssertFalse(entry.nextStepDone, "and undone")
        XCTAssertEqual(entry.originalWords, "Words")
    }

    func testPracticeSuggestionsFillWordingOnlyWhenChosenAndCanBeUndone() async throws {
        let (_, practice) = try await session()
        let composer = GuestPracticeComposerViewModel(store: practice.store, sourceEntryID: nil,
                                                      suggester: FakeSuggester(source: .guided))
        composer.wording = "My own start"
        await composer.suggest()
        XCTAssertEqual(composer.suggestions?.options.count, 2)
        XCTAssertEqual(composer.suggestions?.source, .guided)
        XCTAssertEqual(composer.wording, "My own start", "nothing changes until an option is chosen")
        composer.use(composer.suggestions!.options[1])
        XCTAssertEqual(composer.wording, "Clear option")
        composer.undoSuggestion()
        XCTAssertEqual(composer.wording, "My own start")
        XCTAssertNil(composer.saved, "suggestions never save")
    }

    func testFailedPracticeSuggestionKeepsWording() async throws {
        let (_, practice) = try await session()
        let composer = GuestPracticeComposerViewModel(store: practice.store, sourceEntryID: nil,
                                                      suggester: FakeSuggester(fail: true))
        composer.wording = "Unchanged"
        await composer.suggest()
        XCTAssertNil(composer.suggestions)
        XCTAssertEqual(composer.suggestionError, GuestPracticeComposerViewModel.suggestionFailedMessage)
        XCTAssertEqual(composer.wording, "Unchanged")
    }

    func testGuidedEngineIsLabelledAndUsesOnlyWhatWasTyped() async throws {
        let engine = LocalFirstSuggestionEngine(guidedOnly: true)
        let reflection = try await engine.reflection(for: "I felt stressed and overwhelmed by the group project")
        XCTAssertEqual(reflection.source, .guided)
        XCTAssertFalse(reflection.summary.isEmpty)
        let options = try await engine.wordingOptions(situation: "The group project", goal: "Split the work fairly",
                                                      draft: "")
        XCTAssertEqual(options.source, .guided)
        XCTAssertEqual(options.options.map(\.tone), ["Gentle", "Clear", "Firm"])
        XCTAssertTrue(options.options.allSatisfy { $0.text.contains("the group project") && $0.text.contains("split the work fairly") })
        do {
            _ = try await engine.reflection(for: "   ")
            XCTFail("no words, no suggestion")
        } catch {
            XCTAssertEqual(error as? GuestSuggestionError, .noWords)
        }
        XCTAssertTrue(GuestSuggestionSource.guided.label.contains("not a personal analysis"))
    }
}
