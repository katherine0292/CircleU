# Guest app user stories

Historical prototype evidence, before native alignment: [Today review 18](../design/figma-today-layout-review-18/README.md) reuses scene artwork and groups writing, prompts and voice while preserving fixed footers. That review supplied player/geometry evidence only; native alignment is now covered by T8–T10 and J7.

Updated 31 October 2026. Start with the [product brief](overview.md) and [MVP register](mvp-definition.md); use the [flow checklist](flow-status-checklist.md) for delivery status. Existing stories describe the native guest/review configuration, not the standard Release app. **P7, P8 and S9 are proposed native criteria supported by a partial browser prototype, not implemented behaviour.** Existing quoted copy describes the native baseline; future on-screen wording must follow the [screen content guidelines](../design/screen-content-guidelines.md).

## How to read this

- **Story:** "As a [user], I want [goal], so that [benefit]."
- **Screen and states:** where the story happens, and the states it must handle. The states are empty, filled, in progress, error and permission denied, where relevant.
- **Criteria:** Given/When/Then lines for the behaviour and relevant failure states. Each line names its test in the **Test** column:
  - **Unit** is a repo test in `CircleuTests/` (`XCTestClass.testName`), run by the full `xcodebuild test`.
  - **UI** is an XCUITest in `CircleuUITests/`, run with the `CircleuUITests` scheme (see "Running the tests" below). Each UI test starts from an empty guest journal (Debug-only `-CircleUResetGuestData`).
  - **No test** means nothing checks the line.
- **Proposed / no native test** means an acceptance target, not a test that exists or passed. Browser evidence is separately scoped.
- **(partial)** means the test checks part of the line; the note says which part.
- **Users:**
  - **Person** is anyone using the guest journal.
  - **Returning person** used the earlier CircleU app or had an account.

## 1. Welcome

**W1.** As a person, I want to start writing without making an account, so that my words stay on this iPhone.
Screen: Welcome (three pages) → Today. States: first launch (empty), returning launch.

| # | Given / When / Then | Test |
| --- | --- | --- |
| W1.1 | Given a first launch, when the app opens, then Welcome shows three illustrated pages, starting with "Something on your mind?", with Skip and Next. | UI (partial: the art is checked on screenshots) `GuestStatesUITests.testWelcomePagesNextAndSkip` |
| W1.2 | Given Welcome, when I tap Get started, then Today opens and Welcome doesn't appear on later launches. | UI `GuestStatesUITests.testWelcomeShowsOnlyUntilGetStarted` |
| W1.3 | Given I open the guest journal without logging in, when it loads, then Firebase isn't contacted. | Unit `GuestSignInTests.testOpeningTheGuestJournalNeverTouchesFirebase` |
| W1.4 | Given a first launch, when the journal opens, then it is empty. | Unit `GuestJournalStoreTests.testFirstLaunchIsEmpty` |
| W1.5 | Given Welcome, when I swipe or tap Next twice, or tap Skip once, then the last page shows "Get started" and "Log in", and Skip isn't shown there. At the largest text size both stay reachable and the words readable. | UI `GuestStatesUITests.testWelcomePagesNextAndSkip`, `GuestStatesUITests.testWelcomeLastPageAtLargestText` |

**W2.** As a returning person, I want to log in from Welcome, so that I can bring in my earlier journal before I start.
Screen: Welcome → Log in. States: filled, in progress, error. Login details are in S5.

| # | Given / When / Then | Test |
| --- | --- | --- |
| W2.1 | Given Welcome, when I tap Log in, then Log in opens with "Continue without logging in". | UI `GuestImportUITests.testWelcomeLogInPreviewCopySignedOutAndDelete` |
| W2.2 | Given I copied my backup from Welcome, when I tap Continue, then Today opens and I'm signed out. | UI `GuestImportUITests.testWelcomeLogInPreviewCopySignedOutAndDelete` |

## 2. Today capture

31 October Figma evidence: [Today review 17](../design/figma-today-flow-review-17/README.md) exercises T1 capture/save/retry, a T2 draft round trip, typed-word retention on dictation cancellation, and T6 optional reflection writing/edit/discard/save/reopen. Reflection starts blank, cannot save empty, and remains separate from original words. These are predefined prototype fixtures with session variables, not fresh native test results, real recording or persistence evidence. Original-word edits after a saved reflection still need a dedicated stale-reflection prototype review (J4.4).

**T1. Typing.** As a person, I want to type what happened and save it, so that it's in my journal.
Screen: Today. States: empty, filled, in progress (saving), error.

| # | Given / When / Then | Test |
| --- | --- | --- |
| T1.1 | Given words in the box, when I tap Save, then the entry appears in Journal and the box clears. | Unit `GuestJournalViewModelTests.testSuccessfulSaveClearsDraftAndShowsEntry` |
| T1.2 | Given saving fails, when the error shows, then my words are still in the box and it says "Couldn’t save. Try again." | Unit `GuestJournalViewModelTests.testFailedSaveKeepsDraftAndShowsError` |
| T1.3 | Given a save is in progress, when I keep typing, then the new words are kept. | Unit `GuestJournalViewModelTests.testTextTypedDuringSaveIsKept` |
| T1.4 | Given the entry saved but file protection failed, when Journal opens, then a notice says so. | Unit `GuestJournalViewModelTests.testSavedButUnprotectedClearsDraftAndShowsNoticeOnJournal` |
| T1.5 | Given Today, when I look at the actions, then there is one Save button and question guidance never edits my words. | UI `GuestTodayUITests.testQuestionGuidancePreservesWordsAndResetsAfterSave` |

**T1-P. Prototype origin.** [Review 20](../design/figma-today-prompts-review-20/README.md) established the non-destructive question picker. Native criteria now live in T8–T10 below; the earlier text-inserting chip behavior is superseded.

**T2. Draft kept.** As a person, I want unsaved words to survive closing the app, so that I never lose a half-written moment.
Screen: Today. States: filled (restored), error (unreadable draft).

| # | Given / When / Then | Test |
| --- | --- | --- |
| T2.1 | Given unsaved words, when the app relaunches, then they are back in the box, and saving clears them. | Unit `GuestEntryEditorViewModelTests.testDraftSurvivesRelaunchAndIsClearedAfterSaving` |
| T2.2 | Given fast typing, when the draft is kept, then the latest text wins. | Unit `GuestFindAndControlTests.testABurstOfTypingIsCoalescedAndTheLatestTextIsKept` |
| T2.3 | Given a draft that can't be read, when Today opens, then it is left untouched, not overwritten. | Unit `GuestEntryEditorViewModelTests.testUnreadableDraftIsLeftUntouched` |

