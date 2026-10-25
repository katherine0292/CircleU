import Foundation
import XCTest
@testable import Circleu

@MainActor
final class GuestFindAndControlTests: XCTestCase {
    private var root: URL!
    private var location: GuestJournalLocation!

    override func setUp() {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("GuestFindControl-\(UUID())")
        location = GuestJournalLocation(directory: root.appendingPathComponent("Journal"),
                                        setupMarker: root.appendingPathComponent("Setup/initialized"))
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: root)
    }

    private func entry(_ words: String, on date: Date = Date(), reflection: GuestReflection? = nil,
                       nextStep: String? = nil, done: Bool = false) -> GuestJournalEntry {
        GuestJournalEntry(id: UUID(), originalWords: words, revision: 0, createdAt: date, updatedAt: date,
                          reflection: reflection, nextStep: nextStep, nextStepDone: done)
    }

    // MARK: Search

    func testSearchCoversWordsReflectionAndStepIgnoringCaseAndAccents() {
        let reflection = GuestReflection(summary: "A tense café meeting", feeling: "Anxious", insight: "",
                                         source: .guided, basedOnWords: "x")
        let item = entry("Talked to my manager", reflection: reflection, nextStep: "Book a follow-up")
        XCTAssertTrue(GuestSearch.matches(item, "MANAGER"))
        XCTAssertTrue(GuestSearch.matches(item, "cafe"), "accent-insensitive")
        XCTAssertTrue(GuestSearch.matches(item, "anxious"))
        XCTAssertTrue(GuestSearch.matches(item, "follow-up"))
        XCTAssertTrue(GuestSearch.matches(item, "  "), "empty query shows everything")
        XCTAssertFalse(GuestSearch.matches(item, "holiday"))
        let message = GuestPracticeMessage(id: UUID(), situation: "Rent", goal: "Fair split", wording: "Can we talk?",
                                           sourceEntryID: nil, revision: 0, createdAt: Date(), updatedAt: Date())
        XCTAssertTrue(GuestSearch.matches(message, "fair"))
        XCTAssertFalse(GuestSearch.matches(message, "manager"))
    }

    // MARK: Calendar

    func testCalendarLaysOutTheMonthAndCountsEntriesPerDay() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        calendar.firstWeekday = 2 // Monday
        let october = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 10, day: 15)))
        let oct25 = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 10, day: 25, hour: 9)))
        let oct25Late = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 10, day: 25, hour: 23)))
        let nov1 = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 11, day: 1)))
        let entries = [entry("a", on: oct25), entry("b", on: oct25Late), entry("c", on: nov1)]
        let days = GuestCalendarModel.days(in: october, entries: entries, calendar: calendar)
        // 1 October 2026 is a Thursday: three blank cells before it when weeks start on Monday.
        XCTAssertEqual(days.prefix(3).map(\.date), [nil, nil, nil])
        XCTAssertEqual(days.compactMap(\.date).count, 31)
        let day25 = days.first { $0.date.map { calendar.component(.day, from: $0) } == 25 }
        XCTAssertEqual(day25?.entryCount, 2)
        XCTAssertEqual(days.reduce(0) { $0 + $1.entryCount }, 2, "November isn't counted in October")
        XCTAssertEqual(GuestCalendarModel.entries(on: oct25, in: entries, calendar: calendar).count, 2)
    }

    // MARK: Export

    func testExportIsReadableAndCompleteAndLabelsSuggestions() {
        let source = entry("My groupmate missed the deadline",
                           reflection: GuestReflection(summary: "A missed deadline", feeling: "Let down", insight: "",
                                                       source: .guided, basedOnWords: "My groupmate missed the deadline"),
                           nextStep: "Message them", done: true)
        let message = GuestPracticeMessage(id: UUID(), situation: "Group work", goal: "", wording: "Can we talk?",
                                           sourceEntryID: source.id, revision: 0, createdAt: Date(), updatedAt: Date())
        let text = GuestExport.text(entries: [source], messages: [message])
        XCTAssertTrue(text.contains("1 journal entry and 1 practice message."))
        XCTAssertTrue(text.contains("My words:\nMy groupmate missed the deadline"))
        XCTAssertTrue(text.contains("Reflection (guided prompts):"))
        XCTAssertTrue(text.contains("Feeling: Let down"))
        XCTAssertTrue(text.contains("Next step: Message them (done)"))
        XCTAssertTrue(text.contains("From: My groupmate missed the deadline"))
        XCTAssertTrue(text.contains("Situation: Group work"))
        XCTAssertFalse(text.contains("Goal:"), "empty fields are left out")
        XCTAssertTrue(text.contains("Wording:\nCan we talk?"))
    }

    func testExportFileContainsTheJournal() async throws {
        let (journal, practice) = try await GuestComposition.local(at: location).makeSession()
        journal.draft = "Exported words"
        _ = await journal.saveDraft()
        let settings = GuestSettingsViewModel(journal: journal, practice: practice)
        let folder = root.appendingPathComponent("Export")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let made = await settings.makeExportFile(directory: folder)
        let url = try XCTUnwrap(made)
        let text = try String(contentsOf: url, encoding: .utf8)
        XCTAssertTrue(text.contains("Exported words"))
        XCTAssertNil(settings.message)
    }

    // MARK: Delete all

    func testDeleteAllRemovesEverythingInTheGuestJournalOnly() async throws {
        let legacyKey = "circleu.test.legacy.\(UUID())"
        UserDefaults.standard.set("old app data", forKey: legacyKey)
        defer { UserDefaults.standard.removeObject(forKey: legacyKey) }

        var (journal, practice) = try await GuestComposition.local(at: location).makeSession()
        journal.draft = "Saved entry"
        _ = await journal.saveDraft()
        _ = try await practice.store.createPractice(situation: "", goal: "", wording: "Saved message", sourceEntryID: nil)
        journal.draft = "Unsaved draft"
        practice.keepDraft(GuestPracticeDraft(wording: "Unsaved practice"))
        await journal.flushDraft()
        await practice.flushDraft()

        let settings = GuestSettingsViewModel(journal: journal, practice: practice)
        await settings.deleteAll()
        XCTAssertEqual(settings.message, GuestSettingsViewModel.deletedMessage)
        XCTAssertEqual(journal.entries, [])
        XCTAssertEqual(practice.messages, [])
        XCTAssertEqual(journal.draft, "")
        XCTAssertNil(practice.keptDraft)
        XCTAssertEqual(UserDefaults.standard.string(forKey: legacyKey), "old app data", "earlier app's data untouched")

        // Relaunch: nothing comes back, including drafts.
        journal = GuestJournalViewModel(store: journal.store, drafts: FileGuestDraftStore(location: location))
        await journal.load()
        await journal.restoreDraft()
        practice = GuestPracticeViewModel(store: practice.store,
                                          drafts: FileGuestDraftStore(location: location, fileName: "PracticeDraft.json"))
        await practice.load()
        await practice.loadDraft()
        XCTAssertEqual(journal.entries, [])
        XCTAssertEqual(journal.draft, "")
        XCTAssertEqual(practice.messages, [])
        XCTAssertNil(practice.keptDraft)
    }

    func testFailedDeleteAllRemovesNothing() async throws {
        let failing = FailingSwitch()
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in },
                                                              faults: failing.faults)
        let journal = GuestJournalViewModel(store: store)
        let practice = GuestPracticeViewModel(store: store)
        journal.draft = "Keep me"
        _ = await journal.saveDraft()
        _ = try await store.createPractice(situation: "", goal: "", wording: "Keep me too", sourceEntryID: nil)
        await practice.load()
        failing.on = true
        let settings = GuestSettingsViewModel(journal: journal, practice: practice)
        await settings.deleteAll()
        failing.on = false
        XCTAssertEqual(settings.message, GuestSettingsViewModel.deleteFailedMessage)
        await journal.load()
        await practice.load()
        XCTAssertEqual(journal.entries.map(\.originalWords), ["Keep me"])
        XCTAssertEqual(practice.messages.map(\.wording), ["Keep me too"])
    }

    // MARK: Practice drafts

    func testPracticeDraftSurvivesRelaunchAndIsClearedBySaving() async throws {
        let (_, practice) = try await GuestComposition.local(at: location).makeSession()
        let composer = GuestPracticeComposerViewModel(store: practice.store, sourceEntryID: nil, practice: practice)
        composer.situation = "Rent"
        composer.wording = "Could we split it?"
        await practice.flushDraft()

        let relaunched = GuestPracticeViewModel(store: practice.store,
                                                drafts: FileGuestDraftStore(location: location, fileName: "PracticeDraft.json"))
        await relaunched.loadDraft()
        let kept = try XCTUnwrap(relaunched.keptDraft)
        XCTAssertEqual(kept.situation, "Rent")
        XCTAssertEqual(kept.wording, "Could we split it?")
        XCTAssertNil(kept.sourceEntryID)

        let restored = GuestPracticeComposerViewModel(store: relaunched.store, sourceEntryID: nil, restoring: kept,
                                                      practice: relaunched)
        XCTAssertEqual(restored.wording, "Could we split it?")
        XCTAssertEqual(restored.draftID, kept.id)
        let saved = await restored.save()
        XCTAssertTrue(saved)
        relaunched.clearDraft(id: kept.id)
        await relaunched.flushDraft()
        await relaunched.loadDraft()
        XCTAssertNil(relaunched.keptDraft, "saved, so no draft is offered again")
    }

    func testExportIsRefusedWhenSomethingCantBeRead() async throws {
        let reads = FetchCounter(failFrom: Int.max)
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in },
                                                              faults: reads.faults)
        let journal = GuestJournalViewModel(store: store)
        let practice = GuestPracticeViewModel(store: store)
        journal.draft = "Words"
        _ = await journal.saveDraft()
        reads.failFrom = reads.count + 2 // The journal reads; Practice fails.
        let settings = GuestSettingsViewModel(journal: journal, practice: practice)
        let made = await settings.makeExportFile(directory: root.appendingPathComponent("Export"))
        XCTAssertNil(made, "never a partial export")
        XCTAssertEqual(settings.message, GuestSettingsViewModel.exportFailedMessage)
    }

    func testDeleteAllWithAFailedReadRemovesNothingNowOrLater() async throws {
        let reads = FetchCounter(failFrom: Int.max)
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in },
                                                              faults: reads.faults)
        _ = try await store.create(originalWords: "Kept")
        _ = try await store.createPractice(situation: "", goal: "", wording: "Kept too", sourceEntryID: nil)
        reads.failFrom = reads.count + 2 // Entries are read and marked; then reading messages fails.
        do {
            try await store.deleteAll(consumedDraftIDs: [])
            XCTFail("expected a read failure")
        } catch {}
        reads.failFrom = Int.max
        _ = try await store.create(originalWords: "A later save") // Must not commit stale deletions.
        let entries = try await store.loadAll()
        let messages = try await store.loadPractice()
        XCTAssertEqual(Set(entries.map(\.originalWords)), ["Kept", "A later save"])
        XCTAssertEqual(messages.map(\.wording), ["Kept too"])
    }

    func testDeleteAllThatCantMoveADraftRemovesNothing() async throws {
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in })
        let journal = GuestJournalViewModel(store: store, drafts: StuckDraftStore())
        let practice = GuestPracticeViewModel(store: store)
        journal.draft = "Saved"
        _ = await journal.saveDraft()
        let settings = GuestSettingsViewModel(journal: journal, practice: practice)
        await settings.deleteAll()
        XCTAssertEqual(settings.message, GuestSettingsViewModel.deleteFailedMessage)
        await journal.load()
        XCTAssertEqual(journal.entries.map(\.originalWords), ["Saved"])
    }

    func testFailedStoreDeletePutsDraftsBack() async throws {
        let failing = FailingSwitch()
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in },
                                                              faults: failing.faults)
        let journalDrafts = FileGuestDraftStore(location: location, protection: .init { _ in })
        let practiceDrafts = FileGuestDraftStore(location: location, fileName: "PracticeDraft.json", protection: .init { _ in })
        let journal = GuestJournalViewModel(store: store, drafts: journalDrafts)
        let practice = GuestPracticeViewModel(store: store, drafts: practiceDrafts)
        journal.draft = "Unsaved words"
        practice.keepDraft(GuestPracticeDraft(wording: "Unsaved practice"))
        await journal.flushDraft()
        await practice.flushDraft()
        failing.on = true
        let settings = GuestSettingsViewModel(journal: journal, practice: practice)
        await settings.deleteAll()
        failing.on = false
        XCTAssertEqual(settings.message, GuestSettingsViewModel.deleteFailedMessage)
        XCTAssertEqual(journal.draft, "Unsaved words")
        let journalKept = try await journalDrafts.load()
        XCTAssertEqual(journalKept?.text, "Unsaved words", "draft put back")
        let reloaded = GuestPracticeViewModel(store: store, drafts: practiceDrafts)
        await reloaded.loadDraft()
        XCTAssertEqual(reloaded.keptDraft?.wording, "Unsaved practice")
        journal.draft = "Still kept after a failed delete"
        await journal.flushDraft()
        let afterwards = try await journalDrafts.load()
        XCTAssertEqual(afterwards?.text, "Still kept after a failed delete", "drafts resume")
    }

    func testSavedPracticeDraftIsNeverOfferedAgain() async throws {
        let (_, practice) = try await GuestComposition.local(at: location).makeSession()
        let composer = GuestPracticeComposerViewModel(store: practice.store, sourceEntryID: nil, practice: practice)
        composer.wording = "Saved once"
        await practice.flushDraft()
        let saved = await composer.save()
        XCTAssertTrue(saved)
        // Cleanup "didn't finish": the draft file is still there.
        let drafts = FileGuestDraftStore(location: location, fileName: "PracticeDraft.json")
        let kept = try await drafts.load()
        XCTAssertNotNil(kept)
        let relaunched = GuestPracticeViewModel(store: practice.store, drafts: drafts)
        await relaunched.loadDraft()
        XCTAssertNil(relaunched.keptDraft, "the saved-draft receipt stops it coming back")
        await relaunched.flushDraft()
        let afterCleanup = try await drafts.load()
        XCTAssertNil(afterCleanup, "and the leftover file is removed")
    }

    func testUnreadablePracticeDraftIsLeftAlone() async throws {
        let drafts = FileGuestDraftStore(location: location, fileName: "PracticeDraft.json", protection: .init { _ in })
        try await drafts.save(id: UUID(), text: "not json")
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in })
        let practice = GuestPracticeViewModel(store: store, drafts: drafts)
        await practice.loadDraft()
        XCTAssertEqual(practice.draftWarning, GuestPracticeViewModel.draftUnreadableMessage)
        practice.keepDraft(GuestPracticeDraft(wording: "New text"))
        await practice.flushDraft()
        let kept = try await drafts.load()
        XCTAssertEqual(kept?.text, "not json", "never overwritten")
    }

    func testDeleteAllIgnoresWritesFromScreensOpenedBefore() async throws {
        let (journal, practice) = try await GuestComposition.local(at: location).makeSession()
        let openComposer = GuestPracticeComposerViewModel(store: practice.store, sourceEntryID: nil, practice: practice)
        openComposer.wording = "Typed before delete"
        await practice.flushDraft()
        await GuestSettingsViewModel(journal: journal, practice: practice).deleteAll()
        openComposer.wording = "Typed after delete on a stale screen"
        await practice.flushDraft()
        XCTAssertNil(practice.keptDraft)
        let kept = try await FileGuestDraftStore(location: location, fileName: "PracticeDraft.json").load()
        XCTAssertNil(kept, "a stale screen can't write deleted text back")
    }

    func testDraftsMovedAsideByAnInterruptedDeleteComeBackOnlyIfNothingWasDeleted() async throws {
        // Crash before the delete committed: the draft comes back.
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in })
        let drafts = FileGuestDraftStore(location: location, protection: .init { _ in })
        var journal = GuestJournalViewModel(store: store, drafts: drafts)
        journal.draft = "Unsaved words"
        await journal.flushDraft()
        _ = try await journal.stageDraftRemoval()
        journal = GuestJournalViewModel(store: store, drafts: FileGuestDraftStore(location: location, protection: .init { _ in }))
        await journal.load()
        await journal.restoreDraft()
        XCTAssertEqual(journal.draft, "Unsaved words", "not deleted, so not lost")

        // Crash after the delete committed: the draft never comes back.
        await journal.flushDraft()
        let consumed = try await journal.stageDraftRemoval()
        try await store.deleteAll(consumedDraftIDs: consumed)
        journal = GuestJournalViewModel(store: store, drafts: FileGuestDraftStore(location: location, protection: .init { _ in }))
        await journal.load()
        await journal.restoreDraft()
        await journal.flushDraft()
        XCTAssertEqual(journal.draft, "", "deleted, so it stays deleted")
        let leftover = try await FileGuestDraftStore(location: location, protection: .init { _ in }).load()
        XCTAssertNil(leftover, "and the leftover copy is cleaned up")
    }

    func testAnOpenScreenNeverReplacesAnotherKeptPracticeDraft() async throws {
        let (journal, practice) = try await GuestComposition.local(at: location).makeSession()
        journal.draft = "Entry"
        _ = await journal.saveDraft()
        let entryID = try XCTUnwrap(journal.entries.first?.id)
        let standalone = GuestPracticeComposerViewModel(store: practice.store, sourceEntryID: nil, practice: practice)
        let linked = GuestPracticeComposerViewModel(store: practice.store, sourceEntryID: entryID, practice: practice)
        linked.wording = "Linked draft"
        standalone.wording = "Standalone typing"
        await practice.flushDraft()
        XCTAssertEqual(practice.keptDraft?.wording, "Linked draft", "the first kept draft is not replaced")
        XCTAssertEqual(practice.draftWarning, GuestPracticeViewModel.otherDraftMessage)
    }

    func testExportUsesOneConsistentSnapshot() async throws {
        let (journal, practice) = try await GuestComposition.local(at: location).makeSession()
        journal.draft = "Entry one"
        _ = await journal.saveDraft()
        _ = try await practice.store.createPractice(situation: "", goal: "", wording: "Message one", sourceEntryID: nil)
        let folder = root.appendingPathComponent("Export")
        let made = await GuestSettingsViewModel(journal: journal, practice: practice).makeExportFile(directory: folder)
        let text = try String(contentsOf: try XCTUnwrap(made), encoding: .utf8)
        XCTAssertTrue(text.contains("1 journal entry and 1 practice message."))
        XCTAssertTrue(GuestSettingsViewModel.removeExports(in: folder))
        XCTAssertFalse(FileManager.default.fileExists(atPath: folder.path))
    }

    func testOnlyTheNewestScreenForADraftCanWriteIt() async throws {
        let (_, practice) = try await GuestComposition.local(at: location).makeSession()
        let first = GuestPracticeComposerViewModel(store: practice.store, sourceEntryID: nil, practice: practice)
        first.wording = "First screen"
        await practice.flushDraft()
        let kept = try XCTUnwrap(practice.keptDraft)
        let second = GuestPracticeComposerViewModel(store: practice.store, sourceEntryID: nil, restoring: kept,
                                                    practice: practice)
        second.wording = "Newer text on the second screen"
        first.goal = "A late edit on the older screen"
        await practice.flushDraft()
        XCTAssertEqual(practice.keptDraft?.wording, "Newer text on the second screen", "the older screen can't overwrite it")
        XCTAssertEqual(practice.draftWarning, GuestPracticeViewModel.otherDraftMessage)
    }

    func testAStagedDraftWithAnUnknownOutcomeIsLeftAloneAndNothingIsWritten() async throws {
        let reads = FetchCounter(failFrom: Int.max)
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in },
                                                              faults: reads.faults)
        let drafts = FileGuestDraftStore(location: location, protection: .init { _ in })
        var journal = GuestJournalViewModel(store: store, drafts: drafts)
        journal.draft = "Set aside"
        await journal.flushDraft()
        _ = try await journal.stageDraftRemoval() // Interrupted here.
        reads.failFrom = reads.count + 1 // The store can't be asked at the next launch.
        journal = GuestJournalViewModel(store: store, drafts: FileGuestDraftStore(location: location, protection: .init { _ in }))
        await journal.restoreDraft()
        reads.failFrom = Int.max
        XCTAssertEqual(journal.draft, "")
        XCTAssertEqual(journal.draftWarning, GuestJournalViewModel.draftUnreadableMessage)
        journal.draft = "New typing"
        await journal.flushDraft()
        let folder = location.directory
        let staged = try FileManager.default.contentsOfDirectory(atPath: folder.path).filter { $0.contains(".deleting-") }
        XCTAssertEqual(staged.count, 1, "the set-aside copy is untouched")
        let main = try await FileGuestDraftStore(location: location, protection: .init { _ in }).load()
        XCTAssertNil(main, "and nothing was written over it")
    }
}

