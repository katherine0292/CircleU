# Motion 01 — camera studies

Three finite eight-second MP4 previews based on the accepted ScreenScenes07 originals:

- [Welcome path](WelcomePath-camera-motion-v1.mp4)
- [Reflection garden](ReflectionGarden-camera-motion-v1.mp4)
- [Voice corner](VoiceCorner-camera-motion-v1.mp4)

**These are camera-motion studies, not character animation.** A slow 4% push-in returns to the original framing; Pingu's pose, eyes, pencil and flippers remain still. No sound. 1280 × 640, 30 fps, 240 frames, H.264/yuv420p, fast-start MP4. Generated locally with FFmpeg; no paid model run.

[Source hashes, output hashes and exact filters](provenance.json) and the [render script](render_camera_previews.py) make the derivation traceable. Run the script from the repository root; it refuses to overwrite existing MP4s. Original PNGs are unchanged.

For showcase playback only. These clips do not approve looping/parallax inside the app. The app's existing motion proposal still calls for quiet editing, finite decoration and a still Reduced Motion fallback. Natural blinking, writing or waving requires an image-to-video workflow or purpose-built layered animation; the connected Weave workflow currently requires Figma account linking.

Validation: ffprobe confirmed duration, frame count, codec and dimensions; all three streams decoded end to end without errors. Browser gallery exposes playback and downloads. No native player, performance or accessibility claims.
