# How CircleU works: the two apps in one project

Written 6 November 2026 from a full read of the source on `main`. It explains what each version does, how the code is organised and how data and AI move through it. For screens, see the [final screens](../design/final-screens-2026-11-06/README.md).

## 1. One project, two apps

The repository builds two separate experiences. A launch-time switch picks one, and they share no screens and no stores.

| | **Version 1: team TestFlight app** (June 2026) | **Version 2: CircleU guest app** (Oct–Nov 2026) |
| --- | --- | --- |
| Started by | Every Release build (TestFlight, App Store) | Debug builds with `-CircleUGuestMode`, or the `CircleU Guest Review` scheme |
| Tabs | Home · Journal · Tips · Circle · Profile | **Write · Journal · Talk** |
| Account | Required (Firebase Auth) | None. Optional **Log in** only to recover old data |
| Storage | Local caches plus Firestore sync | **SwiftData on this iPhone only**, file protection on |
| AI | Cloud Gemini (removed 4 Nov), then Apple Intelligence | Apple Intelligence on device, with a guided fallback |
| Social | Circles (community feed), likes, rewards, quests | Removed from the MVP |
| Code | `App/`, `Features/{Home,Journal,Tips,Circle,Profile,…}`, `Stores/`, `Engines/` | `Features/GuestJournal/`, `Services/GuestJournal/` |

The switch is [`AppStartup`](../../Circleu/App/AppStartup.swift). Guest mode is only possible in Debug, and it never configures Firebase or analytics. This is so the testers who already have version 1 on TestFlight keep their data while version 2 is built and checked.

```text
CircleuApp.init
 └─ AppStartup.resolve()
     ├─ .existingApp  → Firebase + analytics → ContentView → RootView (5 tabs)      [version 1]
     └─ .guestJournal → no Firebase → GuestRootView → Welcome → Write/Journal/Talk  [version 2]
```

## 2. Version 1: the team TestFlight app

The first version was built for the Apple Foundation Program by a five-person team. It is still what Release builds open.

| Area | What it does | Main code |
| --- | --- | --- |
| Onboarding and account | Sign up or sign in, then a welcome hints overlay | `Features/Onboarding`, `Stores/AuthStore`, `Services/FirebaseAuthService` |
| Home and recording | Voice check-in with `AVFoundation`, speech-to-text with `Speech`, and a typed fallback | `Features/Home`, `Features/Recording`, `Services/VoiceRecorder`, `TipsSpeechRecognizer` |
| Reflection | The transcript becomes an emotion, a summary, a quote and a suggested quest | `Features/Reflection`, `Engines/ReflectionEngine`, `TranscriptQuality` |
| Journal | Saved reflections with tags | `Features/Journal`, `Stores/ReflectionJournalStore` |
| Tips / Live Coach | You type what you want to say and a coach suggests a reply, with the context kept apart | `Features/Tips`, `Engines/CommunicationCoachEngine`, `Stores/TipsPracticeStore` |
| Circles | A community feed with posts, likes, bookmarks and replies, kept in Firestore behind rules | `Features/Circle`, `Stores/CircleStore`, `Services/FirebaseCircleService` |
| Profile | Quests, rewards (point numbers hidden), settings, delete account | `Features/Profile`, `Stores/QuestStore`, `RewardsStore` |
| Sync | Local caches scoped per Firebase user, uploaded and restored through Firestore | `Services/FirebaseFirestoreSyncService`, `Stores/BackendSessionStore` |

**Why version 2 exists.** Usability sessions and the owner's review (23–24 October) found four problems:
- the account wall came before any value;
- Circles and rewards pulled attention away from reflection;
- sensitive journal text went to the cloud;
- Live Coach was a separate tool, not linked to what the person had written.

The approved direction is **guest-first, local-only, three tabs**. See the [MVP definition](mvp-definition.md).

## 3. Version 2: the guest app, flow by flow

