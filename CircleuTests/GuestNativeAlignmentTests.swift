import XCTest
import os
@testable import Circleu

@MainActor
final class GuestNativeAlignmentTests: XCTestCase {
    func testFailedSaveKeepsQuestionAndWords() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let location = GuestJournalLocation(directory: root.appendingPathComponent("Journal"),
                                            setupMarker: root.appendingPathComponent("Setup/initialized"))
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in },
            faults: .init(beforeSave: { throw CocoaError(.fileWriteOutOfSpace) }))
        let journal = GuestJournalViewModel(store: store)
        journal.draft = "My punctuation: stays!"
        journal.selectedQuestion = .feeling
        let saved = await journal.saveDraft()
        XCTAssertFalse(saved)
        XCTAssertEqual(journal.draft, "My punctuation: stays!")
        XCTAssertEqual(journal.selectedQuestion, .feeling)
    }

    func testTagPickerRejectsStaleSaveAndKeepsChoicesWithoutOverwritingWords() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let location = GuestJournalLocation(directory: root.appendingPathComponent("Journal"),
                                            setupMarker: root.appendingPathComponent("Setup/initialized"))
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in })
        let entry = try await store.create(originalWords: "Old")
        let journal = GuestJournalViewModel(store: store)
        let picker = GuestEntryTagViewModel(entry: entry, journal: journal)
        picker.context = .study; picker.feeling = .calm
        _ = try await store.update(id: entry.id, originalWords: "New", expectedRevision: 0)
        let saved = await picker.save()
        XCTAssertFalse(saved)
        XCTAssertEqual(picker.context, .study)
        XCTAssertEqual(picker.feeling, .calm)
        XCTAssertNotNil(picker.error)
        XCTAssertTrue(picker.needsReopen)
        XCTAssertEqual(journal.entries.first?.originalWords, "New")
        XCTAssertNil(journal.entries.first?.context)
    }

    func testTagPickerFailedSaveKeepsChoicesAndCanRetry() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let location = GuestJournalLocation(directory: root.appendingPathComponent("Journal"),
                                            setupMarker: root.appendingPathComponent("Setup/initialized"))
        let failSave = OSAllocatedUnfairLock(initialState: false)
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in },
            faults: .init(beforeSave: {
                if failSave.withLock({ $0 }) { throw CocoaError(.fileWriteOutOfSpace) }
            }))
        let entry = try await store.create(originalWords: "Keep my words")
        let journal = GuestJournalViewModel(store: store)
        let picker = GuestEntryTagViewModel(entry: entry, journal: journal)
        picker.context = .friends; picker.feeling = .worried
        failSave.withLock { $0 = true }
        let first = await picker.save()
        XCTAssertFalse(first)
        XCTAssertFalse(picker.isSaving)
        XCTAssertFalse(picker.needsReopen)
        XCTAssertEqual(picker.error, GuestJournalViewModel.saveFailedMessage)
        XCTAssertEqual(picker.context, .friends)
        XCTAssertEqual(picker.feeling, .worried)
        let unchanged = try await store.loadAll()
        XCTAssertEqual(unchanged.first, entry)
        failSave.withLock { $0 = false }
        let retry = await picker.save()
        XCTAssertTrue(retry)
        XCTAssertNil(picker.error)
        XCTAssertEqual(journal.entries.first?.originalWords, entry.originalWords)
        XCTAssertEqual(journal.entries.first?.context, .friends)
        XCTAssertEqual(journal.entries.first?.feeling, .worried)
        XCTAssertEqual(journal.entries.first?.revision, 1)
    }

    func testJournalGroupingUsesCreationDayRatherThanLastEdit() {
        let old = Date(timeIntervalSince1970: 100_000), recent = old.addingTimeInterval(86_400)
        let earlier = GuestJournalEntry(id: UUID(), originalWords: "Earlier", revision: 2,
                                        createdAt: old, updatedAt: recent.addingTimeInterval(500))
        let later = GuestJournalEntry(id: UUID(), originalWords: "Later", revision: 0,
                                      createdAt: recent, updatedAt: recent)
        let groups = GuestJournalDayGroup.make([earlier, later])
        XCTAssertEqual(groups.count, 2)
        XCTAssertEqual(groups.first?.entries.first?.id, later.id)
        XCTAssertEqual(groups.last?.entries.first?.id, earlier.id)
    }
}
