import XCTest

/// Talk (6 November 2026): the conversation thread, the moment timeline it links to, branches,
/// "How did it go?", the composer above the keyboard, and the step-by-step guide.
/// Replaces the staged Practice tests (Prepare → Refine → Their reply), whose screens are gone.
final class GuestTalkUITests: XCTestCase {
    func shot(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = name; shot.lifetime = .keepAlways; add(shot)
    }
    func has(_ app: XCUIApplication, _ text: String, _ timeout: TimeInterval = 5) -> Bool {
        app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", text)).firstMatch.waitForExistence(timeout: timeout)
    }

    /// TK1–TK4: say it, another take, a style, copy, said; their reply read two ways; saved once.
    func testSayItCopySaidAndTheirReplyPersistOnce() throws {
        continueAfterFailure = false
        var app = launchGuest(fresh: true)
        startTalk(app, saying: "can we split the slides")
        app.buttons["Regenerate"].tap()
        XCTAssertTrue(has(app, "2/2"), "↻ adds a page")
        app.buttons["Shorter"].tap()
        XCTAssertTrue(has(app, "2/2"), "a style is not a new page")
        app.buttons["Previous suggestion"].tap()
        XCTAssertTrue(has(app, "1/2"))
        shot(app, "tk1-say-it")
        sayIt(app)

        sendInTalk(app, "Sorry, I've been busy. I'll try but no promises.")
        XCTAssertTrue(app.staticTexts["TWO WAYS TO READ THIS"].waitForExistence(timeout: 10))
        let reading = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Yes, but")).firstMatch
        XCTAssertTrue(reading.exists)
        XCTAssertTrue(app.buttons["Neither fits"].exists)
        reading.tap()
        XCTAssertTrue(app.staticTexts["YOU COULD REPLY"].waitForExistence(timeout: 10))
        shot(app, "tk2-reply")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.staticTexts["Earlier conversations"].waitForExistence(timeout: 5))

