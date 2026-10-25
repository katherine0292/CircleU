# UI polish: Pingu avatar picker, Pingu moments and illustrated icons

- Recorded: 2026-10-26 01:20:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), on Mike's Mac
- Status: completed; merged under Mike's auto-merge-when-green rule
- Base revision and branch: `codex/guest-ui-polish` from `main` at `ef28b1e`
- Related record / task / PR: [UI feedback backlog](../design/ui-feedback-backlog.md) item 1; [screenshots](../qa/screenshots/ui-polish-2026-10-26)

## Request and scope

Mike asked for more of the Codex Pingu and icon assets in the UI. This supersedes the earlier "restrained illustrations" choice. Guest journal only.

## Work and outcome

- **Avatars:** all 21 Pingu avatars are bundled, downscaled to 420 px (about 2.4 MB in total).
  - Choose one from the Today hero or Settings → Your Pingu. Each has a spoken name.
  - The choice is kept on this iPhone under a new key, `circleu.guest.avatar.v1` (no legacy keys), and Delete all resets it.
- **Pingu moments:**
  - empty Journal: writing;
  - no search results: thinking;
  - empty calendar day: sleeping;
  - "Saved to your journal": a neutral wave, shown in the top inset so it doesn't cover the new entry;
  - saved Practice message: a wave next to "Saved · not sent".
- **Illustrated icons:** reflection, feeling, next step and privacy; Settings section headers; Get a suggestion. Native symbols stay for the microphone, back, Edit and delete.
- **Accessibility:**
  - decorative art is hidden from VoiceOver and left out at accessibility text sizes;
  - the saved moment is announced;
  - Reduce Motion turns off the sliding animation.
- **Bug fix found by the new UI test:** after **Save with reflection**, going back to Today showed a blank pushed screen. Two nested `isPresented` destinations were being popped at once. Today now uses a path-based stack (`write`, `review`), and saving clears the whole path. This also affected batch A on Mike's phone.

## Verification

- **Full local suite:** 224 passed, 0 failed, 1 skipped (device-only). The new tests check that all 21 avatars and the icons load, that Delete all resets the avatar, and the save moment.
- **Out-of-repo XCUITests** (iPhone 18 Pro / iOS 27.0), eight passed, including a new screenshot test that checks Today returns to its start after saving.
- **Not run:** VoiceOver and Reduce Motion on a device; CI (manual by owner decision).

## Discussion and decisions

- **Codex** ([log](2026-10-26-011500-codex-review-guest-ui-polish.md)): no blocker. All three should-fixes were applied:
  - neutral pose for the automatic save moment;
  - Reduce Motion;
  - banner art hidden at accessibility sizes.
- The navigation fix came afterwards from my own UI test and has not been reviewed by Codex. It is small and covered by the UI test.

## Handoff

- Remaining work: Mike's phone check with the screenshots; batch C (import approved by Mike: copy-only, preview, idempotent, reports skips).
- Owner: Mike (check); Claude (batch C)
- Risks / unresolved questions: none new.
