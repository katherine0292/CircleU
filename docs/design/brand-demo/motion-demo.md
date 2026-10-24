# CircleU isolated motion demo

24 October 2026. The owner approved a small animation demo: a Pingu greeting, screen transitions and Save/Copy feedback, with Reduce Motion support and still writing screens. Implemented only in the standalone visual prototype, not the Circleu app.

## Open it

From the repository root on this Mac:

```sh
bash Prototypes/CircleUVisualPrototype/scripts/build-motion-demo.sh
```

Open the printed app path, normally `/tmp/CircleU Motion Demo.app`, in Finder. The build creates only a disposable local review app; it does not install a signing identity, change system settings or run the production app. Rebuild if the temporary app has been removed. In Xcode, the library's `BrandMotionDemo.swift` also has a named interactive Canvas preview; live Canvas was not checked in this pass.

On macOS, choose **Preview → iPhone width** for a 390-point window, or **Desktop comparison** for both panels. Below 800 points, a segmented switch selects one comparison. The samples keep their own drafts across comparison and width changes. Scroll the workbench to reach the lower actions.

### Isolated iPhone Simulator host

On an Apple Silicon Mac with an installed iPhone Simulator SDK/runtime:

```sh
bash Prototypes/CircleUVisualPrototype/scripts/build-motion-simulator.sh
```

The script prints `/tmp/CircleU Motion Simulator.app`. It compiles the same view source directly with the installed Apple compiler, copies only the required existing artwork/font/license, and ad-hoc signs the disposable bundle. It creates no Xcode project or signing-team configuration. Its identity is `com.circleu.prototype.motionsimulator`, separate from the production app. It currently targets arm64 Simulator only; this is not a device archive or release build.

Choose an available Simulator UUID from `xcrun simctl list devices available`, boot it if necessary, then install and launch (set `CIRCLEU_MOTION_SIMULATOR_ID` to the selected UUID first):

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl install \
  "$CIRCLEU_MOTION_SIMULATOR_ID" '/tmp/CircleU Motion Simulator.app'
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl launch \
  "$CIRCLEU_MOTION_SIMULATOR_ID" com.circleu.prototype.motionsimulator
