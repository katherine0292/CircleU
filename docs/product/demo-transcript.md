# Circleu Demo Transcript

This transcript is written for a 5-minute walkthrough of the current Circleu beta on a real iPhone or simulator.

## Demo Goal

Show that Circleu supports one complete reflection loop:

```text
Onboarding -> Home -> Record or Type -> AI Reflection -> Journal -> Tips -> Progress -> Circle/Profile
```

The demo should prove that a tester can start from the home screen, create a reflection, review AI-assisted insight, save it, continue with a small action, and understand how the app will be tested through TestFlight.

## 5-Minute Script

### 0:00-0:30 | Introduction

Hi everyone, today I am demoing Circleu, our iOS reflection app.

The goal of Circleu is to help users turn everyday thoughts into useful self-reflection. Instead of only writing a journal entry and forgetting it, the app helps the user record or type a reflection, receive an AI-assisted summary, save it into a private journal, and follow up with a small practical action.

This version is built as a local-first beta, so the main experience can be tested on a real iPhone before we add full cloud sync or public release features.

### 0:30-1:10 | Onboarding and Home

I will start from the app's main flow.

When a new user opens the app, they go through onboarding and enter a local display name. The app then brings them to the home screen.

The home screen is the daily hub. From here, the user can start a reflection, see their latest journal entry, continue an active tip, and check their progress.

For this demo, I am going to start a new reflection.

Demo action: tap the reflection or recording entry point.

### 1:10-2:00 | Record or Type Reflection

The app supports voice recording, but it also has a typed fallback. This is important because microphone permission, speech recognition, or a noisy environment should not block the user.

For the demo, I will use a short reflection:

> Today I felt nervous about presenting my project, but after practicing I felt more confident. I still want to improve how clearly I explain the app.

The app checks that the transcript has enough detail before generating a reflection. This helps avoid poor AI results from empty or unclear input.

Demo action: record or type the sample reflection, then continue.

### 2:00-3:00 | AI Reflection Result

Now the app creates a structured AI reflection.

Instead of giving one generic chatbot response, Circleu breaks the result into useful parts: an emotion, a summary, an insight, a meaningful moment from the reflection, and a suggested next step.

In this example, the app might identify that the user felt nervous but became more confident through practice. The insight is that preparation helped reduce anxiety, and the next action could be to practice the explanation one more time using a simple structure.

The user can regenerate the reflection if it does not feel right, or save it if it is useful.

Demo action: show the AI reflection result, then tap Save Entry or Save & Open Tips.

### 3:00-3:50 | Journal and Tips

After saving, the reflection appears in the private journal.

The journal stores reflections locally, and the user can revisit them later, edit details like title or tags, and search through past entries.

Circleu also connects reflections to small practical tips. So the app does not stop at "here is what you felt." It helps the user take one small action afterward.

For this reflection, a tip might be:

> Practice your explanation in three parts: problem, solution, result.

The user can complete, skip, or restart tips. This supports a simple growth loop over time.

Demo action: open the saved journal entry, then show the related tip or active tip screen.

### 3:50-4:30 | Circle, Progress, and Profile

The app also has a local circle feature. This is for privacy-safe sharing. Instead of sharing the full private journal entry, the user can share a safer version into a local support circle.

The profile and progress areas show the user's reflection activity and completed tips. This helps the user see that small daily reflections are building into a longer-term habit.

For testing, the app also includes QA tools so we can reset local data, create demo data, and test the same flow repeatedly.

Demo action: briefly show the Circle screen or Profile/Progress screen.

### 4:30-5:00 | Closing and TestFlight

To finish, this beta already supports the main user loop: onboarding, home, record or type, AI reflection, journal, tips, progress, and circle/profile.

The next step is public testing through TestFlight. We will upload the app to App Store Connect, submit the beta build for review, and then create a public TestFlight link so testers can install it and give feedback.

The main thing we want to test is whether users can complete the reflection loop easily, whether the AI summary feels useful, and whether the suggested tips help them take a realistic next step.

That is the demo.

## Demo Prep Checklist

- Install the latest build on the demo phone or simulator.
- Confirm microphone and speech recognition permissions are ready, or plan to use typed fallback.
- Prepare the sample reflection text before presenting.
- Use QA tools to reset or seed local data if the app already contains messy test entries.
- Keep the demo on the core loop. Do not spend time explaining backend plans unless asked.
- If presenting TestFlight, explain it as beta testing, not public App Store release.

