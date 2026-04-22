import XCTest
@testable import OpenCodeIOSClient

final class OpenCodeIdentifierTests: XCTestCase {
    func testMessageIdentifiersAreLexicographicallyAscending() {
        let first = OpenCodeIdentifier.message()
        let second = OpenCodeIdentifier.message()

        XCTAssertTrue(first.hasPrefix("msg_"))
        XCTAssertTrue(second.hasPrefix("msg_"))
        XCTAssertLessThan(first, second)
    }

    func testPartIdentifiersAreLexicographicallyAscending() {
        let first = OpenCodeIdentifier.part()
        let second = OpenCodeIdentifier.part()

        XCTAssertTrue(first.hasPrefix("prt_"))
        XCTAssertTrue(second.hasPrefix("prt_"))
        XCTAssertLessThan(first, second)
    }
}
