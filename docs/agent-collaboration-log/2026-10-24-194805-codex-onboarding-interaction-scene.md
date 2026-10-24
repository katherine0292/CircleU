# Onboarding interaction review and selected Pingu scene

- Recorded: 2026-10-24 19:48:05 +1100; Australia/Sydney.
- Agent / role: Codex coordinator.
- Status: button review and visual variant delivered; gesture check and native recovery gaps remain pending.
- Base / branch: `17f8a3773f6af416d27a18e35e03ee3feee255b0`, `codex/journal-calendar-planning`; starting tree clean.
- Related: [explicit Canvas model](2026-10-24-192825-codex-onboarding-canvas-model.md), [new QA record](../qa/native-onboarding-interaction-review-2026-10-24.md).

## Request and outcome

Owner requested reviewing buttons, earlier-data screens and scrolling before Today, and asked why Welcome contains a device-storage warning/Privacy but no Login. Owner then explicitly chose Pingu scenery in the upper area with quiet space for text/buttons.

Canvas button input did not navigate reliably, so extended the existing isolated direct-compiler Simulator host with onboarding and larger-text launch options. No production target or additional project was created. Built, installed and launched only `com.circleu.prototype.motionsimulator` on iPhone 18 Pro/iOS 27.0. Existing production app/data and Firebase were untouched.

Actual Device Hub accessibility button presses verified Welcome→Privacy, Privacy→Earlier→Back, Privacy Done→Welcome, direct Earlier→Back, Continue without importing→Opening, Opening cancellation→Welcome and Get started→Opening. The external Figma recovery link was not opened; it remains a handoff rather than native sign-in/import. Opening is static and Retry intentionally inert. Source/UI findings and each verification limit are recorded in the QA table.

The automation scroll command returned `noWindowsAvailable`; larger text visibly exceeds the viewport. Asked the owner to perform a swipe/reachability check in Device Hub and left the prototype on accessibility1 text for that check. No gesture pass, complete native recovery or readiness success is claimed.

Implemented the selected still sky/snow scenery around the existing 172pt transparent Pingu, without placing art behind text/buttons. Kept the prior plain specimen via `illustratedWelcome: false`, stored two new versioned renders and preserved historical artwork/PNGs. No font/palette/account/storage policy change. Recorded recommendations to shorten the storage line, keep a small Privacy link and clarify optional old-account sign-in; these copy/account changes are not approved or implemented by implication.

## Verification

- SwiftPM render-previews build: passed; final log reports 3.76 seconds. Renderer completed with Plus Jakarta Sans verification; normal/compact-width new PNGs visually inspected, 780 × 1688 and 750 × 1688 pixels (490,741 bytes total).
- Existing Simulator-host compiler/script build: passed twice, including the final scene. Shell syntax check passed. The updated host launched with `--onboarding --large-text`; native screenshot confirms the scene and wrapping.
- New code/diff reviewed; local Markdown links and `git diff --check` passed. No new bitmap generation or artifact recompression.
- Not run: physical device, real account/import/storage, full production tests, VoiceOver, short-height gestures or a successful automated scroll. Prior production failures remain unresolved.

## Discussion and handoff

None: no inter-agent exchanges or external messages. Owner's background answer is a design decision, not an agent review. Remain in onboarding pending swipe results and decisions on recovery/readiness prototype completeness. Do not advance to Today or integrate production behavior from this approval. No background work scheduled.
