import Foundation
import XCTest

/// Enforces docs/design/screen-content-guidelines.md for the guest journal's on-screen text:
/// length limits and banned wording, read straight from the source files.
final class GuestCopyLintTests: XCTestCase {
    private let limit = 100
    private let detailLimit = 120
    private let banned = ["ai analysis", "analyses you", "analyzes you", "diagnos", "demo", "sample", "lorem"]

    private var sources: [URL] {
        let repo = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let folder = repo.appendingPathComponent("Circleu/Features/GuestJournal")
        let files = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
        return files.filter { $0.pathExtension == "swift" }
            + [repo.appendingPathComponent("Circleu/Services/GuestJournal/GuestSuggestionEngine.swift")]
    }

    func testOnScreenTextFollowsTheGuidelines() throws {
        let files = sources
        XCTAssertGreaterThan(files.count, 5, "guest journal sources found")
        let literal = try NSRegularExpression(pattern: #""((?:[^"\\]|\\.)*)""#)
        var problems: [String] = []
        for file in files {
            let lines = try String(contentsOf: file, encoding: .utf8).components(separatedBy: "\n")
            for (index, line) in lines.enumerated() {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("//") || trimmed.hasPrefix("///") { continue }
                let marker = index > 0 ? lines[index - 1] + line : line
                if marker.contains("copy: export") { continue }
                let maxLength = marker.contains("copy: detail") ? detailLimit : limit
                for match in literal.matches(in: line, range: NSRange(line.startIndex..., in: line)) {
                    guard let range = Range(match.range(at: 1), in: line) else { continue }
                    let text = String(line[range])
                    guard text.contains(" ") else { continue } // Identifiers, keys and asset names.
                    if text.count > maxLength {
                        problems.append("\(file.lastPathComponent):\(index + 1) is \(text.count) characters (max \(maxLength))")
                    }
                    let lower = text.lowercased()
                    for word in banned where lower.contains(word) {
                        problems.append("\(file.lastPathComponent):\(index + 1) uses banned wording “\(word)”")
                    }
                }
            }
        }
        XCTAssertTrue(problems.isEmpty, "See docs/design/screen-content-guidelines.md:\n" + problems.joined(separator: "\n"))
    }
}
