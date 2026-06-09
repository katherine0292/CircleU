import Foundation

enum CloudKitDatabaseScope: String, Codable, Equatable {
    case privateDatabase
    case sharedDatabase
}

struct CloudKitRecordField: Codable, Equatable {
    var name: String
    var isSensitive: Bool

    init(_ name: String, isSensitive: Bool = false) {
        self.name = name
        self.isSensitive = isSensitive
    }
}

struct CloudKitRecordSchema: Codable, Equatable {
    var recordType: String
    var scope: CloudKitDatabaseScope
    var recordNamePrefix: String
    var fields: [CloudKitRecordField]

    var fieldNames: [String] {
        fields.map(\.name)
    }

    var sensitiveFieldNames: [String] {
        fields.filter(\.isSensitive).map(\.name)
    }

    func recordName(for identifier: String) -> String {
        "\(recordNamePrefix)_\(identifier)"
    }

    func recordName(for id: UUID) -> String {
        recordName(for: id.uuidString)
    }
}

extension CloudKitRecordSchema {
    static let userProfile = CloudKitRecordSchema(
        recordType: "UserProfileRecord",
        scope: .privateDatabase,
        recordNamePrefix: "profile",
        fields: [
            CloudKitRecordField("localUserID"),
            CloudKitRecordField("displayName"),
            CloudKitRecordField("promptIndex"),
            CloudKitRecordField("updatedAt")
        ]
    )

    static let journalEntry = CloudKitRecordSchema(
        recordType: "JournalEntryRecord",
        scope: .privateDatabase,
        recordNamePrefix: "journal",
        fields: [
            CloudKitRecordField("entryID"),
            CloudKitRecordField("createdAt"),
            CloudKitRecordField("updatedAt"),
            CloudKitRecordField("durationSeconds"),
            CloudKitRecordField("transcript", isSensitive: true),
            CloudKitRecordField("engineName"),
            CloudKitRecordField("sessionID"),
            CloudKitRecordField("editableTitle"),
            CloudKitRecordField("editableEmotion"),
            CloudKitRecordField("privateNote", isSensitive: true),
            CloudKitRecordField("tags", isSensitive: true),
            CloudKitRecordField("resultJSON", isSensitive: true)
        ]
    )

    static let aiReflectionSession = CloudKitRecordSchema(
        recordType: "AIReflectionSessionRecord",
        scope: .privateDatabase,
        recordNamePrefix: "aiSession",
        fields: [
            CloudKitRecordField("sessionID"),
            CloudKitRecordField("createdAt"),
            CloudKitRecordField("updatedAt"),
            CloudKitRecordField("entryID"),
            CloudKitRecordField("engineName"),
            CloudKitRecordField("source"),
            CloudKitRecordField("transcript", isSensitive: true),
            CloudKitRecordField("durationSeconds"),
            CloudKitRecordField("selectedAttemptID"),
            CloudKitRecordField("mergedSessionIDs"),
            CloudKitRecordField("attemptsJSON", isSensitive: true)
        ]
    )

    static let quest = CloudKitRecordSchema(
        recordType: "QuestRecord",
        scope: .privateDatabase,
        recordNamePrefix: "quest",
        fields: [
            CloudKitRecordField("questID"),
            CloudKitRecordField("title"),
            CloudKitRecordField("detail"),
            CloudKitRecordField("sourceEntryID"),
            CloudKitRecordField("createdAt"),
            CloudKitRecordField("completedAt"),
            CloudKitRecordField("status")
        ]
    )

    static let tipsPracticeSession = CloudKitRecordSchema(
        recordType: "TipsPracticeSessionRecord",
        scope: .privateDatabase,
        recordNamePrefix: "tipsPractice",
        fields: [
            CloudKitRecordField("sessionID"),
            CloudKitRecordField("createdAt"),
            CloudKitRecordField("updatedAt"),
            CloudKitRecordField("originalMessage", isSensitive: true),
            CloudKitRecordField("scene"),
            CloudKitRecordField("customScene"),
            CloudKitRecordField("tone"),
            CloudKitRecordField("situation", isSensitive: true),
            CloudKitRecordField("attachedImageCount"),
            CloudKitRecordField("turnsJSON", isSensitive: true),
            CloudKitRecordField("coachOutputJSON", isSensitive: true)
        ]
    )

    static let circle = CloudKitRecordSchema(
        recordType: "CircleRecord",
        scope: .sharedDatabase,
        recordNamePrefix: "circle",
        fields: [
            CloudKitRecordField("circleID"),
            CloudKitRecordField("name"),
            CloudKitRecordField("intention"),
            CloudKitRecordField("createdAt"),
            CloudKitRecordField("updatedAt")
        ]
    )

    static let circleMember = CloudKitRecordSchema(
        recordType: "CircleMemberRecord",
        scope: .sharedDatabase,
        recordNamePrefix: "circleMember",
        fields: [
            CloudKitRecordField("memberID"),
            CloudKitRecordField("circleID"),
            CloudKitRecordField("userID"),
            CloudKitRecordField("role"),
            CloudKitRecordField("status"),
            CloudKitRecordField("createdAt"),
            CloudKitRecordField("updatedAt")
        ]
    )

    static let circlePost = CloudKitRecordSchema(
        recordType: "CirclePostRecord",
        scope: .sharedDatabase,
        recordNamePrefix: "circlePost",
        fields: [
            CloudKitRecordField("postID"),
            CloudKitRecordField("circleID"),
            CloudKitRecordField("createdAt"),
            CloudKitRecordField("updatedAt"),
            CloudKitRecordField("title", isSensitive: true),
            CloudKitRecordField("body", isSensitive: true),
            CloudKitRecordField("sourceEntryID")
        ]
    )
}

enum CloudKitDataModel {
    static let recordTypes: [CloudKitRecordSchema] = [
        .userProfile,
        .journalEntry,
        .aiReflectionSession,
        .quest,
        .tipsPracticeSession,
        .circle,
        .circleMember,
        .circlePost
    ]
}
