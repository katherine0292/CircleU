import SwiftUI

/// Immutable editor examples. Only the message layout has verified Figma context.
public enum EditorPreviewKind: String, CaseIterable, Identifiable, Sendable {
    case reflection
    case message

    public var id: String { rawValue }

    var provenance: String {
        switch self {
        case .reflection: "Reflection editor · proposed layout"
        case .message: "Message editor · Figma 27:1671"
        }
    }

    var title: String {
        switch self {
        case .reflection: "Keep what feels\ntrue to you."
        case .message: "Make the\nmessage yours."
        }
    }

    var introduction: String {
        switch self {
        case .reflection: "Change the reflection. Your original words stay unchanged."
        case .message: "Standalone practice. Saving creates no journal entry."
        }
    }

    var actions: [PrototypeAction] {
        switch self {
        case .reflection: [
            .init(label: "Save reflection", style: .primary),
            .init(label: "Discard edits", style: .quiet)
        ]
        case .message: [
            .init(label: "Save message", style: .primary),
            .init(label: "Copy message", style: .secondary),
            .init(label: "Discard edits", style: .quiet)
        ]
        }
    }
}

/// Static sample fields, intentionally without editing, clipboard or save side effects.
public struct EditorPreviewView: View {
    public let kind: EditorPreviewKind

    public init(kind: EditorPreviewKind) { self.kind = kind }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CircleU")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(DraftColor.muted)
                .frame(maxWidth: .infinity)
                .frame(height: 17)
            Text(kind == .reflection ? "PROPOSED / EDIT REFLECTION" : "DRAFT 02 / EDIT MESSAGE")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(DraftColor.accent)
                .frame(height: 17)
            Text(kind.title)
                .font(.system(size: 29, weight: .bold, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            VStack(alignment: .leading, spacing: 12) {
                Text(kind.introduction)
                    .font(.system(size: 16, design: .rounded))
                    .lineSpacing(4)
                    .foregroundStyle(DraftColor.muted)
                    .fixedSize(horizontal: false, vertical: true)
                if kind == .reflection {
                    DraftContentCard(
                        title: "My words · unchanged",
                        text: "My groupmate missed our deadline. I’m worried we won’t finish in time."
                    )
                    DraftContentCard(
                        title: "Reflection · sample edit",
                        text: "Feeling: frustrated and worried.\n\nI need a clear update and a shared plan. I can ask what is realistic without assuming why they are late."
                    )
                } else {
                    DraftContentCard(
                        title: "Context",
                        text: "Ask a groupmate for a clear deadline update."
                    )
                    DraftContentCard(
                        title: "Message · sample edit",
                        text: "Could you send me an update by 3 pm today? If you need more time, let’s agree on a plan together."
                    )
                }
                Text(kind == .reflection
                     ? "Proposed sample; Figma match pending. Free typing is not enabled."
                     : "Preset sample edit; free typing is not enabled. Nothing is sent.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .lineSpacing(3)
                    .foregroundStyle(DraftColor.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            VStack(spacing: 8) {
                ForEach(kind.actions) { DraftActionLabel(action: $0) }
            }
            Text("STATIC PREVIEW · Sample content · Actions do not run")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(DraftColor.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .foregroundStyle(DraftColor.text)
        .background(DraftColor.background)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .environment(\.colorScheme, .light)
        .accessibilityLabel("\(kind.rawValue) editor, static design preview")
    }
}

public struct EditorPreviewGallery: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CircleU · Editing previews")
                .font(.system(size: 26, weight: .bold, design: .rounded))
            Text("Sample content · static fields and actions · macOS SwiftUI renders")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(.secondary)
            HStack(alignment: .top, spacing: 24) {
                ForEach(EditorPreviewKind.allCases) { kind in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(kind.provenance)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                        EditorPreviewView(kind: kind).frame(width: 390, height: 844)
                    }
                }
            }
            Text("Reflection is a proposal. Message follows Draft 02 with native rounded typography.")
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .background(.white)
        .environment(\.colorScheme, .light)
    }
}

#Preview("Reflection editor · proposal", traits: .fixedLayout(width: 390, height: 844)) {
    EditorPreviewView(kind: .reflection)
}

#Preview("Practice message editor", traits: .fixedLayout(width: 390, height: 844)) {
    EditorPreviewView(kind: .message)
}

#Preview("Compare editors", traits: .sizeThatFitsLayout) {
    EditorPreviewGallery()
}
