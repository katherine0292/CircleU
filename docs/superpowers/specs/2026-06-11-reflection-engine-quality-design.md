# Reflection Engine Quality Design

## Goal

Improve Circleu's AI reflection quality for rough language, conflict, and low-signal transcripts without changing the model provider first. The next release should feel more specific, safer to display, and more useful for TestFlight feedback.

## Current Problem

The current engine boundary is good: `ReflectionAnalyzing` lets Circleu use Apple Intelligence when available and fall back to `LocalReflectionEngine`. The weak point is output policy and classification.

The screenshot case shows the failure clearly:

```text
Shit she's fucking bitch oh no I should should I tell her something that is too rough or is it OK
```

The app currently presents this as a generic thoughtful check-in and repeats the rough transcript in the reflection card. That is not the right product behavior. The user is asking whether a message is too harsh, so Circleu should identify a heated boundary/communication moment and coach a calmer next step.

## Decision

Refine the current engine before switching models.

Reasons:

- The app already has an engine/provider boundary.
- The local fallback is what many simulator and unsupported-device tests will use.
- A stronger model will still need safety, display, and classification rules.
- TestFlight reliability matters more than adding a cloud dependency right now.

External AI can be evaluated after this pass if Apple Intelligence and the local engine still miss common TestFlight examples.

## Target Behavior

### Rough Low-Signal Transcript

Input shape:

```text
hello hello hi hi shit fuck fuck you
```

Expected behavior:

- Do not save or present it as a meaningful reflection.
- Ask the user to try again with one real moment, one feeling, and one question.
- Do not repeat profanity or insults in AI fields.
- Confidence should be low.

### Coherent Heated Boundary Transcript

Input shape:

```text
I am angry because she interrupted me. I want to tell her that was disrespectful, but I am worried it sounds too harsh.
```

Expected behavior:

- Classify as a conflict or boundary moment.
- Emotion should be `Protective`, `Heated`, or another conflict-specific label.
- Insight should name the tension: real boundary plus risky wording.
- Suggested quest should coach one calm sentence.
- Do not repeat profanity or insults.

### Relationship Or Social Conflict Transcript

Input shape:

```text
My friend said something hurtful and I want to reply, but I do not want to make it worse.
```

Expected behavior:

- Classify as relationship repair or response planning.
- Reflection should focus on slowing down, naming impact, and choosing one clear ask.
- Suggested quest should be a rewrite or pause step.

### Positive, Tender, Stress, And Neutral Transcripts

Existing useful behavior should remain stable:

- proud/grateful moments stay encouraging,
- sad/lonely moments stay tender,
- stress/overwhelm moments stay practical,
- neutral check-ins stay simple and supportive.

## Product Copy Rules

All reflection result fields must follow these rules:

- `title`: action-oriented and specific to the moment.
- `emotion`: one short label that matches the transcript.
- `summary`: name what happened, how the user felt, and why it matters.
- `insight`: name a pattern, tension, need, or boundary.
- `expressionMoment`: use a clean phrase or paraphrase; never repeat profanity, insults, or slurs.
- `quote`: plainspoken and specific; avoid generic motivational lines.
- `suggestedQuest`: one small concrete next action.
- `confidenceScore`: lower for unclear, repeated, or rough-only content.

## Safe Display

Circleu can keep the raw transcript in the private journal data model, but user-facing cards should avoid prominently repeating rough language.

Add a safe display layer for transcript previews:

- Raw transcript remains available for private detail/history if needed.
- Reflection preview cards and share surfaces should use a cleaned/paraphrased preview when rough language is detected.
- Example safe preview:

```text
You were deciding whether to respond to someone who upset you.
```

This keeps the app honest without amplifying the harsh wording.

## Prompt Changes

The Apple Intelligence prompt should become more explicit:

- If the user asks whether wording is too rough, treat it as response coaching.
- If rough language appears with a real situation, identify the boundary or repair need.
- If rough language appears without a real situation, ask for a clearer check-in.
- Never repeat profanity, insults, slurs, or hostile phrases.
- Prefer concrete rewrite steps over generic encouragement.
- Return valid JSON only.

## Evaluation Set

Add a small repeatable engine evaluation set in tests or docs with at least these categories:

1. rough low-signal filler,
2. coherent angry conflict,
3. relationship/social repair,
4. workplace boundary,
5. stress/overwhelm,
6. tender/sad,
7. proud/grateful,
8. short unclear transcript.

Each case should assert:

- expected category,
- no prohibited rough words in AI result fields,
- non-generic title/insight,
- useful suggested quest,
- valid confidence score.

## Model Strategy

Keep current provider order for now:

```text
Apple Intelligence when available -> LocalReflectionEngine fallback
```

After engine refinement, run the evaluation set against:

- simulator/local fallback,
- eligible Apple Intelligence device,
- TestFlight user feedback.

Only add an external cloud model if:

- Apple Intelligence is unavailable for too many testers,
- result quality still fails common examples,
- the team has consent/privacy copy ready for sending transcript text off-device.

If external AI is added later, it must implement `ReflectionAnalyzing` and preserve local fallback behavior.

## Non-Goals

- Do not add an external AI provider in this pass.
- Do not build server-side prompt infrastructure.
- Do not change Firebase schema unless safe display metadata becomes necessary.
- Do not turn Circleu into therapy or diagnosis.
- Do not moderate or block all rough language; the goal is safer, more useful reflection.

## Success Criteria

- The screenshot example no longer produces a generic `Thoughtful` reflection.
- AI result fields do not repeat profanity or insults.
- Conflict examples produce boundary/repair-specific feedback.
- Existing positive, tender, stress, and neutral tests still pass.
- The implementation remains behind engine/model/display boundaries, not scattered through SwiftUI views.
