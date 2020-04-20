import XCTest
@testable import FiskalySDK

class FiskalySDKTests: XCTestCase {

    func testClientCreation() {
        do {
            // create client with API v0
            _ = try FiskalyHttpClient (
                apiKey:     "API_KEY",
                apiSecret:  "API_SECRET",
                baseUrl:    "https://kassensichv.io/api/v0/"
            )
            // create client with API v1
            _ = try FiskalyHttpClient (
                apiKey:     "API_KEY",
                apiSecret:  "API_SECRET",
                baseUrl:    "https://kassensichv.io/api/v1/"
            )
        } catch {
            print("Error while creating client: \(error).")
            XCTFail()
        }
        
        XCTAssert(true)
    }
    
    func testVersion() {
        do {
            let client = try FiskalyHttpClient (
                apiKey:     "API_KEY",
                apiSecret:  "API_SECRET",
                baseUrl:    "https://kassensichv.io/api/v1/"
            )
            try client.version(
                completion: { (result) in
                    switch result {
                    case .success(let response):
                        XCTAssertNotEqual(response.client.version, "")
                        XCTAssertNotEqual(response.client.source_hash, "")
                        XCTAssertNotEqual(response.client.commit_hash, "")
                        XCTAssertNotEqual(response.smaers.version, "")
                        XCTAssertNotEqual(response.smaers.commit_hash, "")
                        break;
                    case .failure(let error):
                        print("JsonRpcError: \(error.code) \(error.message)")
                        XCTFail()
                        break;
                    }
            })
        } catch {
            print("Error while getting version from client: \(error).")
            XCTFail()
        }
    }
    
    func testConfig() {
        do {
            let client = try FiskalyHttpClient (
                apiKey:     "API_KEY",
                apiSecret:  "API_SECRET",
                baseUrl:    "https://kassensichv.io/api/v1/"
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
                        break;
                    case .failure(let error):
                        print("JsonRpcError: \(error.code) \(error.message)")
                        XCTFail()
                        break;
                    }
            })
        } catch {
            print("Error while setting config: \(error).")
            XCTFail()
        }
    }
    
    func testEcho() {
        do {
            let client = try FiskalyHttpClient (
                apiKey:     "API_KEY",
                apiSecret:  "API_SECRET",
                baseUrl:    "https://kassensichv.io/api/v1/"
            )
            let testUTF8String = "/wuhu/this/is/my/path/äöü+#*'_-?ß!§$%&/()=<>|😀 😁 😂 🤣 😃 😄 😅 😆 😉 😊 😋 😎 😍 😘 🥰 😗 😙 😚 ☺️ 🙂 🤗 🤩 🤔 🤨 😐 😑 😶 🙄 😏 😣 😥 😮 🤐 😯 😪 😫 😴 😌 😛 😜 😝 🤤 😒 😓 😔 😕 🙃 🤑 😲 ☹️ 🙁 😖 😞 😟 😤 😢 😭 😦 😧 😨 😩 🤯 😬 😰 😱 🥵 🥶 😳 🤪 😵 😡 😠 🤬 😷 🤒"
            try client.echo(
                data: testUTF8String,
                completion: { (result) in
                    switch result {
                    case .success(let response):
                        XCTAssertEqual(response, testUTF8String)
                        break;
                    case .failure(let error):
                        print("JsonRpcError: \(error.code) \(error.message)")
                        XCTFail()
                        break;
                    }
            })
        } catch {
            print("Error while getting echo from client: \(error).")
            XCTFail()
        }
    }
    
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
            
            let tssUUID = UUID().uuidString.lowercased()
            
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
            
            let clientUUID = UUID().uuidString.lowercased()
            
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
            
            let transactionUUID = UUID().uuidString.lowercased()
            
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
