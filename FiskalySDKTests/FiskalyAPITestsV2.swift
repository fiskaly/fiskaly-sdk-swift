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
        if let apiKey=ProcessInfo.processInfo.environment["V2_API_KEY"], let apiSecret=ProcessInfo.processInfo.environment["V2_API_SECRET"] {
            client = try FiskalyHttpClient(
                apiKey: apiKey,
                apiSecret: apiSecret,
               baseUrl: "https://kassensichv.fiskaly.com/api/v2",
                miceUrl: "https://kassensichv-middleware.fiskaly.com"
            )
            
            setUpLogging(methodName: self.name)
        } else {
            print("FiskalyAPITestsV2 not running because V2_API_KEY and V2_API_SECRET were not set.")
        }
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
    
    //This is basically an end-to-end test rather than a unit test, but most of these steps won't work without the previous ones
    //todo: add some mocking so we can test the individual steps without the server, keys, etc.
    func testTransactionRequest() throws {
        guard client != nil else {
            return
        }

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
