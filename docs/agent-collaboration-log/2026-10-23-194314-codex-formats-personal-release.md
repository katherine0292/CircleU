# Map legacy formats and research personal-account distribution

- Recorded: 2026-10-23 19:43:14 +11:00; Australia/Sydney; verification completed later in the same turn.
- Agent / role: Codex, source research and release planning.
- Status: research/decision documents completed; release route proposed, implementation not started.
- Base revision and branch: `2f28966`, `main`; earlier documentation changes preserved, no commit/push.
- Related record: [verified TestFlight inventory](2026-10-23-192955-codex-testflight-build-inventory.md).

## Request and scope

The owner requested checking the legacy data format and planning release under their own Apple account without losing existing users' data. They confirmed they only have UTS team access, without a separate paid individual Developer Program membership. The returned upload Mac remains unavailable. Work consisted of repository/history reads, official Apple documentation, read-only App Store Distribution/History inspection and planning documents.

## Findings and deliverables

- Added the [legacy format catalog](../engineering/legacy-data-format.md): JSON-in-UserDefaults collections, scalar settings, local authentication material, Firestore paths/mapping, timestamps, IDs and relationships.
- Historical snapshot `1087b2c` uses unsuffixed device keys. Later upload-day commit `04b1b16` adds per-account scoping. This makes an automatic “base key means guest” assumption unsafe. Timestamps are not proof of the uploaded checkout.
- Allowlisted plist metadata before `b7c0bb5` identifies Dev; that commit removes the tracked plist for per-developer configuration. No credentials/API keys were printed or saved. The shipped project is still not proven.
- Source risks: AI load can remove undecodable stored data; Firestore restore can silently omit malformed documents; practice mutations cap history; practice image bytes are omitted from the cloud mapper; readable text export is not a portable round-trip archive. Existing practice models have no journal link.
- Added the [personal-account release research](../product/personal-account-release-plan.md). Apple's standard transfer requires a released App Store version; live Circleu History shows only Prepare for Submission. Recommend a UTS-authorized compatible recovery bridge plus explicit portable import into a separate personal app, while retaining a conditional transfer alternative. No final owner route selection is implied.
- Updated indexes, inventory, transition plan and prototype limitations. Recorded additional UX work for unresolved data ownership, portable archive errors/import and missing attachments. No Figma canvas changes were made; its existing samples do not implement the new package route.

## Verification

- Live read: App Store Distribution version 1.0 and History; only the initial Prepare for Submission event observed. No submission, build association, transfer, invitation, cleanup or settings save occurred.
- Read official Apple transfer criteria/overview/initiation, enrollment and platform sandbox documentation; sources linked in the release research. No enrollment, payment or agreement was initiated.
- Compared candidate and HEAD model/service diffs. Static source checks confirmed identical practice/AI model Git objects at the two revisions, local optional practice images, cloud omission of image bytes and the 12-session cap.
- Inline Python: seven changed/new Markdown files, 84 relative links, valid 125-state/21-section JSON manifest and source cross-checks passed. One root README trailing-space line matches the unchanged baseline. Final log links/whitespace checked separately. `git diff --check` passed.
- No app build, decoder execution, real-data export/import, backend query/deletion or device upgrade test was performed. The source catalog is not a certified shipped schema, and aggregate TestFlight installs are not unique users or retained copies.

## Discussion and decisions

Inter-agent exchanges: **None**. Owner confirmed no personal paid membership. The agent recommended the bridge/new-app route because current transfer eligibility is unmet and a new app cannot read the old sandbox. This recommendation, archive encryption design and distribution arrangements still need decisions before coding; no approval was inferred from the research request.

## Handoff

- Decide the release route and obtain authorized UTS cooperation for legacy recovery; no messages have been sent.
- Establish real source/provenance and actual tester devices; preserve old installations and both Firebase projects. Unknown/mixed-account caches need a protected unresolved state.
- Refine the missing prototype states and archive security/format, then produce bounded implementation tasks once approved. Keep iOS 17/iPad recovery usable if the new MVP cannot run on those devices.
- Owner: Unassigned. Local-only data inside an inaccessible expired install has no verified recovery path without a bridge/authorized alternative. Do not promise full recovery or use this uncertainty to justify deleting anything.
