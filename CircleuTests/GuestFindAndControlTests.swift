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

    func testExportFileIsWrittenOnlyWhenEverythingCouldBeRead() async throws {
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
