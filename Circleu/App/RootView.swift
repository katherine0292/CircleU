import SwiftUI

struct RootView: View {

    @State private var selectedTab: Tab = .home

    var body: some View {

        ZStack(alignment: .bottom) {

            switch selectedTab {

            case .home:
                HomeView()

            case .tips:
                TipsView()

            case .circle:
                CircleView()

            case .noot:
                ProfileView()
            }

            CustomTabBar(
                selectedTab: $selectedTab
            )
        }
    }
}

#Preview {
    RootView()
}
