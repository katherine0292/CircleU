import SwiftUI

/// Interactive, process-memory design specimens; Save and Copy only demonstrate feedback.
public struct BrandMotionDemo: View {
    @Environment(\.accessibilityReduceMotion) private var systemReducedMotion
    @State private var previewReducedMotion = false
    @State private var resetToken = 0

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                BrandWordmark(size: 26)
                Text("Small moves. A quieter app.")
                    .font(BrandDemoFont.font(28, .bold)).tracking(-0.8)
                Text("Sample only: Save and Copy show feedback. Nothing is stored, copied or sent.")
                    .font(BrandDemoFont.font(13)).foregroundStyle(BrandDemoColor.muted)
                HStack(spacing: 20) {
                    Toggle("Preview reduced motion", isOn: $previewReducedMotion).toggleStyle(.switch)
                    Spacer()
                    Button("Reset both samples") { resetToken += 1 }
                }
                .font(BrandDemoFont.font(13))
                HStack(alignment: .top, spacing: 24) {
                    specimen(title: "Motion", forceReduced: previewReducedMotion)
                    specimen(title: "Reduced Motion", forceReduced: true)
                }
                .id(resetToken)
                Text(systemReducedMotion
                     ? "System Reduce Motion is on: both specimens stay still."
                     : "Left follows the system setting; the right comparison always stays still.")
                    .font(BrandDemoFont.font(12)).foregroundStyle(BrandDemoColor.muted)
                Text("Independent samples · Finite greeting · Still editors · No app data")
                    .font(BrandDemoFont.font(12)).foregroundStyle(BrandDemoColor.muted)
            }
            .padding(28).frame(maxWidth: .infinity, alignment: .center)
        }
        .foregroundStyle(BrandDemoColor.ink).background(.white)
        .environment(\.colorScheme, .light)
    }

    private func specimen(title: String, forceReduced: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(BrandDemoFont.font(15, .semibold))
            BrandMotionPanel(forceReducedMotion: forceReduced)
        }
    }
}

private enum MotionDemoPage { case today, reflection, message }

private struct BrandMotionPanel: View {
    let forceReducedMotion: Bool
    @Environment(\.accessibilityReduceMotion) private var systemReducedMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var page = MotionDemoPage.today
    @State private var greetingReplay = 0
    @State private var reflection = "I feel frustrated and worried. I need a clear update and a shared plan."
    @State private var message = "Could you send me an update by 3 pm today? If you need more time, let’s agree on a plan together."
    @State private var reflectionSaved = false
    @State private var messageSaved = false
    @State private var messageCopied = false

    private var motionEnabled: Bool {
        !systemReducedMotion && !forceReducedMotion && scenePhase == .active
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                if page != .today {
                    Button { page = .today } label: {
                        Label("Today", systemImage: "chevron.left")
                    }
                    .buttonStyle(.plain).foregroundStyle(BrandDemoColor.blue)
                } else {
                    Text("Today").font(BrandDemoFont.font(17, .semibold))
                }
                Spacer()
                Text("Sample").font(BrandDemoFont.font(12)).foregroundStyle(BrandDemoColor.muted)
            }
            .frame(height: 28)

