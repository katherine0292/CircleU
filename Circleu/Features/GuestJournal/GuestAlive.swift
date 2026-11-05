import SwiftUI
import UIKit

// Makes the otter feel alive with the still art we have (owner request, 6 November 2026): standing
// otters breathe and scenes drift very slowly. Everything stops with Reduce Motion. Eye positions are
// kept for placing the otter's speech bubbles. Turning pages or moving a paw need animation frames
// (see the animation brief on the owner's Desktop); blinking drawn over the art was removed.

/// Where the eyes are, as fractions of the image: centres, and one eye's width and height.
struct GuestEyes {
    let left: CGPoint
    let right: CGPoint
    let size: CGSize
}

enum GuestEyeMap {
    static let eyes: [String: GuestEyes] = [
        // Scenes (2:1)
        "GuestSceneWindowPause": .init(left: .init(x: 0.400, y: 0.317), right: .init(x: 0.490, y: 0.298), size: .init(width: 0.018, height: 0.042)),
        "GuestSceneVoiceCorner": .init(left: .init(x: 0.401, y: 0.317), right: .init(x: 0.490, y: 0.297), size: .init(width: 0.018, height: 0.040)),
        "GuestSceneJournalDesk": .init(left: .init(x: 0.406, y: 0.359), right: .init(x: 0.512, y: 0.359), size: .init(width: 0.020, height: 0.045)),
        "GuestScenePracticeStudio": .init(left: .init(x: 0.408, y: 0.257), right: .init(x: 0.500, y: 0.235), size: .init(width: 0.019, height: 0.042)),
        "GuestSceneReflectionGarden": .init(left: .init(x: 0.406, y: 0.280), right: .init(x: 0.496, y: 0.276), size: .init(width: 0.019, height: 0.042)),
        "GuestSceneRefineWorkbench": .init(left: .init(x: 0.424, y: 0.368), right: .init(x: 0.531, y: 0.358), size: .init(width: 0.023, height: 0.060)),
        "GuestSceneReplyReading": .init(left: .init(x: 0.418, y: 0.308), right: .init(x: 0.514, y: 0.285), size: .init(width: 0.019, height: 0.047)),
        "GuestSceneKeepsakeShelf": .init(left: .init(x: 0.416, y: 0.278), right: .init(x: 0.498, y: 0.278), size: .init(width: 0.019, height: 0.042)),
        // Welcome pages (2:3)
        "GuestOnboardingHardMoment": .init(left: .init(x: 0.331, y: 0.234), right: .init(x: 0.505, y: 0.221), size: .init(width: 0.034, height: 0.028)),
        "GuestOnboardingFindWords": .init(left: .init(x: 0.379, y: 0.183), right: .init(x: 0.548, y: 0.167), size: .init(width: 0.034, height: 0.028)),
        "GuestOnboardingSayItKindly": .init(left: .init(x: 0.298, y: 0.270), right: .init(x: 0.452, y: 0.257), size: .init(width: 0.034, height: 0.028)),
        // Avatars (square)
        "GuestPinguWelcome": .init(left: .init(x: 0.440, y: 0.273), right: .init(x: 0.619, y: 0.256), size: .init(width: 0.034, height: 0.042)),
        "GuestPinguWriting": .init(left: .init(x: 0.449, y: 0.267), right: .init(x: 0.628, y: 0.249), size: .init(width: 0.036, height: 0.044)),
        "GuestPinguListening": .init(left: .init(x: 0.455, y: 0.258), right: .init(x: 0.638, y: 0.248), size: .init(width: 0.037, height: 0.044)),
        "GuestPinguThoughtful": .init(left: .init(x: 0.457, y: 0.324), right: .init(x: 0.639, y: 0.312), size: .init(width: 0.036, height: 0.044)),
        "GuestPinguExplorer": .init(left: .init(x: 0.457, y: 0.325), right: .init(x: 0.638, y: 0.328), size: .init(width: 0.040, height: 0.049)),
        "GuestPinguPractising": .init(left: .init(x: 0.413, y: 0.299), right: .init(x: 0.577, y: 0.280), size: .init(width: 0.033, height: 0.039)),
        "GuestPinguReading": .init(left: .init(x: 0.463, y: 0.342), right: .init(x: 0.640, y: 0.329), size: .init(width: 0.038, height: 0.044)),
        "GuestPinguHeart": .init(left: .init(x: 0.441, y: 0.261), right: .init(x: 0.627, y: 0.240), size: .init(width: 0.038, height: 0.046)),
        "GuestPinguJournal": .init(left: .init(x: 0.449, y: 0.251), right: .init(x: 0.633, y: 0.231), size: .init(width: 0.036, height: 0.045)),
        "GuestPinguBackpack": .init(left: .init(x: 0.503, y: 0.272), right: .init(x: 0.673, y: 0.248), size: .init(width: 0.036, height: 0.043)),
        "GuestPinguThumbsUp": .init(left: .init(x: 0.451, y: 0.259), right: .init(x: 0.637, y: 0.239), size: .init(width: 0.036, height: 0.045)),
        "GuestPinguLaptop": .init(left: .init(x: 0.456, y: 0.314), right: .init(x: 0.638, y: 0.296), size: .init(width: 0.038, height: 0.047)),
    ]
}

/// An otter picture that can breathe (standing otters) or drift slowly (scenes).
/// It fits its own aspect ratio; callers add `.aspectRatio(_, contentMode: .fill)` to fill.
struct GuestLivingImage: View {
    let asset: String
    var breathes = false
    var drifts = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var inhale = false
    @State private var drift = false

    var body: some View {
        Image(asset).resizable().aspectRatio(contentMode: .fit)
            .scaleEffect(x: 1, y: breathes && inhale && !reduceMotion ? 1.022 : 1, anchor: .bottom)
            .scaleEffect(drifts && drift && !reduceMotion ? 1.04 : 1)
            .accessibilityHidden(true)
            .onAppear {
                guard !reduceMotion else { return }
                if breathes { withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) { inhale = true } }
                if drifts { withAnimation(.easeInOut(duration: 14).repeatForever(autoreverses: true)) { drift = true } }
            }
    }
}
