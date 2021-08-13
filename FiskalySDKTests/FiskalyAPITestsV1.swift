import XCTest
@testable import FiskalySDK

class FiskalyAPITestsV1: FiskalyAPITests {
    
    override func setUpWithError() throws {
        if let apiKey=ProcessInfo.processInfo.environment["API_KEY"], let apiSecret=ProcessInfo.processInfo.environment["API_SECRET"] {
        client = try FiskalyHttpClient(
            apiKey: apiKey,
            apiSecret: apiSecret,
            baseUrl: "https://kassensichv.io/api/v1/"
        )
        setUpLogging(methodName: self.name)
        } else {
            print("FiskalyAPITestsV1 not running because API_KEY and API_SECRET were not set.")
        }
    }
    
    override func tearDown() {
        showClientLog()
    }

    func testKassensichvRequest() throws {
        guard let client=client else {
            return
        }
        let response = try client.request(
            method: "GET",
            path: "/tss")
        XCTAssertEqual(response.status, 200)
    }
    
    func testManagementRequest() throws {
        if let email=ProcessInfo.processInfo.environment["EMAIL"], let password=ProcessInfo.processInfo.environment["PASSWORD"] {
            let client = try FiskalyHttpClient(
                apiKey: "",
                apiSecret: "",
                baseUrl: "https://dashboard.fiskaly.com/api/v0/",
                email: email,
                password:password
            )
            let response = try client.request(
                method: "GET",
                path: "/organizations")
                XCTAssertEqual(response.status, 200)
        } else {
            print("testManagementRequest not running because EMAIL and PASSWORD were not set.")
        }
    }

    func testTransactionRequest() throws {
        guard let client=client else {
            return
        }
        // create TSS

        let tssUUID = UUID().uuidString

        let tssBody = [
            "description": "iOS Test TSS",
            "state": "INITIALIZED"
        ]
        let tssBodyData = try? JSONSerialization.data(withJSONObject: tssBody)
        let tssBodyEncoded = tssBodyData?.base64EncodedString()

        let responseCreateTSS = try client.request(
            method: "PUT",
            path: "tss/\(tssUUID)",
            body: tssBodyEncoded!
        )
        XCTAssertEqual(responseCreateTSS.status, 200)

        // create Client

        let clientUUID = UUID().uuidString

        let clientBody = [
            "serial_number": "iOS Test Client Serial"
        ]
        let clientBodyData = try? JSONSerialization.data(withJSONObject: clientBody)
        let clientBodyEncoded = clientBodyData?.base64EncodedString()

        let responseCreateClient = try client.request(
            method: "PUT",
            path: "tss/\(tssUUID)/client/\(clientUUID)",
            body: clientBodyEncoded!)
        XCTAssertEqual(responseCreateClient.status, 200)

        // create Transaction

        let transactionUUID = UUID().uuidString

        let transactionBody = [
            "state": "ACTIVE",
            "client_id": clientUUID
        ]
        let transactionBodyData = try? JSONSerialization.data(withJSONObject: transactionBody)
        let transactionBodyEncoded = transactionBodyData?.base64EncodedString()

        let responseCreateTransaction = try client.request(
            method: "PUT",
            path: "tss/\(tssUUID)/tx/\(transactionUUID)",
            body: transactionBodyEncoded!)
        XCTAssertEqual(responseCreateTransaction.status, 200)

        // finish Transaction

        let transactionFinishBody: [String: Any] = [
            "state": "FINISHED",
            "client_id": clientUUID,
            "schema": [
                "standard_v1": [
                    "receipt": [
                        "receipt_type": "RECEIPT",
                        "amounts_per_vat_rate": [
                            ["vat_rate": "19", "amount": "14.28"]
                        ],
                        "amounts_per_payment_type": [
                            ["payment_type": "NON_CASH", "amount": "14.28"]
                        ]
                    ]
                ]
            ]
        ]
        let transactionFinishBodyData = try? JSONSerialization.data(withJSONObject: transactionFinishBody)
        let transactionFinishBodyEncoded = transactionFinishBodyData?.base64EncodedString()

        let responseFinishTransaction = try client.request(
            method: "PUT",
            path: "tss/\(tssUUID)/tx/\(transactionUUID)",
            query: ["last_revision": "1"],
            body: transactionFinishBodyEncoded!)
        XCTAssertEqual(responseFinishTransaction.status, 200)
    }

    func testQueryArray() throws {
        guard let client=client else {
            return
        }
        let query: [String: Any] = [
            "states": ["INITIALIZED", "DISABLED"]
        ]
        let response = try client.request(
            method: "GET",
            path: "/tss",
            query: query)
        XCTAssertEqual(response.status, 200)

    }

}
