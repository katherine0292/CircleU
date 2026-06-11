import XCTest
@testable import Circleu

final class EngineBehaviorTests: XCTestCase {
    func testTranscriptQualityRejectsEmptyInput() {
        let quality = TranscriptQuality.evaluate("   \n  ")

        XCTAssertEqual(quality.wordCount, 0)
        XCTAssertEqual(quality.characterCount, 0)
        XCTAssertFalse(quality.isReady)
        XCTAssertEqual(quality.guidance, "Add a few words before finishing.")
    }

    func testTranscriptQualityRejectsShortInputWithActionableGuidance() {
        let quality = TranscriptQuality.evaluate("I feel nervous today")

        XCTAssertEqual(quality.wordCount, 4)
        XCTAssertFalse(quality.isReady)
        XCTAssertEqual(quality.guidance, "Add one feeling, one moment, and what you want to understand.")
    }

    func testTranscriptQualityAcceptsUsefulReflectionInput() {
        let transcript = "I felt stressed before our team meeting, but I asked one clear question and understood the plan."

        let quality = TranscriptQuality.evaluate(transcript)

        XCTAssertGreaterThanOrEqual(quality.wordCount, 8)
        XCTAssertTrue(quality.characterCount >= 32)
        XCTAssertTrue(quality.isReady)
        XCTAssertEqual(quality.guidance, "Ready for AI reflection.")
    }

    func testTranscriptQualityFlagsRoughLowSignalInputWithActionableGuidance() {
        let transcript = "Hello hello hello hello hello hi hi hi hi shit shitty fuck fuck you"

        let quality = TranscriptQuality.evaluate(transcript)

        XCTAssertFalse(quality.isReady)
        XCTAssertEqual(quality.guidance, "Try again with one real moment, one feeling, and words you would be comfortable saving.")
    }

    func testTranscriptQualityCreatesSafePreviewForRoughConflict() {
        let preview = TranscriptQuality.safePreview(
            "Shit she's fucking bitch oh no I should should I tell her something that is too rough or is it OK"
        )

        XCTAssertEqual(preview, "You were deciding whether to respond to someone who upset you.")
    }

    func testLocalReflectionEngineRejectsEmptyTranscript() async {
        let engine = LocalReflectionEngine()

        do {
            _ = try await engine.analyze(transcript: "   ", durationSeconds: 20)
            XCTFail("Expected empty transcript to throw.")
        } catch ReflectionEngineError.emptyTranscript {
            // Expected behavior.
        } catch {
            XCTFail("Expected emptyTranscript, got \(error).")
        }
    }

    func testLocalReflectionEngineCreatesStressReflectionAndQuest() async throws {
        let engine = LocalReflectionEngine()
        let transcript = "I felt stressed and overwhelmed before the team demo, but writing one clear sentence helped me keep going."

        let result = try await engine.analyze(transcript: transcript, durationSeconds: 90)

        XCTAssertEqual(result.title, "Make the load smaller")
        XCTAssertEqual(result.emotion, "Overloaded")
        XCTAssertTrue(result.summary.contains("stressed"))
        XCTAssertEqual(result.suggestedQuest, "Choose the smallest useful task and leave the rest for the next pass.")
        XCTAssertGreaterThan(result.confidenceScore, 0)
        XCTAssertLessThanOrEqual(result.confidenceScore, 1)
    }

    func testLocalReflectionEngineCreatesAnxiousReflectionProfile() async throws {
        let result = try await analyze(
            "I was nervous before class and worried I would say the wrong thing, but I still asked my question."
        )

        XCTAssertEqual(result.title, "You met uncertainty with courage")
        XCTAssertEqual(result.emotion, "Brave")
        XCTAssertEqual(result.quote, "Courage often starts as one honest sentence.")
        XCTAssertConfidenceScoreIsValid(result)
    }

    func testLocalReflectionEngineCreatesProudReflectionProfile() async throws {
        let result = try await analyze(
            "I felt proud and grateful because I finished the group update and helped everyone understand the next step."
        )

        XCTAssertEqual(result.title, "You noticed a meaningful win")
        XCTAssertEqual(result.emotion, "Proud")
        XCTAssertEqual(result.suggestedQuest, "Save one sentence about what helped this moment go well.")
        XCTAssertConfidenceScoreIsValid(result)
    }

    func testLocalReflectionEnginePreservesLegacyFinishedPrideKeyword() async throws {
        let result = try await analyze(
            "I finished the group update before lunch and helped everyone understand the next step."
        )

        XCTAssertEqual(result.title, "You noticed a meaningful win")
        XCTAssertEqual(result.emotion, "Proud")
        XCTAssertEqual(result.suggestedQuest, "Save one sentence about what helped this moment go well.")
        XCTAssertConfidenceScoreIsValid(result)
    }

    func testLocalReflectionEnginePreservesLegacyHardLoadKeyword() async throws {
        let result = try await analyze(
            "Today felt hard because the meeting notes, project setup, and messages all needed attention at the same time."
        )

        XCTAssertEqual(result.title, "Make the load smaller")
        XCTAssertEqual(result.emotion, "Overloaded")
        XCTAssertEqual(result.suggestedQuest, "Choose the smallest useful task and leave the rest for the next pass.")
        XCTAssertConfidenceScoreIsValid(result)
    }

