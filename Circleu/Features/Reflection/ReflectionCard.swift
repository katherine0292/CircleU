import SwiftUI

struct ReflectionCard: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(PinguDesign.ink)

            Text(content)
                .font(.subheadline)
                .foregroundStyle(PinguDesign.muted)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: PinguDesign.deepBlue.opacity(0.06), radius: 14, y: 6)
    }
}

#Preview {
    ReflectionCard(
        title: "Emotion",
        content: "You seemed a little nervous sharing your thoughts today."
    )
    .padding()
}
