# Figma brand refresh handoff

24 October 2026. **Owner-authorized prototype work; pending canvas update.** Update the existing [CircleU file](https://www.figma.com/design/RVLtfmIVcO8gNk5fam0Vjd) for review before production integration. This brief defines the next canvas pass; it does not represent an uploaded design or approve app feature coding.

## What is being reviewed

Use the [original native layout](original-layout-reuse.md) for composition and proportions, with the accepted [brand guideline](branding-guideline.md), existing Pingu artwork and concise content. The running original app and local browser prototype are separate artifacts. Changing the simulated iPhone model changes the device profile, not the installed app's branding or feature set.

Keep Draft 01 and Draft 02 available. Add a clearly named review area or page in the same file, provisionally **Brand review — original layout**, rather than overwriting the recovery reference. Keep review labels outside depicted product screens. Reuse existing controls/styles where suitable after inspecting them; do not introduce an unrelated UI kit or silently retain Inter in refreshed screens.

## Update order

| Pass | Frames and connections | Review requirement |
| --- | --- | --- |
| 1 — Welcome and readiness | Welcome → opening → first-use Today; optional Privacy & data and earlier-data branches; locked/read-failure retry and back paths | Use the latest [onboarding review](brand-demo/onboarding-review.md) content. Preserve the original centered hero and lower action group. Do not display fabricated history or bypass readiness after failure. |
| 2 — Three destinations | Today, Journal calendar/list and Practice, including first-use empty states | One consistent tab component, with identical bounds and baseline on equal-size phone frames. Journal calendar has no extra decorative header icon. Search and empty/read-failure states remain distinct. |
| 3 — Reflection | Capture → reflection → saved detail; reflection/source editors, discard, words-only save and return to latest saved item | Preserve Draft 02 semantics and source text. Save failure retains edits. Saving opens detail without a duplicate success screen. |
| 4 — Practice | Direct context → wording → saved practice; linked-entry handoff; message editor, Copy/Save/Discard and reopen | Standalone and linked practice remain distinct. Copy sends nothing and is independent of Save. Edits in either order preserve the other linked item. |
| 5 — Recovery consistency | Draft exit, stale suggestions, unavailable model/voice, save errors, export/delete scope and earlier-data recovery | Reuse the [state manifest](prototype-state.json) and existing recovery branches. Brand representative states first; record any branches still using older styling instead of claiming the entire file is refreshed. |

The approved destinations remain Today / Journal / Practice. Do not add circles, rewards, signup requirements or additional mandatory onboarding steps. Calendar interaction proposals still require specific review; a visual refresh does not approve them.

## Layout and identity checks

- Welcome starts from the original 172pt illustration slot, 32pt headline, 32pt hero-to-title gap, constrained helper width and 54pt primary button with 32pt side insets. Adjust optically for transparent artwork padding; preserve flexible vertical space rather than copying fixed board coordinates.
- Main screens start from the original 20–22pt side rhythm and stable root-owned navigation. Figma frames model the same safe areas; they cannot certify native safe-area or keyboard behavior.
- Use actual Plus Jakarta Sans weights and the accepted ink/blue/ice palette. Reuse the transparent Pingu artwork in the existing prototype resources. No new asset generation is needed for this pass.
- Use finite greeting/short transitions from the [motion guideline](motion-guideline.md); provide a still review alternative. Do not simulate loading with a forced delay or claim Figma tests OS Reduce Motion.
- Review a normal phone composition plus a compact/long-content comparison. Check wrapping, visible actions, scroll clearance and tab placement. Native Dynamic Type, keyboard and accessibility validation follow in SwiftUI.

## Review journeys before coding

1. First visit: understand the purpose and device-storage limitation, inspect privacy optionally, then reach an empty Today.
2. Storage cannot open: retry or return safely; no empty Journal replaces unreadable data.
3. Reflection: type a moment, correct an interpretation, save, reopen and edit without creating a duplicate.
4. Practice: start directly or from an entry, edit wording, copy and save independently, then reopen the correct version.
5. Journal: find an entry by date or search, distinguish an empty day from a read failure, and return without moving the navigation bar.
6. Earlier users: inspect recovery choices and continue without automatic import or deletion; existing recovery access stays reachable.

Use invented scenarios only. Figma demonstrates navigation and preset states; it does not prove real typing, storage, clipboard, imports or privacy isolation. After visual/flow review, validate the selected treatment in the existing isolated SwiftUI prototype on a phone-sized destination before authorizing production integration.

## Access and completion status

The owner's intended Figma account was confirmed on 24 October. Both metadata inspection and a read-only canvas-tool availability check returned the Starter-plan MCP call-limit error. **No canvas changes were made in this pass.** The edit workflow requires inspecting the existing file before mutations, so the refresh is pending usable connector access.

Figma's [access documentation](https://developers.figma.com/docs/figma-mcp-server/rate-limits-access/) distinguishes metered read tools from some exempt write tools. This is not a claim that every write operation is universally blocked; the actual canvas tool needed here returned the limit error. No plan, seat, sharing or billing changes were attempted. Once access is available, inspect the current file, perform the passes above, verify screenshots and prototype links, then replace this pending status with actual frame links and remaining gaps.
