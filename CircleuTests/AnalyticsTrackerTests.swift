import XCTest
@testable import Circleu

@MainActor
final class AnalyticsTrackerTests: XCTestCase {
    private var originalTracker: any AnalyticsTracking = NoOpAnalyticsTracker()
    private var spyTracker = SpyAnalyticsTracker()

    override func setUp() {
        super.setUp()
        originalTracker = AnalyticsService.shared
        spyTracker = SpyAnalyticsTracker()
        AnalyticsService.shared = spyTracker
    }

    override func tearDown() {
        AnalyticsService.shared = originalTracker
        super.tearDown()
    }

    func testReflectionSavedTracksWithPrivacySafeProperties() {
        let questStore = QuestStore(userDefaults: makeDefaults())
        let viewModel = ReflectionViewModel(
            entry: makeEntry(),
            session: nil
        ) { _, _ in }

        viewModel.saveEntry(to: .tips, questStore: questStore) {}

        XCTAssertEqual(spyTracker.trackedEvents.count, 1)
        guard let event = spyTracker.trackedEvents.first else {
            XCTFail("No event was tracked")
            return
        }

        XCTAssertEqual(event.name, "reflection_saved")
        XCTAssertEqual(event.properties["destination"], "tips")
        XCTAssertEqual(event.properties["duration_seconds"], "60")
        XCTAssertEqual(event.properties["engine_name"], "Local test engine")
        XCTAssertEqual(event.properties["confidence_score"], "0.80")

        // Crucial safety assertion: ensure transcript, summary, or insight are NOT in the properties
        XCTAssertNil(event.properties["transcript"])
        XCTAssertNil(event.properties["summary"])
        XCTAssertNil(event.properties["insight"])
        XCTAssertNil(event.properties["title"])
    }

    func testQuestCompletedTracksWithPrivacySafeProperties() {
        let quest = Quest(
            title: "Practice a simple reflection",
            detail: "Take 2 minutes to think about your day",
            sourceEntryID: UUID(),
            createdAt: Date().addingTimeInterval(-86400 * 2) // 2 days ago
        )
        let store = QuestStore(userDefaults: makeDefaults())
        store.quests = [quest]

        store.complete(quest)

        XCTAssertEqual(spyTracker.trackedEvents.count, 1)
        guard let event = spyTracker.trackedEvents.first else {
            XCTFail("No event was tracked")
            return
        }

        XCTAssertEqual(event.name, "quest_completed")
        XCTAssertEqual(event.properties["quest_id"], quest.id.uuidString)
        XCTAssertEqual(event.properties["has_source_entry"], "true")
        
        let daysActive = Double(event.properties["days_active"] ?? "0") ?? 0
        XCTAssertEqual(daysActive, 2.0, accuracy: 0.1)

        // Safety assertion: Ensure title and detail of quest are NOT included
        XCTAssertNil(event.properties["title"])
        XCTAssertNil(event.properties["detail"])
    }

    func testCircleCreatedTracksWithPrivacySafeProperties() {
        let store = CircleStore(userDefaults: makeDefaults(), seedStarterSpaces: false)

        store.createCircle(name: "Secret Space", intention: "Sensitive conversation details", emoji: "🌻")

        XCTAssertEqual(spyTracker.trackedEvents.count, 1)
        guard let event = spyTracker.trackedEvents.first else {
            XCTFail("No event was tracked")
            return
        }

        XCTAssertEqual(event.name, "circle_created")
        XCTAssertEqual(event.properties["emoji"], "🌻")
        XCTAssertEqual(event.properties["cover_image_count"], "0")
        XCTAssertEqual(event.properties["has_custom_cover"], "false")
        XCTAssertNotNil(event.properties["circle_id"])

        // Safety assertion: Ensure name and intention of circle are NOT included
        XCTAssertNil(event.properties["name"])
        XCTAssertNil(event.properties["intention"])
    }

    func testQAExportCopiedTracksWithPrivacySafeProperties() {
        let viewModel = ProfileQAToolsViewModel()

        viewModel.copyQAExport("Short QA Export Content")

        XCTAssertEqual(spyTracker.trackedEvents.count, 1)
        guard let event = spyTracker.trackedEvents.first else {
            XCTFail("No event was tracked")
            return
        }

        XCTAssertEqual(event.name, "qa_export_copied")
        XCTAssertEqual(event.properties["char_count"], "24")

        // Safety assertion: raw content should not be in properties
        XCTAssertNil(event.properties["content"])
    }

    // MARK: - Mocks & Helpers

    private class SpyAnalyticsTracker: AnalyticsTracking {
        var trackedEvents: [AnalyticsEvent] = []

        func track(_ event: AnalyticsEvent) {
            trackedEvents.append(event)
        }
    }

    private func makeDefaults() -> UserDefaults {
        let suiteName = "circleu.analytics.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    private func makeEntry() -> JournalReflectionEntry {
        JournalReflectionEntry(
            durationSeconds: 60,
            transcript: "I practiced explaining my thought clearly before the team meeting.",
            engineName: "Local test engine",
            result: AIReflectionResult(
                title: "Clearer voice",
                emotion: "Focused",
                summary: "You found a simpler way to say what mattered.",
                insight: "Clearer preparation made the conversation easier to enter.",
                expressionMoment: "You named the sentence before the moment arrived.",
                quote: "A clear sentence can steady the next step.",
                confidenceScore: 0.8,
                suggestedQuest: "Write one opening sentence before tomorrow's check-in."
            )
        )
    }
}
