# Codex review: Practice with fewer words

- Recorded: 2026-10-26 16:30:00 +11:00; Australia/Sydney
- Agent / role: Codex (gpt-6-astra, high, read-only reviewer), run by Claude Code on Mike's Mac
- Reviewed: `git diff origin/main...HEAD` on `codex/practice-visual` (`2bcf1f5`, `6d5b6c9`, `4df4ec2`)
- Related: [Practice visual entry](2026-10-26-160000-claude-practice-visual.md)

## One pass

**Changes requested.** No draft-loss or guardrail regression found.

**Blockers (both fixed by Claude Code in the follow-up commit)**

1. **A saved message said "Not saved."** After Copy on a saved message, the screen showed "Saved · not sent" and "Copied. Not saved or sent." together. Fix: the saved view now says "Copied. Not sent."; the UI test copies on the saved screen and checks that line.
2. **More than one filled action.** "Get a suggestion" and each "Use this" were filled blue next to Save, against the one-primary-action rule. Fix: "Get a suggestion" is a tinted bubble with blue text; "Use this" is outlined.

**Non-blockers (not changed)**

- Coverage claims are generous: P2.5 cites tests that open only Situation (not Goal or a restored draft); P4.2's UI test uses the first card without swiping; P3.4 checks the Edit pencil exists without using it.
- Accessibility looks right in source (labelled chips with 44-point height, 44×44 Copy, Copy/Copied labels, scaling fonts, no new animation). Largest Dynamic Type, VoiceOver through the card carousel and Reduce Motion still need a runtime check. The audit helper records issues without failing.
- Hidden startup switch, local suggestions, storage and legacy/Firebase paths are unchanged.