```

The iOS editor has a keyboard Done control and interactive scroll dismissal. Their behavior still needs live iOS keyboard validation.

## What to try

1. **Replay greeting:** the left Pingu tilts by up to 3° and settles over 500 ms. It is a finite whole-illustration greeting, not an independently animated flipper or eyelid. The right comparison remains still.
2. **Write a reflection:** open the editor, change the invented text and try Save reflection. The editor has no mascot movement. Return to Today and reopen it to check draft retention.
3. **Practice a message:** try Save and Copy separately. Both feedback cues can coexist; changing the message clears both. Whitespace-only text disables the actions.
4. **Preview reduced motion:** force the left specimen still, including after triggering a greeting. The right specimen always forces reduced motion. Neither can override the real system Reduce Motion setting to re-enable movement.
5. **Reset both samples:** return both panels to their original sample content and Today screen; the preview reduction preference stays selected.

The panels are independent. All text is fictional, editable process-memory sample state, cleared when the demo closes or resets. Save/Copy only change feedback labels: there is no disk persistence, app-data access, clipboard write, network call or message delivery. The workbench labels this limitation above the specimens.

## Implementation

[Workbench source](../../../Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/BrandMotionDemo.swift), [native executable](../../../Prototypes/CircleUVisualPrototype/Sources/MotionDemo/CircleUMotionDemoApp.swift) and [build script](../../../Prototypes/CircleUVisualPrototype/scripts/build-motion-demo.sh) reuse existing artwork, brand colors and actual Plus Jakarta Sans. No animation library or new image generation is involved.

Native keyframes provide one 180 ms tilt and 320 ms return. A still branch replaces the animator whenever motion is disabled or the supplied scene phase is not active. No timer, sleep task or repeating animation is used. Hidden comparisons are disabled, excluded from hit testing/accessibility and clear editor focus. `AnyLayout` keeps both panel identities while changing their arrangement. Page changes use a short 180 ms opacity transition; completion feedback uses a 160 ms transition. These are design starting points, not measured platform timing guarantees. The [motion guideline](../motion-guideline.md) remains the production proposal.

## Evidence and limitations

### Original native demo — prior verification

The following checks are recorded in the [original demo log](../../agent-collaboration-log/2026-10-24-091057-codex-isolated-motion-demo.md); the continuation below records this pass separately.

- Standalone product build, complete package build, shell syntax and `.app` resource loading checked. Live native macOS window showed actual font/artwork and both panels.
- Native UI checks exercised reflection Save, edit invalidation, whitespace disabling, navigation retention, independent Save/Copy feedback, message edit invalidation, blank-message disabling, actual typing in the always-reduced panel, forced reduction, replay and reset. A replay followed immediately by the reduction toggle disabled replay and selected the still branch; exact mid-frame timing was not instrumented.
- The original focused reviewer inspected source/resources and reported no material findings. This was not a second runtime test. Some native accessibility queries immediately following UI updates returned transient errors; settled reads and screenshots confirmed the resulting state. An initial UI assertion expected separate text nodes for Saved/Copied; inspection showed their text is combined, and the corrected check passed.
- App switching was exercised, but inactive-scene interruption was not independently established by the automation. Real OS Reduce Motion changes, physical devices, live Canvas, VoiceOver announcements, Dynamic Type, low-power/performance behavior and precise temporal/comfort evaluation remain unverified. Those checks precede production adoption.
- No main-app, Firebase, existing-data, migration, Figma or release change. Historical static PNGs remain separate evidence; they cannot establish animation behavior. The new launch captures below establish only layout at the initial scroll position, not animation or interaction behavior.

### iPhone-width continuation — 24 October

- Complete standalone package and direct-compiler Simulator host build passed with Xcode 27.1/Swift 6.4. Both disposable bundles pass `codesign --verify --deep --strict`. The Mac script now signs after packaging; before that correction its bundle verification failed with “code has no resources but signature indicates they must be present.”
- The final host installed and launched on **iPhone 18 Pro / iOS 27.0** and **iPhone 17e / iOS 26.5**. Unmodified `simctl io … screenshot` frames are [18 Pro launch](motion-validation/iphone18pro-ios27-launch.png) (1206 × 2622) and [17e launch](motion-validation/iphone17e-ios26-5-launch.png) (1170 × 2532). Both show the selected panel, actual font/art and no horizontal clipping in the visible initial content; lower actions are below the fold.
- Native macOS compact interaction checks confirmed reachable message actions, whitespace-only action disabling, Save/Copy feedback, distinct comparison drafts, selected-panel-only accessibility content, cleared editor focus on switching, disabled replay in the reduced sample, and retained drafts/feedback when expanding to desktop width. These are Mac checks, not iPhone touch evidence.
- A fresh source reviewer found that visual hiding alone did not disable hidden keyboard actions. Added `.disabled(!visible)` alongside focus cleanup, hit-testing and accessibility gating; the reviewer reported no remaining material source findings. Final hosts were rebuilt afterward.
- Native automation sometimes returned an accessibility error immediately after a successful action; subsequent trees/screenshots showed the editor or selected comparison. Treat settled observations as evidence, not the error alone as an app failure or a pass.
- This installation exposes working CoreSimulator CLI runtimes but no resolvable Simulator GUI app. **iOS touch navigation, keyboard/Done behavior, scrolling, rotation, keyboard navigation and VoiceOver remain unverified.** No physical-device check was performed. The compact workbench is not a production mobile screen.
- All 48 historical ImageRenderer exports regenerated successfully and kept their dimensions; a fresh Today render was visually compared with the baseline. The rerenders differed in bytes/pixels, despite unchanged catalog source; they were kept in temporary review output and the exact historical PNGs retained. No deterministic-render equivalence is claimed.

Next: owner review of the native motion feel. Approval of this demo does not approve production integration or settle remaining accessibility/device validation.
