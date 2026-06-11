# Reflection Engine Quality Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve Circleu reflection quality for rough language, conflict, and low-signal transcripts while keeping Apple Intelligence/local fallback architecture unchanged.

**Architecture:** Keep model selection behind `ReflectionAnalyzing`. Add deterministic local classification and safe transcript display helpers in engine/model layers, then update Apple Intelligence prompt rules to match. SwiftUI should consume safe display fields rather than implementing rough-language policy directly.

**Tech Stack:** Swift, SwiftUI, XCTest, Foundation Models when available, existing Circleu engine/store/model boundaries.

---

## File Structure

- Modify `Circleu/Engines/TranscriptQuality.swift`
  - Owns transcript cleanup, rough-language detection, and new safe preview/paraphrase helper.
- Modify `Circleu/Engines/ReflectionEngine.swift`
  - Owns local reflection categories, Apple Intelligence prompt content, and deterministic local fallback results.
- Modify `Circleu/Models/ReflectionEntry.swift`
  - Adds safe display helpers for transcript previews so views do not repeat rough text.
- Modify `Circleu/Features/Journal/JournalEntryDetailView.swift`
  - Displays safe transcript preview in reflection detail surfaces where the raw transcript is currently prominent.
- Modify `Circleu/Features/Journal/JournalView.swift`
  - Keeps list cards safe if they show transcript-derived text.
- Modify `Circleu/Features/Reflection/ReflectionView.swift`
  - Ensures generated reflection cards do not display raw rough transcript in prominent UI.
- Modify `CircleuTests/EngineBehaviorTests.swift`
  - Adds failing tests for screenshot case, relationship repair, workplace boundary, and safe preview behavior.

---

### Task 1: Add Failing Tests For The Screenshot Case

**Files:**
- Modify: `CircleuTests/EngineBehaviorTests.swift`

- [ ] **Step 1: Add a screenshot-case test**

Append this test near the existing rough-language tests:

```swift
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
```

- [ ] **Step 2: Add a relationship repair test**

Append this test near the same section:

```swift
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
```

- [ ] **Step 3: Add a safe preview test**

Append this test near transcript quality tests:

```swift
func testTranscriptQualityCreatesSafePreviewForRoughConflict() {
    let preview = TranscriptQuality.safePreview(
        "Shit she's fucking bitch oh no I should should I tell her something that is too rough or is it OK"
    )

    XCTAssertEqual(preview, "You were deciding whether to respond to someone who upset you.")
}
```

- [ ] **Step 4: Add a no-rough-words assertion helper**

Add this helper below `XCTAssertConfidenceScoreIsValid`:

```swift
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
```

- [ ] **Step 5: Run tests to verify failure**

Run:

```bash
xcodebuild test -quiet -project Circleu.xcodeproj -scheme Circleu -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath /private/tmp/circleu-deriveddata-engine-quality -only-testing:CircleuTests/EngineBehaviorTests
```

Expected: failure because `safePreview` does not exist and the local engine still classifies the screenshot transcript as rough/generic with existing labels.

---

### Task 2: Add Transcript Classification And Safe Preview Helpers

**Files:**
- Modify: `Circleu/Engines/TranscriptQuality.swift`
- Test: `CircleuTests/EngineBehaviorTests.swift`

- [ ] **Step 1: Add response-question detection helpers**

In `TranscriptQuality`, add these methods above `private static func normalizedWords`:

```swift
static func asksWhetherResponseIsTooHarsh(_ transcript: String) -> Bool {
    let text = cleanedTranscript(transcript).lowercased()
    let hasResponseQuestion = text.contains("should i tell")
        || text.contains("should i say")
        || text.contains("should i reply")
        || text.contains("should i respond")
        || text.contains("is it ok")
        || text.contains("is it okay")

    let hasHarshnessConcern = text.contains("too rough")
        || text.contains("too harsh")
        || text.contains("too much")
        || text.contains("disrespectful")
        || text.contains("crossed a line")

    return hasResponseQuestion && hasHarshnessConcern
}

static func mentionsRelationshipRepair(_ transcript: String) -> Bool {
    let text = cleanedTranscript(transcript).lowercased()
    let hasRelationship = text.contains("friend")
        || text.contains("partner")
        || text.contains("teammate")
        || text.contains("classmate")
        || text.contains("family")
        || text.contains("she ")
        || text.contains("he ")
        || text.contains("they ")

    let hasRepairLanguage = text.contains("reply")
        || text.contains("respond")
        || text.contains("make it worse")
        || text.contains("hurtful")
        || text.contains("apolog")
        || text.contains("repair")

    return hasRelationship && hasRepairLanguage
}

static func safePreview(_ transcript: String) -> String {
    let clean = cleanedTranscript(transcript)
    guard containsRoughLanguage(clean) else { return clean }

    if asksWhetherResponseIsTooHarsh(clean) || mentionsRelationshipRepair(clean) {
        return "You were deciding whether to respond to someone who upset you."
    }

    if isRoughLowSignal(clean) {
        return "This check-in needs one clearer real moment before Circleu can reflect on it."
    }

    return "You named a heated moment without needing to repeat the exact words."
}
```

