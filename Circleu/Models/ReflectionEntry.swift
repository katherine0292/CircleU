import Foundation

struct AIReflectionResult: Codable, Equatable {
    var title: String
    var emotion: String
    var summary: String
    var insight: String
    var expressionMoment: String
    var quote: String
    var confidenceScore: Double
    var suggestedQuest: String

    nonisolated init(
        title: String,
        emotion: String,
        summary: String,
        insight: String,
        expressionMoment: String,
        quote: String,
        confidenceScore: Double,
        suggestedQuest: String
    ) {
        self.title = title
        self.emotion = emotion
        self.summary = summary
        self.insight = insight
        self.expressionMoment = expressionMoment
        self.quote = quote
        self.confidenceScore = confidenceScore
        self.suggestedQuest = suggestedQuest
    }
}

struct JournalReflectionEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var createdAt: Date
    var durationSeconds: Int
    var transcript: String
    var engineName: String
    var result: AIReflectionResult
    var sessionID: UUID?
    var editableTitle: String?
    var editableEmotion: String?
    var privateNote: String
    var tags: [String]
    var lastEditedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case durationSeconds
        case transcript
        case engineName
        case result
        case sessionID
        case editableTitle
        case editableEmotion
        case privateNote
        case tags
        case lastEditedAt
    }

    nonisolated init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        durationSeconds: Int,
        transcript: String,
        engineName: String,
        result: AIReflectionResult,
        sessionID: UUID? = nil,
        editableTitle: String? = nil,
        editableEmotion: String? = nil,
        privateNote: String = "",
        tags: [String] = [],
        lastEditedAt: Date? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.durationSeconds = durationSeconds
        self.transcript = transcript
        self.engineName = engineName
        self.result = result
        self.sessionID = sessionID
        self.editableTitle = editableTitle
        self.editableEmotion = editableEmotion
        self.privateNote = privateNote
        self.tags = tags
        self.lastEditedAt = lastEditedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        durationSeconds = try container.decode(Int.self, forKey: .durationSeconds)
        transcript = try container.decode(String.self, forKey: .transcript)
        engineName = try container.decode(String.self, forKey: .engineName)
        result = try container.decode(AIReflectionResult.self, forKey: .result)
        sessionID = try container.decodeIfPresent(UUID.self, forKey: .sessionID)
        editableTitle = try container.decodeIfPresent(String.self, forKey: .editableTitle)
        editableEmotion = try container.decodeIfPresent(String.self, forKey: .editableEmotion)
        privateNote = try container.decodeIfPresent(String.self, forKey: .privateNote) ?? ""
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        lastEditedAt = try container.decodeIfPresent(Date.self, forKey: .lastEditedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(durationSeconds, forKey: .durationSeconds)
        try container.encode(transcript, forKey: .transcript)
        try container.encode(engineName, forKey: .engineName)
        try container.encode(result, forKey: .result)
        try container.encodeIfPresent(sessionID, forKey: .sessionID)
        try container.encodeIfPresent(editableTitle, forKey: .editableTitle)
        try container.encodeIfPresent(editableEmotion, forKey: .editableEmotion)
        try container.encode(privateNote, forKey: .privateNote)
        try container.encode(tags, forKey: .tags)
        try container.encodeIfPresent(lastEditedAt, forKey: .lastEditedAt)
    }

    var displayTitle: String {
        sanitized(editableTitle, fallback: result.title)
    }

    var displayEmotion: String {
        sanitized(editableEmotion, fallback: result.emotion)
    }

    var displayQuest: String {
        result.suggestedQuest
    }

    var displaySummary: String {
        result.summary
    }

    var safeTranscriptPreview: String {
        TranscriptQuality.safePreview(transcript)
    }

    private func sanitized(_ value: String?, fallback: String) -> String {
        guard let value else { return fallback }
        let clean = value
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return clean.isEmpty ? fallback : clean
    }
}

extension JournalReflectionEntry {
    static let preview = JournalReflectionEntry(
        durationSeconds: 103,
        transcript: "I felt nervous before class, but I still asked my question and felt proud afterward.",
        engineName: "Preview",
        result: AIReflectionResult(
            title: "You showed up honestly",
            emotion: "Brave",
            summary: "You noticed nervousness and still took a small public step.",
            insight: "Naming the feeling helped you move through it instead of avoiding it.",
            expressionMoment: "You spoke with honesty about a real moment of growth.",
            quote: "Confidence grows through expression.",
            confidenceScore: 0.76,
            suggestedQuest: "Record one short reflection after your next class."
        )
    )
}
