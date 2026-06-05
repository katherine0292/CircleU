import Combine
import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var selectedPage = 0
    @Published var draftName = ""

    let pages = PinguOnboardingPage.allPages

    var primaryButtonTitle: String {
        selectedPage == pages.indices.last ? "Start Reflecting" : "Continue"
    }

    var primaryButtonIcon: String {
        selectedPage == pages.indices.last ? "mic.fill" : "arrow.right"
    }

    func advance(profileStore: UserProfileStore, onContinue: () -> Void) {
        if selectedPage == pages.indices.last {
            completeOnboarding(profileStore: profileStore, onContinue: onContinue)
        } else {
            selectedPage += 1
        }
    }

    func completeOnboarding(profileStore: UserProfileStore, onContinue: () -> Void) {
        let name = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !profileStore.hasDisplayName {
            profileStore.updateDisplayName(name.isEmpty ? "Friend" : name)
        } else if !name.isEmpty {
            profileStore.updateDisplayName(name)
        }

        onContinue()
    }
}
