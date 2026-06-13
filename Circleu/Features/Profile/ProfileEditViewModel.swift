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

    func save(profileStore: UserProfileStore, backendSessionStore: BackendSessionStore) {
        let nameToSave = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = nameToSave.isEmpty ? "Friend" : nameToSave
        
        profileStore.updateDisplayName(finalName)
        
        if backendSessionStore.backendUserID != nil {
            Task {
                try? await backendSessionStore.updateDisplayName(finalName)
            }
        }
    }
}