        app = launchGuest(fresh: false)
        app.tabBars.buttons["Talk"].tap()
        XCTAssertTrue(app.staticTexts["Earlier conversations"].waitForExistence(timeout: 10))
        let rows = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "slides"))
        XCTAssertEqual(rows.count, 1, "one conversation, not one per turn")
        rows.firstMatch.tap()
        XCTAssertTrue(has(app, "no promises"), "their reply comes back")
        XCTAssertTrue(app.staticTexts["YOU SAID ✓"].exists)
    }

    /// J8, TK5, TK6: a moment's timeline, Talk filled in from it, Back to the moment, How did it go
    /// with only a feeling, and deleting the moment keeps the conversation.
    func testMomentTimelineTalkAndHowItWent() throws {
        continueAfterFailure = false
        let app = launchGuest(fresh: true)
        let editor = app.textViews["Your words"]
        XCTAssertTrue(editor.waitForExistence(timeout: 15))
        editor.tap(); editor.typeText("My groupmate missed the deadline again")
        app.buttons["Save"].tap()
        let row = app.staticTexts["My groupmate missed the deadline again"]
        XCTAssertTrue(row.waitForExistence(timeout: 5)); row.tap()
        XCTAssertTrue(has(app, "WHAT HAPPENED"))
        XCTAssertTrue(has(app, "Not yet. It can help"), "reflection waits as a quiet stop")
        XCTAssertTrue(app.buttons["Reflect"].exists, "the next step is the one main action")
        app.buttons["Add Context"].tap()
        app.buttons["Study"].tap()
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["Context: Study"].waitForExistence(timeout: 5))
        shot(app, "j8-moment")

        app.buttons["Talk it through instead"].tap()
        XCTAssertTrue(has(app, "Filled in from your journal"))
        startTalk(app, saying: "please send your part tonight", fromTalkTab: false)
        sayIt(app)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(has(app, "HOW DID IT GO?"), "Back lands on the moment, which now asks")
        let save = app.buttons["Save"].firstMatch
        XCTAssertFalse(save.isEnabled, "nothing chosen yet")
        app.buttons["Calm"].tap()
        XCTAssertTrue(save.isEnabled, "a feeling alone is enough")
        save.tap()
        XCTAssertTrue(has(app, "HOW IT WENT"))
        XCTAssertTrue(app.buttons["Continue the conversation"].exists)
        shot(app, "tk6-how-it-went")

        app.buttons["More"].tap()
        app.buttons["Delete entry"].tap()
        XCTAssertTrue(app.buttons["Keep message"].waitForExistence(timeout: 3))
        app.buttons["Keep message"].tap()
        XCTAssertTrue(app.navigationBars["Journal"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Talk"].tap()
        XCTAssertTrue(app.staticTexts["Earlier conversations"].waitForExistence(timeout: 5), "the conversation is kept")
    }

    /// TK7: editing an earlier message starts again from there; the earlier branch is one tap away.
    func testEditBranchesAndAnEarlierBranchComesBack() throws {
        continueAfterFailure = false
        let app = launchGuest(fresh: true)
        startTalk(app, saying: "first try")
        app.buttons["Edit"].firstMatch.tap()
        let edit = app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", "Edit message")).firstMatch
        XCTAssertTrue(edit.waitForExistence(timeout: 3))
        edit.tap(); edit.typeText(" again")
        // The edit box's Send (the composer's stays disabled while it's empty).
        try XCTUnwrap(app.buttons.matching(identifier: "Send").allElementsBoundByIndex.first { $0.isEnabled }).tap()
        // Tapping a text field doesn't promise a cursor at the end, so check the added word only.
        XCTAssertTrue(has(app, "again"), "the edited words are the new version")
        XCTAssertTrue(app.buttons["Previous version"].waitForExistence(timeout: 10))
        app.buttons["Previous version"].tap()
        XCTAssertTrue(app.staticTexts["first try"].waitForExistence(timeout: 5), "the earlier branch is back")
        XCTAssertTrue(app.staticTexts["SAY IT LIKE THIS"].exists, "with its suggestion")
    }

    /// The composer stays above the keyboard, at normal and the largest text.
    func testComposerStaysAboveKeyboard() throws { try checkComposer([]) }
    func testComposerStaysAboveKeyboardAtLargestText() throws {
        try checkComposer(["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"])
    }

    private func checkComposer(_ extra: [String]) throws {
        continueAfterFailure = false
        let app = launchGuest(fresh: true, extra)
        app.tabBars.buttons["Talk"].tap()
        let start = app.buttons["Start a conversation"]
        XCTAssertTrue(start.waitForExistence(timeout: 10))
        for _ in 0..<6 where !start.isHittable { app.swipeUp() }
        start.tap()
        let begin = app.buttons["Start"]
        for _ in 0..<6 where !begin.isHittable { app.swipeUp() }
        begin.tap()
        let field = talkField(app)
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap(); field.typeText("Could we agree on a time?")
        let keyboard = app.keyboards.firstMatch
        XCTAssertTrue(keyboard.waitForExistence(timeout: 5), "This check requires the software keyboard")
        let send = app.buttons["Send"]
        XCTAssertTrue(send.isHittable, "Send stays visible while writing")
        XCTAssertLessThanOrEqual(send.frame.maxY, keyboard.frame.minY + 1)
        shot(app, extra.isEmpty ? "talk-composer" : "talk-composer-ax5")
    }

    /// G1: the guide walks Write, Journal and Talk, and can be left at any step.
    func testGuideWalksAllThreeTabs() throws {
        continueAfterFailure = false
        let app = launchGuest(fresh: true)
        XCTAssertTrue(app.textViews["Your words"].waitForExistence(timeout: 15))
        app.buttons["Guide"].tap()
        XCTAssertTrue(has(app, "Step 1 of 13"))
        for step in 2...13 {
            app.buttons["Next"].tap()
            XCTAssertTrue(has(app, "Step \(step) of 13"), "step \(step)")
            if step == 8 { XCTAssertTrue(app.navigationBars["Journal"].exists, "the guide moved to Journal") }
        }
        app.buttons["Done"].tap()
        XCTAssertFalse(has(app, "Step 13 of 13", 1))
        app.tabBars.buttons["Write"].tap()
        app.buttons["Guide"].tap()
        app.buttons["Skip the guide"].tap()
        XCTAssertFalse(has(app, "Step 1 of 13", 1), "Skip leaves at once")
    }
}
