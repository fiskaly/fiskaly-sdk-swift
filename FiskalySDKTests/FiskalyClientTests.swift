import XCTest
@testable import FiskalySDK

class FiskalyClientTests: XCTestCase {

    func testVersion() {
        do {
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
        } catch {
            XCTFail("Error while getting version from client: \(error).")
        }
    }

    func testConfig() {
        do {
            let client = try FiskalyHttpClient(
                apiKey: "API_KEY",
                apiSecret: "API_SECRET",
                baseUrl: "https://kassensichv.io/api/v1/"
            )
            let response = try client.config(
                debugLevel: -1,
                debugFile: "tmp/tmp.log",
                clientTimeout: 1500,
                smaersTimeout: 1500)
            XCTAssertEqual(response.config.debugLevel, -1)
            XCTAssertEqual(response.config.debugFile, "tmp/tmp.log")
            XCTAssertEqual(response.config.clientTimeout, 1500)
            XCTAssertEqual(response.config.smaersTimeout, 1500)
        } catch {
            XCTFail("Error while setting config: \(error).")
        }
    }

    func testEcho() {
        do {
            let client = try FiskalyHttpClient(
                apiKey: "API_KEY",
                apiSecret: "API_SECRET",
                baseUrl: "https://kassensichv.io/api/v1/"
            )
            let testUTF8String = "/wuhu/this/is/my/path/äöü+#*'_-?ß!§$%&/()=<>|"
            let response = try client.echo(data: testUTF8String)
            XCTAssertEqual(response, testUTF8String)
        } catch {
            XCTFail("Error while getting echo from client: \(error).")
        }
    }

}
