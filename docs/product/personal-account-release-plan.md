# Release under a personal Apple account: research and decision plan

23 October 2026. Requested by the owner; **proposed, not an approved implementation or release**. The owner confirmed they only have UTS team access and have not enrolled separately in the paid Apple Developer Program. No enrollment, payment, agreement, transfer, app creation, signing change, upload or outreach was performed.

## Recommendation and constraints

Plan a **UTS-authorized recovery update for the existing app, followed by a separate app under the owner's individual account with explicit content import**. Keep a transfer route open if eligibility is later established. The owner has not selected a final route; this document records the evidence, recommendation and work needed for either choice.

The [verified inventory](../engineering/legacy-data-inventory.md) identifies expired TestFlight 1.0 (1), six reported installs, iOS 17/iPhone+iPad, bundle `edu.uts.tuannm3812.Circleu`, team `3VJ6XS7472`. The owner's roles are Developer and Marketing. App Store Distribution and History show only version 1.0, Prepare for Submission, with its initial history entry on 11 June 2026. No released App Store version was observed.

Apple requires a previously released App Store version for a standard app transfer. CircleU does not currently meet that criterion on the available evidence. A later legitimate App Store release or a route confirmed by Apple Support could change the assessment; do not assume an exception or publish an unready app merely to enable transfer. [Apple transfer criteria](https://developer.apple.com/help/app-store-connect/transfer-an-app/app-transfer-criteria)

## Routes and trade-offs

| Route | Benefit | Constraint / decision |
| --- | --- | --- |
| **Separate personal app + UTS recovery bridge — recommended planning route** | Independent future distribution; keeps recovery work distinct from the new guest MVP | New bundle/app identity cannot directly read the old app's sandbox. Needs UTS cooperation for local-only data, or a verified authorized cloud copy. Users explicitly export/import |
| **Official transfer of the existing app, once eligible** | Retains bundle ID and the update relationship | Not currently eligible; requires both Account Holders and team cooperation. Test the actual device update and reauthentication before claiming preserved data |
| **Personal app with cloud recovery only — limited contingency** | Could recover records already stored in the verified legacy project | Cannot recover unsynced local data or practice-image bytes omitted from cloud payloads. Does not meet a blanket “no data loss” promise |

Apple describes transfers as retaining the bundle ID and user updates. Account Holders initiate/accept them. Its preparation guidance includes ending TestFlight testing and removing associated build/tester information, plus Xcode Cloud cleanup; any future execution must preserve recovery access first. Team/keychain changes can require users to sign in again. None of that cleanup is authorized now. [Transfer overview](https://developer.apple.com/help/app-store-connect/transfer-an-app/overview-of-app-transfer), [initiation roles](https://developer.apple.com/help/app-store-connect/transfer-an-app/initiate-an-app-transfer/)

A new app is sandboxed separately. Renaming CircleU, reusing its visual design or changing the Xcode signing team does not give a new app access to the old container. Existing app identity must not be deleted as a workaround. [Apple sandbox boundaries](https://support.apple.com/guide/security/security-of-runtime-process-sec15bfe098e/web)

## Proposed sequence and gates

### 1. Establish the personal distribution account and UTS cooperation

- Enroll the intended Apple Account in the Apple Developer Program as an individual if that is the chosen ownership model. Apple requires identity verification and an applicable membership payment; individual enrollment uses the person's legal name as seller. Review the current local price and terms in Apple's enrollment flow. The user completes payment/agreements. Do not leave the UTS team during recovery planning. [Enrollment](https://developer.apple.com/help/account/membership/program-enrollment/)
- Ask the UTS Account Holder/program contact whether they authorize a compatible recovery update, continued access for existing testers and any future transfer/support inquiry. Clarify permission to use project code/design/assets and the distribution arrangement without treating Git repository access as Apple ownership. No message has been sent.
- Obtain the personal Team ID only after enrollment is active. Choose a new bundle ID only if the separate-app route is selected; reserve/create nothing during research.
- Keep legacy Firebase administration separate. Apple app ownership does not move Firebase projects or user IDs. Confirm authorized recovery access before configuring any new client; preserve the historical project instead of bulk-copying users to a new one.

**Gate:** a documented distribution route, authorized UTS involvement where required, and access sufficient to maintain existing users' recovery.

### 2. Establish recoverable data before touching installed state

- Use the [source format catalog](../engineering/legacy-data-format.md) to identify both device-wide and Firebase-UID-scoped formats. The upload Mac was returned; the exact binary schema remains unproven. Historical Dev configuration is a lead, not a license to merge Dev and Prod.
- With future authorized tester participation, establish whether the old installation remains, whether it was guest/signed-in/shared, and whether an export or cloud copy exists. Record counts and capability metadata, not private content in project logs. Do not ask testers to delete/reinstall or sign out to “start clean.”
- Preserve raw local bytes before old-store initialization. An AI-session decode failure can currently remove its key; existing restore can skip malformed documents. Unknown ownership, malformed data and unsupported versions must have recoverable states.
- Separate local-only, cloud-only and mixed copies. Current source limits practice history to 12 sessions and omits practice images from cloud writes; no plan can recreate data already lost without another copy.

**Gate:** validated source/provenance and a category/count report that distinguishes preserved, importable, unsupported and unavailable data.

### 3. Build and verify a recovery bridge later, under the existing identity

This is implementation work requiring a later approved specification. Retain the current bundle/team and iOS 17/iPad coverage for the bridge, with a higher build number selected after rechecking uploads. First validate a same-app update on a preserved test installation; never assume installation behavior from code signing alone.

The bridge should read old keys without invoking destructive loaders, keep scopes isolated, offer content preview only after ownership is established, and create a portable content archive on explicit request. It must not reactivate cloud sync, upload new private content or delete old copies. Expired TestFlight means the old UI cannot be relied on; a compatible distributed bridge or an authorized alternative must exist before instructions promise recovery.

An unsuffixed historical cache may contain signed-in or mixed-account material. Its presence alone must not unlock a “guest import.” Keep it protected with an unresolved-ownership path and allow starting a separate empty workspace without clearing it. The proposed Figma device-recovery route needs this additional scenario before implementation.

### 4. Define a portable archive and import contract

Proposed requirements, not an implemented file format:

- Versioned manifest with export ID, source app/build if known, source format, export time, category counts and checksums; record unknown provenance explicitly.
- Stable record UUIDs, original and accepted text, dates, source links that actually exist, all selected practice turns/options and available image bytes. Imported practice remains standalone where the old model provides no journal link. Retain unsupported legacy categories in a protected recovery archive/export instead of silently deleting them or adding rewards/circles to the MVP.
- Exclude passwords, password hashes/salts, Firebase tokens, session markers and API configuration. A manifest/checksum is not proof of account ownership. Never use an imported UID to authorize cloud access.
- Design encryption and transfer UX before production export: prefer an authenticated encrypted package using established platform crypto, with the user retaining the unlock secret separately; no plaintext temporary archive or server upload by default. Exact packaging/key derivation remains a design decision, not a claim that the current text export is encrypted or restorable.
- Import validates version, sizes, types, path traversal if applicable, checksums/authentication, IDs and relationships in staging. Reject unsupported/encrypted-with-wrong-key input with a recoverable error. Show record/category/attachment counts and conflicts before explicit commit.
- Commit atomically with a durable receipt keyed by source scope/export/record identity. Reimport should not duplicate records or resurrect later deletions. Preserve accepted local edits and retain both conflicting versions for review where necessary. Do not run old store truncation during import.
- Verify imported counts/attachments and let the user reopen examples before declaring completion. Retain sources until a separately explained user-controlled cleanup; local import does not delete the old cloud account or other copies.

Current journal text export is a readable copy, not this archive. Draft 02 currently shows readable export and simulated recovery; machine-readable archive creation/import, locked/bad archive, unknown owner, missing attachments and comparison outcomes are planning gaps for a later prototype pass.

### 5. Release and keep legacy management available

For the separate-app route, the personal app has its own app record and bundle. Its guest core uses local storage, with user-invoked file import. If a direct legacy-cloud recovery option is selected, it must authenticate against the verified original project, expose only the verified account's records and remain separate from automatic backup. Firebase client/provider registration, especially Google sign-in, needs a separate configuration review; do not assume a new bundle inherits old OAuth setup.

Validate old installation → bridge → archive → personal app, interrupted/wrong-file/repeated imports, local accepted edits, account isolation, attachment handling and cloud-only recovery. Include iOS 17/iPad bridge users and the proposed new device matrix. Keep a truthful support/export/deletion path for people who have not migrated. No arbitrary retirement date or success claim based solely on six reported installs.

An iOS 17-only phone or iPad may not run the proposed iPhone/iOS 26 MVP. Export alone does not give that user an equivalent app. Maintain usable legacy viewing/export/management, or resolve broader new-app compatibility, before retiring their path. Do not assume they will buy a supported phone. Import on another compatible device is an explicit user choice and must not remove the original copy.

For a later transfer route, additionally validate pre-transfer → post-transfer updates and loss of auth tokens without erasing local data. Complete Apple's transfer prerequisites only after coordinated recovery and a separately approved operational checklist.

## If UTS cannot provide a recovery update

Keep existing apps and Firebase data intact. Explore an authorized replacement-build/support route with UTS/Apple and a verified cloud/export path for each user. Local-only data in an inaccessible expired app has **no verified recovery path yet**. The personal MVP can be planned independently, but must not claim all old data is recoverable. Neither a new Apple membership nor a matching email/bundle label bypasses this constraint.

## Ready-to-code decision

Before implementation, select the release route, confirm UTS cooperation, resolve ownership handling for unsuffixed data, validate the historical schema and choose the archive security/format. Then refine the missing prototype states and write bounded implementation tasks. This research does not authorize app creation, enrollment purchases, publishing, contacting testers or deleting records.
