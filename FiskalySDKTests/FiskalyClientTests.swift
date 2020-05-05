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
                        XCTAssertNotEqual(response.client.source_hash, "")
                        XCTAssertNotEqual(response.client.commit_hash, "")
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
                        XCTAssertEqual(response.config.debug_level, -1)
                        XCTAssertEqual(response.config.debug_file, "tmp/tmp.log")
                        XCTAssertEqual(response.config.client_timeout, 1500)
                        XCTAssertEqual(response.config.smaers_timeout, 1500)
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
