# Circleu Domain Models

This document explains the core app objects in product language.

## Journal Reflection Entry

`JournalReflectionEntry` is one saved journal check-in.

It stores:

- creation time,
- recording or typed duration,
- transcript,
- engine name,
- selected AI reflection result,
- linked AI session ID,
- editable title and emotion,
- private note,
- tags,
- last edited time.

It is the source of truth for Journal, Home progress, Profile progress, suggested tips, and privacy-safe circle sharing.

## AI Reflection Result

`AIReflectionResult` is the structured insight generated from a transcript.

It stores:

- title,
- emotion,
- summary,
- insight,
- expression moment,
- quote,
- confidence score,
- suggested quest.

The app uses this on the Reflection screen and as the starting point for follow-up tips.

## AI Reflection Session

`AIReflectionSession` records how a reflection was generated.

It stores:

- source, such as recording, typed fallback, regeneration, or QA seed,
- transcript and duration,
- engine name,
- linked journal entry when saved,
- attempts,
- selected attempt,
- merged session IDs.

Journal entries are user-facing saved reflections. AI sessions support QA, model evaluation, and future provider comparison.

## Quest

`Quest` is one small action the user can take after a reflection.

Status values:

- `active`: available to do,
- `completed`: finished by the user,
- `skipped`: dismissed by the user.

Completed quests contribute to XP and progress.

## Circle Space

`CircleSpace` is a private local support space on the user's phone.

In the current beta, circles are not live multi-user groups. They organize support notes and privacy-safe reflection shares until shared CloudKit circles are intentionally added.

## Circle Post

`CirclePost` is one note saved inside a circle.

It can be:

- a support note written by the user,
- a privacy-safe share from a saved reflection.

Circle cards derive post count and latest activity from posts.

## Tips Practice Session

`TipsPracticeSession` stores communication practice history.

It includes the original message, scene, tone, situation, turns, coach output, and attached image count. This is private user data and belongs in the private CloudKit database when sync is enabled.

## Progress Snapshot

`AppProgressSnapshot` is derived by `ProgressEngine`.

It contains entry count, streak, level, XP, most common emotion, completed quest count, and badges. It should not be stored as a separate source of truth.

## Stores And Engines

Stores persist local data:

- `ReflectionJournalStore`: saved reflections.
- `AIReflectionSessionStore`: AI generation sessions.
- `UserProfileStore`: display name and local profile preferences.
- `CircleStore`: private circle spaces and posts.
- `QuestStore`: active, completed, and skipped quests.
- `TipsPracticeStore`: recent tips practice sessions.

Engines calculate or generate results:

- `ReflectionEngine`: creates AI reflection results from transcripts.
- `TranscriptQuality`: validates reflection input.
- `ProgressEngine`: calculates XP, level, streak, badges, and emotion mix.
