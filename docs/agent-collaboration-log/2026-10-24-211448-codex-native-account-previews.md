# Native login, password reset and recovery previews

- Recorded: 2026-10-24 21:14:48 +1100; Australia/Sydney.
- Agent / role: Codex coordinator.
- Status: preview implementation and selected checks complete; new-form maximum-text manual check pending.
- Base / branch: `dcaf53ad42b33873f560bd4bb482602ac6f2bf03`, `codex/journal-calendar-planning`; starting tree clean.
- Related: [previous recovery review](2026-10-24-203113-codex-onboarding-accessibility-recovery-review.md), [native guide](../design/brand-demo/native-recovery.md), [QA](../qa/native-recovery-preview-2026-10-24.md).

## Request and scope

Owner explicitly authorized native Log in/password-reset previews, recovery and errors, concise branded copy, before Today. Reused the original checkout and existing isolated preview package/host as previously requested. No production auth/services, dependencies, main-app project, signing, remote records, source assets or Today changes.

## Implementation and verification

Added BrandRecoveryPreview with 22 process-memory screen states, actual email/secure fields, inline validation, reset request/notice/link/new-password states, explicit invented-message selection and error/local exits. Welcome opens login directly; the previous external Figma chooser was removed. Native Back and Privacy preserve the active email; secrets clear on submission/exit. Completed operations leave their forms. Two-second cancellable progress is fixture latency only. Canvas has named form/outcome/error previews; host launch flags choose scenarios outside UI.

SwiftPM build passed; final log reports 34.85 seconds after named previews. Isolated iPhone host compiled successfully. Renderer generated all 22 states and comparison boards. macOS cannot render native text fields/switch: a renderer-only static representation replaced unsupported-control markers; actual Simulator controls were inspected separately. Retained four deliberate artifacts (921,032 bytes total), with byte matches against the final render output. Existing v06/v07/v08 images are preserved.

Selected Device Hub input/button checks on iPhone 18 Pro/iOS 27.0 verified empty/missing/malformed input validation, Privacy/email preservation, reset notice/return, invented login→selection→recovery→Opening, required selection, offline reset/update errors, cancellation without late transition, minimum/mismatched new password, and recovery failure retaining selection. QA lists checks versus source/render-only states. Production tests/CI, real authentication/email/token/import, Google recovery, full keyboard/gestures/VoiceOver/hardware qualification were not run. No backend or persistence API is called by these fixtures.

## Actual agent review

Under requesting-code-review, coordinator dispatched `/root/native_recovery_review` read-only with exact files and requirements. Reviewer found no critical issue; flagged one important offline-reset/update false-success mapping and two minor issues (recovery --large-text ignored; malformed domain accepted). Coordinator accepted all three, fixed the mappings/flag/domain labels, natively verified offline request/update failures and malformed-domain rejection, and did not request a second review. Reviewer source-reviewed cancellation/selection/privacy; runtime checks remain coordinator evidence. Reviewer declined real backend/mail/deep-link, Google, real storage/conflict preservation, Today and parent-owned runtime/device behavior as out of this review's scope; those boundaries remain explicitly deferred in QA.

## Handoff

Review native forms on the selected iPhone, complete new-form maximum-text gesture/keyboard checks, and validate real providers/recovery only under the separate transition implementation plan. Earlier manual scrolling reports do not certify new forms. Google remains help-only; actual provider password policy, reset token handling, archives/ownership, physical device and existing production baseline failures remain unresolved. Owner: Unassigned. No background work scheduled.
