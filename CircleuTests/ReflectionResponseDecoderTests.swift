import XCTest
@testable import Circleu

@MainActor
final class ReflectionResponseDecoderTests: XCTestCase {
    private let json = #"{"title":"A pause","emotion":"Calm","summary":"I wrote {a thought} and said \"hello\"","insight":"Take a breath","expressionMoment":"Asked clearly","quote":"Keep going","confidenceScore":0.7,"suggestedQuest":"Try again"}"#

    func testDecodesRawFencedAndPrefixedObjectsWithoutLosingQuotedBraces() throws {
        for response in [json, " \n\(json)\n ", "```json\n\(json)\n```", "Here is the reflection:\n\(json)\nEnd"] {
            let result = try ReflectionResponseDecoder.decode(response)
            XCTAssertEqual(result.title, "A pause")
            XCTAssertEqual(result.summary, "I wrote {a thought} and said \"hello\"")
            XCTAssertEqual(result.confidenceScore, 0.7)
        }
    }

    func testRejectsReversedMissingMalformedAndSchemaInvalidObjects() {
        for response in ["", "} then {", "only {", "only }", "plain words", "{broken}", "{}", #"{"title":2}"#, "[\(json),\(json)]"] {
            XCTAssertThrowsError(try ReflectionResponseDecoder.decode(response), response) { error in
                guard case ReflectionEngineError.invalidModelResponse = error else {
                    return XCTFail("Unexpected error: \(error)")
                }
            }
        }
    }
}
