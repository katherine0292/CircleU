# CircleU project inventory and improvement review

Reviewed 23 October 2026 against local commit `2f28966`.

Follow-up: the owner approved planning and research. Subsequent checks confirm Xcode first-launch readiness, available simulators and GitHub ownership; local production/signing configuration files are now present. See the [discovery plan](superpowers/plans/2026-10-23-project-discovery.md) for the updated environment evidence. The original observations below remain a record of the initial review.

This is an evidence inventory and proposed priority order, not an approved implementation specification. The review covers repository documentation, application wiring, representative feature implementations, design primitives, stored screenshots, persistence, backend rules, tests, and release configuration. No application code was changed.

## Assessment

CircleU already has a coherent product loop and a useful feature-based SwiftUI structure. Preserve those foundations. The first improvement should be a trustworthy project reference that reconciles implemented behavior, intended behavior, design decisions, and verification status. Documentation drift, overlapping UI systems, and data lifecycle gaps currently matter more than reorganizing every folder.

The documented direction is an iPhone reflection companion: record or type a moment, receive structured feedback, save it, practice a small action, and optionally share selected content. The intended audience, current release goal, and boundaries between private circles and public discovery still need an explicit product decision.

## Feature inventory

“Present” below means found in source and application wiring. It does not mean verified on a running device or deployed backend.

| Area | Present in the repository | Qualification / next evidence needed |
| --- | --- | --- |
| Onboarding and identity | Name, sign-up, sign-in, skip path, Firebase session and local account store | Define guest-to-account migration; review dual local/Firebase credentials |
| Home | Daily prompt, record entry point, latest reflection, progress and tip routing | Verify first-run, empty, and restored-account states |
| Recording | Microphone input, Apple Speech transcription, typed fallback, transcript quality checks | Device permissions, interruptions, offline behavior and speech-processing location require validation |
| Reflection | Emotion, title, summary, insight, quote, expression moment, confidence, suggested action, regeneration and save | Validate provider-specific output and fallback presentation |
| Journal | Persistence, search, detail, editable title/emotion/notes/tags, export, related actions and selected sharing | Individual deletion is local; backup restore can reintroduce deleted entries |
| Suggested actions | Quest state, completion, skipping, restarting and source-entry links | Establish one product vocabulary for “tips,” “quests,” and “practice” |
| Communication practice | Scene/tone/context setup, speech input, suggested wording, pasted replies, attachments, session history | `CommunicationCoachEngine` is deterministic local logic; image presence is passed to coaching, not image interpretation |
| Circles | Discovery, creation, membership, posts, replies, likes, favorites and selected reflection sharing | Live Firestore service is wired; deployed rules and multi-user behavior were not checked |
| Profile and progress | Profile editing, points/activity, progress, policy/support screens and deletion action | Validate account switching, deletion failures and privacy copy |
| QA and AI history | Seed/reset/export tools, upload/restore status and AI session inspection | QA tools are behind `DEBUG`; TestFlight instructions currently assume access to them |
| Private backup | User-scoped Firestore uploads and merge-only restore for profile, journal, quests, practice, rewards and AI history | This is not a complete two-way sync system with deletion propagation |
| Apple Intelligence | Conditional FoundationModels implementation, runtime gated at iOS 26 | Requires compatible SDK and an eligible, available model; not device-tested here |
| Cloud AI | Gemini request adapter, consent/enabled checks and fallback | No feature UI references the consent/enabled properties; provider success is unverified |
| Analytics | Sanitized events, tracker boundary and OSLog logging | FirebaseAnalytics product is not linked in the project; remote logging is conditionally compiled |
| CloudKit | Schema metadata, mapping tests and documentation | Reference groundwork, not the active storage backend |

Feature evidence starts with [app composition](../Circleu/App/ContentView.swift), [navigation and coordination](../Circleu/App/RootView.swift), and [existing product overview](product/overview.md).

## Design inventory

Observed in source and the stored Home/Tips screenshots:

- Penguin mascot, friendly rounded typography, blue primary actions, blue/lilac aurora backgrounds, translucent cards, pill controls and soft shadows.
- Large reflection entry point on Home; conversational cards and an amber coaching panel in Tips.
- Repeated motion effects: press scaling, entrance animations, mascot movement and glass sheen.
- Existing screenshots are reference material, not proof of the current runtime or approved design.

Two overlapping implementations exist:

