import XCTest
@testable import Circleu

/// Audit A06: model wording options are used only when they keep the contract, so option identity
/// (the tone) is unique and nothing oversized or off-contract reaches the screen.
final class GuestWordingValidationTests: XCTestCase {
    func testKeepsKnownTonesOnceInTheAskedOrder() {
        let options = LocalFirstSuggestionEngine.validatedOptions([
            ("Clear", "Could we agree on the split?"),
            ("gentle ", "Hi, could we talk about the split?"),
            ("Clear", "A second clear one"),
            ("Firm", "I need us to agree on the split."),
        ])
        XCTAssertEqual(options.map(\.tone), ["Clear", "Gentle", "Firm"], "case-insensitive, duplicates dropped")
        XCTAssertEqual(Set(options.map(\.id)).count, options.count, "unique SwiftUI identities")
        XCTAssertEqual(options[1].text, "Hi, could we talk about the split?")
    }

    func testDropsUnknownTonesEmptyTextAndOversizedOptions() {
        let long = Array(repeating: "word", count: LocalFirstSuggestionEngine.maximumOptionWords + 1).joined(separator: " ")
        let options = LocalFirstSuggestionEngine.validatedOptions([
            ("Sarcastic", "Fine, whatever."),
            ("Gentle", "   "),
            ("Clear", long),
            ("Firm", "Can we agree on that?"),
        ])
        XCTAssertEqual(options.map(\.tone), ["Firm"])
    }

    func testNothingValidLeavesTheGuidedFallbackToTheEngine() {
        XCTAssertTrue(LocalFirstSuggestionEngine.validatedOptions([("Odd", "x")]).isEmpty)
    }
}
