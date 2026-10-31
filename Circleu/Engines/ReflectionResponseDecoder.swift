import Foundation

/// Both model providers may wrap their JSON in Markdown or explanatory text.
enum ReflectionResponseDecoder {
    static func decode(_ response: String) throws -> AIReflectionResult {
        let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
        let decoder = JSONDecoder()
        if let result = try? decoder.decode(AIReflectionResult.self, from: Data(trimmed.utf8)) {
            return result
        }
        // Check ordering before constructing a range: malformed model output must never trap.
        guard let start = trimmed.firstIndex(of: "{"),
              let end = trimmed.lastIndex(of: "}"), start <= end,
              let result = try? decoder.decode(AIReflectionResult.self,
                                              from: Data(trimmed[start...end].utf8)) else {
            throw ReflectionEngineError.invalidModelResponse
        }
        return result
    }
}
