import Foundation

/// Finds the earlier CircleU app's local journal and practice on this iPhone, for a one-time,
/// copy-only import. It only reads: nothing in the earlier app's storage is changed or removed,
/// and nothing is sent anywhere. Who the earlier data belongs to must be clear before any of it
/// is shown (docs/engineering/legacy-data-format.md): data saved before accounts were separated,
/// or restored from an account backup, can belong to someone who signed in on this iPhone. So the
/// on-device journal is shown and copied only when the earlier app has no sign-in history here;
/// otherwise everything stays sealed until signing in is possible.
struct GuestLegacyScan: Equatable {
    enum SkipReason: Equatable {
        /// The saved data couldn't be read (an unknown or damaged format).
        case unreadable
        /// No words were saved with it.
        case noWords
        /// The earlier app was signed in to an account on this iPhone, so whose data this is
        /// can't be told without signing in to it.
        case needsAccount
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

    /// Where the earlier app's data is read from. Debug UI tests point this at an isolated suite,
    /// so a fixture never touches the real keys.
    static var source: UserDefaults = .standard

    /// Owner decision pending (26 Oct). No marker in the earlier app's data proves whose it is: a
    /// reinstall can keep an account's sign-in in the Keychain and restore its backup into the
    /// on-device keys without leaving any trace (Codex review, round 3). Until account sign-in
    /// exists, or the owner chooses otherwise, nothing from the earlier app is shown or copied.
    static var allowsUnverifiedOnDeviceImport = false

    static func scan(_ defaults: UserDefaults = source) -> GuestLegacyScan {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // As the earlier stores wrote them.
        var scan = GuestLegacyScan()
        var seen = Set<UUID>()
        let keys = defaults.dictionaryRepresentation().keys.sorted()

        // Sealed by policy, or by any sign-in history: never decoded or shown.
        if !allowsUnverifiedOnDeviceImport || hasSignInHistory(keys) {
            let found = keys.contains { $0 == journalKey || $0 == practiceKey || $0.hasPrefix(journalKey + ".user.")
                || $0.hasPrefix(practiceKey + ".user.") }
            if found { scan.skipped.append(.init(what: "Your earlier journal", reason: .needsAccount)) }
            return scan
        }

        for key in keys where key == journalKey {
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
        for key in keys where key == practiceKey {
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

    /// Signs that the earlier app was signed in on this iPhone (the account ID, local account
    /// records, or data kept per account). Signing out removes the ID, so all are checked.
    static func hasSignInHistory(_ keys: [String]) -> Bool {
        keys.contains { key in
            key == "circleu.currentFirebaseUID" || key.hasPrefix("circleu.auth.")
                || (key.hasPrefix("circleu.") && key.contains(".user."))
        }
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
/// and Simulator UI tests (launch argument `-CircleUSeedLegacyFixture YES`, which writes to the
/// isolated `suiteName` suite, never the real keys). Debug builds only.
enum GuestLegacyFixture {
    static let suiteName = "circleu.guest.legacyFixture"

    /// `signedIn` adds sign-in history (an account bucket and ID), which seals everything.
    static func write(to defaults: UserDefaults, signedIn: Bool = false, uid: String = "fixture-uid") {
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
            shared, // The same entry under a signed-in account.
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
        defaults.set(try? encoder.encode(practice), forKey: GuestLegacyImport.practiceKey)
        defaults.set(Data("not the right format".utf8), forKey: "circleu.tipsPractice.sessions.v1.unknown")
        if signedIn {
            defaults.set(try? encoder.encode(account), forKey: GuestLegacyImport.journalKey + ".user." + uid)
            defaults.set(uid, forKey: "circleu.currentFirebaseUID")
        }
    }
}
#endif
