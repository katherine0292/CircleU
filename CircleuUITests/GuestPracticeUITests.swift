import XCTest

final class GuestPracticeUITests: XCTestCase {
    /// Moving Save back into the scrolling form must fail these keyboard bounds checks.
    func testPracticeSaveStaysAboveKeyboard() throws {
        try checkPinnedSave(extraArguments: [])
    }

    func testPracticeSaveStaysAboveKeyboardAtLargestText() throws {
        try checkPinnedSave(extraArguments: ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"])
    }

    private func checkPinnedSave(extraArguments: [String]) throws {
        continueAfterFailure = false
        let app = launchGuest(fresh: true, extraArguments)
        app.tabBars.buttons["Practice"].tap()
        let start = app.buttons["Practice a message"]
        XCTAssertTrue(start.waitForExistence(timeout: 10))
        for _ in 0..<6 where !start.isHittable { app.swipeUp() }
        start.tap()
        let wording = app.textViews["Your wording"]
        for _ in 0..<6 where !wording.isHittable { app.swipeUp() }
        wording.tap()
        wording.typeText("Could we agree on a time to finish the slides?")
        app.buttons["Continue"].tap()
        wording.tap()
        let keyboard = app.keyboards.firstMatch
        XCTAssertTrue(keyboard.waitForExistence(timeout: 5), "This check requires the software keyboard")
        let save = app.buttons["Save"]
        XCTAssertTrue(save.isEnabled)
        XCTAssertTrue(save.isHittable, "Save stays visible while writing")
        XCTAssertLessThanOrEqual(save.frame.maxY, keyboard.frame.minY + 1)
        XCTAssertGreaterThanOrEqual(save.frame.minY, app.navigationBars.firstMatch.frame.maxY)
        let initialY = save.frame.minY
        // Use the visible form beside the text inset. A scroll view's accessibility frame can
        // extend beneath the keyboard; normalized coordinates can start on the keyboard instead.
        let suggestion = app.buttons["Get a suggestion"]
        let initialSuggestionY = suggestion.frame.minY
        let origin = app.coordinate(withNormalizedOffset: .zero)
        let dragStart = origin.withOffset(CGVector(dx: 30, dy: save.frame.minY - 20))
        let dragEnd = origin.withOffset(CGVector(dx: 30, dy: app.navigationBars.firstMatch.frame.maxY + 24))
        dragStart.press(forDuration: 0.05, thenDragTo: dragEnd)
        let formFrame = app.scrollViews["Practice form"].frame
        attach("Form: \(formFrame); Save: \(save.frame); keyboard: \(keyboard.frame); suggestion before: \(initialSuggestionY), after: \(suggestion.frame.minY)", "practice-scroll-bounds")
        XCTAssertLessThan(suggestion.frame.minY, initialSuggestionY, "The outer form must actually move")
        XCTAssertTrue(keyboard.exists)
        XCTAssertEqual(save.frame.minY, initialY, accuracy: 2, "Save must not scroll with the form")
        shot(app, extraArguments.isEmpty ? "practice-pinned-save" : "practice-pinned-save-ax5")
        save.tap()
        XCTAssertTrue(has(app, "Saved · not sent"))
        XCTAssertFalse(keyboard.exists, "Saving dismisses the editor and its keyboard")
        app.buttons["Back"].tap()
        XCTAssertTrue(has(app, "Could we agree on a time to finish the slides?"))
    }

    func testConversationAndVoiceReviewPersistWithoutDuplicating() throws {
        continueAfterFailure = false
        var app = launchGuest(fresh: true, ["-CircleUScriptedDictation", "Spoken thought"])
        app.tabBars.buttons["Practice"].tap()
        XCTAssertTrue(app.buttons["Practice a message"].waitForExistence(timeout: 10))
        app.buttons["Practice a message"].tap()
        let wording = app.textViews["Your wording"]
        wording.tap(); wording.typeText("Could we talk?")
        app.buttons["Continue"].tap()
        reveal(app.buttons["Record your words"], in: app)
        app.buttons["Record your words"].tap()
        app.buttons["Record"].tap()
        let stop = app.buttons["Stop"]
        XCTAssertTrue(stop.waitForExistence(timeout: 10))
        stop.tap()
        let use = app.buttons["Use text"]
        XCTAssertTrue(use.waitForExistence(timeout: 10))
        use.tap()
        XCTAssertTrue((wording.value as? String ?? "").contains("Could we talk?"))
        XCTAssertTrue((wording.value as? String ?? "").contains("Spoken thought"))
        app.buttons["Save"].tap()
        XCTAssertTrue(has(app, "Saved · not sent"))
        reveal(app.buttons["Continue conversation"], in: app)
        app.buttons["Continue conversation"].tap()
        let reply = app.textViews["Their reply"]
        reveal(reply, in: app)
        reply.tap(); reply.typeText("Tomorrow works")
        app.buttons["Continue"].tap()
        XCTAssertEqual(wording.value as? String, "")
        reveal(wording, in: app)
        wording.tap(); wording.typeText("See you tomorrow")
        app.buttons["Save"].tap()
        XCTAssertTrue(has(app, "Saved · not sent"))
        app = launchGuest(fresh: false)
        app.tabBars.buttons["Practice"].tap()
        let row = app.staticTexts["See you tomorrow"]
        XCTAssertTrue(row.waitForExistence(timeout: 10))
        XCTAssertEqual(app.staticTexts.matching(identifier: "See you tomorrow").count, 1)
        row.tap()
        let timeline = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Conversation ·")).firstMatch
        XCTAssertTrue(timeline.waitForExistence(timeout: 5))
        timeline.tap()
        XCTAssertTrue(has(app, "Tomorrow works"))
        shot(app, "practice-conversation-saved")
    }

    private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<8 where !element.isHittable { app.swipeUp() }
        XCTAssertTrue(element.isHittable)
    }

