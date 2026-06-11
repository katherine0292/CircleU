import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var journalStore = ReflectionJournalStore()
    @StateObject private var profileStore = UserProfileStore()
    @StateObject private var circleStore = CircleStore()
    @StateObject private var questStore = QuestStore()
    @StateObject private var tipsPracticeStore = TipsPracticeStore()
    @StateObject private var aiSessionStore = AIReflectionSessionStore()
    @StateObject private var rewardsStore = RewardsStore()
    @StateObject private var authStore = AuthStore()
    @StateObject private var backendSessionStore = BackendSessionStore()

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                RootView()
                    .onAppear { rewardsStore.claimDailyLogin() }
            } else {
                PinguOnboardingView {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                        hasCompletedOnboarding = true
                    }
                }
            }
        }
        .environmentObject(journalStore)
        .environmentObject(profileStore)
        .environmentObject(circleStore)
        .environmentObject(questStore)
        .environmentObject(tipsPracticeStore)
        .environmentObject(aiSessionStore)
        .environmentObject(rewardsStore)
        .environmentObject(authStore)
        .environmentObject(backendSessionStore)
        // Keep backend-aware stores tied to the current Firebase auth session: CircleStore
        // mirrors /circles for whoever is signed in, while journal + AI session stores scope
        // their on-device cache by UID so accounts cannot see each other's reflections.
        .onAppear {
            backendSessionStore.wireBackendStores(
                circleStore: circleStore,
                journalStore: journalStore,
                aiSessionStore: aiSessionStore,
                rewardsStore: rewardsStore,
                questStore: questStore,
                tipsPracticeStore: tipsPracticeStore,
                profileStore: profileStore
            )
        }
        .onChange(of: backendSessionStore.session?.uid) {
            backendSessionStore.wireBackendStores(
                circleStore: circleStore,
                journalStore: journalStore,
                aiSessionStore: aiSessionStore,
                rewardsStore: rewardsStore,
                questStore: questStore,
                tipsPracticeStore: tipsPracticeStore,
                profileStore: profileStore
            )
        }
    }
}

#Preview {
    ContentView()
}
