# Competition UI priority and two-agent coordination

- Recorded: 2026-10-27 01:39:32 +1100; Australia/Sydney
- Agent / role: Codex, coordinator
- Status: both bounded assessments completed; runtime work not started
- Base revision and branch: `9967a10`, `codex/app-upgrade-plan`; uncommitted documentation
- Related: [upgrade plan](../superpowers/plans/2026-10-27-app-upgrade-roadmap.md)

## Request and scope

The owner explicitly requested two agents, one frontend and one backend, and faster UI upgrades for a design competition. Preserve the private-beta goal, approved identity/layout and guest-first scope. Competition name, deadline and required submission format were requested; they remain unknown at the time of dispatch.

## Work and outcome

- Assigned `competition_frontend` to source/screenshot-backed visual review and a concrete first UI batch.
- Assigned `competition_backend` to local data/service contracts and demo-readiness assessment, with release requirements conditional on submission format.
- Restricted each agent to its own new review document and dated log. Shared roadmap/index, Xcode jobs and integration remain with the coordinator. No runtime, Figma, signing, backend or device changes in these assessments.
- Reprioritized the roadmap with a competition fast track: frontend and backend assessment in parallel; choose one concrete UI batch; implement only backend blockers for that journey; capture required artifacts; retain wider release/privacy obligations.

## Actual agent exchanges

- Backend reported that existing guest contracts support the main journey and a server rewrite is unnecessary. It identified the source-enforced Debug-only guest startup as a blocker only if a guest Release/TestFlight submission is required. Draft interruption remains an evidence gap, not a reproduced defect. Coordinator asked to keep those distinctions and avoid backend work that delays UI without an actual blocker.
- Frontend inspected current test screenshots and source. It proposed Today hierarchy/compact artwork/quieter nudge first, Practice continuity next. It observed a default-text keyboard screenshot in the latest test bundle; coordinator requested a clear distinction from the previously inspected AX5 screenshots, which had no visible software keyboard. No broad keyboard certification was inferred.
- Coordinator requested both agents finish bounded assessments rather than expand into an unrequested full audit.
- Frontend delivered its [review](../design/competition-frontend-review-2026-10-27.md): Today scene/nudge hierarchy, Journal background consistency and compact entry date title first; Practice continuity next. Backend delivered its [readiness assessment](../engineering/competition-backend-readiness-2026-10-27.md): qualify existing save/reopen, interruption and offline fallback contracts without a server rewrite. Coordinator reviewed both outputs.

## Verification and handoff

- Documentation-only task: no builds or tests rerun; no new runtime pass claimed.
- Relative links in the new planning/review documents and `git diff --check` passed after both review files were present.
- Owner decisions outstanding: competition requirements and concrete proposed visual changes. The two-agent assignment is authorized; it is not approval of every visual or release idea.
- No outreach, submission or ongoing scheduled work created. Follow-up implementation can resume the two assigned agents when its scope is chosen.