**T3. Voice.** As a person, I want to talk instead of type, so that I can get it out quickly.
Screen: Today (listening). States: empty, in progress (listening), filled.

| # | Given / When / Then | Test |
| --- | --- | --- |
| T3.1 | Given I tap the microphone, when I speak, then the words appear in the box as they're recognised, after anything I typed. | Unit `GuestDictationViewModelTests.testSpokenWordsAppearInTheDraftAsTheyAreRecognised`, `testDictationGoesAfterTypedTextAndKeepsIt` |
| T3.2 | Given I'm listening, when I tap stop, then the words are kept and the final text arrives. | Unit `GuestDictationViewModelTests.testStopKeepsTheWordsAndWaitsForTheFinalText` |
| T3.3 | Given I'm listening, when I tap Save, then listening stops and the words so far are saved. | Unit `GuestDictationViewModelTests.testSavingWhileListeningStopsAndSavesTheWordsSoFar` |
| T3.4 | Given several entries in a row, with and without voice, when the app relaunches, then they are all in Journal. | Unit (partial, same session only) `GuestDictationViewModelTests.testThreeEntriesInARowWithAndWithoutVoice`; UI (relaunch) `GuestVoiceTabsUITests.testThreeEntriesWithAndWithoutVoiceSurviveRelaunch` |

