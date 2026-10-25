# Codex review of guest brand polish (PR #13)

- Recorded: 2026-10-25 20:50:46 +11:00; Australia/Sydney
- Agent / role: Codex, reviewer
- Status: completed
- Base revision and branch: `6834e0e9fd224baed684f251ef16df6101aa576e` on `codex/guest-brand-polish`; cached `origin/main` at `ae59535f431579d4c9363df1a519c20b9c1aa398`; working tree clean.
- Related record / task / PR: PR #13; [Claude’s polish record](2026-10-25-204711-claude-guest-brand-polish.md).

**Verdict: No confirmed finding BLOCKS merge of this DEBUG-only guest polish. Nonblocking findings and verification gaps follow; this is not release qualification.**

## Request and scope

Reviewed `git diff origin/main...HEAD`, the guest branding/screens/root, font and licence, avatar, tests and QA/log documentation. Read AGENTS.md, project and shared standards, log protocol/template, relevant records, MVP decisions and implementation/transition plans. Local reads only; no network, builds or file writes.

## Work and outcome

Findings, ranked by severity:

1. **Medium — inherited contrast limitation, nonblocking for this scope.** [GuestJournalScreens.swift:166](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Features/GuestJournal/GuestJournalScreens.swift:166>) uses fixed dark text on system-controlled list rows. Hiding the list’s scroll background does not set row backgrounds, and the guest root does not enforce light appearance. Dark rows therefore remain problematic; the previous implementation already combined fixed dark text with adaptive rows, and dark mode is explicitly deferred. **Fix:** constrain the guest experience to light appearance until adaptive foreground/background pairs are implemented; keep that constraint guest-local.

2. **Low — font-availability test can report success without successful registration.** [GuestBrand.swift:21](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Features/GuestJournal/GuestBrand.swift:21>) ignores registration success and derives `fontName` from a parsed descriptor. Consequently, `isBrandFontAvailable` and [GuestBrandTests.swift:6](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/CircleuTests/GuestBrandTests.swift:6>) do not prove that name resolves to the bundled font. **Fix:** verify resolution and family identity after registration, accepting an already-registered font when it resolves correctly. Retain the useful licence/avatar bundle checks.

3. **Low — QA status and evidence need qualification.** [QA:27](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/docs/qa/guest-journal-first-slice-2026-10-25.md:27>) still lists work subsequently reported completed. Lines 31–36 describe all navigation titles as bold although inline titles request weight 600, and call audits passed while listing remaining findings without explaining exclusions. **Fix:** reconcile current status; record the tested revision, destination, exact commands and audit exclusions. Describe the device result as verification of `.completeUnlessOpen` attributes: the inspected test does not exercise locked-device access denial. Correct published log claims through a new entry.

Other review conclusions:

- **Licence:** the bundled copyright notice and complete OFL 1.1 permit redistribution with software. Font and licence are byte-identical to the prototype copies; embedded copyright matches. The synchronized app target includes their directory without exclusions. No bundling compliance defect identified; final packaged-resource verification remains reported.
- **Guest isolation:** `UINavigationBar.appearance()` is process-global, including its transparent-background configuration. However, its only caller is `GuestRootView.init`, and startup selects mutually exclusive guest/existing roots. No current legacy visual regression was identified. Scope appearance to guest navigation instances before introducing coexistence or recovery navigation in that process.
- **Dynamic Type:** `.custom(..., relativeTo:)` uses appropriate unscaled baseline sizes; no double scaling is present. UIKit uses style-specific `UIFontMetrics` correctly for initial sizing. Appearance is installed from initialization, so live text-size changes and SwiftUI environment overrides remain unverified; check existing navigation bars without relaunching before claiming complete adaptation.
- **Variable weights:** the font’s `wght` axis spans 200–800, default 400. UIKit explicitly requests valid 600/700 values. SwiftUI uses `.weight`; actual resolved weights were not verified. The “default is ExtraLight” comment should distinguish the selected CoreText descriptor from the font’s axis default.
- **Accessibility:** editors retain labels, the avatar is hidden from VoiceOver, headings retain header traits, and buttons use a 54-point minimum rather than fixed height. Calculated light-palette contrast: ink/ice **17.56:1**, muted/ice **6.11:1**, muted/white **6.42:1**, blue/ice **6.74:1**, white/blue **7.08:1**. These calculations do not certify translucent system surfaces or VoiceOver traversal.
- **Assets and standards:** avatar **751,474 bytes**, 1254 × 1254 RGBA; font **176,288 bytes**. Both match retained prototype originals; artwork provenance exists and the avatar was visually inspected. No unauthorized recompression or binary-size violation identified. Promotion is explicitly authorized in the polish record; the helper remains feature-scoped.

## Verification

- `git diff --check origin/main...HEAD`: passed.
- `git status --porcelain`: clean.
- Read-only binary comparison, font-table inspection, PNG metadata inspection and contrast calculations completed.
- Git returned results despite sandbox temporary-cache warnings.
- **Reported only:** Claude’s 149 passing tests, one simulator device-test skip, UI flow/default-and-largest-text audits, and passing physical-device protection-attribute test.
- Not run / limitations: no independent build, tests, UI, live Dynamic Type changes, resolved-weight inspection or physical-device validation. Full VoiceOver and owner visual acceptance remain pending. No files written.

## Discussion and decisions

None. No direct inter-agent exchange occurred. Claude’s results were supplied by the user and repository records. Recommendations above do not authorize implementation or release.

## Handoff

- Remaining work: strengthen font resolution verification, reconcile QA wording, and validate live text-size changes/resolved weights; retain the deferred dark-mode limitation explicitly.
- Owner: Unassigned for follow-ups; Mike retains merge approval.
- Risks / unresolved questions: process-global appearance must be revisited before guest/legacy coexistence; reported audits do not establish complete accessibility coverage.