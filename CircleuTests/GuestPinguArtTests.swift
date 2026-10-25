import UIKit
import XCTest
@testable import Circleu

@MainActor
final class GuestPinguArtTests: XCTestCase {
    func testAll21AvatarsAndIconsAreBundled() {
        XCTAssertEqual(GuestAvatars.all.count, 21)
        XCTAssertEqual(Set(GuestAvatars.all.map(\.id)).count, 21, "no duplicates")
        XCTAssertTrue(GuestAvatars.all.allSatisfy { !$0.name.isEmpty }, "every avatar has a spoken name")
        let assets = GuestAvatars.all.map(\.id) + ["GuestIconToday", "GuestIconJournal", "GuestIconPractice",
                                                  "GuestIconReflection", "GuestIconFeelings", "GuestIconNextStep",
                                                  "GuestIconPrivacy", "GuestIconLogo"]
        for name in assets { XCTAssertNotNil(UIImage(named: name), name) }
        XCTAssertEqual(GuestAvatars.avatar(id: "unknown").id, GuestAvatars.defaultID, "falls back to the default")
    }

    func testDeleteAllResetsTheChosenPingu() async throws {
        UserDefaults.standard.set("GuestPinguMusic", forKey: GuestAvatars.storageKey)
        defer { GuestAvatars.reset() }
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("GuestArt-\(UUID())")
        defer { try? FileManager.default.removeItem(at: root) }
        let location = GuestJournalLocation(directory: root.appendingPathComponent("Journal"),
                                            setupMarker: root.appendingPathComponent("Setup/initialized"))
        let (journal, practice) = try await GuestComposition.local(at: location).makeSession()
        await GuestSettingsViewModel(journal: journal, practice: practice).deleteAll()
        XCTAssertNil(UserDefaults.standard.string(forKey: GuestAvatars.storageKey))
    }

    func testSavingMarksTheSavedMoment() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("GuestArt-\(UUID())")
        defer { try? FileManager.default.removeItem(at: root) }
        let location = GuestJournalLocation(directory: root.appendingPathComponent("Journal"),
                                            setupMarker: root.appendingPathComponent("Setup/initialized"))
        let journal = try await GuestComposition.local(at: location).makeViewModel()
        XCTAssertNil(journal.lastSavedAt)
        journal.draft = "Words"
        _ = await journal.saveDraft()
        XCTAssertNotNil(journal.lastSavedAt)
    }
}
