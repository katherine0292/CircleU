import XCTest
@testable import Circleu

/// Talk (6 November 2026): the conversation thread, its setup, styles, readings, branches, saving
/// in the existing conversation format, and "How it went".
@MainActor
final class GuestTalkTests: XCTestCase {
    private var root: URL!
    private var location: GuestJournalLocation!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("GuestTalk-\(UUID())")
        location = GuestJournalLocation(directory: root.appendingPathComponent("Journal"),
                                        setupMarker: root.appendingPathComponent("Setup/initialized"))
    }
    override func tearDownWithError() throws { try? FileManager.default.removeItem(at: root) }

    private func session() async throws -> (GuestJournalViewModel, GuestPracticeViewModel) {
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in })
        let journal = GuestJournalViewModel(store: store)
        await journal.load()
        let practice = GuestPracticeViewModel(store: store, suggester: LocalFirstSuggestionEngine(guidedOnly: true))
        await practice.load()
        return (journal, practice)
    }

    /// Waits for the model to finish thinking (guided suggestions answer at once).
    private func settle(_ model: GuestTalkModel) async {
        for _ in 0..<100 where model.isThinking { try? await Task.sleep(for: .milliseconds(20)) }
        try? await Task.sleep(for: .milliseconds(50))
    }

    private var suggestions: (GuestTalkModel) -> [GuestTalkSuggestion] = { model in
        model.items.compactMap { if case .suggestion(let s) = $0 { s } else { nil } }
    }

    // MARK: Setup

    func testSetupComesFromTheEntryAndNeverGuessesTone() {
        let entry = GuestJournalEntry(id: UUID(), originalWords: "The sink was full again. I snapped at him.",
                                      revision: 0, createdAt: .now, updatedAt: .now,
                                      reflection: GuestReflection(summary: "The dishes piled up and you snapped.", feeling: "",
                                                                  insight: "", source: .guided, basedOnWords: ""),
                                      nextStep: "Ask for one simple rule", context: .relationship)
        let setup = GuestTalkSetup.from(entry)
        XCTAssertEqual(setup.scene, "Relationship")
        XCTAssertEqual(setup.situation, "The dishes piled up and you snapped.")
        XCTAssertEqual(setup.hope, "Ask for one simple rule")
        XCTAssertEqual(setup.tone, "Balanced", "tone is the person's choice, never inferred")

        var plain = entry
        plain.reflection = nil
        plain.nextStep = nil
        plain.context = nil
        let fallback = GuestTalkSetup.from(plain)
        XCTAssertEqual(fallback.scene, "Other")
        XCTAssertEqual(fallback.situation, "The sink was full again", "the first words stand in for a summary")
        XCTAssertEqual(fallback.hope, "")
    }

    func testEveryJournalContextIsAScene() {
        XCTAssertEqual(GuestEntryContext.allCases.map(\.title), ["Study", "Work", "Friends", "Family", "Relationship"])
        for context in GuestEntryContext.allCases {
            XCTAssertTrue(GuestTalkSetup.scenes.contains(context.title))
            XCTAssertNotNil(UIImage(named: GuestTalkSetup.asset(for: context.title)), "\(context.title) has art")
        }
        XCTAssertNotNil(UIImage(named: GuestTalkSetup.asset(for: "Other")))
    }

    // MARK: Styles and readings

    func testStylesComeFromOneSuggestionWithoutAskingAgain() {
        let text = "Hi, I hope this is okay to bring up. The dishes keep piling up. Could we each wash ours?"
        XCTAssertEqual(GuestTalkStyle.asIs.apply(text), text)
        XCTAssertEqual(GuestTalkStyle.shorter.apply(text), "The dishes keep piling up. Could we each wash ours?")
        XCTAssertTrue(GuestTalkStyle.warmer.apply(text).hasPrefix("Thanks for hearing me out."))
        XCTAssertFalse(GuestTalkStyle.direct.apply(text).contains("I hope this is okay"))
        let generation = GuestTalkGeneration(base: ["Soft": "A.", "Balanced": "B. C.", "Firm": "D."])
        XCTAssertEqual(generation.text(tone: "Balanced", style: .asIs), "B. C.")
        XCTAssertEqual(generation.text(tone: "Firm", style: .warmer), "Thanks for hearing me out. D.")
    }

    func testTheirReplyAlwaysGetsTwoReadingsNeverAVerdict() {
        XCTAssertEqual(GuestReplyReading.readings(for: "Sorry, I've been busy. I'll try but no promises.").map(\.kind), [.stretched, .vague])
        XCTAssertEqual(GuestReplyReading.readings(for: "It's fine I guess. You always do this.").map(\.kind), [.hurt, .moveOn])
        XCTAssertEqual(GuestReplyReading.readings(for: "Sure, I can take the last three!").map(\.kind), [.yes, .polite])
        for kind in [GuestReplyReading.Kind.yes, .polite, .stretched, .vague, .hurt, .moveOn] {
            XCTAssertEqual(Set(GuestReplyReading.replies(for: kind).keys), ["Soft", "Balanced", "Firm"])
        }
        XCTAssertEqual(Set(GuestReplyReading.replies(for: nil).keys), ["Soft", "Balanced", "Firm"], "Neither fits stays neutral")
    }

    func testToneNamesMatchAndAnotherTakeIsNeverACopy() {
        let base = GuestTalkModel.byTone([.init(tone: "Gentle", text: "Hi, could we talk?"),
                                          .init(tone: "Clear", text: "Could we talk?"),
                                          .init(tone: "Firm", text: "We need to talk.")])
        XCTAssertEqual(base, ["Soft": "Hi, could we talk?", "Balanced": "Could we talk?", "Firm": "We need to talk."])
        for n in 1...3 { XCTAssertNotEqual(GuestTalkModel.anotherTake(base, n: n), base, "take \(n)") }
    }

    // MARK: The thread

    func testSayItRegenerateSaidAndTheirReplySaveAsAttributedTurns() async throws {
        let (journal, practice) = try await session()
        journal.draft = "My flatmate left the dishes again"
        _ = await journal.saveDraft()
        let entry = try XCTUnwrap(journal.entries.first)
        let model = GuestTalkModel(route: .new(sourceEntryID: entry.id), practice: practice, journal: journal)
        XCTAssertTrue(model.showsSetup, "a new conversation starts by setting the scene")

        model.input = "can you wash your dishes"
        model.sendOrStop()
        await settle(model)
        var cards = suggestions(model)
        XCTAssertEqual(cards.count, 1)
        XCTAssertEqual(cards[0].gens.count, 1)
        XCTAssertNil(model.saved, "nothing is saved before something is said")

        model.regenerate(cards[0].id)
        await settle(model)
        cards = suggestions(model)
        XCTAssertEqual(cards[0].gens.count, 2, "↻ adds a page")
        XCTAssertEqual(cards[0].g, 1)
        model.update(cards[0].id) { $0.style = .shorter }
        XCTAssertEqual(suggestions(model)[0].gens.count, 2, "a style is not a new page")

        let said = suggestions(model)[0].shown
        model.markSaid(cards[0].id)
        await settle(model)
        XCTAssertEqual(model.mode, .theirs)
        let saved = try XCTUnwrap(model.saved)
        XCTAssertEqual(saved.sourceEntryID, entry.id)
        XCTAssertEqual(saved.wording, said)
        XCTAssertEqual(saved.conversation?.turns.map(\.kind), [.wording])

        model.input = "Sorry, I've been busy with exams. I'll try but no promises."
        model.sendOrStop()
        await settle(model)
        let reading = try XCTUnwrap(model.items.compactMap { if case .reading(let r) = $0 { r } else { nil } }.first)
        XCTAssertEqual(reading.readings.count, 2)
        model.pick(reading.id, 0)
        await settle(model)
        let reply = try XCTUnwrap(suggestions(model).last)
        XCTAssertTrue(reply.isReply)
        XCTAssertEqual(reply.readingTitle, reading.readings[0].title)
        XCTAssertEqual(model.saved?.conversation?.turns.map(\.kind), [.wording, .theirReply])
        XCTAssertEqual(practice.linkedMessages(to: entry.id).count, 1, "the conversation is linked to the moment")
    }

    func testEditingAnEarlierMessageBranchesAndKeepsTheOldBranch() async throws {
        let (journal, practice) = try await session()
        let model = GuestTalkModel(route: .new(sourceEntryID: nil), practice: practice, journal: journal)
        model.input = "first try"
        model.sendOrStop()
        await settle(model)
        let messageID = try XCTUnwrap(model.items.first?.id)
        XCTAssertEqual(model.items.count, 2, "my words and a suggestion")

        model.edit(messageID, to: "second try")
        await settle(model)
        guard case .message(let edited)? = model.items.first else { return XCTFail("message first") }
        XCTAssertEqual(edited.versions.count, 2)
        XCTAssertEqual(edited.text, "second try")
        XCTAssertEqual(model.items.count, 2, "what came after starts again")

        model.switchVersion(messageID, to: 0)
        guard case .message(let back)? = model.items.first else { return XCTFail("message first") }
        XCTAssertEqual(back.text, "first try")
        XCTAssertEqual(model.items.count, 2, "the earlier branch comes back whole")
    }

    func testANoteIsKeptAsAddedContext() async throws {
        let (journal, practice) = try await session()
        let model = GuestTalkModel(route: .new(sourceEntryID: nil), practice: practice, journal: journal)
        model.input = "can we talk"
        model.sendOrStop()
        await settle(model)
        model.markSaid(try XCTUnwrap(suggestions(model).first?.id))
        await settle(model)
        model.addNote("They were tired today")
        await settle(model)
        XCTAssertEqual(model.saved?.conversation?.turns.map(\.kind), [.wording, .context])
    }

    func testASavedConversationReopensAsTheThread() async throws {
        let (journal, practice) = try await session()
        let first = GuestTalkModel(route: .new(sourceEntryID: nil), practice: practice, journal: journal)
        first.input = "can we talk"
        first.sendOrStop()
        await settle(first)
        first.markSaid(try XCTUnwrap(suggestions(first).first?.id))
        await settle(first)
        let id = try XCTUnwrap(first.saved?.id)

        let reopened = GuestTalkModel(route: .message(id), practice: practice, journal: journal)
        XCTAssertFalse(reopened.showsSetup)
        XCTAssertEqual(reopened.mode, .theirs, "after something said, the next thing is their reply")
        guard case .said? = reopened.items.first else { return XCTFail("the said line comes back") }
    }

    // MARK: How it went

    func testOutcomesDecodeFromOlderSavesAndKeepAFeeling() throws {
        let older = #"{"kind":"wording","text":"Hi","id":"6C0E8B5E-6D0A-4D7E-9C59-1A5B6E8F7A10","createdAt":0}"#
        let turn = try JSONDecoder().decode(GuestPracticeConversation.Turn.self, from: Data(older.utf8))
        XCTAssertNil(turn.feeling, "saves from before Talk have no feeling")
        let outcome = GuestPracticeConversation.Turn(kind: .outcome, text: "", feeling: GuestEntryFeeling.calm.rawValue)
        let round = try JSONDecoder().decode(GuestPracticeConversation.Turn.self, from: JSONEncoder().encode(outcome))
        XCTAssertEqual(round.kind, .outcome)
        XCTAssertEqual(round.feeling, "calm")
        XCTAssertEqual(GuestPracticeConversation.Turn.Kind.outcome.label, "How it went")
    }

    // MARK: Guide

    func testTheGuideCoversAllThreeTabsInOrder() {
        let steps = GuestTour.steps
        XCTAssertEqual(steps.map(\.tab), steps.map(\.tab).sorted(), "Write, then Journal, then Talk")
        XCTAssertEqual(Set(steps.map(\.tab)), [0, 1, 2])
        for step in steps {
            XCTAssertLessThanOrEqual(step.title.count, 30, step.title)
            XCTAssertLessThanOrEqual(step.body.count, 110, step.body)
            XCTAssertFalse(step.body.contains("!"))
            XCTAssertNotNil(UIImage(named: step.pose), step.pose)
        }
        let tour = GuestTour()
        tour.start()
        XCTAssertEqual(tour.index, 0)
        tour.back()
        XCTAssertEqual(tour.index, 0)
        for _ in steps { tour.next() }
        XCTAssertNil(tour.index, "Done ends the guide")
    }
}
