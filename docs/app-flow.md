# Circleu App Flow

This product flow aligns Figma, Xcode, team discussion, and live testing without requiring numbered files or folders in the repo.

- **Onboarding**: Introduce Circleu and move the user into the app.
- **Home**: Invite the user to begin a voice check-in.
- **Recording**: Capture voice, show live transcript, and let the user finish.
- **AI Processing**: Analyze the transcript with Apple Intelligence when available, with local fallback.
- **Reflection**: Show emotion, insight, expression moment, quote, and confidence score.
- **Saved**: Confirm the reflection was saved and explain where it lives.
- **Journal**: List saved AI reflections, open details, manage the related next action, and save useful insights into private circles.
- **Circles**: Store private support notes and selected reflection shares.
- **Profile**: Show journey progress based on saved reflections.

Implementation notes:
- Keep Swift file names semantic, such as `HomeView` and `RecordingView`.
- Keep AI behind `ReflectionAnalyzing` so Apple Intelligence can be replaced or joined by other providers later.
- Keep the daily practice loop local-first: `ReflectionJournalStore` owns saved reflections, `QuestStore` owns next actions, and `CircleStore` owns private support posts.
