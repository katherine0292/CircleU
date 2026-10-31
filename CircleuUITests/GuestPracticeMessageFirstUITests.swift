import XCTest

/// P9: message-first Practice. Guided suggestions keep the result predictable.
final class GuestPracticeMessageFirstUITests: XCTestCase {
    func has(_ app: XCUIApplication, _ text: String, _ timeout: TimeInterval = 5) -> Bool {
        app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", text)).firstMatch.waitForExistence(timeout: timeout)
    }
    func shot(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = name; shot.lifetime = .keepAlways; add(shot)
    }

    /// P9.1, P9.2, P9.5: words first, guidance keeps them, Use / Undo / Copy / Save stay separate.
    func testWordsFirstGuidanceAndUseUndoSave() throws {
        continueAfterFailure = false
        let app = launchGuest(fresh: true, ["-CircleUGuidedSuggestions", "YES"])
        app.tabBars.buttons["Practice"].tap()
        XCTAssertTrue(app.buttons["Practice a message"].waitForExistence(timeout: 10))
        app.buttons["Practice a message"].tap()
        let wording = app.textViews["Your wording"]
        XCTAssertTrue(wording.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Review wording"].isEnabled, "no words, nothing to review")
        XCTAssertFalse(app.textFields["Situation"].exists, "no form before writing")
        wording.tap(); wording.typeText("Can you take a fair share before Friday?")
        XCTAssertTrue(app.buttons["Review wording"].isEnabled)
        shot(app, "m1-words")

        app.buttons["Help me get started"].tap()
        XCTAssertTrue(has(app, "What do you want to happen?"))
        XCTAssertFalse(app.buttons["Continue"].isEnabled, "blank intent can't continue")
        let intent = app.textFields["Your intent"]
        intent.tap(); intent.typeText("Agree on a fair split")
        app.buttons["Continue"].tap()
        XCTAssertTrue(has(app, "What would you like to say?"))
        XCTAssertEqual((wording.value as? String ?? ""), "Can you take a fair share before Friday?", "words survive guidance")
        XCTAssertEqual(app.buttons["Your intent"].value as? String, "Agree on a fair split", "shown as intent")
        shot(app, "m2-intent")

        app.buttons["Review wording"].tap()
        XCTAssertTrue(has(app, "Suggested wording", 10))
        XCTAssertTrue(has(app, "Guided prompts, not a personal analysis"))
        shot(app, "m3-result")
        app.buttons["Compare with mine"].tap()
        XCTAssertTrue(has(app, "My wording"))
        XCTAssertTrue(app.buttons["Use the gentle option"].exists || app.buttons["Use the firm option"].exists)
        shot(app, "m4-compare")
        app.buttons["Use this wording"].tap()
        XCTAssertTrue(app.buttons["Save"].waitForExistence(timeout: 5))
        let used = wording.value as? String ?? ""
        XCTAssertTrue(used.contains("fair share before Friday"), "the suggestion keeps my words: \(used)")
        XCTAssertNotEqual(used, "Can you take a fair share before Friday?", "it's the suggestion, not my draft")
        app.buttons["Undo suggestion"].tap()
        XCTAssertEqual((wording.value as? String ?? ""), "Can you take a fair share before Friday?", "undone")
        app.buttons["Copy"].tap()
        XCTAssertTrue(app.buttons["Copied"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Save"].isEnabled, "copy didn't save")
        app.buttons["Save"].tap()
        XCTAssertTrue(has(app, "Saved · not sent"))
        shot(app, "m5-saved")
        app.buttons["Back"].tap()
        XCTAssertTrue(has(app, "Can you take a fair share before Friday?"), "in history without retyping")
    }

    /// P9.3: a blank start needs an intent; the result is labelled as intent, never as my message.
    func testBlankStartFindsWordsFromIntentOnly() throws {
        continueAfterFailure = false
        let app = launchGuest(fresh: true, ["-CircleUGuidedSuggestions", "YES"])
        app.tabBars.buttons["Practice"].tap()
        XCTAssertTrue(app.buttons["Practice a message"].waitForExistence(timeout: 10))
        app.buttons["Practice a message"].tap()
        XCTAssertTrue(app.buttons["Help me get started"].waitForExistence(timeout: 5))
        app.buttons["Help me get started"].tap()
        let intent = app.textFields["Your intent"]
        XCTAssertTrue(intent.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Continue"].isEnabled)
        intent.tap(); intent.typeText("Agree on a fair split of the slides")
        app.buttons["Continue"].tap()
        XCTAssertTrue(app.buttons["Find words from my intent"].waitForExistence(timeout: 5), "no words yet, so words come from the intent")
        XCTAssertFalse(app.buttons["Save without feedback"].isEnabled, "nothing to save yet")
        app.buttons["Find words from my intent"].tap()
        XCTAssertTrue(has(app, "Suggested wording", 10))
        app.buttons["Compare with mine"].tap()
        XCTAssertTrue(has(app, "From your intent"), "labelled as intent")
        XCTAssertFalse(app.staticTexts["My wording"].exists, "never shown as words I wrote")
        shot(app, "m6-from-intent")
        app.buttons["Keep my wording"].tap()
        XCTAssertTrue(app.buttons["Save"].waitForExistence(timeout: 5))
        XCTAssertEqual((app.textViews["Your wording"].value as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines), "", "nothing was written for me")
        XCTAssertFalse(app.buttons["Save"].isEnabled)
    }

    /// Saving without feedback saves my words as they are, with no request made.
    func testSaveWithoutFeedback() throws {
        continueAfterFailure = false
        let app = launchGuest(fresh: true, ["-CircleUGuidedSuggestions", "YES"])
        app.tabBars.buttons["Practice"].tap()
        XCTAssertTrue(app.buttons["Practice a message"].waitForExistence(timeout: 10))
        app.buttons["Practice a message"].tap()
        let wording = app.textViews["Your wording"]
        XCTAssertTrue(wording.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Save without feedback"].isEnabled)
        wording.tap(); wording.typeText("Could we talk on Friday?")
        app.buttons["Save without feedback"].tap()
        XCTAssertTrue(has(app, "Saved · not sent"))
        XCTAssertFalse(app.staticTexts["Suggested wording"].exists, "no request was made")
        app.buttons["Back"].tap()
        XCTAssertTrue(has(app, "Could we talk on Friday?"))
    }
}
