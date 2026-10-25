import Foundation
import XCTest

/// Enforces docs/design/screen-content-guidelines.md for the guest journal's on-screen text:
/// length limits and banned wording, read straight from the source files.
final class GuestCopyLintTests: XCTestCase {
    private let limit = 100
    private let detailLimit = 120
    /// Whole words or phrases, so "demonstrate" isn't flagged.
    private let banned = [#"\bai analysis\b"#, #"\banaly[sz]es you\b"#, #"\bdiagnos(e|is|es)\b"#, #"\bdemo\b"#,
                          #"\bsample\b"#, #"\blorem\b"#]

    /// Every Swift file under the guest journal's feature and service folders, recursively. The test
    /// reads the checkout it was built from (Simulator and CI hosts); it skips where that isn't
    /// reachable, for example on a device.
    private var sources: [URL] {
        let repo = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        return ["Circleu/Features/GuestJournal", "Circleu/Services/GuestJournal"].flatMap { path -> [URL] in
            let enumerator = FileManager.default.enumerator(at: repo.appendingPathComponent(path), includingPropertiesForKeys: nil)
            return (enumerator?.allObjects as? [URL] ?? []).filter { $0.pathExtension == "swift" }
        }
    }

    func testOnScreenTextFollowsTheGuidelines() throws {
        let files = sources
        try XCTSkipIf(files.isEmpty, "source checkout not reachable from this test host")
        XCTAssertGreaterThan(files.count, 8, "guest journal sources found")
        let bannedPatterns = try banned.map { try NSRegularExpression(pattern: $0, options: .caseInsensitive) }
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
                    for pattern in bannedPatterns
                    where pattern.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil {
                        problems.append("\(file.lastPathComponent):\(index + 1) uses banned wording (\(pattern.pattern))")
                    }
                    // Length applies to sentences, not identifiers, keys or asset names.
                    if text.contains(" "), text.count > maxLength {
                        problems.append("\(file.lastPathComponent):\(index + 1) is \(text.count) characters (max \(maxLength))")
                    }
                }
            }
        }
        XCTAssertTrue(problems.isEmpty, "See docs/design/screen-content-guidelines.md:\n" + problems.joined(separator: "\n"))
    }
}
