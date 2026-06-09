import XCTest
@testable import Circleu

final class CloudKitSchemaTests: XCTestCase {
    func testRecordTypesUseExpectedDatabaseScopes() {
        XCTAssertEqual(CloudKitRecordSchema.userProfile.scope, .privateDatabase)
        XCTAssertEqual(CloudKitRecordSchema.journalEntry.scope, .privateDatabase)
        XCTAssertEqual(CloudKitRecordSchema.aiReflectionSession.scope, .privateDatabase)
        XCTAssertEqual(CloudKitRecordSchema.quest.scope, .privateDatabase)
        XCTAssertEqual(CloudKitRecordSchema.tipsPracticeSession.scope, .privateDatabase)

        XCTAssertEqual(CloudKitRecordSchema.circle.scope, .sharedDatabase)
        XCTAssertEqual(CloudKitRecordSchema.circleMember.scope, .sharedDatabase)
        XCTAssertEqual(CloudKitRecordSchema.circlePost.scope, .sharedDatabase)
    }

    func testJournalEntrySchemaUsesStableFieldsAndSensitiveFlags() {
        XCTAssertEqual(CloudKitRecordSchema.journalEntry.recordType, "JournalEntryRecord")
        XCTAssertEqual(
            CloudKitRecordSchema.journalEntry.fieldNames,
            [
                "entryID",
                "createdAt",
                "updatedAt",
                "durationSeconds",
                "transcript",
                "engineName",
                "sessionID",
                "editableTitle",
                "editableEmotion",
                "privateNote",
                "tags",
                "resultJSON"
            ]
        )
        XCTAssertEqual(
            CloudKitRecordSchema.journalEntry.sensitiveFieldNames,
            ["transcript", "privateNote", "tags", "resultJSON"]
        )
    }

    func testDeterministicRecordNamesUseStablePrefixes() {
        let id = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!

        XCTAssertEqual(CloudKitRecordSchema.userProfile.recordName(for: "local-user"), "profile_local-user")
        XCTAssertEqual(CloudKitRecordSchema.journalEntry.recordName(for: id), "journal_11111111-2222-3333-4444-555555555555")
        XCTAssertEqual(CloudKitRecordSchema.aiReflectionSession.recordName(for: id), "aiSession_11111111-2222-3333-4444-555555555555")
        XCTAssertEqual(CloudKitRecordSchema.quest.recordName(for: id), "quest_11111111-2222-3333-4444-555555555555")
        XCTAssertEqual(CloudKitRecordSchema.tipsPracticeSession.recordName(for: id), "tipsPractice_11111111-2222-3333-4444-555555555555")
        XCTAssertEqual(CloudKitRecordSchema.circle.recordName(for: id), "circle_11111111-2222-3333-4444-555555555555")
        XCTAssertEqual(CloudKitRecordSchema.circleMember.recordName(for: id), "circleMember_11111111-2222-3333-4444-555555555555")
        XCTAssertEqual(CloudKitRecordSchema.circlePost.recordName(for: id), "circlePost_11111111-2222-3333-4444-555555555555")
    }

    func testCloudKitSchemaListsAllRecordTypes() {
        XCTAssertEqual(
            CloudKitDataModel.recordTypes.map(\.recordType),
            [
                "UserProfileRecord",
                "JournalEntryRecord",
                "AIReflectionSessionRecord",
                "QuestRecord",
                "TipsPracticeSessionRecord",
                "CircleRecord",
                "CircleMemberRecord",
                "CirclePostRecord"
            ]
        )
    }
}
