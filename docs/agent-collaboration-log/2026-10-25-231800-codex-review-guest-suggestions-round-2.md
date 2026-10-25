**2026-10-25 — Codex review, round 2 — `7c00c28` (`codex/guest-suggestions`)**

**Verdict: no confirmed BLOCKER in static review. SHOULD-FIX #5 and #9 remain partially addressed.** Reviewed `git show HEAD`, surrounding save/navigation/generation code, tests and project guidance. No files edited.

| Prior finding | Status |
|---|---|
| **1. Reflection edits lost during save** | **Addressed:** review fields, Clear/Add controls and Back are disabled while saving. Runtime interaction remains unverified. |
| **2. `draftAlreadySaved` drops reflection** | **Addressed:** returns failure with an explicit explanation, retaining the draft and review instead of dismissing as success. |
| **3. Next step accepted by default** | **Addressed:** starts empty; requires “Add this step” or personal input. |
| **4. Standalone-step provenance** | **Decision accepted:** explicit adoption makes this a personal action; retaining AI provenance is not required for that product meaning. |
| **5. Stale Practice suggestions** | **Partial:** situation/goal changes are flagged, including changes during generation. Wording changes remain untracked despite wording being a generation input. |
| **6. Bracket-range trap** | **Addressed:** `start < end` prevents constructing a reversed range. |
| **7. Verbatim words** | **Decision accepted:** outer-whitespace trimming predates this slice and has existing test coverage. No new trimming regression identified. |
| **8. Back discards review edits** | **Addressed:** edited reflection fields or an added step trigger a discard confirmation. |
| **9. Test gaps** | **Partial:** default-off steps, duplicate-draft rejection, migration preservation and rollback coverage improved; important regression cases remain absent. |

**Remaining SHOULD-FIX details**

- **#5 — Track the wording input too:** [GuestPracticeViewModels.swift:165](<../../Circleu/Features/GuestJournal/GuestPracticeViewModels.swift:165>). Generate from draft A, then manually replace it with B: options based on A still appear current. Distinguish manual edits from applying an option if necessary.
- **#9 — Exercise actual delayed operations:** [GuestSuggestionTests.swift:246](<../../CircleuTests/GuestSuggestionTests.swift:246>). The “LateResults” test awaits generation before changing inputs; it tests no late result. Add suspended-generation coverage, save-time control/discard interaction coverage, and malformed-output parser cases.

**New BLOCKER / SHOULD-FIX / NIT:** none beyond these remaining findings. The request-counter guard currently cannot encounter a newer overlapping request because `!isSuggesting` serializes calls; it is not evidence of tested supersession.

**Verification / limits:** `git diff --check HEAD^ HEAD` passed; working tree clean. No build, XCTest execution, Simulator/UI, accessibility, physical-device or live Apple Intelligence checks. Legacy/cloud paths were outside scope. No inter-agent exchanges; implementer decisions assessed from the user’s report.