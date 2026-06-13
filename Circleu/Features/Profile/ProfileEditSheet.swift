import SwiftUI

struct ProfileEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var profileStore: UserProfileStore
    @EnvironmentObject private var backendSessionStore: BackendSessionStore
    @StateObject private var viewModel = ProfileEditViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                PinguScreenBackground()

                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Edit display name")
                            .font(PinguFont.screenTitle)
                            .foregroundStyle(PinguDesign.ink)

                        Text("This is the name your circle members and the AI will greet you with.")
                            .font(PinguFont.body)
                            .foregroundStyle(PinguDesign.muted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("DISPLAY NAME")
                            .font(PinguFont.tiny)
                            .foregroundStyle(PinguDesign.muted)
                            .tracking(1.0)

                        TextField("Your display name", text: $viewModel.draftName)
                            .font(PinguFont.body)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(.white.opacity(0.65))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(PinguDesign.border, lineWidth: 1)
                            }
                    }

                    Spacer()

                    Button {
                        viewModel.save(profileStore: profileStore, backendSessionStore: backendSessionStore)
                        dismiss()
                    } label: {
                        Text("Save Changes")
                            .font(PinguFont.button)
                    }
                    .buttonStyle(PinguPrimaryButtonStyle())
                }
                .padding(.horizontal, PinguDesign.screenSidePadding)
                .padding(.bottom, 34)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.load(profileStore: profileStore)
        }
    }
}
