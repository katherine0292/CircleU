# CircleU coding standards

Adopted 23 October 2026 at the owner's request. Based on `~/Documents/GitHub/coding-standards/coding_standards.md`, especially sections 2 (Shape B), 7–10 and 13. Reference the shared standard; do not copy it wholesale. These local rules make the project usable when that workspace-specific path is unavailable.

Rechecked against the shared baseline on 24 October 2026. Its app/product structure, evidence, Git hygiene and scoped Conventional Commits apply. Notebook/ML/Kaggle instructions do not apply to the SwiftUI app. Existing folder names and Git history remain intact.

## 1. Scope and deliberate overrides

CircleU follows the master standard's **app/product Shape B**. Swift source and the Xcode project are the executable source of truth. Product docs record intent, and Figma records the prototype; neither proves runtime behavior.

| Master convention | CircleU adaptation |
| --- | --- |
| Notebook-first layout, Python/PEP 8 | Existing SwiftUI/Xcode feature structure and Swift conventions below |
| Numbered brief/architecture/decisions/next steps | Preserve established paths: `product/mvp-definition.md`, `engineering/architecture.md`, approved-decision tables and `superpowers/plans/`. Add this stable `0_coding_standards.md` entry point; do not renumber existing docs |
| Kaggle data, submission and evaluation rules | Not applicable; use app behavior tests, device QA and release evidence |
| Viridis chart palette | Applies only if suitable for an analytical chart; not a new UI palette. Reuse existing app tokens and reviewed design references |
| Agent collaboration log | Dated entries in `agent-collaboration-log/`, with explicit evidence and append-only corrections |

Current approved scope and remaining proposals live in the [MVP definition](product/mvp-definition.md). The owner approved planning before coding, Today/Journal/Practice and deferring circles/rewards. The latest 24 October decision restores guest-first local use, with optional Log in for earlier-account recovery; see [onboarding](design/account-onboarding.md). Sync/cloud AI are not newly approved. Follow later explicit owner changes and record them.

## 2. Architecture and Swift style

- Keep `Circleu/App/` for composition/navigation, `Features/<Feature>/` for screens and their ViewModels, `Components/` for UI genuinely shared across features, and `Design/` for existing visual foundations.
- `Models/` owns domain values; `Stores/` owns shared state/persistence; `Engines/` owns transformations and reflection logic; `Services/` wraps device/provider APIs. Behavior tests live in `CircleuTests/`.
- Follow View → ViewModel → Store/Engine/Service → Model boundaries. Do not add network or persistence calls directly to SwiftUI bodies. Prefer injected boundaries for behavior that needs isolation in tests; avoid framework layers without a concrete need.
- Use four-space indentation, `UpperCamelCase` types and `lowerCamelCase` members. Match surrounding Swift formatting; avoid unrelated formatting churn. Name files for their primary type or feature.
- Prefer small named operations and domain types to unstructured dictionaries. Document non-obvious contracts with Swift `///` comments; explain why in inline comments.
- Keep UI-observable mutations on the appropriate actor. Handle cancellation and late async results so stale generation cannot overwrite current edits. Do not add unchecked concurrency escapes to silence diagnostics.
- Represent loading, validation, unavailable capability and errors explicitly. Never suppress a persistence/deletion failure into success, or interpret unreadable storage as an empty dataset.
- Reuse existing UI foundations until the design-system consolidation is agreed. Support Dynamic Type, VoiceOver, reduced motion and non-color-only status. Do not introduce a third competing token system.

These are change guidelines, not a claim that every existing file already complies. Refactor only within the authorized task and preserve behavior unless a change is intended.

## 3. Data, privacy and compatibility

- Follow the [privacy/storage plan](product/privacy-storage-plan.md) and [legacy transition plan](superpowers/plans/2026-10-23-local-first-transition.md). New local-first behavior remains unimplemented; do not describe the current app as having no cloud paths.
- Preserve guest/account scope, stable IDs, accepted edits and source links across migrations. Test interruption, retry and deletion without resurrection. Do not delete Firebase projects, accounts or records as incidental cleanup.
- No credentials, journal text, transcripts, private messages, real-user exports or production payloads in Git, test fixtures, screenshots or agent logs. Use invented scenarios; keep local signing/Firebase configuration ignored.
- Existing settings are iOS 17 and iPhone+iPad. The proposed iOS 26+ MVP scope needs validation and legacy recovery; do not change deployment targets, bundle identity or device family merely to make a build pass.
- Treat model and speech capability as runtime conditions. The approved new experience needs useful manual fallbacks and no silent cloud substitution.

## 4. Verification and evidence

| Change | Minimum relevant evidence |
| --- | --- |
| Docs/process only | Review all edited and new files, relative links, structured manifests and `git diff --check`; no app build required |
| Isolated static visual prototype | Build the standalone package; regenerate and visually inspect individual renders and galleries; check fixed dimensions, resources and font loading. Clearly label sample content and noninteractive controls. No full-app or Simulator claim |
| Model, Store, Engine, ViewModel, migration or service behavior | Relevant XCTest coverage, including meaningful failure/cancellation cases; run affected tests |
| SwiftUI/integration | Simulator build and relevant interaction/layout checks; add behavior tests where risk warrants them |
| Microphone, speech, Apple Intelligence, file protection or full release flow | Physical-device checks on the [device matrix](product/supported-devices.md); simulator/mocks are insufficient |
| Firebase rules or account/cloud deletion | Isolated backend/emulator checks for ownership and partial failure, plus explicit deployed-state verification before release |

