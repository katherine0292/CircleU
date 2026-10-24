# Legacy release and Firebase inventory

Observed 23 October 2026, Australia/Sydney. Read-only repository, Firebase Console and signed-in App Store Connect inspection; no service, account, rule, record, billing or release setting was changed. The uploaded TestFlight build is now identified. Its bundled Firebase configuration and data schema remain unverified because the original archive is unavailable.

## Findings and consequences

| Area | Evidence observed | Consequence |
| --- | --- | --- |
| Previous TestFlight release | App `Circleu`, Apple app ID `6779025407`; one version/build visible in iOS Builds and Build Uploads: **1.0 (1)**, **Expired**; binary state **Validated**, upload processing **Complete** | A real uploaded build is verified; it is no longer an available recovery build. No exact expiration timestamp was displayed |
| Upload date | Build Metadata: **Jun 11, 2026 at 11:02 AM**; Build Uploads date created: **Jun 11, 2026 11:01 AM** (console display) | Preserve these distinct labels/times; console timezone was not independently established |
| Build usage | Builds table displays **5 invites, 6 installs, 143 sessions**; crashes and feedback display a dash | Evidence of use, not six unique people or currently retained installations. Dashes are not independently verified zero crashes/feedback; the session measurement window was not established |
| Apple team and role | Signed-in account menu shows **University of Technology Sydney (Edu)**; the user's General profile lists **Developer, Marketing**. Uploaded entitlement and current source use team identifier `3VJ6XS7472` | Account Holder/Admin is not listed for this user. App access is verified, not personal ownership or independent transfer authority. Confirm the team's continuing distribution arrangement before a bridge release |
| Uploaded compatibility | Minimum iOS **17.0**, device family **iPhone, iPad**, architecture **arm64**. Metadata also lists minimum macOS **14.0** and visionOS **1.0** | Preserve legacy compatibility while planning recovery. Metadata does not prove actual Mac/Vision installations or certify their support; tester device/OS distribution remains unknown |
| Uploaded identity | Bundle ID **edu.uts.tuannm3812.Circleu**; short version **1.0**, build **1**, SDK/platform build identifier **23F73** | Bundle matches current source/configuration. This alone does not establish identical source, Firebase project, schema or runtime behavior |
| Historical test instructions | Test Information describes email sign-in, voice/typed reflection, saved-entry editing, Tips practice and circle creation/sharing | Circles were part of the intended test journey, not merely unused source. Instructions alone do not prove each feature passed or was used |
| Current source version | `Circleu.xcodeproj/project.pbxproj` declares marketing version `1.0.0`, build `1` | This is not evidence of the uploaded build |
| Current Release Firebase selection | Xcode build phase copies `Config/Firebase/GoogleService-Info-Prod.plist` into the app as `GoogleService-Info.plist`; its project is `circleu-prod` | Inspect the actual shipped archive/configuration before attributing TestFlight traffic to a project |
| Current non-Release selection | Build phase copies the Dev plist; its project is `circleu-45651` | Development and Release target different backends |
| Firebase CLI default | `.firebaserc` points to `circleu-45651` | A default CLI deployment would target Dev. Do not deploy rules while assuming it is Prod |
| Bundle registration | Both local plist metadata use `edu.uts.tuannm3812.Circleu`; Prod overview shows that registered iOS app | Bundle match is established for current configuration, not historical binaries |
| `CircleU-Prod` / `circleu-prod` | Console accessible; Spark plan. Authentication shows **Get started**; Firestore shows **Create database** | No provisioned Authentication/Firestore interface was observed here. Do not turn this into a guarantee that no historical/cloud data exists anywhere |
| `CircleU-Dev` / `circleu-45651` | Console accessible; Spark plan; default Firestore database exists, location `nam5` | This project has backend state despite its Dev label; preserve it |
| Dev Authentication | Users table reports **1–14 of 14**; Email/Password and Google providers show **Enabled** | Preserve both possible previous sign-in methods. This does not establish that the shipped iOS app exposed Google sign-in |
| Dev Firestore | Root collections `users` and `circles` visible; six circle document rows were visible in the opened collection view | Cloud/social records exist. Visible rows are not a verified full inventory; no judgment that data is disposable |
| Dev rule history | Rules tab shows selected/starred version **Jun 11, 2026 • 10:32 AM** (console display). Visible prefix gates user/profile/journal/AI-session access through UID ownership | Full deployed-rule equivalence and security tests remain unverified. Do not infer that all local rules are deployed or safe |
| Default local Xcode archive directory | `~/Library/Developer/Xcode/Archives` does not exist on this machine | No archive could be inspected in that default location; archives elsewhere or on another machine remain possible |

