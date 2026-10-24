# Onboarding reference research, concise copy and font audit

- Recorded: 2026-10-24 17:23:09 +1100; Australia/Sydney.
- Agent / role: Codex coordinator.
- Status: research and local review refinement delivered; owner/native/Figma validation pending.
- Base revision and branch: `7c0cf9de72b128ce5dbbdfe1be019993e450ea4c`, `codex/journal-calendar-planning`; starting tree clean.
- Related record: [focused onboarding gap pass](2026-10-24-170636-codex-onboarding-gaps-and-review.md).

## Request and scope

Owner requested researching established apps' onboarding/other screens, reducing content, using animation and checking the current font. Reused the authorized isolated prototype and accepted brand/motion direction. No production feature work, backend, release or account changes. Existing scoped commit/push authorization applies.

## Work and outcome

Saved [publisher-based research and screen-copy proposals](../design/onboarding-patterns-research-2026-10-24.md), with primary links, exact-sequence limitations and the distinction between How We Feel's historical check-in explanation and its 2026 Today beta. Headspace's public introduction is not presented as a verified current first-launch flow. No popularity ranking or user-study finding inferred.

The local conversation review v3 preserves v2 and all seven states. Shortens Welcome to Find your words, reduces privacy/earlier-data text and removes repeated Today helper copy. Reuses original artwork/font, adds the previously approved finite 500ms whole-Pingu greeting and 180ms navigation fades, with system reduced-motion and reviewer still alternatives. No continuous animation, fake I/O progress or mascot editor behavior added. Other-screen copy remains a proposal in the research document.

Audited actual TTF metadata, weight axis, license and selected glyphs. Recommend retaining Plus Jakarta Sans with fewer weights; do not infer native rendering correctness from the CoreText descriptor suffix. Documented production system fonts, the last-known Figma Inter state and fixed-size native specimens as separate adoption/accessibility work. Linked the findings from the documentation index, onboarding review and checklist.

## Verification

- `fontTools.ttLib.TTFont`: Plus Jakarta Sans Regular, weight axis 200–800/default 400; selected punctuation, ambiguous Latin characters and Vietnamese glyphs present. Embedded local TTF bytes equal the repository font. Font and original asset files unchanged.
- Browser read-only DOM checks: custom font loaded; body 17px/400, title 700, button 600; images loaded; phone overflow zero at 390 CSS px. At a 320px browser viewport, Welcome, Privacy, Earlier data and Today fit horizontally within the host's 261–276px phone width. Temporary viewport override reset.
- Greeting replay produced a nonidentity transform, then settled to `none`; Still preview disabled replay. No motion-comfort or timing-accuracy certification inferred. OS-setting changes, hidden/offscreen cancellation and native font scaling remain source-reviewed only.
- Exercised nested privacy/earlier-data returns and deferral; completed-user read-error Back to welcome → Get started remains blocked; retry-to-ready; pending cancel with late Ready staying at Welcome; repeated locked retry and Privacy return. Browser error logs empty at end. One stale click after viewport reset succeeded after refreshing the UI state.
- `node --check /tmp/circleu-onboarding-v3-check.js` passed for extracted local script. Fragment is 549,888 bytes, under 1 MB. Relative document links and `git diff --check` checked before publication.
- Not run: Figma calls (last known MCP quota blocked), Xcode/native build, iPhone/VoiceOver/Dynamic Type, actual storage/import/network/relaunch or participant research. This task changed repository documentation and the isolated conversation review only. No CI pass claimed.

## Discussion and decisions

None. No subagent or other-chat exchanges, external messages or participant contact. Concise copy/type choices are coordinator proposals for review; the accepted family, character and navigation are preserved.

## Handoff

- Remaining work: owner reviews purpose, first action, storage understanding and motion/still preference; apply accepted changes to editable Figma when access permits; verify native typography/scaling/lifecycle in a separately authorized slice. Other screen copy is prepared for later review.
- Owner: Unassigned; no background work scheduled.
- Risks: production still contains account/cloud behavior. Local privacy statements describe the intended release, not current runtime guarantees. Existing Figma handoffs retain wireframe/sample-history limitations.
