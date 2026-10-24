# Concise guest Welcome and optional login

- Recorded: 2026-10-24 20:10:46 +1100; Australia/Sydney.
- Agent / role: Codex coordinator.
- Status: isolated Welcome updated and reviewed; native authentication/recovery and gestures pending.
- Base / branch: `a21e5825ea92a141d7f356617069a4a239e37b4c`, `codex/journal-calendar-planning`; starting tree clean.
- Related: [superseded account requirement](2026-10-24-200000-codex-account-onboarding-content.md), [current brief](../design/account-onboarding.md).

## Request and outcome

Owner accepted the recommendation to keep accounts optional and asked for concise copy/removal of unnecessary UI. Restored the current product/agent/privacy/transition guidance to guest-first local use; retained optional existing-account recovery and deferred signup until a clear account benefit exists. The previous account-required log is preserved as history, not rewritten.

Updated only the isolated SwiftUI onboarding: existing Pingu enlarged to 260pt, live Find your words without a full stop, no repeated helper/storage banner/Privacy/Used CircleU before? on Welcome. Two actions: Get started and Log in. Short storage disclosure and Privacy remain in Opening, before meaningful input. Log in opens the existing recovery introduction/Figma handoff; no native auth or data operation added. No production code, original assets, Firebase, signing or user data changed.

## Verification

- SwiftPM render-previews build passed (3.18 seconds); actual bundled Plus Jakarta Sans verified by renderer. New v08 regular/compact/comparison PNGs rendered and visually inspected; historical v06/v07 images preserved.
- Isolated Simulator-host build passed after the first sandboxed macro-plugin attempt failed with Operation not permitted. Installed and launched on iPhone 18 Pro/iOS 27.0, UUID `C7B63706-4D1C-4B7F-A161-8A2339D14E2B`.
- Device Hub button checks: Get started → Opening → Privacy → Done → Opening → Welcome; Log in → Earlier data → Back → Welcome. Native screenshot inspected; left Welcome visible.
- Local Markdown targets, artifact dimensions/sizes and diff whitespace checked before commit.
- Not run: larger-text/short-height gestures, physical device, native authentication/import, production tests or CI. Opening and Retry remain static fixtures. No new mirrored tests for this reversible visual/copy change, per project verification rules.

## Discussion and handoff

None: no inter-agent exchanges. Owner's latest approval supersedes required accounts. Complete native recovery/login and real readiness as separate scoped work; retain all legacy preservation gates. Today is not advanced in this specimen. Remaining owner: Unassigned.
