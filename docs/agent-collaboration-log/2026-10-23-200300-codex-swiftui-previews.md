# Static SwiftUI previews for Draft 02

- Recorded: 2026-10-23 20:03:28 +1100; Australia/Sydney.
- Agent / role: Codex, visual prototype implementation and verification.
- Status: preview package and renders completed; Xcode Canvas verification pending.
- Base revision and branch: `2f28966`, `main`; dirty planning checkout preserved, no commit/push.
- Related record: [legacy-format and release planning](2026-10-23-194314-codex-formats-personal-release.md).

## Request and scope

The owner asked to focus on prototypes and Xcode snapshots, checking the app later, and explicitly confirmed static Figma/SwiftUI previews of Today, Journal and Practice with sample data. This authorizes the isolated preview code, not production implementation or migration.

## Work and outcome

- Added [dependency-free Swift package](../../Prototypes/CircleUVisualPrototype/README.md) with immutable sample content, shared static cards/action/tab labels, scoped named color assets, five named previews and a macOS render utility.
- Read live Figma design contexts and screenshots for nodes `11:100`, `11:104`, `11:107`; retained copy/palette and used native rounded system typography instead of Inter. No Figma edits were made.
- Exported [three screen renders, gallery and compact-width check](../design/swiftui-previews/README.md). Labels explicitly distinguish static macOS design renders from app/Simulator screenshots.
- Updated the design/documentation indexes and [implementation plan](../superpowers/plans/2026-10-23-swiftui-visual-previews.md).

## Verification

- Xcode 27.1; isolated `swift build --scratch-path /tmp/circleu-visual-preview-build --product render-previews` with command-specific Xcode toolchain, temporary module caches and approved local build access: exit 0. Initial sandbox/cache access failed before code compilation; retry passed. Rebuild after the render fix passed.
- Ran `/tmp/circleu-visual-preview-build/debug/render-previews` targeting `docs/design/swiftui-previews`: exit 0. Initial images omitted ScrollView contents; replacing that static-board wrapper with direct layout restored the missing text/cards. Regenerated gallery and compact render visually inspected; all three boards show intended sample content without clipping at tested sizes.
- Verified five PNG dimensions (three 780×1688, compact 640×1688, gallery 2532×2058), seven color JSON resources, nine local links in the two new READMEs and five Swift files without Firebase/UserDefaults/URLSession/app imports.
- `git diff --check` passed; `git diff --name-only -- Circleu Circleu.xcodeproj CircleuTests` returned no changes.
- Selected the new `Package.swift` in Xcode's Open dialog. Clicking Open and subsequent AX/screenshot/reconnection attempts timed out. Did not verify Canvas or claim the package visibly opened.
- Not run: full app, Simulator, production tests, physical-device checks, backend operations or migration. Fixed-size visual checks do not validate Dynamic Type, scrolling or interactive behavior.

## Discussion and decisions

Inter-agent exchanges: **None**. Owner confirmed Figma plus static SwiftUI previews. Existing production startup can initialize Firebase; the independent package avoids that startup. Preview assets are deliberately scoped outside the production target. Package platform declarations do not select the future app's support policy.

## Handoff

- Review the three hub screens, then add static editor states if desired; use Figma for connected flow review.
- Open the package and `PreviewGallery.swift` in Xcode, select My Mac and resume Canvas when UI access is available. See package instructions.
- Owner: Unassigned.
- Full app, legacy-data recovery and personal-account release work remain deferred and unresolved as recorded in the preceding planning documents.
