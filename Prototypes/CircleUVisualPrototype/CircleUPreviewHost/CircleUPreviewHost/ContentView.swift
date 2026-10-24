import SwiftUI
import CircleUVisualPrototype

struct ContentView: View {
    var body: some View {
        NavigationStack {
            BrandOnboardingPreview(initialScreen: .logIn)
                .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    ContentView()
}
