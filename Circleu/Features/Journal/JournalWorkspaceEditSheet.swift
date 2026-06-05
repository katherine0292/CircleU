import SwiftUI

struct JournalWorkspaceEditSheet: View {
    let entry: JournalReflectionEntry
    let onSave: (String, String, String, [String]) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: JournalWorkspaceEditViewModel

    init(
        entry: JournalReflectionEntry,
        onSave: @escaping (String, String, String, [String]) -> Void
    ) {
        self.entry = entry
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: JournalWorkspaceEditViewModel(entry: entry))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PinguScreenBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Edit workspace")
                                .font(PinguFont.screenTitle)
                                .foregroundStyle(PinguDesign.ink)

                            Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(PinguDesign.muted)
                        }

                        PinguTextInput(title: "Title", placeholder: "Reflection title", text: $viewModel.title)
                        PinguTextInput(title: "Emotion", placeholder: "Emotion", text: $viewModel.emotion)
                        PinguTextInput(
                            title: "Private note",
                            placeholder: "Add a note only you can see",
                            text: $viewModel.privateNote,
                            axis: .vertical
                        )
                        PinguTextInput(title: "Tags", placeholder: "class, confidence, tips", text: $viewModel.tagsText)
                    }
                    .padding(.horizontal, PinguDesign.screenSidePadding)
                    .padding(.top, 20)
                    .padding(.bottom, 34)
                }
            }
            .navigationTitle("Workspace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(viewModel.title, viewModel.emotion, viewModel.privateNote, viewModel.parsedTags)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }

}

#Preview {
    JournalWorkspaceEditSheet(entry: .preview) { _, _, _, _ in }
}
