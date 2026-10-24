# Focused onboarding flow review

24 October 2026, Australia/Sydney. Owner requested reviewing onboarding and finishing its missing steps before other screens. This records the coordinator's design/technical review, not owner approval, a participant session or a production test.

## Findings and scope

The earlier local proposal had three gaps: Used CircleU before? left the prototype without a local explanation or postponement route; local workspace opening had no loading/locked/read-error alternatives; and only simple Privacy return behavior was defined. Added those states to a versioned local review while preserving the original. Other screens, production Swift, Xcode settings, Firebase and user data were not changed.

Current local states: **Welcome, Privacy, Earlier data, Opening, Locked, Read error, Today**. Today remains the first-use endpoint, not a newly implemented home screen. Existing core and legacy Figma links remain handoffs; no real recovery/import is performed.

Figma `whoami` confirmed the intended connection and a Starter plan with View seat. Reading the known privacy-introduction node again returned the MCP call-limit error. Identity/plan inspection is not proof of edit permission; canvas migration remains blocked and unapplied. No account-plan, seat or sharing change was made or requested automatically.

## Proposed routing rules

| Situation | Required destination / behavior |
| --- | --- |
| New first use | Short Welcome; no signup, mandatory privacy slide or permission prompt |
| Optional Privacy | Return to the originating screen; preserve nested earlier-data navigation |
| Earlier-data choice | Explain separate recovery/network use; Review earlier data is explicit; Continue without importing keeps sources separate |
| Workspace ready | Enter Today only after readiness succeeds; record completion only after required metadata writes succeed in production |
| Workspace opening | Stable pending state without fabricated progress; cancel returns to Welcome and invalidates the pending navigation |
| Protected storage locked | Explain unlock/retry; do not show an empty Journal or reset anything |
| Read failure | Retry or return safely; preserve existing data; no empty-store success fallback |
| Incomplete first use on re-entry | Welcome again, without erasing earlier data |
| Completed first use on re-entry | Recheck storage, then show the existing workspace/draft; onboarding completion never bypasses an error |

These are proposed app contracts. The local review simulates them with UI state and external outcome controls; it does not persist app metadata, create a workspace, decode content, verify ownership or validate real data preservation. Direct screen selectors are reviewer shortcuts, not app routes. Reopen preview simulates routing and is not an OS relaunch test.

## Browser checks performed

| Case | Observed result |
| --- | --- |
| Welcome → Privacy → Earlier data → Back → Done | Returned to Privacy, then Welcome |
| Today → Privacy → Earlier data → Back → Done | Returned to Privacy, then Today |
| Welcome → Earlier data → Continue without importing | Ready scenario entered Today; no import operation exists in the review |
| Reopen before completing first use | Welcome remained visible |
| Reopen after completing with Ready | Today remained reachable through the readiness gate |
| Checking → cancel → change outcome to Ready | Stayed on Welcome; canceled opening could not advance |
| Checking → explicitly finish with Ready | Entered Today |
| Locked → retry while locked | Stayed blocked; Privacy returned to the locked screen |
| Locked → Ready → retry | Entered Today |
| Read error → repeated retry | Stayed blocked; no empty Today success |
| Failed first use → Reopen | Returned to Welcome rather than recording completion |
| Read error → Ready → retry | Entered Today |
| Previously completed use → failed reopening → Back to welcome | Initially exposed a bypass to Today; corrected and rechecked as described below |

Visual checks inspected Welcome, Earlier data, read failure and revised Privacy at the normal browser size. The failure screen's measured phone width was approximately 390 CSS pixels with no horizontal overflow, and the bundled font loaded as `CircleUJakarta` (the embedded Plus Jakarta Sans). The earlier-data link's existing recovery target `65:663` was inspected but not opened/retested. Original artwork, font files and historical PNGs were not modified.

### Corrected prototype defect

Reproduced: complete first use with Ready → select Read error → Reopen preview → Back to welcome. The initial cancel function chose Today when the introduction had already been completed, bypassing the failed-read gate and contradicting its label. Replaced that branch with an unconditional return to Welcome while retaining the completion flag for future gated re-entry.

Targeted recheck passed: completed-user read failure → Back to welcome stayed Welcome; Get started still showed the failure; only selecting Ready and retrying entered Today. Also rechecked cancellation during completed-user Opening followed by a late simulated Ready: it stayed Welcome. This is a correction to the local proposal, not evidence of a production-app defect or runtime storage repair.

## Still required before onboarding is finished

- [x] Fill the local navigation and storage-state design gaps above.
- [x] Recheck the unsafe completed-user failure/back path and cancellation behavior.
- [x] Keep review labels outside the phone, retain recovery explanations, and request no permissions during the introduction.
- [ ] Owner review of purpose, action clarity, privacy/recovery comprehension and the added earlier-data choice. No feedback result has been collected.
- [ ] Recreate the accepted result as editable connected Figma screens when MCP access permits; this task did not update the canvas.
- [ ] Test narrow widths, text scaling, keyboard/focus and VoiceOver on the actual implementation; browser checks are not iPhone accessibility certification.
- [ ] Verify real readiness/metadata-write failures, interrupted first run, re-entry, existing drafts and source preservation in the authorized Swift implementation later.
- [ ] Verify the previous-account handoff and return from the actual supported recovery route. Ownership, bridge distribution and import details remain in the legacy plan.

Keep this review on onboarding until its owner-facing decisions are settled. There is no need to add a name form, signup, notification request, mascot customization or multi-slide tour to fill space.

[Onboarding copy and design handoff](../design/brand-demo/onboarding-review.md) · [Flow checklist](../product/flow-status-checklist.md) · [Storage/legacy transition plan](../superpowers/plans/2026-10-23-local-first-transition.md)
