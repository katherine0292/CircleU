# Today and Journal native alignment — 31 October 2026

Approved audit follow-up, implemented in the current `codex/app-upgrade-plan` worktree. [Plan](../../superpowers/plans/2026-10-31-audit-follow-up-native-alignment.md); [product brief](../../product/overview.md); [stories](../../product/user-stories.md).

## What changed

- Shared safe JSON reflection decoder for both model providers; reversed delimiters throw instead of trapping. Existing fallback behavior stays intact.
- Optional user-selected context and feeling stored in SwiftData V6. V5 migration preserves entries, reflection, linked conversation history, saved-draft receipts and kept drafts. Selection never overwrites original words or an AI reflection's feeling.
- Today uses the approved 2:1 window/voice art, a 24pt Dynamic Type heading, white writing card and compact question/microphone footer. Questions stay separate from the draft and reset after a successful save. Save remains pinned above the native tab bar/keyboard.
- Journal cards group by creation date, with time, writing and independent context/feeling controls. Transparent Pingu art retains labels; 44pt hit areas remain despite compact visuals. Picker supports Done, cancel, deselect, stale/deleted errors and save retry.
- Native TabView, Settings, Pingu selection, calendar/search, entry editing, optional reflection and linked Practice remain. No new calendar decorations, cloud calls, credit spending, signing or Release changes.

## Brand provenance

[Artwork manifest](artwork-provenance.json) records twelve exact copies of existing Codex masters. Six feeling PNGs retain alpha channels. No new illustration generation. Fixed Figma geometry is adapted to native safe areas, system search/navigation and accessibility reflow; it is not a pixel-for-pixel replacement of iOS chrome.

## Verification

Xcode 27.2 (27B52), iPhone 18 Pro Simulator / iOS 27.0. The full unit run passed 274 tests, skipped the physical protection check and had zero failures (`/tmp/circleu-alignment-unit-2.xcresult`). New regression tests first failed on missing decoder/tag/question APIs and the missing question-picker control before implementation. Focused parser and migration/store tests also passed.

The full guest UI run passed 24 tests, skipped the live-Firebase check and had zero failures (`/tmp/circleu-alignment-ui.xcresult`). Visual inspection then found two issues: the new wordmark compressed to zero width, and an additional long-entry AX5 test reproduced a 2782pt history preview. The preview is now limited to six accessibility lines/four normal lines; full detail/edit text is retained. Toolbar sizing was corrected, with a logo-only visual at accessibility sizes. The affected Today/tag follow-up passed five cases. Its long-entry case initially differed only on trailing whitespace (already trimmed by the existing Save contract); the fixture was corrected and that case passed separately in `/tmp/circleu-long-entry-green.xcresult`. The earlier long-preview height failure was a genuine layout defect and was repaired before these checks. The largest-text tag test now ensures the whole control is above Done, asserts selected state and verifies Family after saving; the earlier partial-hittability check was insufficient.

## Independent review

`native_alignment_final_review` reviewed the committed parser/storage and pending UI/assets without modifying files or running concurrent tests. No confirmed actionable defect was found. It requested stronger evidence for tag-save retry and guidance during concurrent typing; focused coverage has been added. The extra long-content screenshot/test found and resolved a bounded-preview issue; no saved text was truncated. Five final focused unit cases pass, including the retry and concurrent-save checks (`/tmp/circleu-alignment-unit-followup.xcresult`).

## Remaining boundaries

No fresh physical-device voice/VoiceOver, minimum-iOS/iPad, deployed Firebase ownership, live recovery, or production release qualification. Source Firestore rules findings, retired legacy cloud model, old TestFlight/Firebase project mapping and guest Release routing remain separate gates from the audit. Simulator fixture speech does not prove real microphone behavior.

## Accessibility audit limits

[Retained audit observations](accessibility-observations.json) are informational output from existing `performAccessibilityAudit` handlers; those handlers do not fail the UI suite. They include disabled-button contrast, native search/navigation/font reports and existing Practice record hit-area reports. The changed wordmark's zero-width report was investigated in this slice. Remaining reports need targeted device triage; passing interaction tests are not a blanket accessibility certification.

## Native captures

- [Today](today-aligned-empty.png) · [Selected question](today-aligned-question.png) · [Largest text](today-aligned-ax5.png)
- [Journal card](journal-tagged-card.png) · [Tag picker](journal-tags-picker.png)
- [Largest-text card](journal-card-ax5.png) · [Largest-text picker](journal-tags-ax5.png) · [Long entry](journal-long-entry-ax5.png)

The final captures show a visible standard-size wordmark, separate context/feeling art, readable scrolling picker controls and bounded large-text previews. The native iOS search field truncates its placeholder at large sizes; its accessible label and search behavior remain available.

## Xcode review

`CircleU Guest Review` builds successfully for iPhone 18 Pro Simulator / iOS 27.0 (`/tmp/circleu-guest-review-build.log`). Open this worktree's `Circleu.xcodeproj`, select **CircleU Guest Review**, and choose **iPhone 18 Pro**. This is the isolated guest review configuration, not a standard Release archive. The project was sent to Xcode with `open -a Xcode`; the app UI-control bridge timed out, so its selected toolbar scheme could not be verified automatically.

[Machine-readable verification](verification.json) separates the full runs, focused follow-ups and skipped device/live-cloud checks. Remaining audit/release gates above are intentionally open.

## Earliest guest-store compatibility

The final launch found an existing simulator store that could not open (`unknownDataStoreSchema` / Core Data 134504). The first guest build in `2a7b630` stored only Entry; `e9c8a3c` later added SavedDraft to V1 in place. The existing migration tests covered that newer V1 shape, leaving the initial shape unrecognised.

A separate initial snapshot now restores that exact model, ordered before V1 as 0.9 without modifying V1–V6. An independent test creates the original **1.0** shape, verifies its historical checksum, and migrates it using the production plan. The test first failed with the same schema error, then passed. The full unit suite after the fix passed **276 tests, skipped one device-only check, and had zero failures** (`/tmp/circleu-initial-schema-green.xcresult`). No metadata rewriting, reset or fallback empty store is used.

A follow-up read-only review found no confirmed migration-safety defect and suggested asserting distinct creation/update timestamps and returned tags. Those assertions are now included. A private consistent SQLite backup was made before opening the existing simulator data; the actual-store comparison is recorded below.

The strengthened timestamp/tag regression passed (`/tmp/circleu-initial-schema-final.xcresult`). The final Guest Review build succeeded, installed over the existing simulator app and launched to onboarding. Read-only comparison confirmed schema 6.0.0 with the same entry count, IDs, original words, revisions and both timestamps as the pre-migration backup. Only the comparison outcome is recorded here. A private backup remains at `/tmp/circleu-legacy-simulator-backup`; do not treat temporary storage as permanent archival storage. Compatibility fix: `5046f73`.

Xcode was reopened with this worktree project, and its installed Device Hub viewer was opened for the iPhone simulator. The final captured screen was onboarding, not a new end-to-end physical-device test. Continue through onboarding to review Today and Journal. The already recorded full UI suite and focused layout checks apply; the final storage-only fix was verified by unit/migration tests and the existing-store comparison.
