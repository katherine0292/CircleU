import AppKit
import SwiftUI
import CircleUVisualPrototype

/// Renders only immutable design fixtures; does not load or run the Circleu app.
@main
struct RenderPreviews {
    @MainActor
    static func main() throws {
        guard CommandLine.arguments.count == 2 else {
            throw RenderError.usage
        }
        let output = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        for screen in PrototypeScreen.allCases {
            try render(
                PrototypeScreenView(screen: screen).frame(width: 390, height: 844),
                to: output.appendingPathComponent("\(screen.rawValue.lowercased()).png")
            )
        }
        try render(PreviewGallery(), to: output.appendingPathComponent("gallery.png"))
        for kind in EditorPreviewKind.allCases {
            try render(
                EditorPreviewView(kind: kind).frame(width: 390, height: 844),
                to: output.appendingPathComponent("edit-\(kind.rawValue).png")
            )
        }
        try render(EditorPreviewGallery(), to: output.appendingPathComponent("editors.png"))
        try render(IconDirectionPreview(), to: output.appendingPathComponent("outline-icon-direction.png"))
        print("Brand font verified: \(BrandDemoFont.postScriptName)")
        try render(BrandDemoBoard(), to: output.appendingPathComponent("brand-demo.png"))
        try render(BrandTodayPreview(), to: output.appendingPathComponent("brand-today.png"))
        for screen in PrototypeScreen.allCases {
            try render(BrandHubPreview(screen: screen), to: output.appendingPathComponent("brand-02-\(screen.rawValue.lowercased()).png"), size: CGSize(width: 390, height: 844))
        }
        for kind in EditorPreviewKind.allCases {
            try render(BrandEditorPreview(kind: kind), to: output.appendingPathComponent("brand-02-edit-\(kind.rawValue).png"), size: CGSize(width: 390, height: 844))
        }
        try render(BrandFlowGallery(), to: output.appendingPathComponent("brand-02-hubs.png"))
        try render(BrandFlowGallery(editors: true), to: output.appendingPathComponent("brand-02-editors.png"))
        try render(JournalCalendarPreview(), to: output.appendingPathComponent("brand-03-journal.png"), size: CGSize(width: 390, height: 844))
        try render(JournalCalendarPreview(emptyDay: true), to: output.appendingPathComponent("brand-03-journal-empty.png"), size: CGSize(width: 390, height: 844))
        try render(JournalCalendarGallery(), to: output.appendingPathComponent("brand-03-calendar.png"))
        try render(
            PrototypeScreenView(screen: .today).frame(width: 320, height: 844),
            to: output.appendingPathComponent("today-compact.png")
        )
        print("Rendered screens, galleries, compact check and icon direction to \(output.path)")
    }

    @MainActor
    private static func render<Content: View>(_ content: Content, to url: URL, size: CGSize? = nil) throws {
        let renderer = ImageRenderer(content: content)
        if let size {
            renderer.proposedSize = ProposedViewSize(width: size.width, height: size.height)
        }
        renderer.scale = 2
        guard let cgImage = renderer.cgImage,
              let png = NSBitmapImageRep(cgImage: cgImage).representation(using: .png, properties: [:]) else {
            throw RenderError.imageUnavailable
        }
        try png.write(to: url, options: .atomic)
    }

    enum RenderError: Error {
        case usage
        case imageUnavailable
    }
}
