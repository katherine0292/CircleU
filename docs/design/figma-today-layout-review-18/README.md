# Today layout review 18

31 October 2026. Figma-only refinement; product brief updated before changes.

[Open Today](https://www.figma.com/proto/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=74-3&starting-point-node-id=74%3A3&scaling=scale-down&content-scaling=fixed). Page `74:2`: CircleU • connected review 18.

## Changes

- Reused Codex artwork `ScreenScenes06/SceneWindowPauseV1.png` for capture and `ScreenScenes07/SceneVoiceCornerV1.png` for listening, under the prototype's BrandArtwork resources. Natural 2:1 ratio, 342 × 171; no new generation.
- Grouped writing, prompts/status and Speak/Stop into one 342 × 310 composer. Removed repeated small Pingu from the filled nudge. Empty copy: “Write what happened…”
- Original microphone instances retained 64/44 scaling after component swap. Replaced them with fresh 44 × 44 instances: centred 14 × 24 microphone or 16 × 16 Stop; the parent 112 × 44 pill owns the click.
- Applied to empty, writing, listening, saving, save-error and microphone-unavailable. Action y=698 and tabs y=764 remain identical across all six 390 × 844 frames.

## Verification

Inspected [Today](today.png), [writing](writing.png), [listening](listening.png) and [save error](save-error.png). Player checks: microphone hit area → listening, Stop label → writing, Save → saving → Journal with saved entry, Today tab → empty, writing field → filled fixture. Structural checks confirm disabled voice actions during saving/unavailable and retained moved input/voice reactions.

Scripts are one-time historical mutations, not idempotent rebuilds: `refine-layout.js` and `fix-microphone.js`. In `result.json`, old microphone IDs were subsequently replaced by `126:461`, `126:463`, `126:465`, `126:467`, `126:469`, `126:471` in the same frame order.

No native code/build/tests or physical-device checks. Figma uses predefined text and simulated dictation/save states. No Figma AI or Weave credit operation; balance not queried. Review 17's stale-reflection and permission-state limitations remain.
