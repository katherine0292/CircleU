import SwiftUI

/// Builds the guest journal's dependencies: the local store and nothing else. It never constructs
/// Firebase, sync, backup or cloud services, and never reads legacy UserDefaults keys.
@MainActor
struct GuestComposition {
    var openStore: () async throws -> any GuestJournalStore

    static var live: GuestComposition {
        GuestComposition { try await SwiftDataGuestJournalStore.open(location: try GuestJournalLocation.standard()) }
    }

    /// The live composition at another location (tests use a temporary folder).
    static func local(at location: GuestJournalLocation) -> GuestComposition {
        GuestComposition { try await SwiftDataGuestJournalStore.open(location: location) }
    }

    func makeViewModel() async throws -> GuestJournalViewModel {
        let viewModel = GuestJournalViewModel(store: try await openStore())
        await viewModel.load()
        return viewModel
    }
}

/// Composition root for the guest journal.
struct GuestRootView: View {
    private enum Phase {
        case opening
        case ready(GuestJournalViewModel)
        case failed(String)
    }

    @State private var phase: Phase = .opening
    var composition: GuestComposition = .live

    var body: some View {
        switch phase {
        case .opening:
            ProgressView("Opening your journal…")
                .task { await open() }
        case .ready(let viewModel):
            GuestHomeView(journal: viewModel)
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
            phase = .ready(try await composition.makeViewModel())
        } catch {
            phase = .failed(GuestJournalViewModel.openFailureMessage(for: error))
        }
    }
}
