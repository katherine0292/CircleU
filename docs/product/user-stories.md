# Guest app user stories

26 October 2026. These are the user stories for the guest journal (the local-only app behind the guest switch), grouped by flow. On-screen wording follows the [screen content guidelines](../design/screen-content-guidelines.md). Quoted text is what the app shows today.

## How to read this

- **Story:** "As a [user], I want [goal], so that [benefit]."
- **Screen and states:** where the story happens, and the states it must handle. The states are empty, filled, in progress, error and permission denied, where relevant.
- **Criteria:** 2–4 Given/When/Then lines per story. Each line names its test in the **Test** column:
  - **Unit** is a repo test in `CircleuTests/` (`File.testName`), run by the full `xcodebuild test`.
  - **UI** is an XCUITest in `CircleuUITests/`, run with the `CircleuUITests` scheme (see "Running the tests" below). Each UI test starts from an empty guest journal (Debug-only `-CircleUResetGuestData`).
  - **No test** means nothing checks the line.
- **(partial)** means the test checks part of the line; the note says which part.
- **Users:**
  - **Person** is anyone using the guest journal.
  - **Returning person** used the earlier CircleU app or had an account.

## 1. Welcome

**W1.** As a person, I want to start writing without making an account, so that my words stay on this iPhone.
Screen: Welcome → Today. States: first launch (empty), returning launch.

| # | Given / When / Then | Test |
| --- | --- | --- |
| W1.1 | Given a first launch, when the app opens, then Welcome shows "Get started" and "Log in". | UI `GuestImportUITests.testWelcomeLogInPreviewCopySignedOutAndDelete` |
| W1.2 | Given Welcome, when I tap Get started, then Today opens and Welcome doesn't appear on later launches. | UI `GuestStatesUITests.testWelcomeShowsOnlyUntilGetStarted` |
| W1.3 | Given I open the guest journal without logging in, when it loads, then Firebase isn't contacted. | Unit `GuestSignInTests.testOpeningTheGuestJournalNeverTouchesFirebase` |
| W1.4 | Given a first launch, when the journal opens, then it is empty. | Unit `GuestJournalStoreTests.testFirstLaunchIsEmpty` |

**W2.** As a returning person, I want to log in from Welcome, so that I can bring in my earlier journal before I start.
Screen: Welcome → Log in. States: filled, in progress, error. Login details are in S5.

| # | Given / When / Then | Test |
| --- | --- | --- |
| W2.1 | Given Welcome, when I tap Log in, then Log in opens with "Continue without logging in". | UI `GuestImportUITests.testWelcomeLogInPreviewCopySignedOutAndDelete` |
| W2.2 | Given I copied my backup from Welcome, when I tap Continue, then Today opens and I'm signed out. | UI `GuestImportUITests.testWelcomeLogInPreviewCopySignedOutAndDelete` |

## 2. Today capture

**T1. Typing.** As a person, I want to type what happened and save it, so that it's in my journal.
Screen: Today. States: empty, filled, in progress (saving), error.

