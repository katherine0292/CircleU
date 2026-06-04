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
}

struct JournalReflectionEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var createdAt: Date
    var durationSeconds: Int
    var transcript: String
    var engineName: String
    var result: AIReflectionResult

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        durationSeconds: Int,
        transcript: String,
        engineName: String,
        result: AIReflectionResult
    ) {
        self.id = id
        self.createdAt = createdAt
        self.durationSeconds = durationSeconds
        self.transcript = transcript
        self.engineName = engineName
        self.result = result
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
