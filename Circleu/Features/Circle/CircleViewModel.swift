import Combine
import Foundation

@MainActor
final class CircleViewModel: ObservableObject {
    @Published var selectedCircle: CircleSpace?
    @Published var showCreateCommunity = false

    func postCount(for circle: CircleSpace, circleStore: CircleStore) -> Int {
        circleStore.posts(for: circle).count
    }

    func lastActivity(for circle: CircleSpace, circleStore: CircleStore) -> Date? {
        circleStore.lastActivity(for: circle)
    }

    func open(_ circle: CircleSpace) {
        selectedCircle = circle
    }

    func showCreateSheet() {
        showCreateCommunity = true
    }
}