### 3.1 The core loop

```text
 Write ──save──▶ Moment ──Reflect──▶ Reflection ──"Save and prepare what to say"──▶ Talk
   ▲                │                                                                   │
   │                └──────────── timeline: what happened · reflection · ───────────────┤
   │                              conversation · how did it go                          │
   └──────────────────── Journal (search, calendar, tags) ◀────── "How did it go?" ─────┘
```

Each saved entry is a **moment**. Its page is a timeline with four stops. The one main button is always the next stop that isn't done yet: Reflect, then Talk it through, then How did it go?

### 3.2 Screens

| Flow | What the person does | Where in the code |
| --- | --- | --- |
| **Welcome** | Three otter scenes, then Get started or Log in. Shown once. | `GuestImportAndWelcome.swift` (`GuestWelcomeView`) |
| **Write** | Type or dictate, or pick a guiding question. Save. A Saved card offers Reflect. Unsent words are kept as a draft. | `GuestJournalScreens.swift`, `GuestTodayPrompts.swift`, `GuestDictationViewModel.swift`, `GuestVoiceReviewSheet.swift` |
| **Reflect** | A suggestion of what happened, a feeling and what's underneath, plus an optional next step. Edit anything. Save, or Save and prepare what to say. | `GuestReflectionReview.swift`, `GuestEntryEditorViewModel.swift` |
| **Moment** | The timeline. Add a context (Study, Work, Friends, Family, Relationship) and a feeling. Mark the step done. | `GuestJournalScreens.swift` (`GuestEntryDetailView`, `GuestTimelineStep`), `GuestEntryTagPicker.swift` |
| **Talk** | Set the scene: where it is, the tone (Soft, Balanced or Firm) and optional notes. Write what you mean and get a suggestion. Change the style (Shorter, Warmer, More direct). ↻ gives another take. Copy, then mark *I said it*. Paste their reply and get **two ways to read it**; you choose, then get reply ideas. Edit an earlier message to branch. | `GuestTalkScreens.swift` (`GuestTalkModel`, `GuestTalkScreen`) |
| **How did it go?** | A feeling, a line, or both. Saved as its own turn. | `GuestOutcomeCard` in `GuestTalkScreens.swift` |
| **Journal** | Entries by day, search, a calendar, context and feeling chips. | `GuestJournalScreens.swift`, `GuestFindAndControl.swift` |
| **Talk home** | Start a conversation, *From your journal* (moments with a context and no conversation yet), *Earlier conversations*. | `GuestPracticeScreens.swift` (`GuestPracticeHomeView`) |
| **Guide** | The **?** starts a 13-step tour across the three tabs. A spotlight lights one control and dims the rest; the otter changes pose at each step. | `GuestTour.swift` |
| **Settings** | Choose your otter, export everything as text, copy data from the earlier app, delete all. | `GuestFindAndControl.swift`, `GuestImportAndWelcome.swift`, `GuestSignIn.swift` |

### 3.3 Layers

```text
View (SwiftUI)                 GuestJournalScreens, GuestTalkScreens, GuestTour, …
  │ calls actions on
ViewModel (@MainActor)         GuestJournalViewModel, GuestPracticeViewModel, GuestTalkModel, …
  │ uses protocols
Store / Engine / Service       GuestJournalStore, GuestConversationStore, GuestSuggesting, GuestDictationEngine
  │ implemented by
SwiftData + file protection    SwiftDataGuestJournalStore (schema V1→V6, migrations tested)
FoundationModels               LocalFirstSuggestionEngine (Apple Intelligence, then guided templates)
Speech / AVFoundation          on-device dictation only
```

Every store is a protocol, so tests use the same code with in-memory or failing stores. ViewModels own loading, saving and error states. A failed save keeps the person's words and says what happened.

## 4. Data