- [ ] **Step 2: Run focused transcript test**

Run:

```bash
xcodebuild test -quiet -project Circleu.xcodeproj -scheme Circleu -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath /private/tmp/circleu-deriveddata-engine-quality -only-testing:CircleuTests/EngineBehaviorTests/testTranscriptQualityCreatesSafePreviewForRoughConflict
```

Expected: pass.

---

### Task 3: Refine Local Reflection Categories

**Files:**
- Modify: `Circleu/Engines/ReflectionEngine.swift`
- Test: `CircleuTests/EngineBehaviorTests.swift`

- [ ] **Step 1: Add category cases**

Update `LocalReflectionKind`:

```swift
private enum LocalReflectionKind {
    case roughLowSignal
    case heatedResponseQuestion
    case roughLanguage
    case relationshipRepair
    case boundaryConflict
    case overwhelm
    case anxiety
    case pride
    case tender
    case neutral
}
```

- [ ] **Step 2: Prioritize response-question and repair classification**

Update `reflectionKind(for:)` so the top of the method becomes:

```swift
private func reflectionKind(for cleanTranscript: String) -> LocalReflectionKind {
    if TranscriptQuality.isRoughLowSignal(cleanTranscript) { return .roughLowSignal }
    if TranscriptQuality.asksWhetherResponseIsTooHarsh(cleanTranscript) { return .heatedResponseQuestion }
    if TranscriptQuality.mentionsRelationshipRepair(cleanTranscript) { return .relationshipRepair }
    if TranscriptQuality.containsRoughLanguage(cleanTranscript) { return .roughLanguage }
    let text = cleanTranscript.lowercased()
    let words = normalizedWords(in: text)
    if containsAny(["boundary", "interrupted", "crossed a line", "need space", "angry", "frustrated", "conflict"], in: text, words: words) { return .boundaryConflict }
    if containsAny(["proud", "grateful", "happy", "relieved", "excited", "win", "good", "great", "won", "finished"], in: text, words: words) { return .pride }
    if containsAny(["stress", "stressed", "busy", "hard", "overwhelmed", "too much", "too many", "burned out", "burnt out", "exhausted"], in: text, words: words) { return .overwhelm }
    if containsAny(["nervous", "anxious", "scared", "afraid", "worried", "panic"], in: text, words: words) { return .anxiety }
    if containsAny(["sad", "lonely", "hurt", "miss", "tired", "cry"], in: text, words: words) { return .tender }
    return .neutral
}
```

- [ ] **Step 3: Add direct result helpers**

Add these methods near `roughLanguageReflection()`:

```swift
private func heatedResponseQuestionReflection() -> AIReflectionResult {
    AIReflectionResult(
        title: "Pause before you respond",
        emotion: "Protective",
        summary: "You noticed the message might be too rough, which means part of you wants the boundary to land without causing more harm.",
        insight: "The boundary may be valid, but the wording needs to be steady enough for the other person to hear it.",
        expressionMoment: "You wondered whether the response was too rough.",
        quote: "A clear boundary does not need a sharp edge.",
        confidenceScore: 0.7,
        suggestedQuest: "Rewrite the message with one clear boundary and no attack."
    )
}

private func relationshipRepairReflection() -> AIReflectionResult {
    AIReflectionResult(
        title: "Choose the reply carefully",
        emotion: "Careful",
        summary: "You want to respond to something hurtful without making the situation worse.",
        insight: "Repair starts when you name the impact clearly and leave room for the other person to answer.",
        expressionMoment: "You wanted to reply without making it worse.",
        quote: "Careful words can protect both honesty and connection.",
        confidenceScore: 0.73,
        suggestedQuest: "Write one sentence that names the impact and one clear ask."
    )
}
```

- [ ] **Step 4: Route direct helpers in `analyze`**

In `analyze`, after the rough-low-signal branch, add:

```swift
if kind == .heatedResponseQuestion {
    return heatedResponseQuestionReflection()
}

if kind == .relationshipRepair {
    return relationshipRepairReflection()
}
```

- [ ] **Step 5: Update switch exhaustiveness**

Add `.heatedResponseQuestion` and `.relationshipRepair` to switch cases in `reflectionProfile(for:)` and `suggestedQuest(for:durationSeconds:kind:)` where needed:

```swift
case .roughLowSignal, .heatedResponseQuestion, .roughLanguage, .relationshipRepair:
```

and:

```swift
case .roughLowSignal, .heatedResponseQuestion, .roughLanguage, .relationshipRepair, .neutral:
```

- [ ] **Step 6: Run focused engine tests**

Run:

```bash
xcodebuild test -quiet -project Circleu.xcodeproj -scheme Circleu -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath /private/tmp/circleu-deriveddata-engine-quality -only-testing:CircleuTests/EngineBehaviorTests/testLocalReflectionEngineTreatsRoughResponseQuestionAsBoundaryCoaching -only-testing:CircleuTests/EngineBehaviorTests/testLocalReflectionEngineCreatesRelationshipRepairReflection
```

