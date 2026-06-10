import SwiftUI

struct PolicyDetailView: View {

    let title: String
    let content: String

    var body: some View {

        ScrollView {

            VStack(alignment: .leading) {

                Text(content)
                    .font(.body)
                    .lineSpacing(6)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 24
                        )
                    )
            }
            .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
