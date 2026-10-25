import Foundation

/// Finds the earlier CircleU app's local journal and practice on this iPhone, for a one-time,
/// copy-only import. It only reads: nothing in the earlier app's storage is changed or removed,
/// and nothing is sent anywhere. The earlier app kept both in UserDefaults, on this device and per
/// signed-in account ("….user.<uid>"); every bucket is read and duplicates are merged.
struct GuestLegacyScan: Equatable {
    enum SkipReason: Equatable {
        /// The saved data couldn't be read (an unknown or damaged format).
        case unreadable
        /// No words were saved with it.
        case noWords
    }

    struct Skip: Equatable {
        let what: String
        let reason: SkipReason
    }

    var entries: [GuestImportedEntry] = []
    var messages: [GuestImportedMessage] = []
    var skipped: [Skip] = []

    var isEmpty: Bool { entries.isEmpty && messages.isEmpty && skipped.isEmpty }
}

enum GuestLegacyImport {
    static let journalKey = "circleu.saved.reflections.v1"
    static let practiceKey = "circleu.tipsPractice.sessions.v1"

    static func scan(_ defaults: UserDefaults = .standard) -> GuestLegacyScan {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // As the earlier stores wrote them.
        var scan = GuestLegacyScan()
        var seen = Set<UUID>()
        let keys = defaults.dictionaryRepresentation().keys.sorted()

        for key in keys where key == journalKey || key.hasPrefix(journalKey + ".user.") {
            guard let data = defaults.data(forKey: key),
                  let saved = try? decoder.decode([JournalReflectionEntry].self, from: data) else {
                scan.skipped.append(.init(what: "A saved journal", reason: .unreadable))
                continue
            }
            for entry in saved where seen.insert(entry.id).inserted {
                guard let mapped = map(entry) else {
                    scan.skipped.append(.init(what: "An entry from \(entry.createdAt.formatted(date: .abbreviated, time: .omitted))",
                                              reason: .noWords))
                    continue
                }
                scan.entries.append(mapped)
            }
        }
        for key in keys where key == practiceKey || key.hasPrefix(practiceKey + ".user.") {
            guard let data = defaults.data(forKey: key),
                  let sessions = try? decoder.decode([TipsPracticeSession].self, from: data) else {
                scan.skipped.append(.init(what: "Saved practice", reason: .unreadable))
                continue
            }
            for session in sessions where seen.insert(session.id).inserted {
                guard let mapped = map(session) else {
                    scan.skipped.append(.init(what: "A practice message from \(session.createdAt.formatted(date: .abbreviated, time: .omitted))",
                                              reason: .noWords))
                    continue
                }
                scan.messages.append(mapped)
            }
        }
        scan.entries.sort { $0.createdAt > $1.createdAt }
        scan.messages.sort { $0.createdAt > $1.createdAt }
        return scan
    }

    /// The person's own words become the entry; a private note is kept with them, labelled.
    /// The earlier reflection is kept apart from the words and marked as from the earlier app.
    static func map(_ entry: JournalReflectionEntry) -> GuestImportedEntry? {
        let transcript = entry.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        let note = entry.privateNote.trimmingCharacters(in: .whitespacesAndNewlines)
        let words = [transcript, note.isEmpty ? "" : "My note: \(note)"].filter { !$0.isEmpty }.joined(separator: "\n\n")
        guard !words.isEmpty else { return nil }
        let feeling = (entry.editableEmotion ?? entry.result.emotion).trimmingCharacters(in: .whitespacesAndNewlines)
        let summary = entry.result.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        let insight = entry.result.insight.trimmingCharacters(in: .whitespacesAndNewlines)
        let reflection = summary.isEmpty && feeling.isEmpty && insight.isEmpty ? nil
            : GuestReflection(summary: summary, feeling: feeling, insight: insight, source: .imported, basedOnWords: words)
        return GuestImportedEntry(legacyID: entry.id, originalWords: words, createdAt: entry.createdAt,
                                  updatedAt: entry.lastEditedAt ?? entry.createdAt, reflection: reflection)
    }

    /// The person's own message, with the situation they described.
    static func map(_ session: TipsPracticeSession) -> GuestImportedMessage? {
        let wording = session.originalMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !wording.isEmpty else { return nil }
        let situation = session.situation.trimmingCharacters(in: .whitespacesAndNewlines)
        return GuestImportedMessage(legacyID: session.id, situation: situation.isEmpty ? session.scene.title : situation,
                                    wording: wording, createdAt: session.createdAt, updatedAt: session.updatedAt)
    }
}

#if DEBUG
/// Realistic earlier-app data, written with the earlier app's own models and encoding, for tests
/// and Simulator UI tests (launch argument `-CircleUSeedLegacyFixture YES`). Debug builds only.
enum GuestLegacyFixture {
    static func write(to defaults: UserDefaults, uid: String = "fixture-uid") {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let day: TimeInterval = 86_400
        let base = Date(timeIntervalSince1970: 1_790_000_000)
        func result(_ emotion: String, _ summary: String) -> AIReflectionResult {
            AIReflectionResult(title: "A moment", emotion: emotion, summary: summary,
                               insight: "Being heard seems to matter here.", expressionMoment: "",
                               quote: "", confidenceScore: 0.7, suggestedQuest: "Ask for a quick check-in.")
        }
        let shared = JournalReflectionEntry(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
                                            createdAt: base, durationSeconds: 40,
                                            transcript: "My manager cut me off in the meeting again.",
                                            engineName: "Local test engine",
                                            result: result("Frustrated", "You were interrupted in a meeting."),
                                            privateNote: "Talk to her on Friday.")
        let device = [
            shared,
            JournalReflectionEntry(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
                                   createdAt: base.addingTimeInterval(day), durationSeconds: 30,
                                   transcript: "I finally said no to the extra shift and felt okay.",
                                   engineName: "Apple Intelligence", result: result("Relieved", "You set a limit at work."),
                                   editableEmotion: "Proud"),
            JournalReflectionEntry(id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
                                   createdAt: base.addingTimeInterval(2 * day), durationSeconds: 2,
                                   transcript: "   ", engineName: "Local test engine", result: result("Unclear", "")),
        ]
        let account = [
            shared, // The same entry under the signed-in account: merged, not duplicated.
            JournalReflectionEntry(id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
                                   createdAt: base.addingTimeInterval(3 * day), durationSeconds: 25,
                                   transcript: "My sister and I sorted out the holiday plans.",
                                   engineName: "Gemini", result: result("Calm", "You and your sister agreed on plans.")),
        ]
        let practice = [
            TipsPracticeSession(id: UUID(uuidString: "55555555-5555-5555-5555-555555555555")!,
                                createdAt: base.addingTimeInterval(day), updatedAt: base.addingTimeInterval(day),
                                originalMessage: "Could we split the group slides more evenly?", scene: .workplace,
                                tone: .diplomatic, situation: "Group project", turns: [],
                                coachOutput: TipsCoachOutput(suggestedPhrasing: "", whyItWorks: "", simulatedReply: "",
                                                             roomReading: "", replyOptions: [])),
        ]
        defaults.set(try? encoder.encode(device), forKey: GuestLegacyImport.journalKey)
        defaults.set(try? encoder.encode(account), forKey: GuestLegacyImport.journalKey + ".user." + uid)
        defaults.set(try? encoder.encode(practice), forKey: GuestLegacyImport.practiceKey)
        defaults.set(Data("not the right format".utf8), forKey: GuestLegacyImport.practiceKey + ".user.broken")
    }
}
#endif