    func testLocalReflectionEngineLetsLegacyPrideBeatGenericLoadKeyword() async throws {
        let result = try await analyze(
            "I worked hard and finished the project before the meeting started."
        )

        XCTAssertEqual(result.title, "You noticed a meaningful win")
        XCTAssertEqual(result.emotion, "Proud")
        XCTAssertEqual(result.suggestedQuest, "Save one sentence about what helped this moment go well.")
        XCTAssertConfidenceScoreIsValid(result)
    }

    func testLocalReflectionEngineDoesNotTreatWindowAsWinKeyword() async throws {
        let result = try await analyze(
            "I sat by the window after class and noticed that tomorrow could feel more organized and clear."
        )

        XCTAssertEqual(result.title, "You checked in with yourself")
        XCTAssertEqual(result.emotion, "Thoughtful")
        XCTAssertEqual(result.suggestedQuest, "Write down one next step that would make tomorrow feel lighter.")
        XCTAssertConfidenceScoreIsValid(result)
    }

    func testLocalReflectionEngineLetsGratefulBeatStressedKeyword() async throws {
        let result = try await analyze(
            "I felt stressed before the update, but I was grateful that the team helped me finish calmly."
        )

        XCTAssertEqual(result.title, "You noticed a meaningful win")
        XCTAssertEqual(result.emotion, "Proud")
        XCTAssertEqual(result.suggestedQuest, "Save one sentence about what helped this moment go well.")
        XCTAssertConfidenceScoreIsValid(result)
    }

    func testLocalReflectionEngineCreatesTenderReflectionProfile() async throws {
        let result = try await analyze(
            "I felt sad and lonely after lunch because I missed my old friends and did not know who to talk with."
        )

        XCTAssertEqual(result.title, "You gave a tender feeling some space")
        XCTAssertEqual(result.emotion, "Tender")
        XCTAssertEqual(result.quote, "Soft honesty is still strength.")
        XCTAssertConfidenceScoreIsValid(result)
    }

    func testLocalReflectionEngineCreatesNeutralReflectionProfile() async throws {
        let result = try await analyze(
            "I checked in after school and noticed I want tomorrow to feel more organized and clear."
        )

        XCTAssertEqual(result.title, "You checked in with yourself")
        XCTAssertEqual(result.emotion, "Thoughtful")
        XCTAssertEqual(result.suggestedQuest, "Write down one next step that would make tomorrow feel lighter.")
        XCTAssertConfidenceScoreIsValid(result)
    }

    func testLocalReflectionEngineSuggestsLongerCheckInForShortDuration() async throws {
        let result = try await analyze(
            "I felt proud because I asked a clear question and understood what the team needed from me.",
            durationSeconds: 20
        )

        XCTAssertEqual(result.suggestedQuest, "Try a one-minute check-in next time and name one feeling clearly.")
    }

    func testLocalReflectionEngineCoachesRoughLowSignalInputWithoutRepeatingProfanity() async throws {
        let result = try await analyze(
            "Hello hello hello hello hello hi hi hi hi shit shitty fuck fuck you",
            durationSeconds: 17
        )

        XCTAssertEqual(result.title, "Try that check-in again")
        XCTAssertEqual(result.emotion, "Unclear")
        XCTAssertFalse(result.expressionMoment.lowercased().contains("fuck"))
        XCTAssertFalse(result.summary.lowercased().contains("fuck"))
        XCTAssertEqual(result.suggestedQuest, "Record again with one real moment, one feeling, and one thing you want to understand.")
    }

    func testLocalReflectionEngineTreatsRoughResponseQuestionAsBoundaryCoaching() async throws {
        let result = try await analyze(
            "Shit she's fucking bitch oh no I should should I tell her something that is too rough or is it OK",
            durationSeconds: 45
        )

        XCTAssertEqual(result.title, "Pause before you respond")
        XCTAssertEqual(result.emotion, "Protective")
        XCTAssertTrue(result.summary.lowercased().contains("too harsh") || result.summary.lowercased().contains("too rough"))
        XCTAssertTrue(result.insight.lowercased().contains("boundary") || result.insight.lowercased().contains("wording"))
        XCTAssertFalse(result.summary.contains("You gave shape to what was on your mind"))
        XCTAssertNoRoughWords(in: result)
        XCTAssertEqual(result.suggestedQuest, "Rewrite the message with one clear boundary and no attack.")
        XCTAssertConfidenceScoreIsValid(result)
    }

    func testLocalReflectionEngineCreatesRelationshipRepairReflection() async throws {
        let result = try await analyze(
            "My friend said something hurtful and I want to reply, but I do not want to make it worse.",
            durationSeconds: 70
        )

        XCTAssertEqual(result.title, "Choose the reply carefully")
        XCTAssertEqual(result.emotion, "Careful")
        XCTAssertTrue(result.insight.lowercased().contains("repair"))
        XCTAssertEqual(result.suggestedQuest, "Write one sentence that names the impact and one clear ask.")
        XCTAssertNoRoughWords(in: result)
        XCTAssertConfidenceScoreIsValid(result)
    }

