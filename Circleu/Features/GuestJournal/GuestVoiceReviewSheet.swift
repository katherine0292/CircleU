import SwiftUI
import UIKit

struct GuestVoiceReviewSheet: View {
    @StateObject private var model: GuestVoiceReviewModel
    let use: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @FocusState private var editing: Bool

    init(engine: any GuestDictationEngine, use: @escaping (String) -> Void) {
        _model = StateObject(wrappedValue: GuestVoiceReviewModel(engine: engine))
        self.use = use
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Image("GuestPinguListening").resizable().scaledToFit().frame(height: 130)
                        .frame(maxWidth: .infinity).accessibilityHidden(true)
                    Text(model.isActive ? "Listening to you" : "Review your words")
                        .font(GuestBrand.font(.title2, .bold)).accessibilityAddTraits(.isHeader)
                    Text("On-device transcription · no audio saved")
                        .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                    TextEditor(text: $model.transcript).focused($editing)
                        .scrollContentBackground(.hidden).frame(minHeight: 180).padding(12)
                        .background(.white, in: RoundedRectangle(cornerRadius: 20))
                        .disabled(model.isActive).accessibilityLabel("Transcript")
                    if let error = model.error {
                        Text(error).font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
                    }
                    if model.needsSettings {
                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                        }.frame(minHeight: 44)
                    }
                    if !model.isActive && !model.transcript.isEmpty {
                        Button("Record more", systemImage: "mic") { editing = false; Task { await model.start() } }
                            .frame(minHeight: 44)
                    }
                }.padding(24)
            }
            .background(GuestBrand.ice.ignoresSafeArea())
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 10) {
                    if model.isActive {
                        Button(model.state == .finishing ? "Finishing…" : "Stop") { model.stop() }
                            .buttonStyle(GuestBrandButtonStyle()).disabled(model.state != .listening)
                    } else if model.canUse {
                        Button("Use text") {
                            let words = model.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
                            model.cancel(); editing = false; use(words); dismiss()
                        }.buttonStyle(GuestBrandButtonStyle())
                    } else {
                        Button("Record", systemImage: "mic") { editing = false; Task { await model.start() } }
                            .buttonStyle(GuestBrandButtonStyle())
                    }
                }.padding(.horizontal, 24).padding(.vertical, 12).background(GuestBrand.ice)
            }
            .navigationTitle("Voice input").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { model.cancel(); dismiss() }
            } }
        }
        .tint(GuestBrand.blue)
        .onDisappear { model.cancel() }
        .onChange(of: scenePhase) { _, phase in if phase == .background { model.interrupt() } }
        .onChange(of: model.error) { _, error in
            if let error { UIAccessibility.post(notification: .announcement, argument: error) }
        }
    }
}
