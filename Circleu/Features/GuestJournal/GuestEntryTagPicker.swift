import Combine
import SwiftUI

@MainActor
final class GuestEntryTagViewModel: ObservableObject {
    @Published var context: GuestEntryContext?
    @Published var feeling: GuestEntryFeeling?
    @Published private(set) var error: String?
    @Published private(set) var isSaving = false
    @Published private(set) var needsReopen = false
    private let entry: GuestJournalEntry
    private let journal: GuestJournalViewModel

    init(entry: GuestJournalEntry, journal: GuestJournalViewModel) {
        self.entry = entry
        self.journal = journal
        context = entry.context
        feeling = entry.feeling
    }

    func save() async -> Bool {
        guard !isSaving, !needsReopen else { return false }
        guard let store = journal.store as? any GuestEntryTagStore else {
            self.error = GuestJournalViewModel.saveFailedMessage
            return false
        }
        isSaving = true
        defer { isSaving = false }
        error = nil
        do {
            _ = try await store.updateTags(id: entry.id, context: context, feeling: feeling,
                                            expectedRevision: entry.revision)
        } catch GuestJournalError.savedButUnprotected {
            journal.addNotice(GuestJournalViewModel.savedButUnprotectedMessage)
        } catch GuestJournalError.staleRevision {
            error = "This entry changed. Close and try again."
            needsReopen = true
            await journal.load()
            return false
        } catch GuestJournalError.notFound {
            error = "This entry was deleted. Close to return to your journal."
            needsReopen = true
            await journal.load()
            return false
        } catch {
            self.error = GuestJournalViewModel.saveFailedMessage
            return false
        }
        await journal.load()
        return true
    }
}

extension GuestEntryContext {
    var asset: String { "GuestPingu\(title)Tag" }
}
extension GuestEntryFeeling {
    var asset: String { "GuestFeeling\(title)" }
}

struct GuestEntryTagPicker: View {
    @StateObject private var model: GuestEntryTagViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize

    init(entry: GuestJournalEntry, journal: GuestJournalViewModel) {
        _model = StateObject(wrappedValue: GuestEntryTagViewModel(entry: entry, journal: journal))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Tap a selected tag to remove it")
                        .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.muted)
                    section("Conversation context") {
                        ForEach(GuestEntryContext.allCases, id: \.self) { context in
                            choice(context.title, asset: context.asset, selected: model.context == context) {
                                model.context = model.context == context ? nil : context
                            }
                        }
                    }
                    section("Feeling · optional") {
                        ForEach(GuestEntryFeeling.allCases, id: \.self) { feeling in
                            choice(feeling.title, asset: feeling.asset, selected: model.feeling == feeling) {
                                model.feeling = model.feeling == feeling ? nil : feeling
                            }
                        }
                    }
                    if let error = model.error {
                        Text(error).font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
                            .accessibilityLabel(error)
                    }
                }
                .padding(24)
            }
            .disabled(model.isSaving)
            .background(GuestBrand.ice)
            .navigationTitle("Your tags").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Image(systemName: "xmark").frame(minWidth: 44, minHeight: 44) }
                        .accessibilityLabel("Cancel tags").disabled(model.isSaving)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(model.isSaving ? "Saving…" : "Done") {
                    Task { if await model.save() { dismiss() } }
                }
                .buttonStyle(GuestBrandButtonStyle())
                .disabled(model.isSaving || model.needsReopen)
                .padding(.horizontal, 24).padding(.vertical, 12).background(GuestBrand.ice)
            }
        }
        .font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink).tint(GuestBrand.blue)
        .interactiveDismissDisabled(model.isSaving)
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(GuestBrand.font(.subheadline, .semibold)).accessibilityAddTraits(.isHeader)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: typeSize.isAccessibilitySize ? 230 : 94))], spacing: 12,
                      content: content)
        }
    }

    private func choice(_ title: String, asset: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(asset).resizable().scaledToFit().frame(height: 64).accessibilityHidden(true)
                Text(title).font(GuestBrand.font(.caption, .semibold))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(10).frame(maxWidth: .infinity, minHeight: 100)
            .background(selected ? GuestBrand.wash : .white, in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(selected ? GuestBrand.blue : .clear, lineWidth: 2))
        }
        .buttonStyle(.plain).accessibilityLabel(title)
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityHint(selected ? "Tap to remove" : "Tap to select")
    }
}

struct GuestJournalDayGroup: Identifiable {
    let id: Date
    let entries: [GuestJournalEntry]
    static func make(_ entries: [GuestJournalEntry], calendar: Calendar = .current) -> [Self] {
        Dictionary(grouping: entries, by: { calendar.startOfDay(for: $0.createdAt) })
            .map { Self(id: $0.key, entries: $0.value.sorted {
                $0.createdAt == $1.createdAt ? $0.id.uuidString < $1.id.uuidString : $0.createdAt > $1.createdAt
            }) }
            .sorted { $0.id > $1.id }
    }
}
