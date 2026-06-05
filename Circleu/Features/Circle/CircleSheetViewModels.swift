import Combine
import Foundation

@MainActor
final class CircleCreateViewModel: ObservableObject {
    @Published var name = ""
    @Published var intention = ""

    var canSave: Bool {
        !clean(name).isEmpty && !clean(intention).isEmpty
    }

    func create(circleStore: CircleStore) {
        circleStore.createCircle(name: name, intention: intention)
    }

    private func clean(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

@MainActor
final class CircleDetailViewModel: ObservableObject {
    @Published var noteTitle = ""
    @Published var noteBody = ""
    @Published var showEditCircle = false
    @Published var showReflectionPicker = false
    @Published var editingPost: CirclePost?

    var canSaveNote: Bool {
        !clean(noteTitle).isEmpty && !clean(noteBody).isEmpty
    }

    func circle(id: UUID, circleStore: CircleStore) -> CircleSpace? {
        circleStore.circles.first { $0.id == id }
    }

    func saveNote(circle: CircleSpace, circleStore: CircleStore) {
        circleStore.addNote(circle: circle, title: noteTitle, body: noteBody)
        noteTitle = ""
        noteBody = ""
    }

    func edit(_ post: CirclePost) {
        editingPost = post
    }

    private func clean(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

@MainActor
final class CircleEditViewModel: ObservableObject {
    @Published var name = ""
    @Published var intention = ""
    private var hasLoaded = false

    var canSave: Bool {
        !clean(name).isEmpty && !clean(intention).isEmpty
    }

    func load(circle: CircleSpace) {
        guard !hasLoaded else { return }
        hasLoaded = true
        name = circle.name
        intention = circle.intention
    }

    func save(circle: CircleSpace, circleStore: CircleStore) {
        circleStore.updateCircle(circle, name: name, intention: intention)
    }

    private func clean(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

@MainActor
final class CirclePostEditViewModel: ObservableObject {
    @Published var title = ""
    @Published var postBody = ""
    private var hasLoaded = false

    var canSave: Bool {
        !clean(title).isEmpty && !clean(postBody).isEmpty
    }

    func load(post: CirclePost) {
        guard !hasLoaded else { return }
        hasLoaded = true
        title = post.title
        postBody = post.body
    }

    func save(post: CirclePost, circleStore: CircleStore) {
        circleStore.updatePost(post, title: title, body: postBody)
    }

    private func clean(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