Record command, build/commit or working-tree state, destination, result and limitations. Do not write tests that merely mirror code or make unsupported coverage claims. A failed tool/environment check is a limitation, not a passing app test.

Use command-specific Xcode selection and discover an available destination:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -version
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -showdestinations -project Circleu.xcodeproj -scheme Circleu
```

Set `CIRCLEU_TEST_SIMULATOR_ID` to an actual available simulator UUID, then run the relevant build/test action:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test \
  -project Circleu.xcodeproj -scheme Circleu \
  -destination "platform=iOS Simulator,id=$CIRCLEU_TEST_SIMULATOR_ID"
```

Xcode 27.1 was verified in the planning session; the existing CI workflow still selects Xcode 16.0. Neither that observation nor these commands establish a passing baseline. Do not install a formatter, alter CI or change global Xcode settings incidentally while applying documentation rules.

## 5. Git and collaboration

- Inspect `git status --short --branch` and diffs before editing. Preserve unrelated uncommitted work; check untracked files explicitly because ordinary `git diff` omits them.
- Prefer `codex/<topic>` for new agent branches. Reuse an appropriate existing branch/worktree; do not switch/reset a dirty checkout blindly. See the [Git workflow](process/git-workflow.md).
- Use scoped Conventional Commits, for example `docs(process): add agent collaboration records` or `fix(journal): preserve draft after failed save`. Keep changes coherent and stage explicit paths or hunks.
- Commit/push only within the active task's authorization; never force-push shared history or bundle others' changes for convenience. Adopting these standards does not itself perform a commit or push.
- Before handoff, follow the [agent log protocol](agent-collaboration-log/README.md). Record actual review findings, replies, agreements, rejected suggestions and unresolved questions, with references. A report from another agent remains reported evidence until inspected/verified.
- For authorized parallel work, agree file ownership and integration order; each agent writes a unique log file rather than racing on a shared ledger. Shared coordinator/project files need one integration owner. The log records coordination; it is not a scheduler or lock.

## 6. Documentation ownership

Use the [content standard](design/content.md) for new/revised interface copy; it records the proposed sentence-case and punctuation rules separately from coding conventions.

Keep this file authoritative for coding rules, [team standards](process/team-standards.md) for working agreements, and the [log protocol](agent-collaboration-log/README.md) for history. Root `AGENTS.md` points agents here; `CLAUDE.md` only imports `AGENTS.md`.

Update the affected product/engineering/QA doc when behavior changes. Log entries link to those documents instead of becoming another product specification. Distinguish **owner-approved**, **proposed**, **implemented**, **verified** and **historically reported**. Correct historical logs by appending a new record that identifies the old claim and evidence; current standards and indexes can be edited normally.

## 7. Prototype and design artifacts

- Keep design experiments in `Prototypes/CircleUVisualPrototype/`; do not import the app, initialize Firebase, or add real storage/network side effects there. A demo approval selects a visual direction, not production implementation or release approval.
- Reuse the accepted brand's font/color/artwork helpers across new preview screens. Keep historical draft helpers scoped to their comparison views; promote one reviewed system to production only in an authorized implementation task.
- Commit deliberate, documented review artifacts: source artwork used by the prototype, exact generation prompts, bundled fonts with their license, and PNG/JPEG renders linked from design documentation. These are the project-specific exception to avoiding disposable generated output. Keep caches, build products, raw backend data and unreferenced experiment dumps out of Git. Review new binary sizes before staging; do not silently recompress or replace accepted artwork.
- Use versioned filenames for revised artwork and retain selected originals. Prompt provenance should use repository-relative reference paths, not machine-specific cache paths. Never treat generated lettering or artwork colors as authoritative font/token definitions.
- Run the renderer after visual changes and inspect both individual screens and comparison boards. Record macOS ImageRenderer, Canvas, Simulator and hardware evidence separately. Fixed-size specimens do not certify Dynamic Type, VoiceOver, dark mode, keyboard handling or production touch targets.
- Sample calendar dates must be internally correct and deterministic. Document week-start, selected day, today marker and entry-dot meaning. Date browsing must not introduce streak pressure or imply that an empty day is missing data. Real calendar/time-zone filtering, accessibility and month-navigation tests belong to implementation work.

## 8. Publishing a planning milestone

When the owner authorizes commit/push, review the whole pending scope and separate process standards, product/recovery research, and visual prototype deliverables into coherent commits where practical. Include material verification and limitations in each commit body. Stage explicit paths; check the complete staged diff, including untracked documents, artwork provenance and font licenses.

Use a `codex/` branch from a verified base, push without force, and compare the remote branch SHA with local HEAD. State whether CI ran: a feature-branch push may not match the existing main/PR-only workflow. Do not alter CI, merge, deploy or release merely to make a planning milestone appear validated.
