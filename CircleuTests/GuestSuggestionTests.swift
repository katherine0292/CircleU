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
        try FileManager.default.createDirectory(at: location.directory, withIntermediateDirectories: true)
        do {
            let container = try ModelContainer(for: Schema(versionedSchema: GuestJournalSchemaV2.self),
                                               configurations: ModelConfiguration(url: location.storeURL,
                                                                                  cloudKitDatabase: .none))
            let context = ModelContext(container)
            let now = Date()
            context.insert(GuestJournalSchemaV2.Entry(id: entryID, originalWords: "Before suggestions", revision: 1,
                                                      createdAt: now, updatedAt: now))
            context.insert(GuestJournalSchemaV2.PracticeMessage(id: messageID, situation: "", goal: "", wording: "Hi",
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
