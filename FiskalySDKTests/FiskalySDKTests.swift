import XCTest
@testable import FiskalySDK

class FiskalySDKTests: XCTestCase {

    func testClientCreation() throws {
        // create client with API v0
        _ = try FiskalyHttpClient(
            apiKey: "API_KEY",
            apiSecret: "API_SECRET",
            baseUrl: "https://kassensichv.io/api/v0/"
        )
        // create client with API v1
        _ = try FiskalyHttpClient(
            apiKey: "API_KEY",
            apiSecret: "API_SECRET",
            baseUrl: "https://kassensichv.io/api/v1/"
        )

        XCTAssert(true)
    }
}
