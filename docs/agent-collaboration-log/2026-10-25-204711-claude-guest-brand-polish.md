# Guest journal brand polish

- Recorded: 2026-10-25 20:47:11 +11:00; Australia/Sydney.
- Agent / role: Claude (Claude Code).
- Status: PR open for Codex review and owner approval; not merged.
- Base revision and branch: `codex/guest-brand-polish` on main `ae59535` (PR #12 merged).
- Related record: [QA](../qa/guest-journal-first-slice-2026-10-25.md#brand-polish-follow-up-branch-codexguest-brand-polish).

## Request and scope

Mike chose option (a), polish: the brand font and look on the guest screens only, Dynamic Type, an accessibility pass at default and largest text, and the on-phone encryption test in a separate bundle only.

## Work and outcome

- `GuestBrand`: the preview palette, a Plus Jakarta Sans helper scaling with Dynamic Type, bold navigation titles, and a brand button style. The font and its OFL licence are in `Circleu/Resources/GuestBrandFonts`. The `GuestBrandAvatar` asset (copied unchanged from the approved preview artwork, 751 KB) is used on Today.
- Guest screens moved to the brand look; the Journal list uses the brand background. The existing app is unchanged.
- `GuestBrandTests`: the font, licence and avatar ship in the app bundle.

## Verification

- `xcodebuild test` with the CI signing config: 149 passed, 1 device-only skipped.
- Out-of-repo XCUITest flow with accessibility audits at default and largest text: passed. Findings are listed in the QA doc.
- Device: `testRealDataProtectionOnDevice` passed on the owner's iPhone under a separate test app ID, which was then uninstalled.
- Not run: owner look-and-feel check (pending), full VoiceOver pass.

## Discussion and decisions

Codex review requested (read-only).

## Handoff

- Remaining work: Codex review; reinstall CircleU Guest Test for the owner's look-and-feel check; merge go-ahead.
- Owner: Mike.