            Group {
                switch page {
                case .today: today
                case .reflection: reflectionEditor
                case .message: messageEditor
                }
            }
            .transition(.opacity)
            Spacer(minLength: 0)
        }
        .padding(24).frame(width: 350, height: 660, alignment: .topLeading)
        .background(BrandDemoColor.ice, in: RoundedRectangle(cornerRadius: 32))
        .animation(motionEnabled ? .easeOut(duration: 0.18) : nil, value: page)
        .transaction { if !motionEnabled { $0.disablesAnimations = true } }
        .onChange(of: reflection) { _, _ in reflectionSaved = false }
        .onChange(of: message) { _, _ in
            messageSaved = false
            messageCopied = false
        }
    }

    private var today: some View {
        VStack(alignment: .leading, spacing: 16) {
            heading("What’s on\nyour mind?")
            Text("A little room to reflect.")
                .font(BrandDemoFont.font(15)).foregroundStyle(BrandDemoColor.muted)
            Group {
                if motionEnabled {
                    BrandArtwork(name: "PinguWelcomeV1")
                        .keyframeAnimator(initialValue: 0.0, trigger: greetingReplay) { content, angle in
                            content.rotationEffect(.degrees(angle))
                        } keyframes: { _ in
                            LinearKeyframe(-3.0, duration: 0.18)
                            LinearKeyframe(0.0, duration: 0.32)
                        }
                        .onAppear { greetingReplay += 1 }
                } else {
                    BrandArtwork(name: "PinguWelcomeV1")
                }
            }
            .frame(width: 185, height: 185).frame(maxWidth: .infinity)
            .accessibilityHidden(true)
            Button("Replay greeting") { greetingReplay += 1 }
                .font(BrandDemoFont.font(12, .medium)).buttonStyle(.plain)
                .foregroundStyle(BrandDemoColor.blue).frame(maxWidth: .infinity)
                .disabled(!motionEnabled)
            Spacer(minLength: 10)
            action("Write a reflection", symbol: "square.and.pencil") { page = .reflection }
            action("Practice a message", symbol: "bubble.left", primary: false) { page = .message }
        }
    }

    private var reflectionEditor: some View {
        VStack(alignment: .leading, spacing: 16) {
            heading("Your reflection")
            Text("The group deadline").font(BrandDemoFont.font(13)).foregroundStyle(BrandDemoColor.muted)
            editor("Reflection text", text: $reflection)
            feedback(reflectionSaved ? "Saved" : "", symbol: "checkmark.circle")
            Spacer(minLength: 12)
            action("Save reflection", symbol: "checkmark") { reflectionSaved = true }
                .disabled(reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private var messageEditor: some View {
        VStack(alignment: .leading, spacing: 16) {
            heading("Find your words")
            Text("Nothing is sent for you.").font(BrandDemoFont.font(13)).foregroundStyle(BrandDemoColor.muted)
            editor("Message text", text: $message)
            HStack(spacing: 18) {
                feedback(messageSaved ? "Saved" : "", symbol: "checkmark.circle")
                feedback(messageCopied ? "Copied" : "", symbol: "doc.on.doc")
            }
            Spacer(minLength: 12)
            action("Save message", symbol: "checkmark") { messageSaved = true }
                .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            action("Copy message", symbol: "doc.on.doc", primary: false) { messageCopied = true }
                .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private func heading(_ text: String) -> some View {
        Text(text).font(BrandDemoFont.font(27, .bold)).tracking(-0.8)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func editor(_ label: String, text: Binding<String>) -> some View {
        TextEditor(text: text).font(BrandDemoFont.font(17)).lineSpacing(5)
            .scrollContentBackground(.hidden).padding(12)
            .frame(height: 230).background(.white, in: RoundedRectangle(cornerRadius: 20))
            .accessibilityLabel(label)
    }

    private func feedback(_ title: String, symbol: String) -> some View {
        HStack(spacing: 6) {
            if !title.isEmpty {
                Image(systemName: symbol).accessibilityHidden(true)
                Text(title)
            }
        }
        .font(BrandDemoFont.font(13, .semibold)).foregroundStyle(BrandDemoColor.blue)
        .frame(height: 24).accessibilityElement(children: .combine)
        .animation(motionEnabled ? .easeOut(duration: 0.16) : nil, value: title)
    }

    private func action(_ title: String, symbol: String, primary: Bool = true,
                        perform: @escaping () -> Void) -> some View {
        Button(action: perform) {
            HStack(spacing: 8) {
                Image(systemName: symbol).accessibilityHidden(true)
                Text(title).font(BrandDemoFont.font(15, .semibold))
            }
            .frame(maxWidth: .infinity).frame(height: 48)
        }
        .buttonStyle(MotionDemoButtonStyle(primary: primary))
    }
}

private struct MotionDemoButtonStyle: ButtonStyle {
    let primary: Bool
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(primary ? .white : BrandDemoColor.blue)
            .background(primary ? BrandDemoColor.blue : .white, in: RoundedRectangle(cornerRadius: 16))
            .opacity(isEnabled ? (configuration.isPressed ? 0.78 : 1) : 0.4)
    }
}

#Preview("Motion comparison · interactive", traits: .sizeThatFitsLayout) {
    BrandMotionDemo()
}