| # | Given / When / Then | Test |
| --- | --- | --- |
| T1.1 | Given words in the box, when I tap Save, then the entry appears in Journal and the box clears. | Unit `GuestJournalStoreTests.testSuccessfulSaveClearsDraftAndShowsEntry` |
| T1.2 | Given saving fails, when the error shows, then my words are still in the box and it says "Couldn’t save. Try again." | Unit `GuestJournalStoreTests.testFailedSaveKeepsDraftAndShowsError` |
| T1.3 | Given a save is in progress, when I keep typing, then the new words are kept. | Unit `GuestJournalStoreTests.testTextTypedDuringSaveIsKept` |
| T1.4 | Given the entry saved but file protection failed, when Journal opens, then a notice says so. | Unit `GuestJournalStoreTests.testSavedButUnprotectedClearsDraftAndShowsNoticeOnJournal` |
| T1.5 | Given Today, when I look at the actions, then there is one Save button (the question prompts only add text). | UI `GuestTodayUITests.testChipsStartTheWordsAndTheNudgeHelpsWhileWriting` |

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
| T4.1 | Given microphone or speech access is denied, when I tap the microphone, then it says "Dictation needs microphone and speech recognition access. Turn them on in Settings, or keep typing." and typing works. | Unit `GuestDictationViewModelTests.testDeniedPermissionLeavesTypingAndOffersSettings`; UI `GuestVoiceTabsUITests.testTabsPracticeAndDictationDenied` |
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
| T6.1 | Given I just saved, when Journal opens, then the "Saved" card offers Reflect (Reflect on it) and × (Not now), for that entry only, and Not now closes it. | Unit `GuestSuggestionTests.testSavingOffersAReflectionOnlyForThatEntryUntilDismissed`, `testFinishingAnOlderReflectionKeepsTheNewerOffer`; UI `GuestTodayUITests.testChipsStartTheWordsAndTheNudgeHelpsWhileWriting` |
| T6.2 | Given I tap Reflect on it and Save reflection, when the entry reopens, then my edits to the reflection are kept apart from my unchanged words. | Unit `GuestSuggestionTests.testEditedSuggestionIsSavedApartFromTheWords`, `testReflectionAndNextStepAreSavedWithTheWordsAndSurviveReopen`; UI `GuestSuggestionUITests.testReflectionNextStepAndPracticeSuggestions` |
| T6.3 | Given no on-device model, when a suggestion shows, then it is labelled as guided prompts and uses only what I wrote. | Unit (partial, guided engine forced) `GuestSuggestionTests.testGuidedEngineIsLabelledAndUsesOnlyWhatWasTyped` |
| T6.4 | Given the suggestion fails or I clear every part, when I look, then nothing is added and the entry stays as it is. | Unit `GuestSuggestionTests.testFailedSuggestionLeavesTheSavedEntryAsItIs`, `testClearingEverythingAddsNothing` |
| T6.5 | Given the entry changed somewhere else, when I save the reflection, then it isn't added and I'm told why. | Unit `GuestSuggestionTests.testReflectionOnAnEntryChangedMeanwhileIsNotAdded` |
| T6.6 | Given a reflection is open, when I delete all data, then it closes and Journal is empty. | UI `GuestTodayUITests.testDeleteAllClosesAnOpenReflection` |

**T7. Next step.** As a person, I want to choose whether to keep a suggested next step, so that nothing is added without my say.
Screen: Reflection review, Entry. States: filled, done or not done.

| # | Given / When / Then | Test |
| --- | --- | --- |
| T7.1 | Given a suggested step, when I don't add it, then it isn't saved. | Unit `GuestSuggestionTests.testSuggestedStepIsNotSavedUnlessAdded` |
| T7.2 | Given a saved step, when I mark it done, undo it or remove it, then the entry updates. | Unit `GuestSuggestionTests.testNextStepCanBeDoneUndoneAndRemovedWithRevisions`, `testNextStepIsVoluntaryAndReversibleFromTheEntry` |

**T8. Question chips.** As a person who isn't sure where to start, I want a few questions above the empty box, so that I can begin without staring at a blank page.
Screen: Today (empty). States: empty, filled.

| # | Given / When / Then | Test |
| --- | --- | --- |
| T8.1 | Given an empty box, when Today opens, then "What happened?", "Who was it with?" and "What do you wish you’d said?" show above it. | Unit `GuestTodayPromptsTests.testThreeStarterChipsEachAddOnlyTheirStarter`; UI `GuestTodayUITests.testChipsStartTheWordsAndTheNudgeHelpsWhileWriting` |
| T8.2 | Given the chips, when I tap one, then only its sentence starter (such as "I wish I’d said") goes into my words, and the chips go. | Unit `GuestTodayPromptsTests.testThreeStarterChipsEachAddOnlyTheirStarter`; UI `GuestTodayUITests.testChipsStartTheWordsAndTheNudgeHelpsWhileWriting` |
| T8.3 | Given I saved, when I'm back on Today, then the box is empty and the chips are back. | UI `GuestTodayUITests.testChipsStartTheWordsAndTheNudgeHelpsWhileWriting` |

