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

    func testExportDoneShowsOnlyAfterSharingAndCleanup() async throws {
        let (journal, practice) = try await GuestComposition.local(at: location).makeSession()
        let settings = GuestSettingsViewModel(journal: journal, practice: practice)
        settings.noteExportCleanup(succeeded: true, shared: false)
        XCTAssertNil(settings.message, "closing the share sheet without sharing says nothing")
        settings.noteExportCleanup(succeeded: true, shared: true)
        XCTAssertEqual(settings.message, "Export done. The copy you shared is yours to keep or delete.")
        settings.noteExportCleanup(succeeded: false, shared: true)
        XCTAssertEqual(settings.message, GuestSettingsViewModel.exportCleanupMessage, "a leftover copy is never hidden")
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

    private func store() async throws -> SwiftDataGuestJournalStore {
        try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in })
    }

    private func slot(_ store: SwiftDataGuestJournalStore, _ name: String) -> StoreGuestDraftStore {
        StoreGuestDraftStore(store: store, slot: name)
    }

    func testDeleteAllRemovesEverythingInTheGuestJournalOnly() async throws {
        let legacyKey = "circleu.test.legacy.\(UUID())"
        UserDefaults.standard.set("old app data", forKey: legacyKey)
        defer { UserDefaults.standard.removeObject(forKey: legacyKey) }

        let (journal, practice) = try await GuestComposition.local(at: location).makeSession()
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
        let (reopened, reopenedPractice) = try await GuestComposition.local(at: location).makeSession()
        XCTAssertEqual(reopened.entries, [])
        XCTAssertEqual(reopened.draft, "")
        XCTAssertEqual(reopenedPractice.messages, [])
        XCTAssertNil(reopenedPractice.keptDraft)
    }

    func testFailedDeleteAllRemovesNothingIncludingDrafts() async throws {
        let failing = FailingSwitch()
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in },
                                                              faults: failing.faults)
        let journal = GuestJournalViewModel(store: store, drafts: slot(store, StoreGuestDraftStore.writeSlot))
        let practice = GuestPracticeViewModel(store: store, drafts: slot(store, StoreGuestDraftStore.practiceSlot))
        journal.draft = "Keep me"
        _ = await journal.saveDraft()
        _ = try await store.createPractice(situation: "", goal: "", wording: "Keep me too", sourceEntryID: nil)
        journal.draft = "Unsaved words"
        practice.keepDraft(GuestPracticeDraft(wording: "Unsaved practice"))
        await journal.flushDraft()
        await practice.flushDraft()
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
        XCTAssertEqual(journal.draft, "Unsaved words")
        let keptWrite = try await slot(store, StoreGuestDraftStore.writeSlot).load()
        XCTAssertEqual(keptWrite?.text, "Unsaved words")
        XCTAssertEqual(practice.keptDraft?.wording, "Unsaved practice")
        journal.draft = "Still kept after a failed delete"
        await journal.flushDraft()
        let afterwards = try await slot(store, StoreGuestDraftStore.writeSlot).load()
        XCTAssertEqual(afterwards?.text, "Still kept after a failed delete", "drafts resume")
    }

    func testDeleteAllWithAFailedReadRemovesNothingNowOrLater() async throws {
        let reads = FetchCounter(failFrom: Int.max)
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in },
                                                              faults: reads.faults)
        _ = try await store.create(originalWords: "Kept")
        _ = try await store.createPractice(situation: "", goal: "", wording: "Kept too", sourceEntryID: nil)
        reads.failFrom = reads.count + 2 // Entries are read; then reading messages fails.
        do {
            try await store.deleteAll()
            XCTFail("expected a read failure")
        } catch {}
        reads.failFrom = Int.max
        _ = try await store.create(originalWords: "A later save") // Must not commit stale deletions.
        let entries = try await store.loadAll()
        let messages = try await store.loadPractice()
        XCTAssertEqual(Set(entries.map(\.originalWords)), ["Kept", "A later save"])
        XCTAssertEqual(messages.map(\.wording), ["Kept too"])
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
        let kept = try await slot(try await store(), StoreGuestDraftStore.practiceSlot).load()
        XCTAssertNil(kept, "a stale screen can't write deleted text back")
    }

    // MARK: Drafts in the store

    func testDraftsKeptInOlderFilesMoveIntoTheStoreOnce() async throws {
        let oldWrite = FileGuestDraftStore(location: location, protection: .init { _ in })
        let oldPractice = FileGuestDraftStore(location: location, fileName: "PracticeDraft.json", protection: .init { _ in })
        try await oldWrite.save(id: UUID(), text: "Words from before")
        let practiceDraft = String(data: try JSONEncoder().encode(GuestPracticeDraft(wording: "Practice from before")),
                                   encoding: .utf8)!
        try await oldPractice.save(id: UUID(), text: practiceDraft)

        let (journal, practice) = try await GuestComposition.local(at: location).makeSession()
        XCTAssertEqual(journal.draft, "Words from before")
        XCTAssertEqual(practice.keptDraft?.wording, "Practice from before")
        let leftWrite = try await oldWrite.load()
        let leftPractice = try await oldPractice.load()
        XCTAssertNil(leftWrite, "old file removed after moving")
        XCTAssertNil(leftPractice)
    }

    func testAnOlderDraftFileIsNeverImportedAgainAfterDeleteAll() async throws {
        let oldWrite = FileGuestDraftStore(location: location, protection: .init { _ in })
        try await oldWrite.save(id: UUID(), text: "From an older build")
        let (journal, practice) = try await GuestComposition.local(at: location).makeSession()
        XCTAssertEqual(journal.draft, "From an older build")
        await GuestSettingsViewModel(journal: journal, practice: practice).deleteAll()
        // The file comes back (say its removal failed): it's never imported again, and it's removed.
        try await oldWrite.save(id: UUID(), text: "From an older build")
        let (reopened, _) = try await GuestComposition.local(at: location).makeSession()
        XCTAssertEqual(reopened.draft, "", "deleted text doesn't come back")
        let leftover = try await oldWrite.load()
        XCTAssertNil(leftover, "the leftover file is removed")
    }

    func testDeleteAllRemovesAnUnreadableOlderDraftFile() async throws {
        let url = location.directory.appendingPathComponent("Draft.json")
        try FileManager.default.createDirectory(at: location.directory, withIntermediateDirectories: true)
        try Data([0xFF, 0xFE]).write(to: url)
        let (journal, practice) = try await GuestComposition.local(at: location).makeSession()
        XCTAssertEqual(journal.draftWarning, GuestJournalViewModel.olderDraftUnreadableMessage)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path), "left untouched until asked")
        let settings = GuestSettingsViewModel(journal: journal, practice: practice)
        await settings.deleteAll()
        XCTAssertEqual(settings.message, GuestSettingsViewModel.deletedMessage)
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
    }

    func testAdoptionNeverReplacesANewerDraftAndFailsClosedOnAReadError() async throws {
        let reads = FetchCounter(failFrom: Int.max)
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in },
                                                              faults: reads.faults)
        let slot = StoreGuestDraftStore(store: store, slot: StoreGuestDraftStore.writeSlot)
        try await slot.save(id: UUID(), text: "Newer draft in the store")
        let oldFile = FileGuestDraftStore(location: location, protection: .init { _ in })
        try await oldFile.save(id: UUID(), text: "Older file")
        reads.failFrom = reads.count + 1
        let failed = await slot.adoptLegacyFile(oldFile, named: "Draft.json")
        reads.failFrom = Int.max
        XCTAssertEqual(failed, .unknown)
        let untouched = try await oldFile.load()
        XCTAssertEqual(untouched?.text, "Older file", "nothing changed")
        let done = await slot.adoptLegacyFile(oldFile, named: "Draft.json")
        XCTAssertEqual(done, .done)
        let kept = try await slot.load()
        XCTAssertEqual(kept?.text, "Newer draft in the store", "never replaced by the older file")
        let gone = try await oldFile.load()
        XCTAssertNil(gone)
    }

    func testAScreenClosedByDeleteAllCantSave() async throws {
        let (journal, practice) = try await GuestComposition.local(at: location).makeSession()
        let open = GuestPracticeComposerViewModel(store: practice.store, sourceEntryID: nil, practice: practice)
        open.wording = "Typed before delete"
        await GuestSettingsViewModel(journal: journal, practice: practice).deleteAll()
        let saved = await open.save()
        XCTAssertFalse(saved)
        XCTAssertEqual(open.saveError, GuestPracticeComposerViewModel.closedByDeleteMessage)
        await practice.load()
        XCTAssertEqual(practice.messages, [], "nothing recreated")
    }

    func testABurstOfTypingIsCoalescedAndTheLatestTextIsKept() async throws {
        let counting = CountingDraftStore()
        let journal = GuestJournalViewModel(store: try await store(), drafts: counting)
        for length in 1...60 { journal.draft = String(repeating: "a", count: length) }
        await journal.flushDraft()
        let writes = await counting.writes
        let last = await counting.lastText
        XCTAssertLessThanOrEqual(writes, 3, "not one write per keystroke")
        XCTAssertEqual(last, String(repeating: "a", count: 60))
    }

    func testPracticeDraftSurvivesRelaunchAndIsClearedBySaving() async throws {
        let (_, practice) = try await GuestComposition.local(at: location).makeSession()
        let composer = GuestPracticeComposerViewModel(store: practice.store, sourceEntryID: nil, practice: practice)
        composer.situation = "Rent"
        composer.wording = "Could we split it?"
        await practice.flushDraft()

        let (_, relaunched) = try await GuestComposition.local(at: location).makeSession()
        let kept = try XCTUnwrap(relaunched.keptDraft)
        XCTAssertEqual(kept.situation, "Rent")
        XCTAssertEqual(kept.wording, "Could we split it?")
        let restored = GuestPracticeComposerViewModel(store: relaunched.store, sourceEntryID: nil, restoring: kept,
                                                      practice: relaunched)
        let saved = await restored.save()
        XCTAssertTrue(saved)
        relaunched.clearDraft(id: kept.id)
        await relaunched.flushDraft()
        let (_, again) = try await GuestComposition.local(at: location).makeSession()
        XCTAssertNil(again.keptDraft, "saved, so no draft is offered again")
    }

    func testSavedPracticeDraftIsNeverOfferedAgain() async throws {
        let (_, practice) = try await GuestComposition.local(at: location).makeSession()
        let composer = GuestPracticeComposerViewModel(store: practice.store, sourceEntryID: nil, practice: practice)
        composer.wording = "Saved once"
        await practice.flushDraft()
        let saved = await composer.save()
        XCTAssertTrue(saved)
        // Cleanup "didn't finish": the draft is still kept.
        let leftover = try await slot(try await store(), StoreGuestDraftStore.practiceSlot).load()
        XCTAssertNotNil(leftover)
        let (_, relaunched) = try await GuestComposition.local(at: location).makeSession()
        XCTAssertNil(relaunched.keptDraft, "the saved-draft receipt stops it coming back")
        await relaunched.flushDraft()
        let afterCleanup = try await slot(try await store(), StoreGuestDraftStore.practiceSlot).load()
        XCTAssertNil(afterCleanup, "and the leftover is removed")
    }

    func testUnreadablePracticeDraftIsLeftAlone() async throws {
        let store = try await store()
        let drafts = slot(store, StoreGuestDraftStore.practiceSlot)
        try await drafts.save(id: UUID(), text: "not json")
        let practice = GuestPracticeViewModel(store: store, drafts: drafts)
        await practice.loadDraft()
        XCTAssertEqual(practice.draftWarning, GuestPracticeViewModel.draftUnreadableMessage)
        practice.keepDraft(GuestPracticeDraft(wording: "New text"))
        await practice.flushDraft()
        let kept = try await drafts.load()
        XCTAssertEqual(kept?.text, "not json", "never overwritten")
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
        XCTAssertEqual(practice.keptDraft?.wording, "Linked draft", "the kept draft is not replaced")
        XCTAssertEqual(practice.draftWarning, GuestPracticeViewModel.otherDraftMessage)
    }

    func testOnlyTheNewestScreenForADraftCanWriteOrClearIt() async throws {
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

        // Saving from the older screen keeps its own text as a message and leaves the newer draft.
        XCTAssertFalse(first.ownsDraft)
        let savedOld = await first.save()
        XCTAssertTrue(savedOld)
        XCTAssertEqual(practice.keptDraft?.wording, "Newer text on the second screen")
        let savedNew = await second.save()
        XCTAssertTrue(savedNew, "the newer screen can still save its draft")
        await practice.load()
        XCTAssertEqual(practice.messages.count, 2)
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
}

/// Counts writes, to check that typing is coalesced.
private actor CountingDraftStore: GuestDraftStore {
    private(set) var writes = 0
    private(set) var lastText = ""
    func load() throws -> KeptDraft? { nil }
    func save(id: UUID, text: String) async throws {
        writes += 1
        lastText = text
        try? await Task.sleep(for: .milliseconds(5)) // Like a real write taking a moment.
    }
    func remove(id: UUID) throws {}
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
