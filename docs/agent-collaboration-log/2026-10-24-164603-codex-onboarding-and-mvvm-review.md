# Onboarding, prototype review and MVVM assessment

- Recorded: 2026-10-24 16:46:03 +1100; Australia/Sydney.
- Agent / role: Codex coordinator.
- Status: review/proposal prepared; requested Figma edits blocked by Starter-plan MCP quota.
- Base revision and branch: `65495a5061d24083866799f9a1a8de0855b908ee`, `codex/journal-calendar-planning`; starting tree clean.
- Related record: [motion validation](2026-10-24-160601-codex-iphone-motion-validation.md).

## Request and scope

Owner asked what to review in PNGs versus Xcode, whether to apply MVVM, for a proper Figma prototype without review-only frontend labels, and to inspect onboarding. Scope is design/architecture review; no production refactor or data change.

## Work and outcome

[Onboarding review and continuation brief](../design/brand-demo/onboarding-review.md) records exact copy, routes, evidence and limitations. Figma inspection showed existing Inter wireframes, draft variables/styles, the privacy-heavy introduction and standard review footers. The next Figma reads failed with the Starter-plan MCP call-limit response. No canvas writes were attempted/completed, no plan upgrade, permission change or alternative access used to bypass the limit. Existing Figma/SwiftUI labels remain unchanged.

Prepared a local interactive first-use proposal in the conversation: Welcome, optional Privacy, empty Today, accepted Pingu/font/colors and links to existing core/recovery wireframes. Review controls and an implementation disclaimer sit outside the depicted phone. No account requirement, permission request, persistence, network service or new motion was implemented. Existing assets were encoded as smaller display renditions for this mockup; source files and historical images remain unchanged. This is a review fallback, not a Figma update or a production onboarding implementation.

Read onboarding/Journal source and architecture standards. MVVM is already present. Recommended incremental boundary improvements, small views, injected dependencies and a single source of truth; no blanket rewrite or forced Observation migration. Checked Apple's primary data-model guidance; project architecture remains our convention rather than an asserted Apple requirement.

## Verification

- Browser walkthrough exercised Welcome → Privacy → Done → Welcome and Welcome → empty Today; actual font and image loading and approximately 390-point horizontal fit checked. Final mockup includes a visible proposal/storage disclaimer outside the phone. External Figma handoff branches not rerun; no iOS/accessibility certification.
- Documentation links, scope/whitespace checks and explicit staged paths checked before publication. No Swift/Xcode test run required for repository documentation only; no app build or runtime privacy claim.
- Figma mutations, file-wide label cleanup and rebranding remain incomplete because of the quota. Resume from the brief when MCP access is available. Do not treat the local mockup as an editable Figma deliverable.

## Discussion and decisions

None. No other agents, other chats or external communications. Proposed first-use copy/layout awaits owner feedback; existing guest-local/branding direction was reused.

## Handoff

- Remaining work: owner review of purpose/action clarity and privacy comprehension; editable Figma onboarding and scoped cleanup once MCP access is available; then continue the agreed core-flow review before production implementation.
- Owner: Unassigned; no background work scheduled.
- Risks: current app still has account/cloud paths; the proposed local-storage copy must not ship until runtime/recovery requirements are met. The old Journal wireframe has fictional history, not an actual first-use empty Journal.
