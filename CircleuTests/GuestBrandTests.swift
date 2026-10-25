import XCTest
@testable import Circleu

final class GuestBrandTests: XCTestCase {
    func testBundledBrandFontAndLicenceShipWithTheApp() {
        XCTAssertTrue(GuestBrand.isBrandFontAvailable, "Plus Jakarta Sans should load from the app bundle")
        XCTAssertNotNil(Bundle.main.url(forResource: "OFL-PlusJakartaSans", withExtension: "txt"),
                        "the SIL Open Font License must ship with the font")
        XCTAssertNotNil(UIImage(named: "GuestBrandAvatar"))
    }
}
