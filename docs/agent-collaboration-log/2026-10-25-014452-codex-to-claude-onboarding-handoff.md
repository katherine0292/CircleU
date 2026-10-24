# Codex → Claude: finish onboarding preview checks

- Recorded: 2026-10-25 01:44:52 +1100; Australia/Sydney.
- Agent / role: Codex, outgoing implementer; reviewer on the owner's next review request.
- Status: handoff requested by owner; Claude receipt/acceptance not confirmed.
- Base revision / branch: `da83ddccfd959d8743026e36edfff7efa7d3d860`, `codex/journal-calendar-planning`. Pending work below is **uncommitted in this local checkout**. Do not reset, discard or blindly stage it.
- Successor: Claude, as requested by owner. No agent has been spawned or messaged by this record.
- Related: [latest fixture delivery/provider review](2026-10-25-014234-codex-password-fixture-provider-review.md), [current onboarding review](../qa/native-onboarding-final-review-2026-10-25.md), [flow checklist](../product/flow-status-checklist.md).

## Request and boundaries

Owner requested a handoff to Claude in the agent log. Finish the isolated onboarding/password-recovery review before Today; Codex can review the resulting changes afterward. Read root AGENTS.md, [project standards](../0_coding_standards.md), [log protocol](README.md), [MVP decisions](../product/mvp-definition.md), [onboarding brief](../design/account-onboarding.md), the linked current QA and relevant [legacy transition plan](../superpowers/plans/2026-10-23-local-first-transition.md) before acting. Read the shared coding baseline at the path in AGENTS.md as well.

Keep guest-first local use, Today/Journal/Practice and deferred circles/rewards. Existing production Firebase/accounts/cloud remain untouched. Prototype approval does not authorize production implementation, adding providers, migration, release, merging or deleting any old data. All preview account/reset/import operations are process-memory fixtures: invented details only, no real credentials or requests.

## Exact current phone and source state

- The owner uses an iPhone 11 Pro Max / iOS 26.6.1. Developer Mode, Xcode account setup, Mac keychain signing and the phone's certificate-trust step are complete enough to run the isolated app.
- Separate project: `Prototypes/CircleUVisualPrototype/CircleUPreviewHost/CircleUPreviewHost.xcodeproj`; scheme `CircleUPreviewHost`; bundle `com.tuannm3812.circleu.preview`; display CircleU Preview. Personal Team, iPhone only, iOS 17 minimum, Swift 6. Do not run the original Circleu target for this task.
- [ContentView.swift](../../Prototypes/CircleUVisualPrototype/CircleUPreviewHost/CircleUPreviewHost/ContentView.swift) is temporarily configured with `BrandOnboardingPreview(initialScreen: .logIn, recoveryScreen: .newPassword)` for the last manual check. This is deliberate unfinished test setup, not the intended default.
- A prior Xcode Running banner was insufficient: owner still saw Log in. A fresh physical build/install/launch using `/tmp/circleu-phone-password-review` succeeded, and the owner then explicitly confirmed **New password appears**. Precise cause of the earlier mismatch is unknown; do not claim a source bug was fixed.
- Latest unanswered request is the three New password checks below. Merely seeing the screen does not mean they passed.
- Physical screen sharing is unavailable with the current Device Hub/iOS combination; use owner reports for screen, speech and gestures. Simulator inspection, launch output and actual phone observations are separate evidence.

## Verified or reported so far

Owner-reported physical checks:

1. Log in opens after developer certificate trust.
2. Email Next reaches a Password field visible above the keyboard.
3. Invented login Done dismisses the keyboard and opens Earlier data.
4. Reset-request Email Done opens Check your email.
5. VoiceOver reads labels and error, and Back works. Exact speech/announcement timing was not independently recorded.
6. At maximum accessibility text with VoiceOver, Welcome Get started/Log in, Privacy scrolling/Done, and Earlier data Continue without importing are readable/reachable, without a reported focus trap.
7. New password screen is now visible; its final interactions are pending.

Native Simulator follow-up on iPhone 18 Pro / iOS 27.0:

- Guest → Opening → Privacy → earlier data → local exit reaches the static Opening endpoint.
- Expired link → Request new link opens the reset form.
- Invalid link → Back to Log in opens login with empty fields.
- Failed-backup Retry check returns to the failure explanation, not an empty/success result; Continue locally reaches static Opening.

The direct Simulator host rebuilt/installed/launched successfully. The fresh physical Xcode project build succeeded; compile log named the intended ContentView path; explicit app install and launch succeeded. Only reported build warning was skipped AppIntents extraction without a dependency. Commands and scope are in the linked QA/latest log. No full-app tests or CI were run; no production/backend verification is implied.

## Claude's next actions, in order