| Data | Shape | Notes |
| --- | --- | --- |
| Entry (moment) | Original words, created date, optional context and feeling, reflection, next step and done | Words are never rewritten by AI. A reflection based on older words is marked as outdated. |
| Reflection | Summary, feeling, insight, and its source (Apple Intelligence, guided prompts or imported) | The source is always shown on screen. |
| Conversation | `GuestPracticeConversation`: a list of turns of kind *wording*, *their reply*, *context* or *outcome* (with an optional feeling) | Talk saves in this same format, so older Practice messages open as Talk threads. |
| Drafts | One per slot (Write, Talk), with a receipt so a saved draft is never offered again | |
| Settings | Chosen otter, Welcome seen | `UserDefaults` |

Internal names such as `GuestPracticeConversation`, `PracticeDraft.json` and the `practice` draft slot keep their old spelling on purpose. They are saved keys and type names, and renaming them would break data already on testers' phones. Everything the person sees says Talk or conversation.

## 5. AI design

| Decision | How it works in the code | Why |
| --- | --- | --- |
| **On device only** | `LocalFirstSuggestionEngine` calls Apple's `FoundationModels` (`LanguageModelSession`). No AI request leaves the phone. | Journal text is sensitive. It also costs nothing and works offline. |
| **Always works** | If the model is unavailable or fails, guided templates built from the person's own words answer instead. | No core task depends on AI. |
| **Says why** | `GuestFallbackReason` has six cases (device not eligible, Apple Intelligence off, model not ready, needs iOS 26, unavailable, didn't answer). Each is shown as one short line. | Honest about what produced the text. |
| **Shows the source** | "Suggested on this iPhone by Apple Intelligence" or "Guided prompts, not a personal analysis" on every suggestion. | The person can tell their words from the AI's. |
| **Suggests, never decides** | Suggestions are only applied after an explicit tap (Use this, Copy, I said it). Edits can be undone. | The person keeps authorship. |
| **No mind reading** | Their reply gets **two possible readings**, plus *Neither fits*. The person picks one before getting reply ideas. | A model can't know the other person's motive. Two guesses keep it a choice. |
| **One request, many styles** | Shorter, Warmer and More direct come with the same suggestion, so switching style is instant. ↻ is the only thing that asks again. | Fast, and fewer model calls. |
| **Inputs checked** | Too few words to reflect on get one prompt ("Add what happened and how it felt") instead of a model call. Model wording options are validated before they are shown. | Avoids confident nonsense. |

## 6. Privacy and safety

- The guest app never configures Firebase or analytics. This is checked by `AppBootstrap` tests.
- SwiftData files use iOS data protection.
- Export is plain text that the person shares themselves. Delete all removes entries, reflections, conversations, drafts and receipts in one transaction.
- Log in exists only for people who used the earlier app. It uses a separate, named Firebase app restricted to the Dev project. It copies their old entries onto this iPhone and can delete the old cloud account; nothing new is uploaded.

## 7. Quality

- **311 unit tests:** stores and migrations, ViewModels, the AI fallback, Talk, the guide and export.
- **28 UI tests:** each user story's main path, the keyboard at the largest text size, and accessibility audits.
- **Copy lint:** `GuestCopyLintTests` enforces the [screen content guidelines](../design/screen-content-guidelines.md) (length limits, one main action, banned wording).
- **User stories:** [user-stories.md](user-stories.md) maps every Given/When/Then to the test behind it.
- **Not yet checked:** a physical iPhone, VoiceOver end to end, the iOS 17/18 fallbacks, and dark mode.

## 8. Where to read next

- [MVP definition](mvp-definition.md) · [User stories](user-stories.md) · [Screen content guidelines](../design/screen-content-guidelines.md)
- [Architecture](../engineering/architecture.md) · [Local-first transition plan](../superpowers/plans/2026-10-23-local-first-transition.md)
- [Agent collaboration log](../agent-collaboration-log/README.md): every design decision and review, by date