**T9. Need a nudge?** As a person who gets stuck partway, I want one follow-up question while I write, so that I can keep going in my own words.
Screen: Today (writing). States: filled, hidden, listening (not shown).

| # | Given / When / Then | Test |
| --- | --- | --- |
| T9.1 | Given at least five words and no dictation, when I write, then "Need a nudge?" shows one question. | Unit `GuestTodayPromptsTests.testNudgeShowsOnceThereAreWordsAndNotWhileDictating`; UI `GuestTodayUITests.testChipsStartTheWordsAndTheNudgeHelpsWhileWriting` |
| T9.2 | Given a question, when I tap Another question, then a different one shows; when I tap Add to my words, then only its starter goes on a new line and the next question shows. | Unit `GuestTodayPromptsTests.testAnotherQuestionCyclesAndAddMovesOn`, `testAStarterGoesOnANewLineAfterExistingWords`; UI `GuestTodayUITests.testChipsStartTheWordsAndTheNudgeHelpsWhileWriting` |
| T9.3 | Given the nudge, when I tap Hide, then it stays hidden for this entry and comes back for the next one. | Unit `GuestTodayPromptsTests.testHideLastsForThisEntryOnly`; UI `GuestTodayUITests.testChipsStartTheWordsAndTheNudgeHelpsWhileWriting` |
| T9.4 | Given the keyboard is up, when the nudge shows, then the words are still in view (the microphone gets smaller). | No test (checked on the `t2-nudge` screenshot from `GuestTodayUITests`) |

**T10. Visual Today.** As a person, I want Today to show me what to do with pictures rather than instructions, so that I can start without reading.
Screen: Today. States: empty, in progress (listening), filled (writing). Mocked in the canvas row "D · Visual Today" (D1–D3). Uses Pingu art already in the app; the new mic and scene art (ART-1 to ART-6) will go in the same card.

| # | Given / When / Then | Test |
| --- | --- | --- |
| T10.1 | Given an empty box, when Today opens, then my Pingu and the microphone share one card, the question chips show their icons, and there's no "Type, or tap the microphone and talk.", "Tap to talk" or "Not sure where to start?". | UI (partial, checks the words are gone and the microphone is there, not the art) `GuestTodayUITests.testChipsStartTheWordsAndTheNudgeHelpsWhileWriting` |
| T10.2 | Given I'm listening, when I look, then Pingu listens inside the rings, with stop and cancel as icons that VoiceOver names "Stop dictation" and "Cancel dictation". | UI (partial, checks the names, not the art) `GuestStatesUITests.testPinguChoiceIsKeptAndThePickerStopsDictation` |
| T10.3 | Given at least five words, when the nudge shows, then it's a speech bubble from Pingu with the question, Add, and icons named "Another question" and "Hide", and no "Need a nudge?" label. | UI `GuestTodayUITests.testChipsStartTheWordsAndTheNudgeHelpsWhileWriting` |
| T10.4 | Given the largest text sizes, when Today opens, then the Pingu art is left out and the microphone and chips stay. | No test |

## 3. Journal

**J1. Browse.** As a person, I want to see what I've saved, so that I can look back.
Screen: Journal. States: empty, filled, error.

| # | Given / When / Then | Test |
| --- | --- | --- |
| J1.1 | Given nothing saved, when Journal opens, then Pingu and "Nothing saved yet." show. | UI (partial, checks the text, not the art) `GuestFindControlUITests.testSearchCalendarDraftExportAndDeleteAll`, `GuestStatesUITests.testEmptyJournalPracticeAndCalendarDay` |
| J1.2 | Given the journal can't be read, when Journal opens or refreshes, then it says "Couldn’t open your journal. Try again." and never shows an empty journal. | Unit `GuestJournalStoreTests.testFailedLoadIsAnErrorNotAnEmptyJournal`, `testFailedRefreshIsAnErrorNotAnEmptyOrDeletedJournal` |
| J1.3 | Given the store file is corrupt or missing, when it opens, then it reports an error and keeps the file's bytes. | Unit `GuestJournalStoreTests.testCorruptStoreIsAnErrorAndBytesArePreserved`, `testVanishedStoreFileIsAnError` |

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

