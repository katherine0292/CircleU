# App icon: the brand mark on ice

- Recorded: 2026-11-04 18:15 +11:00; Australia/Sydney.
- Agent / role: Claude Code, implementer.
- Status: on `codex/app-icon-ice`; suite and Codex results in the PR.
- Related: [branding guideline](../design/branding-guideline.md) section 3 (the icon is an application of the agreed mark), [app-icon note](../design/brand-demo/app-icon/README.md).

## Request and work

Owner chose the ice candidate on 4 November ("let's go with the ice"). `AppIcon.appiconset` now carries `AppIconIce.png` (the brand mark on #F5FAFF, 1024 px); the June 2026 TestFlight icon `PinguLight.png` moved unchanged to `docs/design/brand-demo/app-icon/AppIcon-legacy-2026-06.png`, next to the rejected blue candidate. No code change; the tinted-appearance slot stays empty as before.

## Verification

Debug build for the iPhone 18 Pro Simulator succeeded and the bundle's `AppIcon60x60@2x.png` shows the ice mark. `GuestPinguArtTests` and `GuestSceneArtTests` pass (4). Full suites and the Codex pass are recorded in the PR. The icon on a physical phone and the App Store/TestFlight icon are not changed by this; a release build would pick it up when one is made.
