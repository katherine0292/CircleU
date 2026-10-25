import SwiftUI

/// Composition root for the guest journal: opens the local store and nothing else. It never
/// constructs Firebase, sync, backup or cloud services, and never reads legacy UserDefaults keys.
struct GuestRootView: View {
    private enum Phase {
        case opening
        case ready(GuestJournalViewModel)
        case failed(String)
    }

    @State private var phase: Phase = .opening

    var body: some View {
        switch phase {
        case .opening:
            ProgressView("Opening your journal…")
                .task { await open() }
        case .ready(let viewModel):
            GuestJournalView(viewModel: viewModel)
        case .failed(let message):
            VStack(spacing: 16) {
                Text(message).multilineTextAlignment(.center)
                Button("Try again") { phase = .opening }
                    .buttonStyle(.borderedProminent)
            }
            .padding(24)
        }
    }

    private func open() async {
        do {
            let store = try await SwiftDataGuestJournalStore.open(location: try GuestJournalLocation.standard())
            let viewModel = GuestJournalViewModel(store: store)
            await viewModel.load()
            phase = .ready(viewModel)
        } catch {
            phase = .failed(GuestJournalViewModel.openFailureMessage(for: error))
        }
    }
}

/// Minimal journal list for step 3. Writing and editing screens come in the next step.
struct GuestJournalView: View {
    @ObservedObject var viewModel: GuestJournalViewModel

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.loadState {
                case .loading:
                    ProgressView()
                case .failed(let message):
                    VStack(spacing: 16) {
                        Text(message).multilineTextAlignment(.center)
                        Button("Try again") { Task { await viewModel.load() } }
                    }
                    .padding(24)
                case .loaded(let entries) where entries.isEmpty:
                    Text("Nothing saved yet.").foregroundStyle(.secondary)
                case .loaded(let entries):
                    List(entries) { entry in
                        Text(entry.originalWords).lineLimit(3)
                    }
                }
            }
            .navigationTitle("Journal")
        }
    }
}
