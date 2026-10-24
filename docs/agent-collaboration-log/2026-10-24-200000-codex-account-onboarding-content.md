# Required-account direction and content rules

- Recorded: 2026-10-24 20:00:00 +1100; Australia/Sydney.
- Agent / role: Codex coordinator.
- Status: planning/copy documents prepared; native design and authentication implementation pending.
- Base revision and branch: `84476ba7335cb830eee2ef5779d764bc201000d1`, `codex/journal-calendar-planning`; starting tree clean.
- Related: [previous interaction/scene pass](2026-10-24-194805-codex-onboarding-interaction-scene.md).

## Request and outcome

Owner requested a larger artwork-led Welcome, Log in / Sign up lower actions and a content standard, then explicitly chose to require an account before entering. Recorded that change in MVP/current agent guidance and the flow checklist. Added a supersession notice to the old transition plan: guest-only authentication assumptions cannot be executed unchanged. Preserved local-content/cloud limitations and legacy recovery safeguards; no provider, sync or automatic import was approved by this answer.

Created the [content standard](../design/content.md): concise sentence-case copy, no terminal full stop on phrase headings/buttons, ordinary punctuation in full explanations, stable action terms and accurate state/privacy claims. Added the [account-onboarding brief](../design/account-onboarding.md): large Pingu composition, proposed Sign up/Log in hierarchy, live tagline rather than baked lettering, privacy/recovery access and missing form/session/error coverage. Detailed layout/copy remains for review; no Swift, bitmap, backend or production files changed. The prior v07 SwiftUI screen still depicts guest entry.

## Verification

- Reviewed new documents and scoped diffs; local Markdown target existence and `git diff --check` checked before commit.
- Consulted Apple's Writing and Alerts guidance; project sentence-case button style is explicitly a house-style adaptation, not an Apple requirement.
- Not run: builds, Simulator, Canvas, Figma or production tests; documentation-only change. No CI result claimed.
- Manual scrolling is still unverified. The owner's reply changed the design rather than confirming gestures.

## Discussion and decisions

None: no inter-agent exchanges or external communications. Owner decision: accounts required. Agent recommendations: primary Sign up, secondary Log in; live Find your words; move Privacy to forms and Settings while retaining pre-authentication recovery access. These recommendations are not recorded as owner approval of all details.

## Handoff

- Remaining work: review the small account-Welcome brief, define fields/provider/session behavior, then build the isolated native account specimen and verify keyboard, Back, scrolling, errors and legacy recovery before Today. Revise production transition tasks before implementation.
- Owner: Unassigned.
- Risks / unresolved questions: provider/backend identity and offline unlock policy; account-scoped data isolation/logout/deletion; exact legacy build/backend mapping; gesture coverage. Production auth, cloud behavior, user data and signing remain unchanged.
