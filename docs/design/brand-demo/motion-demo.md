# CircleU isolated motion demo

24 October 2026. The owner approved a small animation demo: a Pingu greeting, screen transitions and Save/Copy feedback, with Reduce Motion support and still writing screens. Implemented only in the standalone visual prototype, not the Circleu app.

## Open it

From the repository root on this Mac:

```sh
bash Prototypes/CircleUVisualPrototype/scripts/build-motion-demo.sh
```

Open the printed app path, normally `/tmp/CircleU Motion Demo.app`, in Finder. The build creates only a disposable local review app; it does not install a signing identity, change system settings or run the production app. Rebuild if the temporary app has been removed. In Xcode, the library's `BrandMotionDemo.swift` also has a named interactive Canvas preview; live Canvas was not checked in this pass.

## What to try

1. **Replay greeting:** the left Pingu tilts by up to 3° and settles over 500 ms. It is a finite whole-illustration greeting, not an independently animated flipper or eyelid. The right comparison remains still.
2. **Write a reflection:** open the editor, change the invented text and try Save reflection. The editor has no mascot movement. Return to Today and reopen it to check draft retention.
3. **Practice a message:** try Save and Copy separately. Both feedback cues can coexist; changing the message clears both. Whitespace-only text disables the actions.
4. **Preview reduced motion:** force the left specimen still, including after triggering a greeting. The right specimen always forces reduced motion. Neither can override the real system Reduce Motion setting to re-enable movement.
5. **Reset both samples:** return both panels to their original sample content and Today screen; the preview reduction preference stays selected.

The panels are independent. All text is fictional, editable process-memory sample state, cleared when the demo closes or resets. Save/Copy only change feedback labels: there is no disk persistence, app-data access, clipboard write, network call or message delivery. The workbench labels this limitation above the specimens.

## Implementation

[Workbench source](../../../Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/BrandMotionDemo.swift), [native executable](../../../Prototypes/CircleUVisualPrototype/Sources/MotionDemo/CircleUMotionDemoApp.swift) and [build script](../../../Prototypes/CircleUVisualPrototype/scripts/build-motion-demo.sh) reuse existing artwork, brand colors and actual Plus Jakarta Sans. No animation library or new image generation is involved.

Native keyframes provide one 180 ms tilt and 320 ms return. A still branch replaces the animator whenever motion is disabled or the supplied scene phase is not active. No timer, sleep task or repeating animation is used. Page changes use a short 180 ms opacity transition; completion feedback uses a 160 ms transition. These are design starting points, not measured platform timing guarantees. The [motion guideline](../motion-guideline.md) remains the production proposal.

## Evidence and limitations

- Standalone product build, complete package build, shell syntax and `.app` resource loading checked. Live native macOS window showed actual font/artwork and both panels.
- Native UI checks exercised reflection Save, edit invalidation, whitespace disabling, navigation retention, independent Save/Copy feedback, message edit invalidation, blank-message disabling, actual typing in the always-reduced panel, forced reduction, replay and reset. A replay followed immediately by the reduction toggle disabled replay and selected the still branch; exact mid-frame timing was not instrumented.
- A focused independent reviewer inspected source/resources and reported no material findings. This was not a second runtime test. Some native accessibility queries immediately following UI updates returned transient errors; settled reads and screenshots confirmed the resulting state. An initial UI assertion expected separate text nodes for Saved/Copied; inspection showed their text is combined, and the corrected check passed.
- App switching was exercised, but inactive-scene interruption was not independently established by the automation. Real OS Reduce Motion changes, iPhone Simulator/hardware, live Canvas, VoiceOver announcements, Dynamic Type, low-power/performance behavior and precise temporal/comfort evaluation remain unverified. Those checks precede production adoption.
- No main-app, Firebase, existing-data, migration, Figma or release change. Historical static PNGs remain separate evidence; they cannot establish animation behavior. No new committed screenshot/video is used as a substitute for the live window.

Next: owner review of the native motion feel. Approval of this demo does not approve production integration or settle remaining accessibility/device validation.
