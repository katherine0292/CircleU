# Circleu Product Overview

Status, 24 October 2026: this page describes the broader existing implementation. The approved next direction is guest-first Today / Journal / Practice, with circles and rewards deferred; see the [MVP definition](mvp-definition.md). That transition remains unimplemented. The [next prototype-review milestone](../superpowers/plans/2026-10-24-prototype-review-milestone.md) precedes production integration and legacy distribution work.

Circleu is an iOS reflection app for voice journaling, AI-assisted insight, and small daily actions. A user can record or type a reflection, receive a structured AI summary, save it into a private journal, start a suggested tip, and optionally share a selected insight into a supportive circle.

## Current Beta Loop

```text
Onboarding -> Home -> Record or Type -> AI Reflection -> Journal -> Tips -> Progress -> Circle/Profile
```

The current beta is designed for real iPhone testing through TestFlight. Firebase Authentication handles sign-in, Firestore backs up private user data, and circles use Firestore for shared circle data. Local persistence remains part of the app so the reflection loop stays responsive during normal beta testing.

## One-Minute Script

Circleu helps people turn everyday reflection into practical growth. Instead of acting like a generic chatbot, it guides a user through a calm loop: speak or type honestly, review a structured AI reflection, save the insight, and take one small follow-up action.

The current version supports recording, speech recognition, typed fallback, AI reflection generation, saved journals, tips, Firebase-backed circles, progress, and QA tools for repeatable testing.

## Product Areas

- **Onboarding**: introduces the app and stores a local display name.
- **Home**: daily hub for reflection entry points, latest reflection, active tip, and progress.
- **Recording**: microphone capture, transcript status, typed fallback, and quality checks.
- **Reflection**: AI-generated emotion, summary, insight, quote, expression moment, confidence, regenerate, save, and Save & Open Tips.
- **Journal**: saved reflections, search, editable workspace fields, related tips, export, and circle sharing.
- **Tips**: active, completed, skipped, and restarted suggested actions.
- **Circle**: supportive circle spaces, selected reflection shares, posts, replies, likes, and bookmarks.
- **Profile**: progress, profile editing, Firebase status, local data summary, QA tools, and AI session lab.

## Project Shape

```text
Circleu/
  App/                 App entry, dependency injection, root navigation
  Assets.xcassets/     Colors, app icon, mascot, and image assets
  Components/          Shared reusable SwiftUI components and button styles
  Design/              Design tokens such as colors, spacing, and layout constants
  Engines/             Business logic and AI/reflection logic
  Features/            User-facing screens grouped by product workflow
  Models/              Codable domain models and value types
  Services/            Device APIs, Firebase sync, and provider boundaries
  Stores/              ObservableObject app state and local persistence
```

See [project-structure.md](../engineering/project-structure.md) for folder ownership rules.

## Earlier cloud-beta direction

The earlier beta roadmap prioritized a Firebase-backed TestFlight experience in these slices:

1. identity,
2. Firebase-backed sync,
3. privacy-safe analytics,
4. optional external AI providers.

Firebase remains in the current source. The earlier [backend plan](../engineering/firebase-backend-plan.md) and [CloudKit reference](../engineering/cloudkit-data-model.md) are implementation/history references; they do not override the approved guest-local direction or prove current runtime correctness.