/// Fails every fetch from the `failFrom`th onwards.
private final class FetchCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var fetches = 0
    private var threshold: Int
    init(failFrom: Int) { threshold = failFrom }
    var count: Int { lock.withLock { fetches } }
    var failFrom: Int {
        get { lock.withLock { threshold } }
        set { lock.withLock { threshold = newValue } }
    }
    var faults: GuestJournalFaults {
        GuestJournalFaults(beforeFetch: { [self] in
            let shouldFail = lock.withLock { () -> Bool in fetches += 1; return fetches >= threshold }
            if shouldFail { throw CocoaError(.fileReadUnknown) }
        })
    }
}

/// A draft store whose kept draft can't be moved aside.
private actor StuckDraftStore: GuestDraftStore {
    func load() throws -> KeptDraft? { nil }
    func save(id: UUID, text: String) throws {}
    func remove(id: UUID) throws {}
    func stageRemoval() throws -> UUID? { throw GuestJournalError.saveFailed("stuck") }
    func finishRemoval(commit: Bool) throws {}
    func recoverStaged(isConsumed: @escaping @Sendable (UUID) async -> Bool?) async throws -> Bool { true }
}

/// Fails saves while `on`, inside the real store.
private final class FailingSwitch: @unchecked Sendable {
    private let lock = NSLock()
    private var value = false
    var on: Bool {
        get { lock.withLock { value } }
        set { lock.withLock { value = newValue } }
    }
    var faults: GuestJournalFaults {
        GuestJournalFaults(beforeSave: { [self] in if on { throw CocoaError(.fileWriteOutOfSpace) } })
    }
}
