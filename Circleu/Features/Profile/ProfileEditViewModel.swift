import Combine
import Foundation

@MainActor
final class ProfileEditViewModel: ObservableObject {
    @Published var draftName = ""
    private var hasLoaded = false

    func load(profileStore: UserProfileStore) {
        guard !hasLoaded else { return }
        hasLoaded = true
        draftName = profileStore.displayName
    }

    func save(profileStore: UserProfileStore) {
        profileStore.updateDisplayName(draftName.isEmpty ? "Friend" : draftName)
    }
}
