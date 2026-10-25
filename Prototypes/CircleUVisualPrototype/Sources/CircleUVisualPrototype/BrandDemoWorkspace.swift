import SwiftUI

/// Invented demo login for the isolated preview. Checked only in process memory: nothing is
/// authenticated, stored or sent, and it never reaches Firebase or the production app.
public enum BrandDemoAccount {
    public static let email = "demo@circleu.app"
    public static let password = "demo1234"

    static func matches(email: String, password: String) -> Bool {
        email.lowercased() == Self.email && password == Self.password
    }
}

/// Sample workspace opened by the demo login: swipe between the static Today, Journal,
/// Journal calendar and Practice boards. Entries and messages are invented fixtures.
public struct BrandDemoWorkspace: View {
    @State private var page = 0

    public init() {}

    public var body: some View {
        GeometryReader { geometry in
            let scale = min(geometry.size.width / 390, geometry.size.height / 844, 1.06)
            TabView(selection: $page) {
                board(BrandHubPreview(screen: .today), scale: scale).tag(0)
                board(BrandHubPreview(screen: .journal), scale: scale).tag(1)
                board(JournalCalendarPreview(day: .multiple), scale: scale).tag(2)
                board(BrandHubPreview(screen: .practice), scale: scale).tag(3)
            }
            // Page dots would cover each board's own tab bar, which already shows the location.
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(BrandDemoColor.ice.ignoresSafeArea())
        .accessibilityLabel("Demo workspace: swipe between Today, Journal, calendar and Practice")
    }

    private func board<Board: View>(_ view: Board, scale: CGFloat) -> some View {
        view.frame(width: 390, height: 844).scaleEffect(scale)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Demo workspace") { BrandDemoWorkspace() }