| # | Given / When / Then | Test |
| --- | --- | --- |
| J4.1 | Given I edit and save, when the entry reopens, then the change is kept, including after a relaunch. | Unit `GuestEntryEditorViewModelTests.testSaveUsesOpenedRevisionAndClearsChanges`, `testSaveAndEditPersistAcrossRelaunch` |
| J4.2 | Given unsaved edits, when I leave, then the app asks before discarding. | Unit (partial, checks unsaved changes, not the dialog) `GuestEntryEditorViewModelTests.testEditingMarksChangesSoLeavingAsksFirst`; UI `GuestFlowUITests.testWriteSaveRelaunchEditDiscard` |
| J4.3 | Given the entry changed or was deleted elsewhere, when I save, then my text is kept with a clear message. | Unit `GuestEntryEditorViewModelTests.testStaleAndDeletedEntriesKeepTextWithClearMessages` |
| J4.4 | Given an entry with a reflection, when I edit the words, then the reflection is marked as earlier. | Unit `GuestSuggestionTests.testEditingTheWordsMarksTheReflectionAsEarlierAndRemovingItKeepsTheWords` |

**J5. Delete an entry.** As a person, I want to delete an entry and choose what happens to its practice message, so that I control what's kept.
Screen: Entry (delete dialog). States: in progress, error.

| # | Given / When / Then | Test |
| --- | --- | --- |
| J5.1 | Given an entry with a message, when I delete it, then I can keep the message on its own or delete both. | Unit `GuestPracticeTests.testDeletingAnEntryCanKeepItsMessageOnItsOwn`, `testDeletingAnEntryCanDeleteBoth`; UI `GuestPracticeUITests.testPracticeDirectFromEntryAndDeleteChoices` |
| J5.2 | Given delete fails, when the error shows, then the entry and message are unchanged. | Unit `GuestPracticeTests.testFailedEntryDeleteKeepsEntryAndMessage` |
| J5.3 | Given a deleted entry, when an old screen saves, then it doesn't come back. | Unit `GuestJournalStoreTests.testUpdateAfterDeleteDoesNotResurrectEntry` |

**J6. Icons over labels.** As a person, I want Journal to show status and actions as pictures, so that my own words stand out.
Screen: Journal, Calendar, Entry. States: filled, one day chosen. Mocked in the canvas row "J · Simpler Journal" (JS1–JS3).

| # | Given / When / Then | Test |
| --- | --- | --- |
| J6.1 | Given entries, when Journal opens, then each row shows a date tile, the words, icons for a reflection, a next step (a tick when done) and a practice message, and the time; VoiceOver reads the icons in words. | No test |
| J6.2 | Given I just saved, when Journal opens, then the "Saved" card is one row: Pingu, "Saved", Reflect and ×. | UI `GuestTodayUITests.testChipsStartTheWordsAndTheNudgeHelpsWhileWriting` |
| J6.3 | Given the calendar, when I choose a day, then a day chip with × replaces "Showing …" and Show all, each day shows up to three dots, and Go to today is an icon. | UI `GuestFindControlUITests.testSearchCalendarDraftExportAndDeleteAll` |
| J6.4 | Given an entry, when it opens, then the date is the title, Edit is a pencil, Delete entry is in the ••• menu, and the reflection, feeling and next step show as icons with spoken names. | UI `GuestPracticeUITests.testPracticeDirectFromEntryAndDeleteChoices`, `GuestSuggestionUITests.testReflectionNextStepAndPracticeSuggestions` |

## 4. Practice

**P1. Practise from an entry.** As a person, I want to practise what to say about an entry, so that I'm ready for the conversation.
Screen: Entry → Practice message. States: empty, filled, in progress, error.

