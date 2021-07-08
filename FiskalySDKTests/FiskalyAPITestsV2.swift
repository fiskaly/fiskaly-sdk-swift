//
//  FiskalyAPITestsV2.swift
//  FiskalySDKTests
//
//  Created by Angela Brett on 07.07.21.
//  Copyright © 2021 fiskaly. All rights reserved.
//

import XCTest
@testable import FiskalySDK

class FiskalyAPITestsV2: FiskalyAPITests {
    
    override func setUpWithError() throws {
        client = try FiskalyHttpClient(
            apiKey: ProcessInfo.processInfo.environment["V2_API_KEY"]!,
            apiSecret: ProcessInfo.processInfo.environment["V2_API_SECRET"]!,
            baseUrl: "https://sign.fiskaly.dev/api/v2",
            smaersUrl: "http://smaers-gateway:8080",
            miceUrl: "https://mice.fiskaly.dev"
        )
        
        setUpLogging(methodName: self.name)
    }
    
    override func tearDown() {
        showClientLog()
    }
    
    func disableTSS(_ tssUUID:String) throws {
        try setTSSState(tssUUID, state: "DISABLED")
    }
    
    func setTSSState(_ tssUUID:String,state:String) throws {
        let disableTSSBody = [
            "state" : state
        ]
        let _ = try clientRequest(method: "PATCH",
                                                    path: "tss/\(tssUUID)",
                                                    body: disableTSSBody
                                                    )
    }
    
    //This is actually done by the client so doesn't need to be done here.
    func testV2Authentication() throws {
        let authenticateBody = [
            "api_key": ProcessInfo.processInfo.environment["V2_API_KEY"]!,
            "api_secret": ProcessInfo.processInfo.environment["V2_API_SECRET"],
            "base_url":"http://backend:3000",
            "smaers_url":"http://smaers-gateway:8080"
        ]
        
        let authBodyData = try? JSONSerialization.data(withJSONObject: authenticateBody)
        let authBodyEncoded = authBodyData?.base64EncodedString()
        
        let responseAuthenticate = try client.request(
            method: "POST",
            path: "auth",
            body: authBodyEncoded!)
        XCTAssertEqual(responseAuthenticate.status, 200)
    }
    
    //This is basically an end-to-end test rather than a unit test, but most of these steps won't work without the previous ones
    //todo: add some mocking so we can test the individual steps without the server, keys, etc.
    func testTransactionRequest() throws {
        
        //try clientRequest(method: "h", path: "hkh")

        // create TSS

        let tssUUID = UUID().uuidString

        let tssBody = [
            "description": "iOS Test TSS",
            "state": "INITIALIZED"
        ]

        let responseCreateTSS = try clientRequest(
            method: "PUT",
            path: "tss/\(tssUUID)",
            body: tssBody
        )
        
        //this is the only chance to get the admin puk, which we will need to change the admin pin later
        let responseBodyData = Data(base64Encoded: responseCreateTSS.body)
        XCTAssertNotNil(responseBodyData,"Create TSS response body is not valid base64")
        let responseBody = try JSONSerialization.jsonObject(with: responseBodyData!, options: []) as? [String: Any]
        XCTAssertNotNil(responseBody,"Create TSS response body is not valid JSON")
        let adminPUK = responseBody!["admin_puk"]
        XCTAssertNotNil(adminPUK,"Create TSS response body did not contain Admin PUK")
        
        // personalise TSS
        
        try setTSSState(tssUUID, state: "UNINITIALIZED")
        
        // change admin pin
        let adminPIN = "1234567890"
        let changeAdminPinBody = [
            "admin_puk": adminPUK,
            "new_admin_pin": adminPIN
        ]
        let _ = try clientRequest(method: "PATCH", path: "tss/\(tssUUID)/admin", body: changeAdminPinBody)
        
        //authenticate Admin
        let _ = try clientRequest(method: "POST", path: "tss/\(tssUUID)/admin/auth", body: ["admin_pin":adminPIN])
        
        //Initialise TSS
        try setTSSState(tssUUID, state: "INITIALIZED")

        // create Client

        let clientUUID = UUID().uuidString

        let clientBody = [
            "serial_number": "iOS Test Client Serial"
        ]

        let responseCreateClient = try clientRequest(
            method: "PUT",
            path: "tss/\(tssUUID)/client/\(clientUUID)",
            body: clientBody)
        XCTAssertEqual(responseCreateClient.status, 200)
        
        // logout admin
        let _ = try clientRequest(method: "POST", path: "tss/\(tssUUID)/admin/logout", body: nil)
        
        // authenticate client
        let _ = try clientRequest(method: "POST", path: "tss/\(tssUUID)/client/\(clientUUID)/auth")

        // create Transaction

        let transactionUUID = UUID().uuidString

        let transactionBody = [
            "state": "ACTIVE",
            "client_id": clientUUID
        ]
        var transactionRevision = 1;
        let _ = try clientRequest(
            method: "PUT",
            path: "tss/\(tssUUID)/tx/\(transactionUUID)",
            query: ["tx_revision":transactionRevision],
            body: transactionBody)
        
        // update transaction
        transactionRevision += 1
        let updateTransactionBody: [String: Any] = [
            "schema": [
                "standard_v1": [
                    "receipt": [
                        "receipt_type": "RECEIPT",
                        "amounts_per_vat_rate": [
                            [
                                "vat_rate": "NORMAL",
                                "amount": "21.42"
                            ]
                        ],
                        "amounts_per_payment_type": [
                            [
                                "payment_type": "NON_CASH",
                                "amount": "21.42"
                            ]
                        ]
                    ]
                ]
            ],
            "state": "ACTIVE",
            "client_id": clientUUID
        ]
        let _ = try clientRequest(
            method: "PUT",
            path: "tss/\(tssUUID)/tx/\(transactionUUID)",
            query: ["tx_revision": transactionRevision],
            body: updateTransactionBody)

        // finish Transaction
        transactionRevision += 1
        let transactionFinishBody: [String: Any] = [
            "schema": [
                "standard_v1": [
                    "receipt": [
                        "receipt_type": "RECEIPT",
                        "amounts_per_vat_rate": [
                            [
                                "vat_rate": "NORMAL",
                                "amount": "21.42"
                            ]
                        ],
                        "amounts_per_payment_type": [
                            [
                                "payment_type": "NON_CASH",
                                "amount": "21.42"
                            ]
                        ]
                    ]
                ]
            ],
            "state": "FINISHED",
            "client_id": clientUUID
        ]

        let _ = try clientRequest(
            method: "PUT",
            path: "tss/\(tssUUID)/tx/\(transactionUUID)",
            query: ["tx_revision": transactionRevision],
            body: transactionFinishBody)
        
        
        //authenticate Admin again so we can disable TSS
    
        let _ = try clientRequest(method: "POST", path: "tss/\(tssUUID)/admin/auth", body: ["admin_pin":adminPIN])
        
        //disable TSS (otherwise we will get 'Limit of active TSS reached' errors
        try disableTSS(tssUUID)
    }
}
