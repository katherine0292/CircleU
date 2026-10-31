# Compact Journal and illustrated tag picker

- Recorded: 2026-10-31 10:33:07 +11:00; Australia/Sydney
- Agent / role: Codex / prototype design and verification
- Status: completed for visual review
- Base revision and branch: 9967a10, codex/app-upgrade-plan; uncommitted working tree, unrelated pre-existing changes preserved
- Related record: [Today and Journal review 11](2026-10-31-095502-codex-today-journal-figma-review-11.md)

## Request and scope

Owner found type too large, clarified tags beneath individual entries, and asked to see the proposed activity/optional-feeling flow. Figma prototype and scoped product documentation only. No native implementation, new generation, cloud activation, commit or push.

## Work and outcome

Created [review 12](../design/figma-journal-tags-review-12/README.md) on new page `67:220` in the existing Figma file. Reused existing Pingu art and brand type; added labelled activity/feeling chips and a chooser with independent selection and removal. Reduced heading size and line spacing, and moved dates above full-width excerpts. Retained fixed navigation and unchanged calendar cells. Older review pages remain available.

Updated the product brief before constructing the screens and added proposed J7 review criteria. Native schemas/tests remain pending rather than being reported as implemented.

## Verification

- Figma structure: 40 frames, 20 possible tag combinations, 199 internal links; no invalid destinations, one font family, fixed Journal tab y764. Final choice labels fit a single line after visual correction.
- Browser: tag → chooser; remove activity and feeling → Done → untagged entry; Add tag → Work → Calm → Done → updated first entry. Original words unchanged. Screenshot evidence and native limitations in the review README.
- Final PNGs inspected. Final documentation/file checks recorded in the task output.
- Not run: Swift build, XCTest/UI suites, device/VoiceOver/Dynamic Type tests. No Swift edited.

## Discussion and decisions

No inter-agent exchanges. Owner approved seeing a bounded visual prototype. Both categories optional and user-selected; no automated emotion inference. Other two entries are visual examples, and external navigation returns to earlier standalone flows without retaining tag selections.

## Handoff

- Remaining work: owner reviews tags/type before authorising implementation planning. Native cancel/persistence/error/migration/export/accessibility scope needs definition.
- Owner: Unassigned
- Risks / unresolved questions: Figma is a fixed scenario, not live storage or a full Journal replacement. Artwork recognition and accessibility need user/device validation.
