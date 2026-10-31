# Today layout review 19

31 October 2026. Owner rejected review 18's stacked prompt-chip and separate voice rows. This bounded Figma revision keeps the existing artwork and fixed footer geometry, and combines the composer controls into one 44pt row.

- Empty: one quiet, left-aligned “What stayed with you?” prompt with its existing writing-fixture action; one 44 × 44 microphone at right.
- Writing: “What would help next?” and microphone in the same row.
- Listening/error: status wraps within 246pt beside the microphone/Stop control. Saving and unavailable controls retain no click action.
- Writing field now occupies the released 56pt; Save and tabs do not move.
- Existing components, artwork and Plus Jakarta Sans reused. No generated artwork, credit operation, native changes or release action.

The mutation returned dimensions and retained action counts across all six states. Visually inspected Today and microphone-unavailable; error remains readable in two lines. Final correction left-aligns text `74:17` (not included in the one-time historical mutation script). Native accessibility label must be “Record your words” / “Stop dictation” if ported; a Figma layer name is not an accessibility test.

[Open prototype](https://www.figma.com/proto/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=74-3&starting-point-node-id=74%3A3). Page `74:2` is connected review 19. [Today screenshot](today.png), [unavailable state](microphone-unavailable.png).

No fresh native tests, physical-device or VoiceOver check; no full journey rerun this layout-only pass. Prior fixture limitations remain. Review candidate awaiting owner feedback.
