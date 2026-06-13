import Foundation
import UIKit

final class HapticManager {
    static let shared = HapticManager()

    private init() {}

    /// Trigger a notification feedback (success, warning, error)
    func trigger(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        }
    }

    /// Trigger an impact feedback (light, medium, heavy, rigid, soft)
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        DispatchQueue.main.async {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
    }

    /// Trigger selection feedback (minor tick)
    func selection() {
        DispatchQueue.main.async {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
}
