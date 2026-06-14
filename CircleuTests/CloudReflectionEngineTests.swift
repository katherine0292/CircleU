import XCTest
@testable import Circleu

final class CloudReflectionEngineTests: XCTestCase {

    func testCloudEngineFallsBackToLocalWhenConsentNotGranted() async throws {
        var consentChecked = false
        let engine = CloudReflectionEngine(
            fallback: LocalReflectionEngine(),
            apiKey: "some-key",
            hasConsent: {
                consentChecked = true
                return false
            },
            isEnabled: { true }
        )

        let transcript = "I felt proud because I finished the group update."
        let result = try await engine.analyze(transcript: transcript, durationSeconds: 60)

        XCTAssertTrue(consentChecked)
        XCTAssertEqual(result.title, "You noticed a meaningful win")
        XCTAssertEqual(result.emotion, "Proud")
    }

    func testCloudEngineFallsBackToLocalWhenDisabledInSettings() async throws {
        var isEnabledChecked = false
        let engine = CloudReflectionEngine(
            fallback: LocalReflectionEngine(),
            apiKey: "some-key",
            hasConsent: { true },
            isEnabled: {
                isEnabledChecked = true
                return false
            }
        )

        let transcript = "I felt sad and lonely after lunch."
        let result = try await engine.analyze(transcript: transcript, durationSeconds: 60)

        XCTAssertTrue(isEnabledChecked)
        XCTAssertEqual(result.title, "You gave a tender feeling some space")
        XCTAssertEqual(result.emotion, "Tender")
    }

    func testCloudEngineFallsBackToLocalOnNetworkFailure() async throws {
        let engine = CloudReflectionEngine(
            fallback: LocalReflectionEngine(),
            apiKey: "", // empty key will fail execution of executeRemoteRequest
            hasConsent: { true },
            isEnabled: { true }
        )

        let transcript = "I checked in and noticed I want tomorrow to feel clear."
        let result = try await engine.analyze(transcript: transcript, durationSeconds: 60)

        XCTAssertEqual(result.title, "You checked in with yourself")
        XCTAssertEqual(result.emotion, "Thoughtful")
    }
}
