import SwiftUI

struct SaveConfirmationView: View {
    let entry: JournalReflectionEntry?
    let onDone: () -> Void
    let onViewJournal: () -> Void
    let onRecordAnother: () -> Void

    init(
        entry: JournalReflectionEntry?,
        onDone: @escaping () -> Void,
        onViewJournal: @escaping () -> Void = {},
        onRecordAnother: @escaping () -> Void = {}
    ) {
        self.entry = entry
        self.onDone = onDone
        self.onViewJournal = onViewJournal
        self.onRecordAnother = onRecordAnother
    }

    var body: some View {
        ZStack {
            PinguScreenBackground()

            VStack(spacing: 26) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(PinguDesign.lightBlue.opacity(0.72))
                        .frame(width: 124, height: 124)

                    Image(systemName: "checkmark")
                        .font(.system(size: 46, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 86, height: 86)
                        .background(PinguDesign.blue)
                        .clipShape(Circle())
                }

                VStack(spacing: 12) {
                    Text("Reflection saved")
                        .font(.system(size: 35, weight: .bold, design: .rounded))
                        .foregroundStyle(PinguDesign.ink)

                    Text(entry == nil ? "Your reflection flow is complete." : "Your AI-powered reflection is now available in Journal History.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(PinguDesign.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .frame(maxWidth: 330)
                }

                if let entry {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(entry.result.title)
                            .font(.system(size: 21, weight: .bold, design: .rounded))
                            .foregroundStyle(PinguDesign.ink)

                        Text(entry.result.summary)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(PinguDesign.body)
                            .lineSpacing(4)

                        Text(entry.engineName)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(PinguDesign.blue)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: PinguDesign.deepBlue.opacity(0.06), radius: 16, y: 8)
                    .padding(.horizontal, PinguDesign.screenSidePadding)
                }

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        onViewJournal()
                    } label: {
                        Label("View Journal", systemImage: "book.closed.fill")
                    }
                    .buttonStyle(PinguPrimaryButtonStyle())
                    .disabled(entry == nil)
                    .opacity(entry == nil ? 0.55 : 1)

                    Button {
                        onRecordAnother()
                    } label: {
                        Label("Record Another", systemImage: "mic.fill")
                    }
                    .buttonStyle(PinguSecondaryButtonStyle())

                    Button("Done") {
                        onDone()
                    }
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(PinguDesign.blue)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, PinguDesign.screenSidePadding)
                .padding(.bottom, 28)
            }
        }
    }
}

#Preview {
    SaveConfirmationView(entry: .preview, onDone: {})
}