Expected: both tests pass.

---

### Task 4: Add Safe Transcript Display To Models And Views

**Files:**
- Modify: `Circleu/Models/ReflectionEntry.swift`
- Modify: `Circleu/Features/Journal/JournalEntryDetailView.swift`
- Modify: `Circleu/Features/Journal/JournalView.swift`
- Modify: `Circleu/Features/Reflection/ReflectionView.swift`
- Test: `CircleuTests/EngineBehaviorTests.swift`

- [ ] **Step 1: Add safe display helper to `JournalReflectionEntry`**

In `JournalReflectionEntry`, below `displaySummary`, add:

```swift
var safeTranscriptPreview: String {
    TranscriptQuality.safePreview(transcript)
}
```

- [ ] **Step 2: Replace prominent raw transcript previews**

Search:

```bash
rg -n "transcript|What you said|WHAT YOU SAID|displaySummary" Circleu/Features/Journal Circleu/Features/Reflection -g '*.swift'
```

For any card/preview that prominently shows `entry.transcript`, use:

```swift
Text(entry.safeTranscriptPreview)
```

Keep raw transcript only in a clearly private detail area if the existing UI already labels it as private/raw. If there is no raw/private distinction, use the safe preview everywhere for now.

- [ ] **Step 3: Run build**

Run:

```bash
xcodebuild build -quiet -project Circleu.xcodeproj -scheme Circleu -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath /private/tmp/circleu-deriveddata-engine-quality
```

Expected: build passes.

---

### Task 5: Tighten Apple Intelligence Prompt

**Files:**
- Modify: `Circleu/Engines/ReflectionEngine.swift`
- Test: `CircleuTests/EngineBehaviorTests.swift`

- [ ] **Step 1: Add prompt assertions**

Extend `testAppleIntelligencePromptAsksForSpecificTranscriptAnchoredFeedback`:

```swift
XCTAssertTrue(prompt.contains("If the user asks whether wording is too rough, treat it as response coaching."))
XCTAssertTrue(prompt.contains("Prefer concrete rewrite steps over generic encouragement."))
XCTAssertTrue(prompt.contains("For conflict, name the boundary, repair need, or response choice."))
```

- [ ] **Step 2: Update prompt requirements**

In `ReflectionPromptContent.prompt`, add these bullets after the existing rough-language bullets:

```swift
- If the user asks whether wording is too rough, treat it as response coaching.
- For conflict, name the boundary, repair need, or response choice.
- Prefer concrete rewrite steps over generic encouragement.
```

- [ ] **Step 3: Run prompt test**

Run:

```bash
xcodebuild test -quiet -project Circleu.xcodeproj -scheme Circleu -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath /private/tmp/circleu-deriveddata-engine-quality -only-testing:CircleuTests/EngineBehaviorTests/testAppleIntelligencePromptAsksForSpecificTranscriptAnchoredFeedback
```

Expected: pass.

---

### Task 6: Run Full Engine Verification

**Files:**
- Verify: `CircleuTests/EngineBehaviorTests.swift`
- Verify: project build

- [ ] **Step 1: Run all engine tests**

Run:

```bash
xcodebuild test -quiet -project Circleu.xcodeproj -scheme Circleu -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath /private/tmp/circleu-deriveddata-engine-quality -only-testing:CircleuTests/EngineBehaviorTests
```

Expected: all `EngineBehaviorTests` pass.

- [ ] **Step 2: Run local data flow tests**

Run:

```bash
xcodebuild test -quiet -project Circleu.xcodeproj -scheme Circleu -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath /private/tmp/circleu-deriveddata-engine-quality -only-testing:CircleuTests/LocalDataFlowTests
```

Expected: all `LocalDataFlowTests` pass.

- [ ] **Step 3: Build app**

Run:

```bash
xcodebuild build -quiet -project Circleu.xcodeproj -scheme Circleu -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath /private/tmp/circleu-deriveddata-engine-quality
```

Expected: build passes.

- [ ] **Step 4: Manual QA on iPhone or simulator**

Use this transcript:

```text
Shit she's fucking bitch oh no I should should I tell her something that is too rough or is it OK
```

Expected result:

- title: `Pause before you respond`
- emotion: `Protective`
- no profanity repeated in insight, quote, expression moment, or suggested quest
- suggested quest: `Rewrite the message with one clear boundary and no attack.`
- preview text avoids repeating the raw rough transcript in prominent cards

---

## Self-Review

- Spec coverage: rough low-signal, heated boundary, relationship repair, positive/tender/stress/neutral regression, safe display, prompt tightening, and model deferral are covered.
- Placeholder scan: no task contains `TBD`, `TODO`, or unspecified implementation instructions.
- Type consistency: all planned helpers belong to existing types: `TranscriptQuality`, `LocalReflectionEngine`, `JournalReflectionEntry`, and `ReflectionPromptContent`.
