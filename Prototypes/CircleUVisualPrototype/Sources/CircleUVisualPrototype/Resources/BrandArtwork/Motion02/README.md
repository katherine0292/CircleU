# Pingu keyframe studies 02

31 October 2026. Owner approved trying a free idle loop and voice waves using existing artwork after Weave rejected video access on the connected plan. No generation credits or paid services used. Review candidates for showcase use; no native app integration.

| Export | Source | Motion |
| --- | --- | --- |
| [Idle MP4](PinguIdle-keyframe-v1.mp4) | Activities01/PinguQuietBreathV1.png | Whole illustration lifts by up to six pixels over three seconds |
| [Voice MP4](PinguVoice-keyframe-v1.mp4) | Activities01/PinguPractisingV1.png | Same lift with seventeen illustrative blue waveform bars |

Both exports: 720 × 720, six seconds, 30 fps, 180 frames, H.264/yuv420p, silent, opaque ice background. Total video size: 570,333 bytes. Each sequence is periodic for reuse in presentation playback; the review page plays once on request. PNG companions are first-frame stills.

These are keyframed whole-sprite compositions, not articulated breathing, blinking, writing or waving. Original transparent PNGs are unchanged. The waveform is synthetic and is not microphone input. No recording, upload or model run occurs in the review page.

## Review and reproduction

Open [MotionReview02](../../../../../MotionReview02/index.html) through the existing repository-root local server. Play/Pause/Replay both and individual video controls are available. Still artwork replaces both videos with PNGs and disables combined playback. The browser's Reduced Motion preference selects the still version; changing the preference updates it. Hidden tabs pause playback. No autoplay or automatic replay.

Run `render-motion.cjs` from the repository root using Node with the bundled `@napi-rs/canvas` module on `NODE_PATH` and FFmpeg/ffprobe at `/opt/homebrew/bin/`. It refuses to overwrite an export. Use a new version name for revisions. Source/output hashes and export verification are in [provenance.json](provenance.json).

Verified: export dimensions, duration, frame count, no audio, full decode; browser playback through both six-second ends; combined replay/pause and still-artwork toggle; visual layout. Browser screenshot is in the review folder. Real OS Reduced Motion changes, mobile layout, assistive technology and native performance were not tested. This does not change the app motion guideline, which discourages continuous decorative movement while writing.
