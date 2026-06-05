import Combine
import Foundation

@MainActor
final class JournalWorkspaceEditViewModel: ObservableObject {
    @Published var title: String
    @Published var emotion: String
    @Published var privateNote: String
    @Published var tagsText: String

    init(entry: JournalReflectionEntry) {
        title = entry.displayTitle
        emotion = entry.displayEmotion
        privateNote = entry.privateNote
        tagsText = entry.tags.joined(separator: ", ")
    }

    var parsedTags: [String] {
        tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