    var findings: [String] = []
    func shot(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = name; shot.lifetime = .keepAlways; add(shot)
    }
    func audit(_ app: XCUIApplication, _ screen: String) {
        try? app.performAccessibilityAudit { issue in
            self.findings.append("\(screen) | \(issue.compactDescription) | \(issue.element?.label ?? "-") | \(issue.element?.frame ?? .zero)"); return true
        }
    }
    func has(_ app: XCUIApplication, _ text: String, _ timeout: TimeInterval = 5) -> Bool {
        app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", text)).firstMatch.waitForExistence(timeout: timeout)
    }

    /// P3: copying reflects the current wording; edit/discard preserves the saved version.
    func testCopyEditAndDiscardKeepTheRightWording() throws {
        continueAfterFailure = false
        var app = launchGuest(fresh: true)
        app.tabBars.buttons["Practice"].tap()
        app.buttons["Practice a message"].tap()
        let wording = app.textViews["Your wording"]
        XCTAssertTrue(wording.waitForExistence(timeout: 5))
        wording.tap(); wording.typeText("Could we talk on Friday?")
        app.buttons["Continue"].tap()
        app.buttons["Copy"].tap()
        XCTAssertTrue(app.buttons["Copied"].waitForExistence(timeout: 3))
        wording.tap(); wording.typeText(" After class.")
        XCTAssertTrue(app.buttons["Copy"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["Copied"].exists)
        XCTAssertFalse(app.staticTexts["Copied. Not saved or sent."].exists)
        let savedWords = try XCTUnwrap(wording.value as? String).trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertTrue(savedWords.contains("Could we talk on Friday?"))
        XCTAssertTrue(savedWords.contains("After class."))
        app.buttons["Save"].tap()
        XCTAssertTrue(has(app, "Saved · not sent"))
        app.buttons["Edit"].tap()
        wording.tap(); wording.typeText(" Unsaved change.")
        app.buttons["Back"].tap()
        let discard = app.alerts["Discard your changes?"]
        XCTAssertTrue(discard.waitForExistence(timeout: 3))
        discard.buttons["Keep editing"].tap()
        XCTAssertTrue((wording.value as? String ?? "").contains("Unsaved change."))
        app.buttons["Back"].tap()
        discard.buttons["Discard"].tap()
        XCTAssertTrue(app.staticTexts[savedWords].waitForExistence(timeout: 5))
        app.staticTexts[savedWords].tap()
        XCTAssertFalse(has(app, "Unsaved change.", 1))
        app.buttons["Edit"].tap()
        wording.tap(); wording.typeText(" Please.")
        // Tapping a TextEditor doesn't guarantee an insertion point at the end.
        // Verify persistence of the actual edit, independent of UIKit's cursor placement.
        let editedWords = try XCTUnwrap(wording.value as? String).trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertTrue(editedWords.contains("Please."))
        XCTAssertTrue(editedWords.contains(savedWords))
        XCTAssertNotEqual(editedWords, savedWords)
        app.buttons["Save"].tap()
        XCTAssertTrue(has(app, "Saved · not sent"))
        app = launchGuest(fresh: false)
        app.tabBars.buttons["Practice"].tap()
        let updated = app.staticTexts[editedWords]
        XCTAssertTrue(updated.waitForExistence(timeout: 5), "saved edits survive reopening")
        XCTAssertEqual(app.staticTexts.matching(identifier: editedWords).count, 1)
        XCTAssertFalse(app.staticTexts[savedWords].exists, "editing must not make a second message")
    }

    func testPracticeDirectFromEntryAndDeleteChoices() throws {
        continueAfterFailure = false
        let tag = Int.random(in: 1000...9999)
        let app = XCUIApplication()
        app.terminate(); app.launchArguments = ["-CircleUResetGuestData", "-circleu.guest.welcomeSeen.v1", "YES", "-CircleUGuestMode"]; app.launch()

        // Direct practice
        app.tabBars.buttons["Practice"].tap()
        XCTAssertTrue(app.buttons["Practice a message"].waitForExistence(timeout: 10))
        shot(app, "p1-home"); audit(app, "practice-home")
        app.buttons["Practice a message"].tap()
        XCTAssertTrue(has(app, "On its own"))
        let wording = app.textViews["Your wording"]; wording.tap(); wording.typeText("Can we split the slides \(tag)?")
        app.buttons["Continue"].tap()
        shot(app, "p2-compose"); audit(app, "compose")
        app.buttons["Copy"].tap()
        XCTAssertTrue(app.buttons["Copied"].waitForExistence(timeout: 3))
        XCTAssertTrue(has(app, "Copied. Not saved or sent."))
        XCTAssertTrue(app.buttons["Save"].isEnabled, "copy didn't save")
        app.buttons["Save"].tap()
        XCTAssertTrue(has(app, "Saved · not sent"))
        XCTAssertTrue(app.buttons["Copy"].exists, "Copy is the main action on a saved message")
        XCTAssertTrue(app.buttons["Edit"].exists, "Edit is a toolbar pencil")
        app.buttons["More"].tap()
        XCTAssertTrue(app.buttons["Delete message"].waitForExistence(timeout: 3), "Delete waits in the ••• menu")
        app.buttons["Delete message"].tap()
        XCTAssertTrue(app.alerts["Delete this message?"].waitForExistence(timeout: 3), "it asks first")
        app.alerts.buttons["Cancel"].tap()
        app.buttons["Copy"].tap()
        XCTAssertTrue(has(app, "Copied. Not sent."), "a saved message isn't called unsaved")
        XCTAssertFalse(has(app, "Not saved or sent.", 1))
        shot(app, "p3-saved"); audit(app, "saved")
        app.buttons["Back"].tap()
        XCTAssertTrue(has(app, "Can we split the slides \(tag)?"), "in history")
        shot(app, "p4-history")

        // From a journal entry
        app.tabBars.buttons["Today"].tap()
        let editor = app.textViews["Your words"]; XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.tap(); editor.typeText("Groupmate missed the deadline \(tag)")
        app.buttons["Save"].tap()
        let row = app.staticTexts["Groupmate missed the deadline \(tag)"]
        XCTAssertTrue(row.waitForExistence(timeout: 5)); row.tap()
        app.buttons["Practice what to say"].tap()
        XCTAssertTrue(has(app, "From: Groupmate missed the deadline"))
        let w2 = app.textViews["Your wording"]; w2.tap(); w2.typeText("Hey, can we talk about Friday \(tag)?")
        app.buttons["Continue"].tap()
        app.buttons["Save"].tap()
        XCTAssertTrue(has(app, "Saved · not sent"))
        shot(app, "p5-linked-saved")
        app.buttons["Back"].tap()
        XCTAssertTrue(has(app, "Hey, can we talk about Friday \(tag)?"), "linked message on the entry")
        shot(app, "p6-entry-with-practice"); audit(app, "entry-detail")

        // Delete the entry, keeping the message
        app.buttons["More"].tap() // Delete waits in the ••• menu.
        app.buttons["Delete entry"].tap()
        XCTAssertTrue(app.buttons["Keep message"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Delete both"].exists)
        shot(app, "p7-delete-choice")
        app.buttons["Keep message"].tap()
        XCTAssertTrue(app.navigationBars["Journal"].waitForExistence(timeout: 5), "back on Journal")
        XCTAssertFalse(app.staticTexts["Groupmate missed the deadline \(tag)"].exists)
        app.tabBars.buttons["Practice"].tap()
        XCTAssertTrue(has(app, "Hey, can we talk about Friday \(tag)?"), "kept")
        shot(app, "p8-kept-on-its-own")
        attach(findings.joined(separator: "\n"), "practice-audit.txt")
    }
}
