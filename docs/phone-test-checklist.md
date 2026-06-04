# Circleu Phone Test Checklist

Use this checklist to run Circleu on a real iPhone from Xcode.

## 1. Open The Right Project

Open:

`/Users/tuanm.nguyen/Documents/JornalApp-personal/Circleu.xcodeproj`

Use branch:

`dev/mike`

## 2. Add Apple Account In Xcode

1. Open Xcode.
2. Go to **Xcode > Settings > Accounts**.
3. Add your Apple ID.
4. Make sure Xcode shows an Apple Development signing identity.

## 3. Select Signing Team

1. Select the `Circleu` project in the left sidebar.
2. Select the `Circleu` target.
3. Open **Signing & Capabilities**.
4. Enable **Automatically manage signing**.
5. Choose your personal/team development team.
6. If the bundle ID is already taken, change it to something unique, such as:

`com.tuannguyen.Circleu`

## 4. Connect iPhone

1. Connect your iPhone by cable.
2. Unlock the phone.
3. Tap **Trust This Computer** if prompted.
4. In Xcode's device picker, choose your iPhone.

## 5. Run The Real User Flow

Test this flow:

1. Reset app data if you want to see onboarding again.
2. Open **Onboarding**.
3. Enter a display name during onboarding.
4. Continue to **Home**.
5. Confirm **Home** greets you by name.
6. Start **Recording**.
7. Allow microphone permission.
8. Allow speech recognition permission.
9. Speak a short reflection, or type in the transcript box if microphone or speech recognition is not ready.
10. Tap **Finish**.
11. Wait for **AI Processing**.
12. Review **Reflection**.
13. Tap **Save Entry**.
14. Confirm the **Saved** screen.
15. Open **Journal** and inspect the saved detail.
16. In the journal detail, add or reactivate the suggested next action.
17. Complete or skip that next action and confirm Home/Profile progress changes.
18. Save the reflection into a private circle from the journal detail.
19. Open **Circles** and confirm the saved reflection appears as a private post.
20. Open **Profile** and confirm the name, entry count, streak, and progress changed.
21. Edit the display name from **Profile** and confirm **Home** updates.
22. Open **Profile > QA tools** and confirm build info, local counts, export, seed, and reset controls are available.

Use Simulator for SwiftUI Previews. Use the connected iPhone for Run testing. Physical-device Preview errors do not necessarily mean the app build is broken.

## 6. Reproducible QA Checks

Use these controls when teammates need the same local state on a phone:

1. Open **Profile**.
2. Tap **QA tools**.
3. Tap **Seed demo data**.
4. Confirm Profile now shows demo reflections, circles, posts, quests, XP, and mood.
5. Open **Home**, **Journal**, and **Circles** to confirm the same demo state appears across tabs.
6. Open the latest journal detail and use the daily practice card to complete, skip, or reactivate the quest.
7. Save the latest reflection into a circle and confirm duplicate saves are disabled.
8. Return to **Profile > QA tools**.
9. Tap **Copy QA** or **Share QA** and confirm the export includes build info, profile summary, local counts, and journal text.
10. Tap **Reset local data** and confirm the warning appears before data is cleared.
11. Relaunch or close the sheet and confirm onboarding can be tested from a first-run state.

## 7. Recording Reliability Checks

Test these before calling the build demo-ready:

1. Start recording and type instead of speaking.
2. Confirm **Finish** stays disabled until text exists.
3. Finish with typed text and confirm AI analysis starts.
4. Save once and confirm the confirmation screen appears.
5. Open Journal and confirm only one new entry exists.
6. Use **Record Another** and confirm the previous transcript is cleared.
7. Deny microphone or speech permission on a fresh install if possible and confirm typed fallback still works.

## 8. Onboarding And Home Visual Checks

1. Reset app data and confirm onboarding fits on the phone.
2. Leave name empty and confirm Home greets `Friend`.
3. Enter a real name and confirm Home greets that name.
4. Tap refresh on the daily prompt and confirm the prompt changes.
5. Save a reflection and confirm Home stats and latest reflection update.
6. Confirm top bar level/streak values are not hard-coded.

## 9. Local Workflow Checks

1. Save a reflection and confirm Home shows a real next action.
2. Tap **Complete** on the Home quest and confirm Profile XP/progress updates.
3. Save another reflection and tap **Skip** on the quest to confirm it disappears from active quests.
4. Open the latest journal detail and reactivate a skipped or completed quest.
5. Save the reflection into a private circle from the journal detail.
6. Open **Circles** and confirm cards show spaces, posts, and reflections instead of member counts.
7. Create a new private circle.
8. Open the circle and add a support note.
9. Share the latest reflection into that circle.
10. Confirm the circle post count and latest activity update.
11. Open **Profile** and confirm entries, streak, circles, mood, badges, quests, and local data summary all reflect real local state.
12. Edit the display name and confirm Home/Profile use the new name.

## Backend Decision

For the current Apple Intelligence test, no backend is required because the reflection engine runs on device when Apple Intelligence is available.

Add a backend later when Circleu needs:

- OpenAI, Claude, or another cloud model.
- Shared team accounts.
- Cloud sync across devices.
- Analytics and production logging.
- Server-side model evaluation.
