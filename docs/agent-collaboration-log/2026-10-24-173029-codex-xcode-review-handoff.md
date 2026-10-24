# Open native previews after navigation movement report

- Recorded: 2026-10-24 17:30:29 +1100; Australia/Sydney.
- Agent / role: Codex coordinator.
- Status: Xcode Canvas visible; reported movement remains unresolved.
- Base revision and branch: `6ba477a5ce212b1b680c6a9908ca81436c3d4a29`, `codex/journal-calendar-planning`; starting tree clean.
- Related record: [onboarding content research](2026-10-24-172309-codex-onboarding-content-research.md).

## Request and scope

Owner reported navigation moving between screens, was unsure whether the shown material was PNG, and requested opening the project in Xcode for inspection. Opened the existing isolated native preview package; did not run or modify the production app.

## Work and outcome

Xcode already had the package open with the `motion-demo` executable scheme. Canvas reported that MotionDemo needed `ENABLE_DEBUG_DYLIB=YES`. Selected the documented `CircleUVisualPrototype` library scheme with My Mac and opened `BrandFlowPreview.swift`. Canvas rendered the branded Journal specimen; Journal, Practice and editor preview selectors were visible. No build-setting edit or dependency installation was needed.

The browser onboarding is interactive HTML with embedded PNG illustrations, separate from these SwiftUI specimens. Source inspection shows per-screen headers and in-flow tabs rather than one persistent navigation shell. That is a relevant layout concern, not a reproduced diagnosis of the owner's specific movement or a finding about the production app. No layout fix made. The newer browser onboarding copy is not yet in this native package.

A subsequent attempt to open the main `.xcodeproj` encountered a user-change interruption; refreshed Xcode state and left the visible prototype available for the owner's review. Main-project opening was not verified.

## Verification

- Native accessibility state confirmed library scheme/My Mac and branded preview selectors. A native screenshot showed the Journal Canvas rendering with the actual brand font/artwork and no prior executable-scheme error.
- Reviewed preview README and related motion instructions. No fresh CLI build, Simulator run, physical-device check or production behavior test.
- `git diff --check` for this work record; no Swift/app/assets changed.

## Discussion and decisions

None. No agents, other chats or external communications. Owner report is recorded as feedback, not a resolved defect.

## Handoff

- Remaining work: compare consistent header/tab positions in native specimens and reproduce the reported transition; establish a shared navigation layout during an authorized prototype refinement. Preserve safe-opening and earlier-data routes.
- Owner: Unassigned; owner is inspecting Xcode.
- Risks: existing specimens are separately authored and mostly static; they do not establish working app navigation or parity with the latest browser proposal.