Only allowlisted plist metadata was printed; credentials and API keys were not recorded. A remembered Firestore document was displayed by the console during project switching; its contents, image data, account identifiers and user names are intentionally omitted from this record. No journal entries were opened or exported. Auth counts are not a user identity list or evidence of active usage.

## Access and limits

Firebase was read in the owner's existing signed-in browser session. This verifies console access, not ownership/IAM roles across every project. The Firebase plugin was subsequently confirmed installed and enabled, but no Firebase tools were exposed in this session; connector account access remains unverified. Browser access supplied the observations above. Native Chrome inspection timed out, so inspection continued in the in-app browser.

After the owner signed in, App Store Connect exposed the Circleu build list, upload history, Test Information and Build Metadata. Only aggregate usage was recorded; no individual tester identities were collected. The owner reported uploading from another Mac that has since been returned to the Apple Foundation Program. No original archive/IPA is currently available; do not assume the machine can be recovered or that its data still exists. App Store metadata does not expose the bundled Firebase project. Do not infer it from current repo settings, matching dates, test instructions or the Dev/Prod names.

Relevant console destinations:

- [App Store Connect apps](https://appstoreconnect.apple.com/apps)
- [Verified TestFlight build metadata](https://appstoreconnect.apple.com/teams/d2340831-563c-4e2e-8a97-e07705af5a57/apps/6779025407/testflight/ios/48376da4-9467-4ce3-a3a1-8994c026c07c/metadata)
- [Production overview](https://console.firebase.google.com/project/circleu-prod/overview), [Authentication](https://console.firebase.google.com/project/circleu-prod/authentication), [Firestore](https://console.firebase.google.com/project/circleu-prod/firestore)
- [Development Authentication](https://console.firebase.google.com/project/circleu-45651/authentication/users), [sign-in providers](https://console.firebase.google.com/project/circleu-45651/authentication/providers), [Firestore rules](https://console.firebase.google.com/project/circleu-45651/firestore/databases/-default-/security/rules)

## Next evidence to collect

Follow-up research: [legacy formats](legacy-data-format.md) now maps current and upload-day source. Historical tracked Firebase metadata points to Dev, but that file was removed for per-developer configuration before the candidate snapshot; the shipped plist is still unknown. Unsuffixed storage is not reliably guest-owned. No live record-content inspection was used for this catalog.

App Store Distribution/History were also read: only version 1.0 **Prepare for Submission** was observed, with its initial event on 11 June 2026 at 10:56 AM (console display). No released version was present. The owner confirms no personal paid Developer Program membership. The [personal-account release research](../product/personal-account-release-plan.md) records Apple's released-version requirement and the proposed recovery/new-app alternatives. No transfer is currently established as eligible.

1. Coordinate continuing distribution and any ownership/transfer decision with the education team's authorized administrator/account holder; the current user has Developer and Marketing roles. Establish tester device/OS coverage and whether existing installations still hold recoverable local data, without collecting journal content. No outreach has been authorized or sent.
2. If an existing backup/export of the original archive becomes available, verify its bundled Firebase project and schema. The original Mac was returned; this evidence is currently unavailable. Preserve both projects and keep migration blocked on reliable schema/source evidence rather than guessing. Any later extraction from an existing device must be separately planned to preserve its only copy.
3. Inventory per-category counts, oldest/newest timestamps and ownership relationships using authorized metadata-only queries. `users` collection visibility does not prove which private subcollections exist or how complete backups are.
4. Read/reconcile full deployed rules and test owner/member/stranger access in an isolated environment. The local repository review remains a risk report, not proof of deployed behavior.
5. Confirm project administration, backup/retention settings, earlier cloud AI use and a lasting account recovery/deletion contact or route. Do not initialize services or create test accounts merely to complete this inventory.

## Impact on recovery planning

Use the [transition plan](../superpowers/plans/2026-10-23-local-first-transition.md) with these evidence gates. Cloud recovery is conditional on a verified account and the correct historical service. A failed/unavailable check must not appear as an empty backup; import must not enable new sync, overwrite accepted edits, or authorize cloud deletion.

The [new Draft 02 recovery flow](../design/legacy-recovery-flow.md) uses invented examples. Backend account/record counts above were not copied into the prototype. The older-device and account-help screens explicitly leave recovery-build/contact availability unresolved rather than link to an invented service.

The verified expiration makes the older-device/expired-build branch relevant now. A future compatible replacement or verified management route must exist before telling testers to recover data. Do not uninstall an old copy to test recovery. Keep iOS 17/iPad compatibility for the proposed bridge until device evidence supports a narrower route. Treat app transfer/team changes as a separate distribution decision; Git repository ownership does not transfer this Apple app.
