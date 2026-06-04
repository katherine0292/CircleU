import SwiftUI

struct ReflectionView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {

        ZStack {

            Color(red: 240/255, green: 249/255, blue: 255/255)
                .ignoresSafeArea()

            VStack(spacing: 16) {

                HStack {

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.primaryBlue)
                    }

                    Spacer()

                    Text("Reflection")
                        .fontWeight(.semibold)

                    Spacer()

                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(.primaryBlue)
                }
                .padding()

                Image("penguin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90)

                Text("Here's what I noticed")
                    .font(.title.bold())

                Text("Take a moment to soak in your growth.")
                    .foregroundStyle(.secondaryBlue)

                reflectionCard(
                    title: "EMOTION",
                    text: "You seemed nervous. It's totally normal to feel this way."
                )

                reflectionCard(
                    title: "EXPRESSION MOMENT",
                    text: "You spoke honestly about your experience."
                )

                quoteCard

                Spacer()

                HStack(spacing: 12) {

                    Button {
                        dismiss()
                    } label: {

                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 14)
                            )
                    }

                    Button {

                        dismiss()

                    } label: {

                        Text("Save Entry")
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 14)
                            )
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    func reflectionCard(
        title: String,
        text: String
    ) -> some View {

        VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(text)
                .fontWeight(.medium)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
        .padding(.horizontal)
    }

    var quoteCard: some View {

        VStack {

            Text("❝")

            Text("Confidence grows through expression")
                .font(.title3.bold())
                .multilineTextAlignment(.center)

            Text("Daily Wisdom")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue)
        .foregroundStyle(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
        .padding(.horizontal)
    }
}

#Preview {
    ReflectionView()
}
