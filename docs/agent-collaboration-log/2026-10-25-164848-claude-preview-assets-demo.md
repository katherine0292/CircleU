# Preview demo account and brand assets

- Recorded: 2026-10-25 16:48:48 +11:00; Australia/Sydney.
- Agent / role: Claude (Claude Code).
- Status: pushed for owner review; not merged.
- Base revision and branch: `codex/preview-assets-demo`, stacked on `codex/today-task1-changes` (Today walkthrough tasks 1–2) from main `812b1ca`.
- Related record: [walkthrough worksheet](../design/prototype-review-results.md).

## Request and scope

The owner asked for a demo account and for the existing assets and icons to be used in the frontend. The coordinator's brief: a preview-only demo login opening a populated sample workspace; restrained use of existing Pingu poses and illustrated icons. Prototype only; no production code, Firebase or new artwork.

## Work and outcome

- **Demo account:** a fixture login (documented in the [host README](../../Prototypes/CircleUVisualPrototype/CircleUPreviewHost/README.md)) opens `BrandDemoWorkspace`: swipe between Today, Journal, Journal calendar (multiple October entries) and Practice (linked and standalone messages). Other credentials keep the existing recovery fixture flow; the brief suggested an error instead, which is left as an owner choice.
- **Illustrations** (one per screen, decorative and hidden from VoiceOver): Privacy (BrandPrivacyV1), Earlier data (PinguThoughtfulV1), Check your email (PinguLaptopV1), Password updated (PinguThumbsUpV1), Message ready (PinguHeartV1). Welcome and Today already had theirs.
- **Action icons:** rounded SF Symbols on the main board buttons (write, suggestion, save, copy, practice, new reflection). The illustrated tab icons were already in place.
- Renders regenerated.

## Verification

- iPhone 18 Pro / iOS 27.0 Simulator: screenshots of every changed screen. XCUITest: demo login → workspace with Today, Journal and Practice pages; other credentials → Earlier data; the host route test passed.
- `performAccessibilityAudit()` on 26 onboarding/recovery states at default and largest text: only the accepted logo finding (21 each).
- Not checked: dark mode, because the preview deliberately forces light appearance (`.environment(\.colorScheme, .light)`). A dark palette is not designed yet.

## Discussion and decisions

None between agents. Owner choices pending: other-credential behaviour, dark mode scope, and the task 3 cards.

## Handoff

- Remaining work: owner review on the phone; Today walkthrough tasks 3–5.
- Owner: Mike.
