import Foundation

/// External cloud-based reflection analyzer that routes requests to a remote
/// LLM (e.g., Gemini) when the user consents and enables it, falling back to
/// `LocalReflectionEngine` on failure or if consent is not granted.
struct CloudReflectionEngine: ReflectionAnalyzing {
    let displayName = "Cloud AI (Gemini)"
    private let fallback: LocalReflectionEngine
    private let hasConsent: @Sendable () -> Bool
    private let isEnabled: @Sendable () -> Bool
    private let apiKey: String?

    init(
        fallback: LocalReflectionEngine = LocalReflectionEngine(),
        apiKey: String? = nil,
        hasConsent: @Sendable @escaping () -> Bool,
        isEnabled: @Sendable @escaping () -> Bool
    ) {
        self.fallback = fallback
        self.apiKey = apiKey
        self.hasConsent = hasConsent
        self.isEnabled = isEnabled
    }

    var availabilityMessage: String? {
        if !hasConsent() {
            return "Consent is required to process reflections in the cloud. Using local fallback."
        }
        if !isEnabled() {
            return "Cloud AI is disabled in settings. Using local fallback."
        }
        return nil
    }

    func analyze(transcript: String, durationSeconds: Int) async throws -> AIReflectionResult {
        let cleanTranscript = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTranscript.isEmpty else { throw ReflectionEngineError.emptyTranscript }

        // Enforce user consent and opt-in settings check
        guard hasConsent(), isEnabled() else {
            return try await fallback.analyze(transcript: cleanTranscript, durationSeconds: durationSeconds)
        }

        do {
            return try await executeRemoteRequest(transcript: cleanTranscript, durationSeconds: durationSeconds)
        } catch {
            // Fall back to local engine if network request fails or response is invalid
            return try await fallback.analyze(transcript: cleanTranscript, durationSeconds: durationSeconds)
        }
    }

    private func executeRemoteRequest(transcript: String, durationSeconds: Int) async throws -> AIReflectionResult {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            throw NSError(domain: "CloudReflectionEngine", code: 401, userInfo: [NSLocalizedDescriptionKey: "API Key is missing"])
        }

        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let instructions = ReflectionPromptContent.instructions
        let promptText = ReflectionPromptContent.prompt(transcript: transcript, durationSeconds: durationSeconds)

        let payload: [String: Any] = [
            "contents": [
                ["parts": [["text": promptText]]]
            ],
            "systemInstruction": [
                "parts": [["text": instructions]]
            ],
            "generationConfig": [
                "responseMimeType": "application/json"
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "CloudReflectionEngine", code: 500, userInfo: [NSLocalizedDescriptionKey: "Server returned error status"])
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let textResponse = firstPart["text"] as? String else {
            throw ReflectionEngineError.invalidModelResponse
        }

        return try decodeReflectionResult(from: textResponse)
    }

    private func decodeReflectionResult(from rawResponse: String) throws -> AIReflectionResult {
        let trimmed = rawResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        let jsonText: String

        if let start = trimmed.firstIndex(of: "{"),
           let end = trimmed.lastIndex(of: "}") {
            jsonText = String(trimmed[start...end])
        } else {
            jsonText = trimmed
        }

        guard let jsonData = jsonText.data(using: .utf8),
              let result = try? JSONDecoder().decode(AIReflectionResult.self, from: jsonData) else {
            throw ReflectionEngineError.invalidModelResponse
        }

        return result
    }
}
