# Native onboarding interaction review

24 October 2026. Owner requested button/scroll checks on the selected phone before Today, and asked about storage messaging, Privacy, Login and a Pingu background. Starting revision `17f8a3773f6af416d27a18e35e03ee3feee255b0`; clean `codex/journal-calendar-planning` branch.

## Review setup

Xcode Canvas displayed the correct view but its accessibility button press did not navigate; direct coordinate/scroll input returned `noWindowsAvailable`. These are automation limits, not passing interaction checks or proof of an app defect.

Extended the existing isolated Simulator host with `--onboarding` and `--large-text` launch options. Its default motion-demo path remains available. The host compiles the existing onboarding view directly, copies only the existing logo/Pingu/font resources and uses `com.circleu.prototype.motionsimulator`; it does not import the production app or Firebase. Installed and launched on **iPhone 18 Pro / iOS 27.0**, UUID `C7B63706-4D1C-4B7F-A161-8A2339D14E2B`. This is a Simulator app run, separate from Canvas and physical-device validation.

```sh
bash Prototypes/CircleUVisualPrototype/scripts/build-motion-simulator.sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl install \
  C7B63706-4D1C-4B7F-A161-8A2339D14E2B '/tmp/CircleU Motion Simulator.app'
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl launch \
  C7B63706-4D1C-4B7F-A161-8A2339D14E2B com.circleu.prototype.motionsimulator --onboarding
```

Terminate only this prototype process before relaunching with `--onboarding --large-text` to exercise accessibility1 text. These flags select fixtures, not app storage. No Today destination is added.

## Cases and results

| Case | Result / evidence |
| --- | --- |
| Welcome → Privacy | Pass: Device Hub button press changed the heading to Your words, your choice |
| Privacy → Manage earlier CircleU data | Pass: earlier-data introduction and both choices appeared |
| Earlier data → Back from Privacy origin | Pass: returned to Privacy, not Welcome |
| Privacy → Done | Pass: returned to Welcome |
| Welcome → Used CircleU before? → Back | Pass: returned to Welcome |
| Earlier data → Continue without importing | Pass: reached the static Opening fixture; no data work or automatic Today transition |
| Opening → Back to welcome | Pass: returned to Welcome |
| Welcome → Get started | Pass: reached static Opening; no real readiness success claimed |
| Privacy → header Back | Source-reviewed; not separately tapped in this pass |
| Review earlier data | Existing external Figma handoff. Not opened in this pass; no native sign-in/import flow is implemented in this specimen |
| Retry in locked/read-error fixtures | Intentionally inert, as documented; not a working storage retry |
| Privacy scrolling / bottom Done visibility | Automated scroll returned `noWindowsAvailable`; owner gesture check requested, pending |
| Larger-text Welcome scrolling / lower actions | accessibility1 layout visibly wraps and exceeds viewport; owner gesture check requested, pending |
| Compact-height phone / hardware / VoiceOver | Not run |

The successful cases used the actual running Simulator host before the scene-only visual update. After the update the iPhone host was rebuilt and launched with larger text; gesture checks remain pending. Do not turn a visible accessibility element into proof it can be reached by a physical swipe/tap.

## Owner-selected background and discussion

Owner selected **Pingu scene in the upper area, with a quiet lower area for text and buttons**. Implemented a still native sky/snow backdrop around the existing transparent waving Pingu. Its art slot stays 172pt; text/actions keep the original composition. Scenery ignores hit testing and is hidden from accessibility. No new bitmap generation, icon family, font, palette or backend work. The old plain comparison remains available via `illustratedWelcome: false`; new review exports use `brand-07-*` filenames.

Both normal and compact-width scene exports were built/rendered and visually inspected. These are 390 × 844 and 375 × 844 ImageRenderer specimens, not short-height gesture tests. Historical PNGs remain unchanged.

| Question | Rationale / recommendation; not an approved feature change |
| --- | --- |
| Why say Saved on this device? | It communicates the approved local guest plan's recovery tradeoff. People should not mistake local entries for account-synced data. The current banner can become a shorter, quieter line; retain a clear deletion/recovery explanation before meaningful input. |
| Do we need Privacy as a button? | Keep easy access to the data explanation, but a small text link is enough on Welcome. Detailed backup/export/voice information can stay in the optional panel and later Settings; no mandatory privacy slide is needed. |
| Why no Login like the old version? | Guest-first means no account is required for new local use. Existing users still need an explicit old-account recovery route. Recommend a clearer Sign in to recover earlier data label there, without implying ongoing sync or wiring live auth into the prototype. Restoring ordinary account/sync features would be a separate product decision. |
| Why a quiet lower area? | It keeps illustration away from text/control reading surfaces while adding character to the upper scene. This was the owner's chosen visual option, not approval of broader login/storage changes. |

Apple recommends brief onboarding, teaching through interaction and optional contextual help ([Onboarding](https://developer.apple.com/design/human-interface-guidelines/onboarding)). Its [Accessibility guidance](https://developer.apple.com/design/human-interface-guidelines/accessibility) supports auditing text/contrast in context. Our specific scene, copy and control hierarchy are project recommendations, not Apple requirements.

## Before Today

Complete and record the owner gesture check, then resolve the native earlier-data handoff and static readiness endpoint scope. The current prototype is useful for visual and limited navigation review; it is not a complete production onboarding/recovery implementation. Storage, backup, authentication, migration and deletion remain governed by the existing transition plan.
