import XCTest
@testable import FiskalySDK

class FiskalyAPITests: XCTestCase {

    func testRequest() {
        do {
            let client = try FiskalyHttpClient (
                apiKey:     ProcessInfo.processInfo.environment["API_KEY"]!,
                apiSecret:  ProcessInfo.processInfo.environment["API_SECRET"]!,
                baseUrl:    "https://kassensichv.io/api/v1/"
            )
            try client.request(
                method: "GET",
                path: "/tss",
                completion: { (result) in
                    switch result {
                    case .success(let response):
                        XCTAssertEqual(response.response.status, 200)
                        break;
                    case .failure(let error):
                        print("JsonRpcError: \(error.code) \(error.message) \(error.data!.response.body)")
                        XCTFail()
                        break;
                    }
            })
        } catch {
            print("Error while performing: \(error).")
            XCTFail()
        }
    }
    
    func testTransactionRequest() {
        
        do {
            let client = try FiskalyHttpClient (
                apiKey:     ProcessInfo.processInfo.environment["API_KEY"]!,
                apiSecret:  ProcessInfo.processInfo.environment["API_SECRET"]!,
                baseUrl:    "https://kassensichv.io/api/v1/"
            )
            
            // create TSS
            
            let tssUUID = UUID().uuidString
            
            let tssBody = [
                "description": "iOS Test TSS",
                "state": "INITIALIZED"
            ]
            let tssBodyData = try? JSONSerialization.data(withJSONObject: tssBody)
            let tssBodyEncoded = tssBodyData?.base64EncodedString()
            
            try client.request(
                method: "PUT",
                path: "tss/\(tssUUID)",
                body: tssBodyEncoded!,
                completion: { (result) in
                    switch result {
                    case .success(let response):
                        XCTAssertEqual(response.response.status, 200)
                        break;
                    case .failure(let error):
                        print("JsonRpcError: \(error.code) \(error.message) \(error.data!.response.body)")
                        XCTFail()
                        break;
                    }
            })
            
            // create Client
            
            let clientUUID = UUID().uuidString
            
            let clientBody = [
                "serial_number": "iOS Test Client Serial"
            ]
            let clientBodyData = try? JSONSerialization.data(withJSONObject: clientBody)
            let clientBodyEncoded = clientBodyData?.base64EncodedString()
            
            try client.request(
                method: "PUT",
                path: "tss/\(tssUUID)/client/\(clientUUID)",
                body: clientBodyEncoded!,
                completion: { (result) in
                    switch result {
                    case .success(let response):
                        XCTAssertEqual(response.response.status, 200)
                        break;
                    case .failure(let error):
                        print("JsonRpcError: \(error.code) \(error.message) \(error.data!.response.body)")
                        XCTFail()
                        break;
                    }
            })
            
            // create Transaction
            
            let transactionUUID = UUID().uuidString
            
            let transactionBody = [
                "state": "ACTIVE",
                "client_id": clientUUID
            ]
            let transactionBodyData = try? JSONSerialization.data(withJSONObject: transactionBody)
            let transactionBodyEncoded = transactionBodyData?.base64EncodedString()
            
            try client.request(
                method: "PUT",
                path: "tss/\(tssUUID)/tx/\(transactionUUID)",
                body: transactionBodyEncoded!,
                completion: { (result) in
                    switch result {
                    case .success(let response):
                        XCTAssertEqual(response.response.status, 200)
                        break;
                    case .failure(let error):
                        print("JsonRpcError: \(error.code) \(error.message) \(error.data!.response.body)")
                        XCTFail()
                        break;
                    }
            })
            
            // finish Transaction
            
            let transactionFinishBody: [String: Any] = [
                "state": "ACTIVE",
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
            
            try client.request(
                method: "PUT",
                path: "tss/\(tssUUID)/tx/\(transactionUUID)",
                query: ["last_revision": "1"],
                body: transactionFinishBodyEncoded!,
                completion: { (result) in
                    switch result {
                    case .success(let response):
                        XCTAssertEqual(response.response.status, 200)
                        break;
                    case .failure(let error):
                        print("JsonRpcError: \(error.code) \(error.message) \(error.data!.response.body)")
                        XCTFail()
                        break;
                    }
            })
            
        } catch {
            print("Error while performing request: \(error).")
            XCTFail()
        }
        
    }

}
