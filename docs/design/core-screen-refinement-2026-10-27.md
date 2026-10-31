# Native core screen refinement

27 October 2026. Owner requested continued screen-by-screen UI refinement after the landscape poster. This pass changes the running guest SwiftUI views, preserving the original structure, Plus Jakarta Sans, brand palette and existing Pingu assets.

## Screen decisions

| Screen | Refinement |
| --- | --- |
| Today | A shallower 2.2:1 crop removes quiet sky and exposes more writing space; microphone and chosen-avatar controls stay in place. The writing nudge uses a pale surface, ink text and blue secondary controls so Save remains prominent. Listening art is unchanged. |
| Journal | The ice background fills the available area in empty, loading, error and populated states. Existing date tiles and the clean calendar remain. |
| Entry detail | Compact inline date title; the time is secondary, with the full creation timestamp available through its accessibility label. Original words lead the screen. |
| Practice home | Empty and populated states share an ice-toned Pingu card with a blue action strip and one tap target. Decorative art is omitted at accessibility text sizes. |
| Practice editor | Save sits above the keyboard, independent of form/suggestion scrolling. Editing failure feedback sits beside it and dismisses keyboard focus without losing the draft. Suggestion cards size to the available width. |
| Welcome, reflection, settings and recovery | Retained for this pass. Reflection already uses a pinned primary action. Existing privacy/source labels, account scope and recovery behavior stay explicit. Regression checks are separate from a visual redesign of these screens. |

## Evidence and boundaries

Implementation: [screen-refinement plan](../superpowers/plans/2026-10-27-core-screen-refinement.md). Existing data models, persistence, Firebase adapters and tab destinations are unchanged. This is a development refinement, not a Release/TestFlight qualification.

The new Practice keyboard regression failed against the baseline because Save was not hittable. The first updated focused run passed at normal and largest accessibility text with the software keyboard visible. Independent source review prompted a failure-feedback fix and a stronger outer-scroll assertion. Final suite results and the native screenshot review are recorded after verification in the agent log.

No generated poster screen is used as an exact implementation specification. No new animations, artwork files, fonts, community features or cloud behavior are introduced here. Hardware VoiceOver and error-announcement speech require separate device validation.

## Review artifacts

[Open the native screen gallery](core-screen-review-2026-10-27/index.html). The local browser version is available at http://127.0.0.1:55987/ while its server runs. Each capture opens at full size.

Verification: 256 unit tests passed; 21 runnable UI tests passed across the full run and targeted reruns, with 1 live-Firebase test deliberately skipped. The initial full run had two failing test gestures, corrected and rerun successfully. [Detailed evidence and review exchange](../agent-collaboration-log/2026-10-27-083849-codex-core-screen-refinement.md).
