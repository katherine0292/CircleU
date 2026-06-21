import SwiftUI

struct TrustSafetyView: View {
    @EnvironmentObject private var journalStore: ReflectionJournalStore
    @EnvironmentObject private var profileStore: UserProfileStore
    @EnvironmentObject private var circleStore: CircleStore
    @EnvironmentObject private var questStore: QuestStore
    @EnvironmentObject private var tipsPracticeStore: TipsPracticeStore
    @EnvironmentObject private var aiSessionStore: AIReflectionSessionStore
    @EnvironmentObject private var rewardsStore: RewardsStore
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var backendSessionStore: BackendSessionStore
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                NavigationLink {
                    PolicyDetailView(
                        title: "Privacy Policy",
                        content: privacyPolicy
                    )
                } label: {
                    PolicyCard(
                        icon: "lock.shield.fill",
                        title: "Privacy Policy",
                        subtitle: "How your information is handled."
                    )
                }

                NavigationLink {
                    PolicyDetailView(
                        title: "Community Guidelines",
                        content: communityGuidelines
                    )
                } label: {
                    PolicyCard(
                        icon: "person.2.fill",
                        title: "Community Guidelines",
                        subtitle: "How we keep it safe and supportive."
                    )
                }

                NavigationLink {
                    PolicyDetailView(
                        title: "How CircleU Uses AI",
                        content: aiPolicy
                    )
                } label: {
                    PolicyCard(
                        icon: "sparkles",
                        title: "How CircleU Uses AI",
                        subtitle: "Understanding AI-generated insights."
                    )
                }

                NavigationLink {
                    PolicyDetailView(
                        title: "Safety & Wellbeing",
                        content: safetyPolicy
                    )
                } label: {
                    PolicyCard(
                        icon: "heart.fill",
                        title: "Safety & Wellbeing",
                        subtitle: "Supportive reflection, not therapy."
                    )
                }

                if backendSessionStore.session != nil {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Delete Account & Data")
                            if isDeleting {
                                Spacer()
                                ProgressView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.red.opacity(0.1))
                        .foregroundStyle(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    .disabled(isDeleting)
                    .padding(.top, 24)
                }
            }
            .padding()
        }
        .navigationTitle("Trust & Safety")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Permanently delete your account?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete My Account", role: .destructive) {
                deleteAccount()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete your authentication account, delete your entire reflection & journal backup from the cloud, and fully reset this device. This cannot be undone.")
        }
        .alert("Failed to Delete Account", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage + "\n\nFor security reasons, Apple and Firebase may require you to sign out and sign back in recently before deleting your account.")
        }
    }

    private func deleteAccount() {
        isDeleting = true
        Task {
            do {
                try await backendSessionStore.deleteAccount(
                    authStore: authStore,
                    profileStore: profileStore,
                    journalStore: journalStore,
                    questStore: questStore,
                    tipsPracticeStore: tipsPracticeStore,
                    rewardsStore: rewardsStore,
                    aiSessionStore: aiSessionStore,
                    circleStore: circleStore,
                    hasCompletedOnboarding: &hasCompletedOnboarding
                )
            } catch {
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
            isDeleting = false
        }
    }
}

struct PolicyCard: View {

    let icon: String
    let title: String
    let subtitle: String

    var body: some View {

        HStack(spacing: 16) {

            Image(systemName: icon)
                .font(.title2)

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 24
            )
        )
    }
}

#Preview{
    TrustSafetyView()
}
