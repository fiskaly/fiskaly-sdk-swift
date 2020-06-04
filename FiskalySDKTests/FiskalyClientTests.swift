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
            try client.version(
                completion: { (result) in
                    switch result {
                    case .success(let response):
                        XCTAssertNotEqual(response.client.version, "")
                        XCTAssertNotEqual(response.client.sourceHash, "")
                        XCTAssertNotEqual(response.client.commitHash, "")
                        XCTAssertNotEqual(response.smaers.version, "")
                    case .failure(let error):
                        XCTFail("JsonRpcError: \(error.code) \(error.message)")
                    }
            })
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
            try client.config(
                debugLevel: -1,
                debugFile: "tmp/tmp.log",
                clientTimeout: 1500,
                smaersTimeout: 1500,
                completion: { (result) in
                    switch result {
                    case .success(let response):
                        XCTAssertEqual(response.config.debugLevel, -1)
                        XCTAssertEqual(response.config.debugFile, "tmp/tmp.log")
                        XCTAssertEqual(response.config.clientTimeout, 1500)
                        XCTAssertEqual(response.config.smaersTimeout, 1500)
                    case .failure(let error):
                        XCTFail("JsonRpcError: \(error.code) \(error.message)")
                    }
            })
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
            try client.echo(
                data: testUTF8String,
                completion: { (result) in
                    switch result {
                    case .success(let response):
                        XCTAssertEqual(response, testUTF8String)
                    case .failure(let error):
                        XCTFail("JsonRpcError: \(error.code) \(error.message)")
                    }
            })
        } catch {
            XCTFail("Error while getting echo from client: \(error).")
        }
    }

}
