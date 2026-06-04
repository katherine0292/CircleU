import SwiftUI

struct JournalCircleShareSheet: View {
    let entry: JournalReflectionEntry
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var circleStore: CircleStore

    var body: some View {
        NavigationStack {
            ZStack {
                PinguScreenBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Save to circle")
                                .font(.system(size: 31, weight: .bold, design: .rounded))
                                .foregroundStyle(PinguDesign.ink)

                            Text("Choose where this reflection should live as a private local support post.")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(PinguDesign.muted)
                                .lineSpacing(4)
                        }

                        if circleStore.circles.isEmpty {
                            emptyCircleState
                        } else {
                            ForEach(circleStore.circles) { circle in
                                circleChoice(circle)
                            }
                        }
                    }
                    .padding(.horizontal, PinguDesign.screenSidePadding)
                    .padding(.top, 20)
                    .padding(.bottom, 34)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var emptyCircleState: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(PinguDesign.blue)

            Text("No private circles yet")
                .font(.system(size: 21, weight: .bold, design: .rounded))
                .foregroundStyle(PinguDesign.ink)

            Text("Open the Circles tab and create a private space before saving journal insights there.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(PinguDesign.muted)
                .lineSpacing(4)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func circleChoice(_ circle: CircleSpace) -> some View {
        let hasShared = circleStore.hasShared(entry: entry, to: circle)

        return Button {
            circleStore.share(entry: entry, to: circle)
            dismiss()
        } label: {
            HStack(spacing: 13) {
                Image(systemName: hasShared ? "checkmark.circle.fill" : "person.2.wave.2.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(hasShared ? PinguDesign.muted : PinguDesign.blue)
                    .frame(width: 46, height: 46)
                    .background(PinguDesign.lightBlue.opacity(0.62))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 5) {
                    Text(circle.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(PinguDesign.ink)
                        .lineLimit(1)

                    Text(hasShared ? "Already saved here" : circle.intention)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(PinguDesign.muted)
                        .lineLimit(2)
                        .lineSpacing(3)
                }

                Spacer()

                Image(systemName: hasShared ? "checkmark" : "plus")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(hasShared ? PinguDesign.muted : PinguDesign.blue)
            }
            .padding(15)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .opacity(hasShared ? 0.62 : 1)
        }
        .buttonStyle(.plain)
        .disabled(hasShared)
    }
}