1. Obtain the owner's result for the **currently displayed New password** fixture, with VoiceOver and maximum text: enter an invented password → Next keeps confirmation visible; mismatched confirmation → Done produces a spoken/discoverable, correctable error; matching confirmation → Done reaches completion, dismisses the keyboard, and Log in returns with an empty Password field. These checks must be reported, not inferred. Do not ask for real credentials.
2. If a problem is reported, reproduce/investigate before a scoped preview fix. Keep current branding/layout and discuss any proposed palette/font/artwork change with the owner. Use proportional native verification rather than mirrored unit tests.
3. Once that check is complete, restore ContentView to `BrandOnboardingPreview(initialScreen: .logIn)` and rebuild/install/launch **only the separate host**. Confirm the intended screen with the owner; Xcode Running alone previously misled us. Leave the original app installed and its data intact.
4. Update [current review](../qa/native-onboarding-final-review-2026-10-25.md), [keyboard/accessibility QA](../qa/native-recovery-keyboard-accessibility-2026-10-24.md), [host README](../../Prototypes/CircleUVisualPrototype/CircleUPreviewHost/README.md) and [flow checklist](../product/flow-status-checklist.md) with actual results and limits. Append your own dated log and reference this handoff; do not rewrite prior historical entries.
5. Review pending changes, local links, JSON/project syntax where affected and `git diff --check`. Under the standing owner authorization, commit/push a coherent scoped checkpoint, excluding the temporary fixture configuration after restoration and excluding user state, certificates/profiles, device identifiers and build products. Never stage all files blindly or force-push. Verify the remote SHA and say whether CI actually ran.
6. Provide a concise review handback to Codex via the owner/current log: changed files, tests/destinations/results, unresolved findings and decisions needed. Do not message other chats merely because this log asks for a handback. Today remains outside this handoff until onboarding review is closed with explicit limits; no production feature coding is approved.

## Unresolved review findings

- Previous Accessibility Inspector Dynamic Type/contrast warnings remain open. A new Inspector target could not be selected through the available UI connection; there is no fresh clean audit.
- The old reported 1.09 contrast pair is `#F5FAFF` against `#E8F0FC`, two light surface colors. Source text-token calculations range 6.11–17.56:1, but that does not identify the rendered audited element or dismiss warnings. Keep this as a discrepancy to investigate.
- Broader rotation/compact-height, all intermediate text sizes, hardware keyboard, real Reduce Motion/lifecycle and full VoiceOver coverage are not complete. Selected owner checks are not release accessibility certification.
- On-device Canvas previously failed with a weak DeveloperToolsSupport symbol error. Normal Run of this separate app is the working fallback. Do not erase caches, change production settings or require a phone upgrade as incidental cleanup.
- Closing the standalone package window resolved a disabled Add Local Package picker while setting up this host. It links the parent library only; do not duplicate its source/assets or link renderer/motion executables.

## Account-provider question: proposal only

Owner asked why Used Google? appears and whether Google, X or Facebook can be used. The preview link opens help. Earlier Dev Firebase inventory found Google enabled, but shipped Google support is unverified; current production adapter implements email/password only. Recommendations in [account-onboarding.md](../design/account-onboarding.md): clearer **Account help** copy; consider Apple/Google only when an account benefit is approved; defer X/Facebook. Firebase supports those integrations, and Apple guideline 4.8 must be considered for primary social-login accounts. **None of those provider/copy changes were approved or implemented.** Do not expand the account scope or silently convert guest-first to mandatory login.

## Pending working-tree ownership

Tracked modifications inherited from Codex:

- `Prototypes/CircleUVisualPrototype/CircleUPreviewHost/CircleUPreviewHost/ContentView.swift` — temporary New password launch; restore after manual test.
- `Prototypes/CircleUVisualPrototype/CircleUPreviewHost/README.md` — current setup/evidence.
- `docs/design/account-onboarding.md` — provider discussion, clearly proposed.
- `docs/product/flow-status-checklist.md` — selected physical checks and outstanding gates.
- `docs/qa/native-recovery-keyboard-accessibility-2026-10-24.md` — owner-reported follow-up evidence.

Untracked intentional documents inherited from Codex, plus this new handoff:

- [phone display](2026-10-25-011639-codex-preview-phone-display.md)
- [phone keyboard](2026-10-25-012024-codex-phone-keyboard-confirmation.md)
- [onboarding final checks](2026-10-25-013239-codex-onboarding-final-checks.md)
- [fixture delivery/provider review](2026-10-25-014234-codex-password-fixture-provider-review.md)
- [current onboarding review](../qa/native-onboarding-final-review-2026-10-25.md)

These are related current-task changes, not an unknown third party's work. Inspect them before integrating. `/tmp` build/log artifacts are local support evidence, not durable or Git deliverables.

## Discussion and verification of this handoff

Actual inter-agent exchanges: **None.** The owner requested Claude as successor, but writing this record does not send it or establish acceptance. Codex has not contacted another chat or controlled the Claude app.

Handoff preparation inspected current Git status/diff, latest relevant log, temporary source and the QA paths. Local Markdown link targets and whitespace checked; no app rebuild or new behavioral result occurred while writing this record. Work remains uncommitted for the successor's scoped review/integration.
