# CircleU motion proposal

24 October 2026. The owner asked whether to add animation and subsequently approved the small isolated demo. [The native motion demo](brand-demo/motion-demo.md) now implements the greeting/transitions/feedback comparison in the preview package. Production motion adoption remains a proposal; accessibility support is not certified by this demo.

## Purpose and proposed first pass

Motion should help explain an action or state change. Keep input usable immediately; no animation may delay saving, copying, navigation, cancellation or error recovery. Retain readable labels and completion states after movement ends. The timings below are project starting points to assess, not Apple-prescribed values.

| Moment | Proposed treatment | Reduced Motion alternative |
| --- | --- | --- |
| Navigation and opening an editor | Prefer native transitions; optional short 180–250 ms fade for custom content | Brief dissolve or immediate state change, preserving context |
| Button press | Short subtle response using existing native/SwiftUI control behavior | Avoid additional scale/bounce; preserve visible pressed state |
| Save or Copy completes | One short check/label transition, then persistent Saved or Copied feedback as appropriate | Immediate check/label; announce the result accessibly without requiring movement |
| Welcome or a quiet empty state | Optional single small Pingu tilt on entry or explicit tap, settling within about 600 ms | Still illustration; no decorative movement |
| Real loading | Native progress feedback tied to actual work, with cancellation and retained input | Stable status text plus reduced visual motion; no fictional progress or mascot implying hidden processing |
| Writing, editing or reading an entry | Still mascot outside the editor, or no mascot | Same still layout |

Do not add continuous bouncing, floating backgrounds, parallax, celebratory reactions to disclosure or a moving calendar header. Do not autoplay decorative movement while the user is typing. A Quiet breath illustration does not add a breathing exercise or a health claim; that feature would need a separate scope decision.

Apple recommends adjusting motion that causes discomfort and preserving useful meaning with alternatives such as fades or highlights. It also recommends responding to the system setting. Follow its [Reduced Motion evaluation criteria](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/reduced-motion-evaluation-criteria); SwiftUI exposes the setting through [accessibilityReduceMotion](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion). Sources checked 24 October 2026. Our proposed placements and durations are design judgments, not findings from a usability study.

## Reuse and existing issues to address

Source inspection of [PinguGlassKit.swift](../../Circleu/Design/PinguGlassKit.swift) found an existing `PinguMascot` with idle/think/celebrate loops, ring pulses and a repeating timer. It currently applies its blink scale to the whole image; this compresses the character rather than animating eyelids. The timer returned by `Timer.scheduledTimer` is not retained for invalidation, and no Reduce Motion environment check appears in that component. This is a source finding; the app was not run in this task. Existing navigation and pressed-control animations also need review in context rather than wholesale removal.

Before reusing that component: choose finite motions, respond to Reduce Motion changes while visible, stop tasks/timers when hidden or backgrounded, prevent duplicate animation loops after repeated appearances, and avoid transforming the whole body to imitate an eye blink. Preserve all interaction and status behavior with motion off. Do not replace production code during this asset/planning task.

## Asset and implementation approach

Start with native SwiftUI transitions and a finite transform of a whole illustration where appropriate. No new animation dependency is needed for that proposed first pass. Existing [Pingu activities](brand-demo/pingu-activities.md) are separate static PNGs, not aligned frames, layered artwork or an animation rig. Crossfading between unrelated poses is not a natural writing/reading animation.

For a real flipper wave, eye blink or pencil movement later, prepare a layered/vector master or an intentionally aligned frame set using the selected character. A vector-animation tool can be evaluated if those authored actions justify it; do not add a dependency merely to move a PNG. Preserve transparent originals and use a static fallback. Avoid animated GIFs as the primary app asset format because the proposed design needs explicit playback, state and accessibility control.

## Validation before adoption

The authorized isolated demo compares a short transition, Save/Copy feedback and one Pingu greeting against the still version. Its [evidence record](brand-demo/motion-demo.md) distinguishes completed native interaction checks from remaining OS-setting, lifecycle, device, performance and accessibility checks. Test real Reduce Motion changes while visible, re-entry/background/resume, keyboard focus, cancellation and VoiceOver before adoption. Static ImageRenderer catalogs cannot validate animation behavior, performance or motion comfort.

Current status: owner approved and received the isolated demo. The responsive continuation adds a compact comparison, a separate Simulator host and launch/layout captures from iPhone 18 Pro/iOS 27.0 and iPhone 17e/iOS 26.5. Native Mac compact checks are separate evidence; iOS touch/keyboard/Done, rotation, VoiceOver and real system-setting changes remain pending. Motion feel and production integration remain for review. No animation has been added to the main app or historical static catalogs.