| Source | Contents | Issue |
| --- | --- | --- |
| [PinguDesign.swift](../Circleu/Design/PinguDesign.swift) | Asset colors, `PinguFont`, layout constants, aurora and glass modifier | Mixes tokens and views despite the documented tokens-only rule |
| [PinguGlassKit.swift](../Circleu/Design/PinguGlassKit.swift) | Separate `Pingu` palette, glass variants, buttons, cards, navigation, mascot and animation | Duplicates foundations and combines many reusable components in one file |
| [Components](../Circleu/Components) | Shared controls, cards, navigation and avatars | Some older primitives coexist with the current ones; check references before retiring anything |
| [Screenshots](product/snapshots/README.md) | Home, reflection, journal, tips, circle and framed listing assets | Need capture date, commit, device, state and design approval status |

No authoritative Figma URL was found in the reviewed source/docs. An archived Tips spec references a prototype under another user's Downloads directory. Recover that design source or explicitly adopt the app as the baseline before a visual refactor.

The design guideline should define semantic colors, text styles, spacing/radius scales, button hierarchy, component states, navigation, mascot usage, tone of voice and accessibility behavior. Current fixed font sizes and repeated animations deserve a Dynamic Type / Reduce Motion review; contrast and screen-reader usability have not been measured. Apple's [Dynamic Type guidance](https://developer.apple.com/videos/play/wwdc2024/10074/) provides the verification baseline for text scaling.

## Existing structure and ownership

The documented flow is `View → ViewModel → Store / Engine / Service → Model`. Feature screens and view models already live together, while shared models, stores, engines, services, components and design files have separate homes. Keep that arrangement for now.

Focused improvements to consider after establishing behavior tests:

- Move backup scheduling and restore coordination out of `RootView` into an app-level coordinator. Navigation should not own the data lifecycle.
- Consolidate visual tokens, then organize shared UI by purpose inside the existing Components folder. Move feature-only pieces into their feature folder.
- Split the 904-line Firestore sync file into payload mapping, transport, backup/restore and deletion responsibilities.
- Split large Circle/Profile screens into cohesive local subviews; line count alone is not a reason to change behavior or create modules.
- Resolve naming overlaps: CircleU/Circleu/Pingu, tips/quests/practice, and old versus current tab types.
- Keep CloudKit clearly marked as reference-only unless there is a concrete product requirement for a second backend.

The repository includes team standards and a Git workflow, but no applicable `AGENTS.md` was found. A short root guide could link canonical docs, build/test commands, ownership boundaries and rules for updating documentation. It should avoid duplicating the handbook.

## Findings that should drive priorities

### 1. Circle permissions do not support the private-space promise

[firestore.rules](../firestore.rules) permits all signed-in users to read circle documents and posts. Non-owner update conditions protect only a handful of fields; they do not constrain membership, likes, favorites or replies to changes belonging to the caller. For example, keeping the protected metadata unchanged leaves the membership array unrestricted by those conditions.