| # | Given / When / Then | Test |
| --- | --- | --- |
| P1.1 | Given an entry, when I tap Practice what to say and save, then the message is tagged "From: …" and survives reopening. | Unit `GuestPracticeTests.testStandaloneAndLinkedMessagesSurviveReopen`, `testTagShowsSourceEntryOrOnItsOwn`; UI `GuestPracticeUITests.testPracticeDirectFromEntryAndDeleteChoices` |
| P1.2 | Given the source entry was deleted, when I save a message from it, then my words stay. | Unit `GuestPracticeTests.testDeletedSourceEntryKeepsWords` |

**P2. A message on its own.** As a person, I want to practise without an entry, so that I can prepare for something I haven't written about.
Screen: Practice. States: empty, filled, error.

| # | Given / When / Then | Test |
| --- | --- | --- |
| P2.1 | Given no messages, when Practice opens, then Pingu and "Nothing practised yet." show. | UI (partial, checks the text, not the art) `GuestStatesUITests.testEmptyJournalPracticeAndCalendarDay` |
| P2.2 | Given a new message, when it has no wording, then Save is off; once it has wording, it saves and shows as saved. | Unit `GuestPracticeTests.testNewMessageNeedsWordingThenSavesAndShowsAsSaved` |
| P2.3 | Given saving fails, when the error shows, then my words are kept. | Unit `GuestPracticeTests.testFailedSaveKeepsWordsAndShowsError` |

**P3. Copy and edit.** As a person, I want to copy or edit a message, so that I can send it myself or improve it.
Screen: Practice message. States: filled, error (stale).

| # | Given / When / Then | Test |
| --- | --- | --- |
| P3.1 | Given a message, when I tap Copy, then it is copied and not saved or sent. | Unit `GuestPracticeTests.testCopyDoesNotSave` |
| P3.2 | Given a saved message, when I edit and save, then the same message updates; if it changed elsewhere, my words are kept with an explanation. | Unit `GuestPracticeTests.testEditingASavedMessageUpdatesTheSameMessage`, `testStaleEditKeepsWordsAndExplains` |
| P3.3 | Given delete fails, when the error shows, then the message is kept. | Unit `GuestPracticeTests.testFailedMessageDeleteKeepsIt` |

**P4. Practice draft and suggestions.** As a person, I want my unfinished message kept and optional wording ideas, so that I can come back and get unstuck.
Screen: Practice → Continue your draft. States: filled (restored), in progress, error.

| # | Given / When / Then | Test |
| --- | --- | --- |
| P4.1 | Given an unsaved message, when the app relaunches, then Continue your draft restores it, and once saved it isn't offered again. | Unit `GuestFindAndControlTests.testPracticeDraftSurvivesRelaunchAndIsClearedBySaving`, `testSavedPracticeDraftIsNeverOfferedAgain` |
| P4.2 | Given a suggestion, when I choose it, then it fills the wording and can be undone. | Unit `GuestSuggestionTests.testPracticeSuggestionsFillWordingOnlyWhenChosenAndCanBeUndone` |
| P4.3 | Given a suggestion fails, when the error shows, then my wording is kept. | Unit `GuestSuggestionTests.testFailedPracticeSuggestionKeepsWording` |

## 5. Settings

**S1. Privacy.** As a person, I want to know where my words are kept, so that I can trust the app.
Screen: Settings → Privacy and data. States: filled, Learn more open.

| # | Given / When / Then | Test |
| --- | --- | --- |
| S1.1 | Given Settings, when I look at Privacy and data, then it says "Kept on this iPhone. Not uploaded or synced." and the detail is behind Learn more. | UI `GuestStatesUITests.testPrivacySummaryAndLearnMore` |
| S1.2 | Given the journal opens, when files are written, then iOS file protection is applied, and the journal won't open if it can't be applied. | Unit (partial, protection calls are injected) `GuestJournalStoreTests.testProtectionIsAppliedToFolderStoreAndSidecars`, `testOpenFailsIfProtectionCannotBeApplied` |

