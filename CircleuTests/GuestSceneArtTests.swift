import UIKit
import XCTest
@testable import Circleu

/// The reusable scene family mirrors Figma's `CircleU / Scene artwork` component: one native
/// asset per approved scene, all the same 2:1 shape, so screens can swap scenes by state.
@MainActor
final class GuestSceneArtTests: XCTestCase {
    func testEveryApprovedSceneIsBundledAtTwoToOne() {
        XCTAssertEqual(GuestSceneArt.allCases.count, 9)
        XCTAssertEqual(Set(GuestSceneArt.allCases.map(\.asset)).count, 9, "no duplicate assets")
        for scene in GuestSceneArt.allCases {
            let image = UIImage(named: scene.asset)
            XCTAssertNotNil(image, scene.asset)
            guard let size = image?.size, size.height > 0 else { continue }
            XCTAssertEqual(size.width / size.height, 2, accuracy: 0.01, "\(scene.asset) keeps the 2:1 scene shape")
        }
    }

    func testTodaySceneFollowsListeningState() {
        XCTAssertEqual(GuestSceneArt.today(listening: false), .windowPause)
        XCTAssertEqual(GuestSceneArt.today(listening: true), .voiceCorner)
    }
}