These are source findings, not a claim about deployed rules. First decide whether circles are public communities, invitation-only groups, or both. Then enforce the chosen access model and test stranger/member/owner cases in the Firestore emulator. Firebase documents [field-change restrictions](https://firebase.google.com/docs/firestore/security/rules-fields), which should be combined with checks on the caller's permitted changes. Also verify the member lookup path interpolation during rules compilation.

### 2. Account deletion can report success while backup data remains

`purgePrivateBackup` in [FirebaseFirestoreSyncService.swift](../Circleu/Services/FirebaseFirestoreSyncService.swift) suppresses collection-read and document-delete errors with `try?`. [BackendSessionStore.swift](../Circleu/Stores/BackendSessionStore.swift) also continues after a purge failure and deletes the authentication account. This can leave backup records while the UI claims the account and data were deleted. The public privacy page promises immediate permanent deletion.

Define observable, retryable deletion completion, including shared contributions and local account records. Add failure-path tests before changing the flow. The current happy-path deletion test cannot establish failure recovery.

### 3. A deleted journal entry can return after restore

Journal deletion removes the local entry. Upload uses merge writes for entries still present, without deleting missing remote entries. Restore reads remote entries and merges them back. Therefore an entry uploaded before local deletion can return on a later restore. Document the current backup behavior and specify deletion propagation/conflict rules before presenting it as full cross-device sync.

### 4. A fresh checkout does not have a consistent build contract

- README requests Xcode 15+, CI selects Xcode 16.0, while the project uses newer concurrency settings and conditional FoundationModels code. Establish one supported toolchain from a verified build.
- README advertises Swift 6.0; build settings use Swift language mode 5.0. Compiler version and language mode should be documented separately.
- README directs Firebase configuration to `Circleu/App/`, but the build script copies environment-specific plists from `Config/Firebase/`.
- The copy phase lists both Dev and Prod plists as inputs. Prod is ignored and absent from the tracked checkout; copying is unconditional for the selected configuration.
- Signing depends on an ignored local xcconfig; CI does not provision it. Document or generate the simulator-safe configuration.
- CI, README and Fastlane use different simulator selections. Fastlane lacks a tracked Gemfile/lockfile for reproducible Ruby dependencies.

These are configuration findings; no successful clean build was obtained in this review.

### 5. Documentation and public claims have drifted

The overview describes Firebase-backed circles, while release readiness still says shared circles are local-only. Backend roadmap items include work already present in source. TestFlight checklists require QA tools compiled only in Debug. README describes local transcription, but the speech request does not explicitly require on-device recognition. Verify the actual speech path before making an offline/on-device guarantee.

The cloud adapter and stored consent flags exist, but no user-facing opt-in control was found. The privacy page's service description needs reconciliation with actual enabled providers and data flows. No claim about provider retention or training behavior was validated here.

### 6. Quality controls exist but leave important gaps

Found 12 XCTest files with 95 `func test…` declarations covering engines, stores, view models, mappings, authentication and analytics. This is useful groundwork; it is not a coverage measurement or a passing test result. No UI-test target or Firestore rules emulator test suite was found in the reviewed tree.

Prioritize tests for authorization, deletion failures, delete-and-restore, account switching, consent, and the first reflection-to-save flow. Add formatter/lint checks and documentation-link checks gradually, with one agreed configuration rather than overlapping tools.

## Information to collect and keep current

Use the existing [documentation index](README.md) as the entry point, then maintain these compact references:

| Reference | Required information | Current starting point |
| --- | --- | --- |
| Product brief | Target user, problem, primary outcome, release goal, non-goals, success measures | Product overview; audience and success measures need confirmation |
| Feature register | User story, status, owner, screens, code, dependencies, acceptance checks, known gaps | Inventory above plus feature source and tests |
| Design guideline | Authoritative design link, visual principles, tokens, components, states, accessibility, content tone | Two code systems and stored screenshots |
| Architecture/data map | Ownership, dependencies, navigation, local persistence, backend schemas, provider selection | Existing engineering docs plus current wiring |
| Data lifecycle | What leaves the device, consent, visibility, retention, export, deletion, account migration | Code/rules/policies currently disagree in places |
| Development handbook | Supported Xcode/compiler, setup, environments, dependencies, tests, CI and release steps | README, Config, CI, Fastlane and team standards |
| Decision log | Decision, alternatives, reason, date and consequences | Historical specs exist; active decisions need a concise index |
| Prioritized backlog | Problem, impact, dependency, acceptance criteria and verification evidence | Findings in this review |

Each feature record should distinguish **implemented**, **partially wired**, **planned**, **reference-only**, and **verified**, with evidence and a last-reviewed commit. A code file alone should not mark a feature release-ready.

Keep canonical product information under `docs/product/`, design guidance in a new `docs/design/`, architecture/setup/data handling under `docs/engineering/`, test evidence under `docs/qa/`, and working agreements under `docs/process/`. Continue using `docs/archive/` for superseded plans. Prefer updating the existing documents over producing many competing summaries.

## Recommended order of work

1. **Establish the reference.** Reconcile the feature register, product vocabulary, public/private circle intent, design authority and current versus historical docs. Done when each core claim has code/design/test evidence or an explicit open question.
2. **Make setup repeatable.** Establish supported tooling, a clean simulator setup, environment-specific Firebase configuration and a working CI baseline. Done when a fresh checkout can build and run tests using documented steps.
3. **Make data behavior dependable.** Address circle access, account deletion, local authentication duplication, backup deletion propagation and account migration. Done when critical failure and multi-user cases have passing automated checks.
4. **Unify the experience.** Consolidate design foundations and component states; verify Dynamic Type, contrast, screen-reader labels and reduced motion on key flows. Done when agreed reference screens and accessibility checks pass.
5. **Improve the core product loop.** Run a small beta around first reflection, save, follow-up action and return visit. Use observed friction to choose improvements such as clearer fallback status, useful reflection history and better coaching specificity. Treat these as hypotheses until user feedback supports them.

Avoid expanding social features or adding another backend before the core loop and its privacy promises are dependable. A full modular rewrite is not justified by the evidence collected so far.

## Verification and remaining unknowns

- Source inspection was performed on local commit `2f28966`; initial working tree was clean.
- Read product/engineering/process docs, app composition, design files, backend rules/services/stores, feature implementations and test declarations. Visually inspected the stored Home and Tips screenshots.
- Default `xcodebuild` points at CommandLineTools. Explicitly selecting `/Applications/Xcode.app/Contents/Developer` reports Xcode 27.1, but simulator tooling stops because the Xcode license has not been accepted. No license was accepted or global tool configuration changed.
- Build/test results, deployed Firebase rules, real-device audio/AI behavior, production configuration, current TestFlight status and external design files remain unverified.
- Product decisions still needed: primary audience, next release objective, circle visibility model, approved design source, and whether cloud AI should be user-facing in that release.
