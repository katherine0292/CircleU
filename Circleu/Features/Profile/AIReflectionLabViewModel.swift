#if DEBUG
import Combine
import Foundation
import UIKit

@MainActor
final class AIReflectionLabViewModel: ObservableObject {
    @Published var selectedSession: AIReflectionSession?
    @Published var statusMessage = "Ready to inspect AI reflection sessions."

    func copyAll(from aiSessionStore: AIReflectionSessionStore) {
        UIPasteboard.general.string = aiSessionStore.exportText()
        statusMessage = "Copied AI QA export to clipboard."
    }

    func copySession(_ session: AIReflectionSession) {
        UIPasteboard.general.string = session.exportText
        statusMessage = "Copied AI session export to clipboard."
    }
}
#endif