**T4. Microphone denied or unavailable.** As a person who said no to the microphone, I want typing to keep working, so that I'm never stuck.
Screen: Today. States: permission denied, error (can't start). Mocked in the canvas "States" page.

| # | Given / When / Then | Test |
| --- | --- | --- |
| T4.1 | Given microphone or speech access is denied, when I tap the microphone, then it says "Dictation needs microphone and speech recognition access. Turn them on in Settings, or keep typing." and typing works. | Unit `GuestDictationViewModelTests.testDeniedPermissionLeavesTypingAndOffersSettings`; UI `GuestVoiceTabsUITests.testTabsPracticeAndDictationDenied` (denies the system prompt when it shows, then checks the message; the Debug, Simulator-only `-CircleUAssumeOnDeviceSpeech` launch argument gets past the Simulator’s missing on-device speech model) |
| T4.2 | Given no on-device speech support, when I tap the microphone, then it never listens or sends audio. | Unit `GuestDictationViewModelTests.testNoOnDeviceSupportNeverListens` |
| T4.3 | Given dictation can't start, when I tap the microphone, then it says "Dictation couldn’t start. You can keep typing." | Unit `GuestDictationViewModelTests.testStartFailureLeavesTypingAvailable` |
| T4.4 | Given the permission prompt is showing, when I stop, then listening never starts. | Unit `GuestDictationViewModelTests.testStoppingDuringThePermissionPromptNeverStartsListening` |

**T5. Interruptions.** As a person, I want my spoken words kept when something interrupts me, so that a call or a crash doesn't cost me words.
Screen: Today. States: error (interrupted).

| # | Given / When / Then | Test |
| --- | --- | --- |
| T5.1 | Given I'm listening, when a call or audio interruption happens, then the words so far are kept. | Unit `GuestDictationViewModelTests.testInterruptionKeepsTheWordsSoFar` |
| T5.2 | Given I'm listening, when I leave the app, then listening stops and the words are kept. | Unit `GuestDictationViewModelTests.testLeavingTheAppStopsListeningAndKeepsTheWords` |
| T5.3 | Given I cancel dictation, when late results arrive, then only the spoken words are removed and the next dictation isn't affected. | Unit `GuestDictationViewModelTests.testCancelRemovesOnlyTheSpokenWords`, `testLateEventsFromACancelledDictationDontReachTheNextOne` |

**T6. Reflect after saving.** As a person, I want an optional reflection on an entry after I've saved it, so that I can see it differently, without it changing my words or slowing down saving.
Screen: Journal ("Saved to your journal" card) → Reflection review. States: filled (offer), in progress, error, dismissed.

| # | Given / When / Then | Test |
| --- | --- | --- |
| T6.1 | Given I just saved, when Journal opens, then the "Saved" card offers Reflect (Reflect on it) and × (Not now), for that entry only, and Not now closes it. | Unit `GuestSuggestionViewModelTests.testSavingOffersAReflectionOnlyForThatEntryUntilDismissed`, `testFinishingAnOlderReflectionKeepsTheNewerOffer`; UI `GuestTodayUITests.testQuestionGuidancePreservesWordsAndResetsAfterSave` |
| T6.2 | Given I tap Reflect on it and Save reflection, when the entry reopens, then my edits to the reflection are kept apart from my unchanged words. | Unit `GuestSuggestionViewModelTests.testEditedSuggestionIsSavedApartFromTheWords`, `testReflectionAndNextStepAreSavedWithTheWordsAndSurviveReopen`; UI `GuestSuggestionUITests.testReflectionNextStepAndPracticeSuggestions` |
| T6.3 | Given no on-device model, when a suggestion shows, then it is labelled as guided prompts and uses only what I wrote. | Unit (partial, guided engine forced) `GuestSuggestionViewModelTests.testGuidedEngineIsLabelledAndUsesOnlyWhatWasTyped` |
| T6.4 | Given the suggestion fails or I clear every part, when I look, then nothing is added and the entry stays as it is. | Unit `GuestSuggestionViewModelTests.testFailedSuggestionLeavesTheSavedEntryAsItIs`, `testClearingEverythingAddsNothing` |
| T6.5 | Given the entry changed somewhere else, when I save the reflection, then it isn't added and I'm told why. | Unit `GuestSuggestionViewModelTests.testReflectionOnAnEntryChangedMeanwhileIsNotAdded` |
| T6.6 | Given a reflection is open, when I delete all data, then it closes and Journal is empty. | UI `GuestTodayUITests.testDeleteAllClosesAnOpenReflection` |

**T7. Next step.** As a person, I want to choose whether to keep a suggested next step, so that nothing is added without my say.
Screen: Reflection review, Entry. States: filled, done or not done.

| # | Given / When / Then | Test |
| --- | --- | --- |
| T7.1 | Given a suggested step, when I don't add it, then it isn't saved. | Unit `GuestSuggestionViewModelTests.testSuggestedStepIsNotSavedUnlessAdded` |
| T7.2 | Given a saved step, when I mark it done, undo it or remove it, then the entry updates. | Unit `GuestReflectionStoreTests.testNextStepCanBeDoneUndoneAndRemovedWithRevisions`, `testNextStepIsVoluntaryAndReversibleFromTheEntry` |

**T8. Optional question guidance — native alignment approved, 31 October.** Today offers a compact question picker in the writing-card footer, alongside the microphone. Questions guide; they never insert or replace original words.

| # | Given / When / Then | Test |
| --- | --- | --- |
| T8.1 | Given an empty or filled draft, when I open Suggest a question / Change question, then I can choose What happened?, How did it make you feel?, or What would you like to say next?. | UI `GuestTodayUITests.testQuestionGuidancePreservesWordsAndResetsAfterSave` (new native slice) |
| T8.2 | Given a draft, when I select, change, remove or cancel a question, then every original character remains unchanged. | Same UI test |
| T8.3 | Given a successful save and an empty next draft, when I return, then the selected question resets. A failed save retains words and guidance. | Same UI test; `GuestNativeAlignmentTests.testFailedSaveKeepsQuestionAndWords`, `GuestJournalViewModelTests.testTextTypedDuringSaveIsKept` |

**T9. Earlier starter/nudge interaction superseded.** Review 20 replaces automatic sentence starters and the follow-up bubble with T8. Existing helper tests are retained for the older prototype utilities, not evidence of the new screen.

**T10. Visual Today.** Use the accepted window scene above a white writing card; voice activity uses the voice-corner scene. Questions and microphone share the footer. Save remains the one filled primary action. Native navigation, Settings and the avatar picker stay accessible; artwork is decorative and omitted at accessibility sizes.

| # | Given / When / Then | Test |
| --- | --- | --- |
| T10.1 | Given Today, when I write or dictate, then the microphone stays in the composer footer and Save stays above the keyboard. | UI `GuestTodayUITests.testQuestionGuidancePreservesWordsAndResetsAfterSave`; existing voice UI suite |
| T10.2 | Given dictation, when I stop/cancel or choose my Pingu, then listening stops and text handling keeps its existing contract. | UI `GuestStatesUITests.testPinguChoiceIsKeptAndThePickerStopsDictation` |
| T10.3 | Given largest text, when I scroll Today and its question picker, then questions, microphone, avatar and Save remain reachable. | UI `GuestTodayUITests.testTodayAtLargestTextKeepsPromptsAvatarAndSaveReachable`; physical follow-up pending |

## 3. Journal

**J1. Browse.** As a person, I want to see what I've saved, so that I can look back.
Screen: Journal. States: empty, filled, error.

| # | Given / When / Then | Test |
| --- | --- | --- |
| J1.1 | Given nothing saved, when Journal opens, then the dusk scene (Pingu with an open journal) and "Nothing saved yet." show. | UI (partial, checks the text, not the art) `GuestFindControlUITests.testSearchCalendarDraftExportAndDeleteAll`, `GuestStatesUITests.testEmptyJournalPracticeAndCalendarDay` |
| J1.2 | Given the journal can't be read, when Journal opens or refreshes, then it says "Couldn’t open your journal. Try again." and never shows an empty journal. | Unit `GuestJournalViewModelTests.testFailedLoadIsAnErrorNotAnEmptyJournal`, `testFailedRefreshIsAnErrorNotAnEmptyOrDeletedJournal` |
| J1.3 | Given the store file is corrupt or missing, when it opens, then it reports an error and keeps the file's bytes. | Unit `GuestJournalStoreTests.testCorruptStoreIsAnErrorAndBytesArePreserved`, `testVanishedStoreFileIsAnError` |

**J7. Optional context and feeling tags — native alignment approved, 31 October.** Each saved entry can hold one user-selected context and one feeling, independently. Tags never rewrite original words or replace a suggested reflection feeling. Native implementation and scoped verification are recorded in the [alignment report](../qa/native-alignment-2026-10-31/README.md).

| # | Given / When / Then | Test |
| --- | --- | --- |
| J7.1 | Given an old or new untagged entry, when loaded, then tags remain unset and no feeling is inferred. | `GuestEntryTagTests.testV5MigrationPreservesEntriesReflectionConversationAndDraftsWithNoInventedTags` |
| J7.2 | Given the picker, when Done succeeds, then the left context chip and right labelled feeling portrait reflect the independent selections. | `GuestJournalTagsUITests.testTagsSaveCancelClearAndReopen` |
| J7.3 | Given saved tags, when I change or deselect them, then Done changes only tags and Cancel leaves saved values unchanged. | Same UI test; `GuestEntryTagTests.testTagsSurviveReopenAndWordEditsAndCanBeClearedIndependently` |
| J7.4 | Given a failed, stale or deleted-entry save, when Done runs, then it does not overwrite newer words or recreate the entry. | `GuestEntryTagTests.testStaleDeletedAndFailedTagSavesNeverOverwriteSavedWords`; `GuestNativeAlignmentTests.testTagPickerRejectsStaleSaveAndKeepsChoicesWithoutOverwritingWords`, `testTagPickerFailedSaveKeepsChoicesAndCanRetry` |
| J7.5 | Given largest text, when choosing tags, then labels and Done remain reachable with visible selections and VoiceOver labels. | `GuestJournalTagsUITests.testTagPickerAtLargestText`; physical VoiceOver follow-up pending |
| J7.6 | Given persisted tags, when I reopen, edit, search, export or delete data, then tags follow their entry. | `GuestEntryTagTests.testTagsSurviveReopenAndWordEditsAndCanBeClearedIndependently` |
| J7.7 | Given history, when browsing, then cards group by creation day with time, words, optional context and feeling. Long words use a bounded preview; detail/edit retain the complete entry. | `GuestNativeAlignmentTests.testJournalGroupingUsesCreationDayRatherThanLastEdit`; `GuestJournalTagsUITests.testLongEntryAtLargestTextKeepsTagActionsAndFullWords` |

**J2. Search.** As a person, I want to search my entries, so that I can find a moment again.
Screen: Journal (search). States: filled (results), empty (no results).

| # | Given / When / Then | Test |
| --- | --- | --- |
| J2.1 | Given entries, when I search, then words, reflections and steps match, ignoring case and accents. | Unit `GuestFindAndControlTests.testSearchCoversWordsReflectionAndStepIgnoringCaseAndAccents` |
| J2.2 | Given no match, when I search, then it says "No entries match “…”." | UI `GuestPolishUITests.testPinguArtScreens` |

**J3. Calendar.** As a person, I want a month view, so that I can see when I wrote.
Screen: Journal → Calendar. States: filled, empty day.

| # | Given / When / Then | Test |
| --- | --- | --- |
| J3.1 | Given entries, when the calendar opens, then each day shows how many entries it has. | Unit `GuestFindAndControlTests.testCalendarLaysOutTheMonthAndCountsEntriesPerDay` |
| J3.2 | Given another month, when I tap Go to today, then the current month shows. | UI `GuestFindControlUITests.testSearchCalendarDraftExportAndDeleteAll` |
| J3.3 | Given a day with nothing, when I tap it, then it says "Nothing written that day." | UI `GuestStatesUITests.testEmptyJournalPracticeAndCalendarDay` |

**J4. Edit.** As a person, I want to edit a saved entry, so that it says what I meant.
Screen: Entry → Edit. States: filled, in progress, error (stale, deleted).

31 October prototype evidence: [Journal review 16](../design/figma-journal-flow-review-16/README.md) applies J4.2 to Back and tab exits across four entry editors. The player verified the work-entry draft, Keep editing, then Practice → confirmation → Discard → Practice. Search-based wording/tag edits returned to the same result; calendar-based entry navigation retained the selected date. J2/J3 checks also covered populated/empty query fixtures, empty day/month, and one-to-two entry counts after a fixture save. These are bounded Figma session checks, not fresh native test results or relaunch persistence evidence.

| # | Given / When / Then | Test |
| --- | --- | --- |
| J4.1 | Given I edit and save, when the entry reopens, then the change is kept, including after a relaunch. | Unit `GuestEntryEditorViewModelTests.testSaveUsesOpenedRevisionAndClearsChanges`, `testSaveAndEditPersistAcrossRelaunch` |
| J4.2 | Given unsaved edits, when I leave, then the app asks before discarding. | Unit (partial, checks unsaved changes, not the dialog) `GuestEntryEditorViewModelTests.testEditingMarksChangesSoLeavingAsksFirst`; UI `GuestFlowUITests.testWriteSaveRelaunchEditDiscard` |
| J4.3 | Given the entry changed or was deleted elsewhere, when I save, then my text is kept with a clear message. | Unit `GuestEntryEditorViewModelTests.testStaleAndDeletedEntriesKeepTextWithClearMessages` |
| J4.4 | Given an entry with a reflection, when I edit the words, then the reflection is marked as earlier. | Unit `GuestReflectionStoreTests.testEditingTheWordsMarksTheReflectionAsEarlierAndRemovingItKeepsTheWords` |

**J5. Delete an entry.** As a person, I want to delete an entry and choose what happens to its practice message, so that I control what's kept.
Screen: Entry (delete dialog). States: in progress, error.

| # | Given / When / Then | Test |
| --- | --- | --- |
| J5.1 | Given an entry with a message, when I delete it, then I can keep the message on its own or delete both. | Unit `GuestPracticeStoreTests.testDeletingAnEntryCanKeepItsMessageOnItsOwn`, `testDeletingAnEntryCanDeleteBoth`; UI `GuestPracticeUITests.testPracticeDirectFromEntryAndDeleteChoices` |
| J5.2 | Given delete fails, when the error shows, then the entry and message are unchanged. | Unit `GuestPracticeStoreTests.testFailedEntryDeleteKeepsEntryAndMessage` |
| J5.3 | Given a deleted entry, when an old screen saves, then it doesn't come back. | Unit `GuestJournalStoreTests.testUpdateAfterDeleteDoesNotResurrectEntry` |

**J6. Icons over labels.** As a person, I want Journal to show status and actions as pictures, so that my own words stand out.
Screen: Journal, Calendar, Entry. States: filled, one day chosen. Mocked in the canvas row "J · Simpler Journal" (JS1–JS3).

| # | Given / When / Then | Test |
| --- | --- | --- |
| J6.1 | Given entries, when Journal opens, then each row shows a date tile, the words, icons for a reflection, a next step (a tick when done) and a practice message, and the time; VoiceOver reads the icons in words. | No test (layout checked on screenshots; VoiceOver speech not checked) |
| J6.2 | Given I just saved, when Journal opens, then the "Saved" card is one row: Pingu, "Saved", Reflect and ×. | UI (partial, checks "Saved" and Reflect, not the one-row layout) `GuestTodayUITests.testQuestionGuidancePreservesWordsAndResetsAfterSave` |
| J6.3 | Given the calendar, when I choose a day, then a day chip with × replaces "Showing …" and Show all, each day shows up to three dots, and Go to today is an icon. | UI (partial, checks the day chip and Go to today, not the dots) `GuestFindControlUITests.testSearchCalendarDraftExportAndDeleteAll` |
| J6.4 | Given an entry, when it opens, then a compact date is the inline title and the time below exposes the full creation timestamp to accessibility, Edit is a pencil, Delete entry is in the ••• menu, and the reflection, feeling and next step show as icons with spoken names. | UI (partial, checks the actions, not the title or every spoken name) `GuestPracticeUITests.testPracticeDirectFromEntryAndDeleteChoices`, `GuestSuggestionUITests.testReflectionNextStepAndPracticeSuggestions` |

## 4. Practice

**P1. Practise from an entry.** As a person, I want to practise what to say about an entry, so that I'm ready for the conversation.
Screen: Entry → Practice message. States: empty, filled, in progress, error.

| # | Given / When / Then | Test |
| --- | --- | --- |
| P1.1 | Given an entry, when I tap Practice what to say and save, then the message is tagged "From: …" and survives reopening. | Unit `GuestPracticeStoreTests.testStandaloneAndLinkedMessagesSurviveReopen`, `testTagShowsSourceEntryOrOnItsOwn`; UI `GuestPracticeUITests.testPracticeDirectFromEntryAndDeleteChoices` |
| P1.2 | Given the source entry was deleted, when I save a message from it, then my words stay. | Unit `GuestPracticeViewModelTests.testDeletedSourceEntryKeepsWords` |

**P2. A message on its own.** As a person, I want to practise without an entry, so that I can prepare for something I haven't written about.
Screen: Practice. States: empty, filled, error.

| # | Given / When / Then | Test |
| --- | --- | --- |
| P2.1 | Given no messages, when Practice opens, then the shared Pingu start card and "Nothing practised yet." show; decorative art is omitted at accessibility text sizes. | UI (partial, checks the text, not the art) `GuestStatesUITests.testEmptyJournalPracticeAndCalendarDay` |
| P2.2 | Given Prepare has no wording, Continue is off; after entering words and continuing to Refine, Save stores them and shows the saved conversation. | Unit `GuestPracticeViewModelTests.testNewMessageNeedsWordingThenSavesAndShowsAsSaved` |
| P2.3 | Given saving fails, when the error shows, then my words are kept. | Unit `GuestPracticeViewModelTests.testFailedSaveKeepsWordsAndShowsError` |
| P2.4 | Given saved messages, when Practice opens, then an ice-toned Pingu card with one blue action strip starts a new message and each message shows as a bubble with a journal icon (if it came from an entry) and its date, with no header. | UI (partial, checks the button and text) `GuestPracticeUITests.testPracticeDirectFromEntryAndDeleteChoices` |
| P2.5 | Given Prepare, when I choose a scene and tone or expand Situation and Goal, those values remain part of my draft; existing details reopen expanded. | Automated scene/detail interaction not yet covered; draft coding covered by `GuestConversationTests.testDraftRoundTripPreservesPendingReplyAndOriginalWords` |
| P2.6 | Given Refine and the software keyboard are open, when I write or scroll at default or largest text, then Save stays fully above the keyboard; saving dismisses the keyboard and preserves my wording. | UI `GuestPracticeUITests.testPracticeSaveStaysAboveKeyboard`, `testPracticeSaveStaysAboveKeyboardAtLargestText` |

**P3. Copy and edit.** As a person, I want to copy or edit a message, so that I can send it myself or improve it.
Screen: Practice message. States: filled, error (stale).

| # | Given / When / Then | Test |
| --- | --- | --- |
| P3.1 | Given a message, when I tap Copy (the icon in the bubble, or the button once saved), then it is copied and nothing is saved or sent; "Copied. Not saved or sent." shows (or "Copied. Not sent." once saved). | Unit `GuestPracticeViewModelTests.testCopyDoesNotSave`; UI `GuestPracticeUITests.testPracticeDirectFromEntryAndDeleteChoices` |
| P3.2 | Given a saved message, when I edit and save, then the same message updates; if it changed elsewhere, my words are kept with an explanation. | Unit `GuestPracticeViewModelTests.testEditingASavedMessageUpdatesTheSameMessage`, `testStaleEditKeepsWordsAndExplains`; UI (saved edit, reopen and no duplicate; concurrent edits remain unit-tested) `GuestPracticeUITests.testCopyEditAndDiscardKeepTheRightWording` |
| P3.3 | Given delete fails, when the error shows, then the message is kept. | Unit `GuestPracticeViewModelTests.testFailedMessageDeleteKeepsIt` |
| P3.4 | Given a saved message, when I look at it, then my words are a blue prepared-wording bubble labelled Saved · not sent, Copy is primary, Continue conversation is secondary, and Edit (pencil) and Delete message (in the ••• menu, asks first) are in the toolbar. | UI `GuestPracticeUITests.testPracticeDirectFromEntryAndDeleteChoices` |
| P3.5 | Given copied wording, when I type, clear it or undo a suggestion, then the Copied confirmation clears; copying again confirms the new wording without saving. | Unit `GuestPracticeViewModelTests.testEditingCopiedWordingClearsConfirmationUntilCopiedAgain`, `testClearingCopiedWordingClearsConfirmationAndDisablesCopy`, `testUndoingACopiedSuggestionClearsConfirmation`; UI (typing and visible confirmation) `GuestPracticeUITests.testCopyEditAndDiscardKeepTheRightWording` |
| P3.6 | Given unsaved edits to a saved message, when I tap Back, then Keep editing preserves those edits and Discard leaves the saved message unchanged. | UI `GuestPracticeUITests.testCopyEditAndDiscardKeepTheRightWording` |

**P4. Practice draft and suggestions.** As a person, I want my unfinished message kept and optional wording ideas, so that I can come back and get unstuck.
Screen: Practice → Continue your draft. States: filled (restored), in progress, error.

| # | Given / When / Then | Test |
| --- | --- | --- |
| P4.1 | Given an unsaved message, when the app relaunches, then Continue your draft restores it, and once saved it isn't offered again. | Unit `GuestFindAndControlTests.testPracticeDraftSurvivesRelaunchAndIsClearedBySaving`, `testSavedPracticeDraftIsNeverOfferedAgain` |
| P4.2 | Given a suggestion, when I choose it from the swipeable tone cards, then it fills the wording and can be undone. | Unit `GuestSuggestionViewModelTests.testPracticeSuggestionsFillWordingOnlyWhenChosenAndCanBeUndone`; UI `GuestSuggestionUITests.testReflectionNextStepAndPracticeSuggestions` |
| P4.3 | Given a suggestion fails, when the error shows, then my wording is kept. | Unit `GuestSuggestionViewModelTests.testFailedPracticeSuggestionKeepsWording` |

**P5. Continue a conversation.** As a person, I want to add their reply or more context without losing earlier wording.
Screens: Prepare → Refine → Their reply → Refine → Conversation. States: empty, editable, saved, unreadable, stale revision.

| # | Given / When / Then | Test |
| --- | --- | --- |
| P5.1 | Given prepared wording, when I paste a reply and/or context and continue, previous wording and attributed additions stay in the timeline; the next draft starts empty and nothing is sent. | Unit `GuestConversationTests.testReplyPreservesAttributedHistoryAndSurvivesReopenAndExport`; UI `GuestPracticeUITests.testConversationAndVoiceReviewPersistWithoutDuplicating` |
| P5.2 | Given a saved conversation, when I continue and save, the same ID and journal link remain, the revision advances, and history survives reopening, export and search. | Unit `GuestConversationTests.testConversationReopensAndStaleUpdateCannotReplaceHistory`, `testReplyPreservesAttributedHistoryAndSurvivesReopenAndExport`; UI P5.1 |
| P5.3 | Given a V4 practice record, when the V5 store opens, its original fields and revision survive with no invented turns; unreadable conversation data shows an error. | Unit `GuestConversationTests.testV4MigrationPreservesOldMessageWithoutInventingHistory`, `testUnreadableConversationIsAnErrorInsteadOfEmptyHistory` |
| P5.4 | Given only added context, when guided suggestions are requested, no received reply is invented; actual replies are not repeated as my voice. | Unit `GuestConversationTests.testContextOnlyDoesNotInventAnIncomingReply`, `testGuidedReplyDoesNotEchoTheirWordsOrMetadataAsMine` |
| P5.5 | Given a new unfinished conversation, when encoded/restored, original words, pending reply/context and turns remain; old drafts still decode. Saved-conversation edits require explicit Save. | Unit `GuestConversationTests.testDraftRoundTripPreservesPendingReplyAndOriginalWords`, `testBlankReplyDoesNotEraseCurrentWordingAndOldDraftDecodes` |

**P6. Review voice input.** As a person, I want to speak, correct the transcript and choose when to insert it.
Screens: Prepare / Refine / Their reply → Voice input. States: idle, requesting permission, listening, finishing, review, denied, unavailable, interrupted.

| # | Given / When / Then | Test |
| --- | --- | --- |
| P6.1 | Given existing wording, when I record, stop and use the reviewed transcript, it appends without replacing existing words. | UI (scripted engine) `GuestPracticeUITests.testConversationAndVoiceReviewPersistWithoutDuplicating`; owner confirmed physical Record → Stop → Use text on 27 October; appending to existing text remains simulator-tested |
| P6.2 | Given cancelled recording, when a late recognition callback arrives, it cannot modify the transcript or selected field. | Unit `GuestVoiceReviewTests.testTranscriptIsReviewedAndCancelledLateEventsAreIgnored` |
| P6.3 | Given denied permission, when access fails, typing and transcript review remain available. | Unit `GuestVoiceReviewTests.testDeniedPermissionKeepsTypingAvailable`; real permission/VoiceOver checks pending |

## Proposed Practice extensions — M09 / F23

The owner accepted planning and prototype review. These criteria must be reviewed before native implementation; existing P1–P6 remain the baseline. Evidence: [browser review](../../Prototypes/CircleUVisualPrototype/PracticeFeedbackReview/README.md), [Refine review](../agent-collaboration-log/2026-10-28-refine-prototype-focus.md) and [AI design](../superpowers/specs/2026-10-27-practice-ai-feedback-design.md). Fixed examples do not establish model quality.

**P7.** As a person, I want helpful feedback and editable wording that preserves my intent, so that I can choose words that still sound like me.
Screens: Prepare → Refine → conversation. States: empty, ready, loading/cancelled, result, edited/stale, unavailable and failure. **Proposed; partial browser prototype.**

| # | Given / When / Then | Test / evidence needed |
| --- | --- | --- |
| P7.1 | Given my wording and chosen tone, when feedback succeeds, then at most two grounded observations and one editable rewrite appear separately from the original, with a truthful source label; no new facts, commitments or guessed motives are added. | No native test; fixed browser examples only. Provider evaluation with invented scenarios required |
| P7.2 | Given a rewrite, when I edit and Use it, then only working wording changes; no save/send occurs. Undo restores the prior wording only while that undo is valid; a newer manual edit or request invalidates it. | No native test; browser review 06 checked new-request Undo invalidation after success, cancellation and error; earlier Use/edit checks remain partial evidence |
| P7.3 | Given changed words, tone, context or included style, when the input changes, then an older result cannot be applied as current. Empty wording cannot be used/saved/copied as a valid message. | No native test; plan revision/cancellation tests and blank-input UI checks |
| P7.4 | Given failure, offline status or cancellation, when review ends, then original/draft words remain editable and manually saveable; any guided fallback is explicit and labelled. | No native test for new feedback; browser failure fixtures only |
| P7.5 | Given their actual reply or added context and no draft, when I ask for a reply, then current-turn intent is required and the proposed reply preserves that intent; previous prepared words are never labelled as sent. | No native test; browser reply-intent fixture only; integrate with P5 history tests |
| P7.6 | Given voice input, when I choose Use text after transcript review, then reviewed text is used under the same rules as typing; no recording is included in AI review. | Existing P6 tests cover transcript handling only; new payload exclusion test pending |
| P7.7 | Given keyboard, largest text, VoiceOver or reduced motion, when I review/edit/apply feedback, then labels, errors, focus and actions remain reachable; decoration never blocks the editor. | No native test; review 07 browser editor/clarification/style larger-text layouts inspected and affected actions exercised. Artwork hides at larger text. This is not native accessibility, swipe or keyboard verification |
| P7.8 | Given I am reviewing a first message, when feedback asks for context, then I can answer while staying in that review; no received reply is introduced and my original draft remains intact. A reply review likewise retains its own intent and attribution. | No native test; browser review 06 passed original/reply clarification, validation, exact context preview and Back on 29 October; see [review](../design/refine-story-review-2026-10-29.md#resolution--browser-review-06) |

**P8.** As a person, I want to control an optional online review, so that I know which words leave my phone.
Screen: selected-text confirmation → Refine. States: local default, review payload, explicit send, loading/cancel, failure, stale response. **Proposed; no live provider.**

| # | Given / When / Then | Test / evidence needed |
| --- | --- | --- |
| P8.1 | Given a new request, when confirmation opens, then the exact selected wording/context is shown and style sharing starts unchecked; nothing is uploaded until I explicitly send. | No native test; browser confirmation exercised without network |
| P8.2 | Given a selected payload, when sent, then it includes only the reviewed text and explicitly included preferences; no audio, unrelated journal entries or hidden conversation history is added. | No native test; request-contract and transport tests required |
| P8.3 | Given online review is available, when privacy/source text appears, then it accurately describes that request's processing; a blanket “Not uploaded” claim cannot describe an online request. Local writing remains available without consent. | No native test; reconcile S1 and content rules before activation |
| P8.4 | Given cancellation, backgrounding, a newer request or an edited draft, when a late response arrives, then it cannot overwrite current work; retries require deliberate action and rechecking the payload. | No native test; async race and cancellation tests required |

Activation gate: provider eligibility, retention, server-side credentials, abuse controls, budget, truthful privacy copy and release configuration require the [AI design](../superpowers/specs/2026-10-27-practice-ai-feedback-design.md) review. Passing browser criteria alone cannot open this gate.

## Proposed message-first entry — M04/M09 — F10/F23

**P9.** As someone preparing for a difficult conversation, I want to start with my words and ask for guidance only when needed, so that I can reach useful wording without repeating myself. Direction and short design approved 30 October; native criteria below remain **proposed**, with partial browser review 08 evidence recorded after the table. See the [short design](../superpowers/specs/2026-10-30-message-first-practice-design.md).

| # | Given / When / Then | Evidence needed |
| --- | --- | --- |
| P9.1 | Given direct Practice entry, when I begin, then I can type or choose voice without a journal entry, account, profile or required situation/tone form. | New prototype walkthrough; native UI test pending |
| P9.2 | Given existing wording, when I open optional guidance and return, then my wording survives and I need not repeat it. | Back/cancel walkthrough and draft-preservation test pending |
| P9.3 | Given no wording, when I choose Help me get started, then I can provide an outcome and optional context; they remain labelled as intent/context, never as a message I wrote or sent. Blank input cannot start generation. | Empty-input/intent-only confirmation and result tests pending |
| P9.4 | Given wording or explicit intent, when I request review, then only selected information is confirmed for an online request; completing guidance alone sends nothing. | Prototype walkthrough plus eventual P8 transport tests pending |
| P9.5 | Given a suggestion, when I apply, copy or save it, then each action has its separate effect; returning to the editor does not require entering the same message again. | Integrate with P3/P7.2; new route tests pending |

30 October review 08 provides partial browser evidence for P9.1–P9.5: typed entry without setup, guidance Back/Continue preservation, blank validation, intent-labelled confirmation/result, no generation on guidance Continue, selected context and separate Use/Copy/Save actions. See [checks and screenshots](../../Prototypes/CircleUVisualPrototype/PracticeFeedbackReview/README.md). No native P9 tests, real voice integration into this route, durable storage or provider tests were added. P5 conversation attribution, P6 voice review, P7 feedback/stale results and P8 consent continue to apply. The showcase entry choice does not change the app's default launch tab.

## 5. Settings

S1 describes the current guest baseline. If P8 is implemented, revise the privacy summary and its tests before enabling online requests; do not reuse a blanket local-only claim for cloud processing.

**S1. Privacy.** As a person, I want to know where my words are kept, so that I can trust the app.
Screen: Settings → "Kept on this iPhone" sheet. States: filled, sheet open.

| # | Given / When / Then | Test |
| --- | --- | --- |
| S1.1 | Given Settings, when I look, then the "Kept on this iPhone" chip and "Not uploaded or synced." show, and tapping the chip opens a sheet with one icon row each for dictation, backups, restore and exports. | UI `GuestStatesUITests.testPrivacySummaryAndLearnMore` |
| S1.2 | Given the journal opens, when files are written, then iOS file protection is applied, and the journal won't open if it can't be applied. | Unit (partial, protection calls are injected) `GuestJournalStoreTests.testProtectionIsAppliedToFolderStoreAndSidecars`, `testOpenFailsIfProtectionCannotBeApplied` |

**S2. Export.** As a person, I want a copy of everything I wrote, so that I can keep it elsewhere.
Screen: Settings → Your data → share sheet. States: in progress, done, error.

| # | Given / When / Then | Test |
| --- | --- | --- |
| S2.1 | Given entries and messages, when I tap Export my data, then a readable text file holds all of them, with suggestions labelled. | Unit `GuestFindAndControlTests.testExportIsReadableAndCompleteAndLabelsSuggestions`, `testExportFileContainsTheJournal` |
| S2.2 | Given something can't be read, when I export, then it says "Couldn’t prepare the export. Try again." and no partial file is made. | Unit `GuestFindAndControlTests.testExportIsRefusedWhenSomethingCantBeRead` |
| S2.3 | Given the share sheet closes after sharing, when I'm back in Settings, then a Pingu banner says "Export done." (that shared copies aren't deleted is in the privacy sheet, S1.1) | Unit (partial, the model's decision, not the share sheet) `GuestFindAndControlTests.testExportDoneShowsOnlyAfterSharingAndCleanup` |

**S3. Delete all.** As a person, I want to delete everything in the guest journal, so that nothing is left on this iPhone.
Screen: Settings → Your data → confirm. States: in progress, done, error.

| # | Given / When / Then | Test |
| --- | --- | --- |
| S3.1 | Given entries, messages and drafts, when I confirm Delete all data, then all of them are gone and my Pingu resets. | Unit `GuestFindAndControlTests.testDeleteAllRemovesEverythingInTheGuestJournalOnly`; `GuestPinguArtTests.testDeleteAllResetsTheChosenPingu`; UI `GuestFindControlUITests.testSearchCalendarDraftExportAndDeleteAll` |
| S3.2 | Given delete fails partway, when the error shows, then nothing is removed. | Unit `GuestFindAndControlTests.testFailedDeleteAllRemovesNothingIncludingDrafts` |
| S3.3 | Given a screen opened before delete all, when it tries to save, then it can't. | Unit `GuestFindAndControlTests.testAScreenClosedByDeleteAllCantSave` |

**S4. Your Pingu.** As a person, I want to choose my Pingu, so that the app feels like mine.
Screen: Today (the Pingu badge on the scene) or Settings → Your Pingu. States: filled.

| # | Given / When / Then | Test |
| --- | --- | --- |
| S4.1 | Given the picker, when it opens, then all 21 Pingu avatars show with spoken names. | Unit (partial, checks bundled art and names) `GuestPinguArtTests.testAll21AvatarsAndIconsAreBundled`; UI `GuestPolishUITests.testPinguArtScreens` |
| S4.2 | Given I pick a Pingu, when the app relaunches, then the same Pingu shows on Today's badge. | UI `GuestStatesUITests.testPinguChoiceIsKeptAndThePickerStopsDictation` |
| S4.3 | Given I'm dictating, when I tap the Pingu badge, then dictation stops and my words are kept. | UI (partial, checked once the picker closes) `GuestStatesUITests.testPinguChoiceIsKeptAndThePickerStopsDictation` |

**S5. Log in and bring in my backup.** As a returning person, I want to log in once and copy my earlier account's backup, so that my old journal is here without anything new being uploaded.
Screen: Log in → Backup preview → Copied. States: filled, in progress, error (wrong details, offline), done.

| # | Given / When / Then | Test |
| --- | --- | --- |
| S5.1 | Given correct details, when I log in, then I see only that account's backup, copying adds it once, and I'm signed out after. | Unit `GuestSignInTests.testLogInPreviewsOnlyThatAccountsBackupCopiesOnceAndSignsOut`; UI `GuestImportUITests.testWelcomeLogInPreviewCopySignedOutAndDelete` |
| S5.2 | Given wrong details, when I log in, then one generic message shows without saying whether the account exists, and repeated tries back off. | Unit `GuestSignInTests.testFailuresAreGenericSignedOutAndBackOff`; UI `GuestImportUITests.testRealDevRejectsAnInventedAccountGenerically` |
| S5.3 | Given no connection, when I log in, then it says so plainly. | Unit `GuestSignInTests.testOfflineAndUnavailableAreSaidPlainly` |
| S5.4 | Given copying the backup fails, when the error shows, then it says "Couldn’t copy your earlier journal. Nothing was added; try again." and nothing is added. | Unit `GuestSignInTests.testFailedBackupCopyAddsNothingSaysSoAndSignsOut` |
| S5.5 | Given Log in, when it opens, then "Nothing uploaded" and "Signed out after" show as chips, and the detail is behind the (i) "What logging in does" button; after copying, a "Signed out" chip shows. | UI `GuestImportUITests.testWelcomeLogInPreviewCopySignedOutAndDelete` |

**S7. Reset password.** As a returning person who forgot my password, I want a reset link, so that I can log in.
Screen: Log in → Reset password. States: filled, in progress, done, error.

| # | Given / When / Then | Test |
| --- | --- | --- |
| S7.1 | Given an email, when I tap Send reset link, then it says "If an account uses this email, a link is on its way." whether or not the account exists. | Unit (partial, checks the success state and the error rule separately; the Firebase conversion and the on-screen sentence aren't run) `GuestSignInTests.testPasswordResetLooksTheSameWhetherOrNotAnAccountExists` |
| S7.2 | Given no connection, when I send, then it says so and no success shows. | Unit `GuestSignInTests.testPasswordResetOfflineSaysSoAndNeverShowsSuccess` |

**S8. Delete my account.** As a returning person, I want to delete my earlier account and its cloud journal, so that my account data isn't kept online.
Screen: Settings → Delete my account. States: in progress, done, error.

| # | Given / When / Then | Test |
| --- | --- | --- |
| S8.1 | Given I log in again to confirm, when I delete, then the account and its cloud data are deleted and entries on this iPhone stay. Before deleting, a Will be deleted card and a Stays card show what goes and what stays, and Learn more says what's kept (circles, replies and likes on others' posts). | Unit `GuestSignInTests.testDeleteMyAccountNeedsAFreshLogInAndKeepsLocalEntries`; UI (partial, success wording only) `GuestImportUITests.testWelcomeLogInPreviewCopySignedOutAndDelete` |
| S8.2 | Given the cloud data can't be deleted, when the error shows, then the account isn't deleted and success is never shown. | Unit `GuestSignInTests.testDeleteFailuresNeverReportSuccess` |
| S8.3 | Given an account action is running, when I start another, then only one runs at a time. | Unit `GuestSignInTests.testOneAccountActionAtATime` |

## Proposed communication style — M10 / F24

**S9.** As a person, I want to choose and clear how I prefer to phrase messages, so that suggestions can fit me without guessing my background.
Screen: Settings → My communication style; per-request confirmation in Practice. States: off, edited, saved, cleared, failed save/load, not shared/shared for one request. **Proposed native behaviour.** The [browser prototype](../agent-collaboration-log/2026-10-29-communication-style-prototype.md) stores preferences only in memory; it does not test durable preferences, export/deletion or a real model.

| # | Given / When / Then | Test / evidence needed |
| --- | --- | --- |
| S9.1 | Given first use, when I enter Today, Journal or Practice, then preferences are off and optional; no account or profile setup blocks writing. | No native test; browser default plus saved-off/enabled/clear status checks on 29 October |
| S9.2 | Given my chosen English variety, wording style and length, when Save succeeds, then the values reopen after relaunch. Clear removes the preferences without changing journal entries or conversations; failed saving retains edits and reports failure. | No native test; durable storage and failure behaviour proposed |
| S9.3 | Given saved preferences, when I prepare an online request, then I choose whether to include them each time; the preview shows exact values. Conversation tone takes priority, and changing included preferences invalidates a pending result. | No native test; browser checkbox/payload and formal/brief fixtures are partial evidence, not language evaluation |
| S9.4 | Given preferences or writing, when suggestions are prepared, then no demographic profile is inferred and no journal, voice recording or accepted suggestion silently trains/saves a profile. Original words, moods and activity tags stay unchanged. | No native test; browser original-entry preservation checked; broader data-boundary tests pending |
| S9.5 | Given saved preferences, when I export or delete all local data, then export includes the explicit preferences and deletion resets them; failure is not reported as success. | Proposed integration with S2/S3; no native test or persistence implementation |
| S9.6 | Given unavailable/corrupt preference storage, when I open the app, then manual writing still works and no default profile is silently substituted as mine. With large text and VoiceOver, choices, Save/Clear and errors stay usable. | Proposed error/accessibility behaviour; no native test |

### Cross-screen refinement boundary

Today retains capture, draft recovery and optional post-save reflection (T1–T10); Journal retains search, calendar and editing (J1–J6). Their browser companion views are partial specimens, not replacement specifications. Style is a Settings preference and a deliberate Practice input; it must not add setup steps to Today or reinterpret saved Journal entries. Any new action on those screens needs its own brief change and criterion first.

## Kept but not reachable

**S6. Earlier app on this iPhone (not reachable now).** As a returning person, I want entries from the earlier CircleU app on this iPhone brought in, so that I don't start from nothing.
Settings no longer opens this screen (Log in replaced it), but the code and tests are kept. Not counted in Coverage. R6.3 checks the empty scan, not the message.

| # | Given / When / Then | Test |
| --- | --- | --- |
| R6.1 | Given nothing is chosen, when the guest journal opens, then nothing from the earlier app is shown or copied. | Unit `GuestImportTests.testByDefaultNothingFromTheEarlierAppIsShownOrCopied` |
| R6.2 | Given earlier guest data, when I copy it, then it is copied once, the earlier app is untouched, and copying again adds no duplicates. | Unit `GuestImportTests.testImportCopiesOnceKeepsTheEarlierAppUntouchedAndNeverDuplicates` |
| R6.3 | Given nothing to bring in, when I look, then it says "Nothing from the earlier CircleU app was found in this app on this iPhone." | Unit `GuestImportTests.testNothingFoundIsSaidPlainly` |
| R6.4 | Given the earlier app was ever signed in, when I look, then its data is sealed and not offered. | Unit `GuestImportTests.testAnySignInHistorySealsEverything` |

## Coverage

P5/P6 were added on 27 October for native conversation and voice review. On 29 October, P7/P8/S9 were added as proposed criteria only; no new native test coverage or pass is claimed. The per-criterion table above is the coverage source. A test named there is not a claim of a fresh pass: see the dated QA evidence for the actual run and its limitations. Physical speech, VoiceOver and scene/detail selection remain explicit review items.

### Running the tests

- **Unit:** `xcodebuild test -project Circleu.xcodeproj -scheme Circleu -destination "platform=iOS Simulator,name=<iPhone>" CODE_SIGNING_ALLOWED=NO`
- **UI:** the same command with `-scheme CircleuUITests`. It runs the Debug app in guest mode, takes about 9 minutes, and uses the fake account, so nothing reaches Firebase. `GuestImportUITests.testRealDevRejectsAnInventedAccountGenerically` contacts Firebase Dev and is skipped unless the run sets `TEST_RUNNER_CIRCLEU_LIVE_DEV=1`.
- Before merging a change to guest behaviour, run both. When a story or test changes, update this file in the same PR.

### Proposed next

1. Review P7/P8/S9 against the compact Refine prototype; resolve native scope before implementation. See F23/F24 for the next review tasks.
2. Preserve Today capture and Journal calendar/editing while refining their presentation. Check each proposed control against T/J criteria before adding it.
3. Close existing partial coverage: physical Practice permission/VoiceOver, actual export/share completion (S2.3), guided-fallback choice (T6.3) and scene/detail interaction (P2.5). J4.2 already has a discard-dialog UI test; its older unit-only limitation must not be treated as an unimplemented dialog.
4. Before merging guest behaviour changes, run the unit and guest UI suites, and attach dated device evidence for capabilities that mocks cannot verify.
