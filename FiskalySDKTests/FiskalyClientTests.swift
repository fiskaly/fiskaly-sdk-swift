import XCTest
@testable import FiskalySDK

class FiskalyClientTests: XCTestCase {

    func testVersion() throws {
        let client = try FiskalyHttpClient(
            apiKey: "API_KEY",
            apiSecret: "API_SECRET",
            baseUrl: "https://kassensichv.io/api/v1/"
        )
        let response = try client.version()
        XCTAssertNotEqual(response.client.version, "")
        XCTAssertNotEqual(response.client.sourceHash, "")
        XCTAssertNotEqual(response.client.commitHash, "")
        XCTAssertNotEqual(response.smaers.version, "")
    }

    func testSelfTest() throws {
        let client = try FiskalyHttpClient(
            apiKey: "API_KEY",
            apiSecret: "API_SECRET",
            baseUrl: "https://kassensichv.io/api/v1/"
        )
        let response = try client.selfTest()
        XCTAssertNotEqual(response.backend, "")
        XCTAssertNotEqual(response.smaers, "")
    }

    func testConfig() throws {
        let client = try FiskalyHttpClient(
            apiKey: "API_KEY",
            apiSecret: "API_SECRET",
            baseUrl: "https://kassensichv.io/api/v1/"
        )
        let response = try client.config(
            debugLevel: -1,
            debugFile: "tmp/tmp.log",
            clientTimeout: 1500,
            smaersTimeout: 1500,
            httpProxy: "")
        XCTAssertEqual(response.debugLevel, -1)
        XCTAssertEqual(response.debugFile, "tmp/tmp.log")
        XCTAssertEqual(response.clientTimeout, 1500)
        XCTAssertEqual(response.smaersTimeout, 1500)
        XCTAssertEqual(response.httpProxy, "")
    }

    func testEcho() throws {
        let client = try FiskalyHttpClient(
            apiKey: "API_KEY",
            apiSecret: "API_SECRET",
            baseUrl: "https://kassensichv.io/api/v1/"
        )
        let testUTF8String = "/wuhu/this/is/my/path/äöü+#*'_-?ß!§$%&/()=<>|"
        let response = try client.echo(data: testUTF8String)
        XCTAssertEqual(response, testUTF8String)
    }

}