    func testLocalReflectionEngineCoachesCoherentRoughLanguageWithoutGenericPraise() async throws {
        let result = try await analyze(
            "She said something really rough and I felt angry. Should I tell her that it was fucking disrespectful and crossed a line?",
            durationSeconds: 45
        )

        XCTAssertEqual(result.title, "Pause before you respond")
        XCTAssertEqual(result.emotion, "Protective")
        XCTAssertFalse(result.summary.contains("You gave shape to what was on your mind"))
        XCTAssertNoRoughWords(in: result)
        XCTAssertFalse(result.quote.contains("Small honest words"))
        XCTAssertEqual(result.suggestedQuest, "Rewrite the message with one clear boundary and no attack.")
    }

    func testLocalReflectionEngineCoachesBoundaryConflictWithoutGenericPraise() async throws {
        let result = try await analyze(
            "I felt angry after my teammate interrupted me twice. I want to tell them I need space to finish my idea before they respond.",
            durationSeconds: 80
        )

        XCTAssertEqual(result.title, "Name the boundary clearly")
        XCTAssertEqual(result.emotion, "Protective")
        XCTAssertTrue(result.summary.lowercased().contains("interrupted"))
        XCTAssertTrue(result.insight.lowercased().contains("boundary"))
        XCTAssertFalse(result.summary.contains("You gave shape to what was on your mind"))
        XCTAssertEqual(result.suggestedQuest, "Write one sentence that names what happened and what you need next.")
        XCTAssertConfidenceScoreIsValid(result)
    }

    func testLocalReflectionEngineAnchorsStressFeedbackToOverwhelm() async throws {
        let result = try await analyze(
            "I felt overwhelmed because the demo, Firebase setup, and team messages all arrived at once, and I did not know what to finish first.",
            durationSeconds: 75
        )

        XCTAssertEqual(result.title, "Make the load smaller")
        XCTAssertEqual(result.emotion, "Overloaded")
        XCTAssertTrue(result.summary.lowercased().contains("overwhelmed"))
        XCTAssertTrue(result.insight.lowercased().contains("too many"))
        XCTAssertEqual(result.suggestedQuest, "Choose the smallest useful task and leave the rest for the next pass.")
        XCTAssertConfidenceScoreIsValid(result)
    }

    func testAppleIntelligencePromptAsksForSpecificTranscriptAnchoredFeedback() {
        let prompt = ReflectionPromptContent.prompt(
            transcript: "I felt ignored in the team meeting, then I asked one clear question and felt calmer.",
            durationSeconds: 75
        )
        let instructions = ReflectionPromptContent.instructions

        XCTAssertTrue(instructions.contains("Do not diagnose"))
        XCTAssertTrue(prompt.contains("Anchor every field to the transcript"))
        XCTAssertTrue(prompt.contains("Avoid generic praise"))
        XCTAssertTrue(prompt.contains("summary should name what happened, what the user felt, and why it mattered"))
        XCTAssertTrue(prompt.contains("insight should name one pattern, tension, or need"))
        XCTAssertTrue(prompt.contains("quote should be original, plainspoken, and specific to this reflection"))
        XCTAssertTrue(prompt.contains("If the transcript is mostly filler, repeated words, or rough language"))
        XCTAssertTrue(prompt.contains("coherent rough, angry, or hostile language"))
        XCTAssertTrue(prompt.contains("If the user asks whether wording is too rough, treat it as response coaching."))
        XCTAssertTrue(prompt.contains("Prefer concrete rewrite steps over generic encouragement."))
        XCTAssertTrue(prompt.contains("For conflict, name the boundary, repair need, or response choice."))
        XCTAssertTrue(prompt.contains("Do not repeat profanity"))
        XCTAssertTrue(prompt.contains("expressionMoment should be a short clean phrase from the transcript"))
        XCTAssertTrue(prompt.contains("suggestedQuest should be one small concrete next action"))
        XCTAssertTrue(prompt.contains("I felt ignored in the team meeting"))
    }

    private func analyze(_ transcript: String, durationSeconds: Int = 90) async throws -> AIReflectionResult {
        let engine = LocalReflectionEngine()
        return try await engine.analyze(transcript: transcript, durationSeconds: durationSeconds)
    }

    private func XCTAssertConfidenceScoreIsValid(
        _ result: AIReflectionResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertGreaterThanOrEqual(result.confidenceScore, 0, file: file, line: line)
        XCTAssertLessThanOrEqual(result.confidenceScore, 1, file: file, line: line)
    }

    private func XCTAssertNoRoughWords(
        in result: AIReflectionResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let combined = [
            result.title,
            result.emotion,
            result.summary,
            result.insight,
            result.expressionMoment,
            result.quote,
            result.suggestedQuest
        ].joined(separator: " ").lowercased()

        for roughWord in ["fuck", "fucking", "shit", "shitty", "bitch"] {
            XCTAssertFalse(combined.contains(roughWord), "Unexpected rough word: \(roughWord)", file: file, line: line)
        }
    }
}