**S2. Export.** As a person, I want a copy of everything I wrote, so that I can keep it elsewhere.
Screen: Settings → Your data → share sheet. States: in progress, done, error.

| # | Given / When / Then | Test |
| --- | --- | --- |
| S2.1 | Given entries and messages, when I tap Export my data, then a readable text file holds all of them, with suggestions labelled. | Unit `GuestFindAndControlTests.testExportIsReadableAndCompleteAndLabelsSuggestions`, `testExportFileContainsTheJournal` |
| S2.2 | Given something can't be read, when I export, then it says "Couldn’t prepare the export. Try again." and no partial file is made. | Unit `GuestFindAndControlTests.testExportIsRefusedWhenSomethingCantBeRead` |
| S2.3 | Given the share sheet closes after sharing, when I'm back in Settings, then it says "Export done. The copy you shared is yours to keep or delete." | Unit (partial, the model's decision, not the share sheet) `GuestFindAndControlTests.testExportDoneShowsOnlyAfterSharingAndCleanup` |

**S3. Delete all.** As a person, I want to delete everything in the guest journal, so that nothing is left on this iPhone.
Screen: Settings → Your data → confirm. States: in progress, done, error.

| # | Given / When / Then | Test |
| --- | --- | --- |
| S3.1 | Given entries, messages and drafts, when I confirm Delete all data, then all of them are gone and my Pingu resets. | Unit `GuestFindAndControlTests.testDeleteAllRemovesEverythingInTheGuestJournalOnly`; `GuestPinguArtTests.testDeleteAllResetsTheChosenPingu`; UI `GuestFindControlUITests.testSearchCalendarDraftExportAndDeleteAll` |
| S3.2 | Given delete fails partway, when the error shows, then nothing is removed. | Unit `GuestFindAndControlTests.testFailedDeleteAllRemovesNothingIncludingDrafts` |
| S3.3 | Given a screen opened before delete all, when it tries to save, then it can't. | Unit `GuestFindAndControlTests.testAScreenClosedByDeleteAllCantSave` |

**S4. Your Pingu.** As a person, I want to choose my Pingu, so that the app feels like mine.
Screen: Today avatar → Your Pingu. States: filled.

| # | Given / When / Then | Test |
| --- | --- | --- |
| S4.1 | Given the picker, when it opens, then all 21 Pingu avatars show with spoken names. | Unit (partial, checks bundled art and names) `GuestPinguArtTests.testAll21AvatarsAndIconsAreBundled`; UI `GuestPolishUITests.testPinguArtScreens` |
| S4.2 | Given I pick a Pingu, when the app relaunches, then the same Pingu shows on Today. | UI `GuestStatesUITests.testPinguChoiceIsKeptAndThePickerStopsDictation` |
| S4.3 | Given I'm dictating, when I open the picker, then dictation stops and my words are kept. | UI (partial, checked once the picker closes) `GuestStatesUITests.testPinguChoiceIsKeptAndThePickerStopsDictation` |

**S5. Log in and bring in my backup.** As a returning person, I want to log in once and copy my earlier account's backup, so that my old journal is here without anything new being uploaded.
Screen: Log in → Backup preview → Copied. States: filled, in progress, error (wrong details, offline), done.

