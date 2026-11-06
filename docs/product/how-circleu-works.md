# How CircleU works: three versions, two apps in one project

Written 6 November 2026 from a full read of the source on `main`. It covers four things:
- what each version does;
- which folders belong to which version;
- how data and AI move through the app;
- whether Firebase is still needed.

For screens, see the [final screens](../design/final-screens-2026-11-06/README.md).

## 1. Three versions, two apps

| | **Version 1** · first MVP | **Version 2** · guest-first rebuild | **Version 3** · current redesign |
| --- | --- | --- | --- |
| App | **Legacy app**: what every Release build opens | **Guest app**: opened only in Debug and the `CircleU Guest Review` scheme | **The same guest app**, redesigned |
| Tabs | Home · Journal · Tips · Circle · Profile | Today · Journal · Practice | Write · Journal · Talk |
| Account | Required (Firebase Auth) | None; Log in only to recover old data | Same |
| Storage | Local caches plus Firestore sync | SwiftData on this iPhone | Same, plus outcome turns and the Relationship context |
| AI | Cloud Gemini (removed 4 Nov), then Apple Intelligence | Apple Intelligence with a guided fallback | Plus an input check, fallback reasons, reply readings and a reply prompt |
| Coaching | Live Coach | Staged Practice (Prepare → Refine → Their reply) | Talk thread, moment timeline, How did it go?, step-by-step guide |

Versions 2 and 3 are not separate apps. Version 3 changed version 2's files in `Features/GuestJournal/` and `Services/GuestJournal/` and added new ones, so the two can't be split by folder.

The switch between the legacy and guest apps is [`AppStartup`](../../Circleu/App/AppStartup.swift). Guest mode only exists in Debug, and it never configures Firebase or analytics. This keeps the data of testers who have version 1 from TestFlight safe while the guest app is built and checked.

```text
CircleuApp.init
 └─ AppStartup.resolve()
     ├─ .existingApp  → Firebase + analytics → ContentView → RootView (5 tabs)      [version 1]
     └─ .guestJournal → no Firebase → GuestRootView → Welcome → Write/Journal/Talk  [versions 2 + 3]
```

## 1a. Folder map

Every folder is under `Circleu/`. **Legacy** means only the version 1 app uses it. **Guest** means versions 2 and 3. **Shared** means both use it.

| Folder | Belongs to | What it holds | Last real change |
| --- | --- | --- | --- |
| `App/` | Shared | `CircleuApp`, `AppStartup` (the switch), `ContentView` and `RootView` (version 1's tab shell) | Oct 2026 |
| `Features/GuestJournal/` | **Guest** | Every guest screen and ViewModel: Welcome, Write, Reflect, Journal, moment timeline, Talk, guide, Settings, Log in recovery | **Nov 2026 (version 3)** |
| `Services/GuestJournal/` | **Guest** | SwiftData store (schema V1–V6), drafts, tags, conversation turns, suggestion engine, dictation, legacy import, account recovery | **Nov 2026 (version 3)** |
| `Engines/` | Shared | `ReflectionEngine` (Apple Intelligence and local reflection) and `TranscriptQuality`, used by both apps; `CommunicationCoachEngine` and the rest are legacy | Nov 2026 (Gemini removed) |
| `Models/` | Mostly legacy | Version 1 data shapes. The guest app reuses `AIReflectionResult` and `TipsPracticeSession` only to read old data | Jun 2026 |
| `Services/` (top level) | Legacy, except one file | Firebase Auth, Firestore sync, circles, analytics, recorder, CloudKit notes. The guest app uses `FirebaseRuntime` for Log in recovery only | Nov 2026 |
| `Stores/` | Legacy | `ObservableObject` stores for journal, quests, rewards, tips, circles and the session | Oct 2026 |
| `Features/Home`, `Recording`, `Reflection`, `Journal`, `Tips`, `Circle`, `Profile`, `Onboarding` | Legacy | Version 1 screens | Jun–Jul 2026 |
| `Components/`, `Design/` | Legacy | Version 1 shared UI and the liquid-glass kit (`PinguGlassKit`) | Jun–Oct 2026 |
| `PreviewSupport/` | Legacy | Preview data | Jun 2026 |
| `Assets.xcassets/` | Shared | Both apps' art. The `Guest…` images are the Podo set (version 3) | Nov 2026 |

Test targets: `CircleuTests/` mixes both. Files named `Guest…` test the guest app, the rest test version 1. `CircleuUITests/` tests only the guest app.

### Is Firebase still needed?

Yes, for two reasons, though not for the guest app's everyday use:
1. **Release builds still open version 1.** TestFlight testers sign in and their data syncs through Firestore. Removing Firebase would break the app they have installed.
2. **Log in in the guest app** uses a separate, named Firebase app (Dev project only). It copies a tester's old entries onto the iPhone and can delete the old cloud account.

Firebase can go once two things are true: Release opens the guest app, and testers have had a chance to recover their data. That's when the legacy folders above can be deleted, keeping only the recovery path. The [transition plan](../superpowers/plans/2026-10-23-local-first-transition.md) sets the order.

### Why the folders aren't regrouped by version

- **Versions 2 and 3 share files,** so a `v2/` and `v3/` split can't exist.
- **Moving the legacy folders into a `Legacy/` group** would touch hundreds of paths. Git blame and merges with the team repository would get harder, and the project's rules ask for no bulk renaming.
- **The clean step is deletion,** once Firebase can go (above). Until then, this map, the `Guest` prefix and `AppStartup` mark the line.

## 2. Version 1: the team TestFlight app

The first version was built for the Apple Foundation Program. It is still what Release builds open.

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

**Why the guest app exists (version 2).** Usability sessions and the owner's review (23–24 October) found four problems:
- the account wall came before any value;
- Circles and rewards pulled attention away from reflection;
- sensitive journal text went to the cloud;
- Live Coach was a separate tool, not linked to what the person had written.

The approved direction is **guest-first, local-only, three tabs**. See the [MVP definition](mvp-definition.md).

## 3. The guest app (versions 2 and 3), flow by flow

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

**Which version added each flow:**
- **Version 2** built Welcome, Write, Reflect, Journal (search, calendar, tags), Settings, Log in recovery, the data layer and the Practice home.
- **Version 3** added the moment timeline, Talk (replacing staged Practice), *How did it go?*, the guide and the Relationship context.
- **Version 3** also restyled every screen (warm glass, Podo) and added the AI input check and fallback reasons.

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
