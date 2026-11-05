# AI answer acceptance cases

- Recorded: 2026-11-05 22:10:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (desktop app, Katherine's Mac), QA documentation
- Status: completed; docs only, no app code changed
- Base revision and branch: `codex/ai-acceptance-cases` from `katherine/amazing-cray-w6rap2` at `8b3ba00` (that commit and its parent were re-authored under katherine0292 as `43b3a6d` and `738ce98` before merging, at her request)
- Related record: [portfolio contribution map](2026-11-05-213000-claude-portfolio-contribution-map.md); item 3 of [next steps](../portfolio/next-steps-ai-fallback.md)

## Request and scope

Katherine asked to start with item 3 of the AI next steps (the acceptance table), in plain language, and to confirm each item before committing. Files: `docs/qa/ai-acceptance-cases.md` (new), one link in `docs/README.md`.

## Work and outcome

- 19 invented inputs in five groups: too little text, swearing and insults, everyday conflicts, sensitive, long text and other languages. Each row says what a good reflection contains and what must never appear.
- Each row also records what `LocalReflectionEngine` returns today when called as the guest Journal calls it (`durationSeconds: 0`).
- Main findings: the guest next step is almost always "Try a one-minute check-in next time…" because typed entries pass a duration of 0; too-short text still gets a full card; exact keyword matching misses words such as "interrupting" and "overloaded"; a non-swear insult is copied back in the summary; there is no safety response for a hopeless entry (needs an owner decision on wording).

## Verification

- Compiled `TranscriptQuality.swift`, `ReflectionEngine.swift` (Apple Intelligence blocks removed), `ReflectionResponseDecoder.swift` and `AIReflectionResult` with `swiftc` on macOS in a scratch folder outside the repo, and printed the engine output for every row. The probe is not committed.
- `git diff --check` and relative links reviewed.
- Katherine ran the unit suite (scheme Circleu, ⌘U) in Xcode on the iPhone 17 Pro Simulator, iOS 26.5, at 22:20: 291 tests, 290 passed, 0 failed, 1 skipped (`testRealDataProtectionOnDevice`, physical device only). The first attempt failed before building because the git-ignored `Config/Signing.xcconfig` was missing; it was created locally from the example as CI does.
- Not run / limitations: the `CircleuUITests` scheme was not run (docs-only change); no row was checked with Apple Intelligence on a physical iPhone.

## Discussion and decisions

None.

## Handoff

- Remaining work: items 1 and 2 of the next steps; optionally turn rows A3–A5, B4 and C1's next step into unit tests; owner decision on D2 (safety wording) and E2 (non-English entries).
- Owner: Katherine
- Risks / unresolved questions: the "today" column goes stale once the engine changes; update it with the change.