| # | Given / When / Then | Test |
| --- | --- | --- |
| S5.1 | Given correct details, when I log in, then I see only that account's backup, copying adds it once, and I'm signed out after. | Unit `GuestSignInTests.testLogInPreviewsOnlyThatAccountsBackupCopiesOnceAndSignsOut`; UI `GuestImportUITests.testWelcomeLogInPreviewCopySignedOutAndDelete` |
| S5.2 | Given wrong details, when I log in, then one generic message shows without saying whether the account exists, and repeated tries back off. | Unit `GuestSignInTests.testFailuresAreGenericSignedOutAndBackOff`; UI `GuestImportUITests.testRealDevRejectsAnInventedAccountGenerically` |
| S5.3 | Given no connection, when I log in, then it says so plainly. | Unit `GuestSignInTests.testOfflineAndUnavailableAreSaidPlainly` |
| S5.4 | Given copying the backup fails, when the error shows, then it says "Couldn’t copy your earlier journal. Nothing was added; try again." and nothing is added. | Unit `GuestSignInTests.testFailedBackupCopyAddsNothingSaysSoAndSignsOut` |

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
| S8.1 | Given I log in again to confirm, when I delete, then the account and its cloud data are deleted, entries on this iPhone stay, and Learn more says what's kept (circles, replies and likes on others' posts). | Unit `GuestSignInTests.testDeleteMyAccountNeedsAFreshLogInAndKeepsLocalEntries`; UI (partial, success wording only) `GuestImportUITests.testWelcomeLogInPreviewCopySignedOutAndDelete` |
| S8.2 | Given the cloud data can't be deleted, when the error shows, then the account isn't deleted and success is never shown. | Unit `GuestSignInTests.testDeleteFailuresNeverReportSuccess` |
| S8.3 | Given an account action is running, when I start another, then only one runs at a time. | Unit `GuestSignInTests.testOneAccountActionAtATime` |

## Kept but not reachable

**S6. Earlier app on this iPhone (not reachable now).** As a returning person, I want entries from the earlier CircleU app on this iPhone brought in, so that I don't start from nothing.
Settings no longer opens this screen (Log in replaced it), but the code and tests are kept. Not counted in Coverage. S6.3 checks the empty scan, not the message.

| # | Given / When / Then | Test |
| --- | --- | --- |
| R6.1 | Given nothing is chosen, when the guest journal opens, then nothing from the earlier app is shown or copied. | Unit `GuestImportTests.testByDefaultNothingFromTheEarlierAppIsShownOrCopied` |
| R6.2 | Given earlier guest data, when I copy it, then it is copied once, the earlier app is untouched, and copying again adds no duplicates. | Unit `GuestImportTests.testImportCopiesOnceKeepsTheEarlierAppUntouchedAndNeverDuplicates` |
| R6.3 | Given nothing to bring in, when I look, then it says "Nothing from the earlier CircleU app was found in this app on this iPhone." | Unit `GuestImportTests.testNothingFoundIsSaidPlainly` |
| R6.4 | Given the earlier app was ever signed in, when I look, then its data is sealed and not offered. | Unit `GuestImportTests.testAnySignInHistorySealsEverything` |

## Coverage

Counted on 26 October 2026, over 29 stories and 94 criteria (S6 is not counted):

| Covered by | Criteria |
| --- | --- |
| A unit test (17 also have a UI test) | 70 |
| Only a UI test | 21 |
| No test | 3 |
| Marked partial (either kind) | 13 |

Every criterion but three has a test (T9.4, T10.4 and J6.1 are layout, checked on screenshots); 13 only partly check theirs (see each "(partial)" note).

### Running the tests

- **Unit:** `xcodebuild test -project Circleu.xcodeproj -scheme Circleu -destination "platform=iOS Simulator,name=<iPhone>" CODE_SIGNING_ALLOWED=NO`
- **UI:** the same command with `-scheme CircleuUITests`. It runs the Debug app in guest mode, takes about 9 minutes, and uses the fake account, so nothing reaches Firebase. `GuestImportUITests.testRealDevRejectsAnInventedAccountGenerically` contacts Firebase Dev and is skipped unless the run sets `TEST_RUNNER_CIRCLEU_LIVE_DEV=1`.
- Before merging a change to guest behaviour, run both. When a story or test changes, update this file in the same PR.

### Proposed next

1. **Partial checks:** the most useful upgrades are J4.2 (the discard dialog), S2.3 (a real share completing) and T6.3 (choosing guided prompts when no model is available).
2. **Today options A and C:** when the art is ready, it replaces the Pingu and microphone in T10's card; write their criteria and tests then. Option B is T1.5, T6, T8 and T9.
