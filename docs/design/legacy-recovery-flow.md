# Draft 02: previous-data recovery

Updated 23 October 2026. Prototype work authorized by the owner before coding. [Live inventory](../engineering/legacy-data-inventory.md) found accounts and circle records in Dev and now verifies expired TestFlight **1.0 (1)** with iOS 17/iPhone+iPad support. The shipped Firebase mapping remains unknown; the upload Mac was returned and no archive is currently available. These screens describe proposed recovery behavior, not existing implementation or actual accounts.

- [Play the previous-data review guide](https://www.figma.com/proto/RVLtfmIVcO8gNk5fam0Vjd?node-id=65-1436&starting-point-node-id=65%3A1436)
- [Start the previous-data journey](https://www.figma.com/proto/RVLtfmIVcO8gNk5fam0Vjd?node-id=65-663&starting-point-node-id=65%3A663)
- Entry links also appear in Privacy settings, the privacy introduction and the existing recovery guide.

## Routes represented

| Route | Behavior shown |
| --- | --- |
| Earlier guest data on this phone | Preview one reflection and linked message → prepare a local copy → verify completion → open the matching saved entry. Cancel keeps originals |
| Earlier account data on this phone | Verify original account before importing; otherwise continue in a separate guest workspace without clearing the archive |
| Previous account sign-in | Email/password or Google method → read-only backup check. Provider handoff and fields are simulated; the inspected source's authentication adapter currently implements email/password |
| Sign-in/check failure | Retry or use local content. “Couldn’t check” remains separate from a completed check that found no backup |
| Earlier cloud backup | Preview invented categories and a conflicting reflection → keep this device's accepted reflection or export both versions for review → explicitly import only the cloud-only practice message |
| Import failure/interruption | Preserve sources, retry selection, check the completion record before retrying, and avoid duplicating an already imported item |
| Export | Preview scope and readable-copy warning → simulated share-sheet handoff, cancellation or retry. No success/delivery claim just because the share sheet opened |
| Old cloud account | Separate account-management route → deletion scope warning → reauthentication/final confirmation → pending or verified completion. Local entries and exported copies are distinct |
| Expired TestFlight/older device | Preserve old installation; compatible recovery build or verified management route must be established. No download/contact is invented |

Circles and rewards remain outside the new application navigation. Existing shared content is a legacy account-management concern: it must be reviewed before deleting ownership or membership, and other people's content is not a private journal import.

## Inventory-driven decisions

- Dev has 14 Auth accounts and two enabled providers; do not assume there were no users because Prod has setup screens.
- Current Release selects Prod; CLI/non-Release selects Dev. Do not let the app automatically search or merge unrelated projects/accounts to work around this uncertainty. Resolve the shipped configuration before implementation.
- Preserve local accepted edits when old backup history lacks reliable deletion/conflict metadata. This representative branch keeps the local reflection and permits exporting both versions; full per-record selection/replacement UI is still to be designed if required.
- Separate cloud-only import consent from cloud deletion consent. Recovering a copy does not erase the source, and retrying a migration must not resurrect a later local deletion.
- Support/password-reset delivery, Google OAuth integration, older-device distribution and exact shared-circle deletion handling require implementation decisions backed by the inventory. The prototype labels these dependencies rather than promising working services.
- The expired-build/older-device route already represents the newly verified release condition; no new screen or claimed working download is needed. Preserve existing installations, establish an authorized compatible replacement or management route under the education team, and verify actual tester devices before narrowing recovery support.

## Review exercises

New planning gaps after historical-format/release research: an unsuffixed cache can include old signed-in or mixed-account content, so the device-data sample applies only once ownership is established. Add an unresolved-ownership branch before implementation. The recommended separate-app route also needs portable archive creation/import, locked/invalid archives, missing attachments and explicit preservation of unsupported categories. The current readable export sample is not that archive. These are documented gaps, not new canvas states; see [format evidence](../engineering/legacy-data-format.md) and [release options](../product/personal-account-release-plan.md).

1. Start from Privacy settings → Previous CircleU data. Choose device data, cancel preparation, then retry and open the saved linked entry.
2. From the new review guide, compare sign-in failure, service unavailable and no-backup states. Explain why none should erase local data.
3. Follow cloud import. Keep the current reflection, explicitly choose the cloud-only message and reopen its saved wording. Explain why the old cloud copy still exists.
4. Review interrupted import and the already-saved result. Compare with an import failure; a receipt/status check must determine which outcome is real.
5. Follow old-account deletion, cancel before confirmation, then try the pending and completed examples. Confirm that local data and external copies are described separately.
6. Read older-device and sign-in help. Identify the unresolved distribution/support work before offering the migration to testers.

## Verification and limitations

Thirty screen/state frames were added in five sections, bringing Draft 02 to 125. The live structural pass covered 1,712 assertions for destinations, reachability, new-screen typography and bounds. A first audit incorrectly classified seven valid component `CHANGE_TO` transitions as screen links; a targeted recheck distinguished them and validated all 407 node-target actions (400 screen navigations and seven component transitions), with no invalid destinations. All 125 states are reachable from declared starting points. There are ten sample timers, including four new three-second transitions; these are demonstrations, not latency or reliability claims.

The new screens contain 120 frames, 135 component instances and 355 editable text nodes, with no image-filled nodes. They reuse the existing cards/buttons, colors and styles. Inter matches Draft 02's documented prototype font substitution; native SF Rounded remains a later design task. No missing fonts or new text/screen-bound errors were found. All five new sections were visually reviewed; long content scrolls above fixed actions.

No real authentication, data retrieval/import, migration receipt, export, account deletion, process-death recovery or automatic state persistence occurs. Error alternatives are review-guide scenarios. Sign-in and reauthentication use descriptive placeholders, not implemented native provider dialogs. The legacy category chooser, full shared-content ownership resolution and support delivery remain specified dependencies rather than complete interactive screens. No participant study or physical-device testing was conducted.
