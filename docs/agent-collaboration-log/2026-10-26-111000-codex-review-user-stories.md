# Codex review: guest user stories (docs)

- Recorded: 2026-10-26 11:10:00 +11:00; Australia/Sydney
- Agent / role: Codex (gpt-6-astra, high, read-only reviewer), run by Claude Code
- Reviewed: `63121aa` on `codex/user-stories`

Reviewed `63121aa`. **Changes required for inaccurate coverage claims.** No files edited.

**Blockers**

- **S5.4 — wrong flow.** [The cited mapping](<docs/product/user-stories.md:234>) uses `GuestImportTests.testFailedImportAddsNothing`, which exercises `GuestImportViewModel.importAll()` against on-device legacy data. It never exercises the account-backup failure path, `GuestSignInViewModel.copy()`. Sharing the error string does not cover that path.

- **P1.2 — wrong operation.** [This criterion](<docs/product/user-stories.md:160>) describes opening a saved message after deleting its source. `testDeletedSourceEntryKeepsWords` instead creates an unsaved composer, injects `.notFound`, attempts **save**, and checks that unsaved wording remains.

- **T3.4 — no relaunch tested.** [The mapped unit test](<docs/product/user-stories.md:66>) uses `MemoryJournalStore` and checks three entries in the same session. It never reopens storage. Mark its contribution as partial; the external UI† test was not inspected.

- **W1.3 — startup evidence becomes an unrestricted promise.** [“When I use it … Firebase is never contacted”](<docs/product/user-stories.md:26>) exceeds a test that only creates a local session and compares the Firebase access counter. Optional account actions intentionally access Firebase. Restrict the criterion to opening the local journal without an account action.

- **S6 — disabled flow presented as current UI.** [S6’s screen and criteria](<docs/product/user-stories.md:236>) describe an on-device import route that Settings no longer opens. Settings opens `GuestSignInView`; no app code constructs `GuestImportView`. S6.2’s test explicitly enables the otherwise-disabled import path. S6.3’s quoted string exists in that unused view, but its test only checks an empty scan and `canImport == false`; it never checks the message. Label this retained implementation/test coverage separately from current guest behaviour.

- **S8 — deletion promise is too broad.** [“Nothing of mine is left online” and S8.1](<docs/product/user-stories.md:254>) omit retained content. The app explicitly says replies and likes on others’ posts cannot be removed; the cited test also expects a retained circle. Qualify the deletion scope to satisfy the guideline’s truthful-state rule.

**Minor notes**

- Several mappings provide partial evidence: **J4.2** checks `hasChanges`, not the discard dialog; **S4.1** checks bundled assets and nonempty names, not picker rendering or spoken labels; **T6.3** forces `guidedOnly`, rather than testing unavailable-model selection; **S1.2** checks injected protection callbacks, not actual iOS protection attributes. **S3.3** covers a Practice composer, and **S8.3** covers login/delete overlap—not every screen or account action.
- **T1.2** accurately quotes existing source, but its three-sentence error is longer in structure than the guideline’s “one sentence … plus the next step” pattern.
- The [art brief](<docs/design/pingu-scene-art-brief.md:26>) requests a warm peach sky despite specifying orange beak colour as the only warm accent. Clarify that exception.

**Checks:** All 78 cited unit-test methods exist. Coverage arithmetic matches the tables: **26 stories, 80 criteria; 65 unit, 6 UI-only, 9 untested; 12 unit-plus-UI**. Those counts describe the labels, not complete verified coverage. Quoted strings match source, allowing interpolated placeholders, with S6’s reachability caveat above. Relative links and whitespace checks passed. XCTest, external UI† tests, and simulator/device validation were not run.