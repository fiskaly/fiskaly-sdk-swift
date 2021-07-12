//
//  FiskalyzerV2.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 09.07.21.
//

import Foundation
import FiskalySDK

class FiskalyzerV2 : Fiskalyzer {
    @Published var adminPUK:String?
    @Published var tssState:String?
    @Published var adminPIN:String?
    @Published var adminStatus:String = "No TSS"
    @Published var transactionRevision:Int = 0
    @Published var changeAdminPINResponse:RequestResponse?
    @Published var personalizeTSSResponse:RequestResponse?
    @Published var initializeTSSResponse:RequestResponse?
    @Published var logoutAdminResponse:RequestResponse?
    @Published var updateTransactionResponse:RequestResponse?
    @Published var authenticateClientResponse:RequestResponse?
    @Published var authenticateAdminResponse:RequestResponse?
    @Published var disableTSSResponse:RequestResponse?

    override func createHttpClient(apiKey: String, apiSecret: String) throws -> FiskalyHttpClient {
        return try FiskalyHttpClient(
            apiKey: apiKey,
            apiSecret: apiSecret,
            baseUrl: "https://sign.fiskaly.dev/api/v2",
            smaersUrl: "http://smaers-gateway:8080",
            miceUrl: "https://mice.fiskaly.dev"
        )
    }
    
    //V2 does not set the state when creating the TSS; it sets it later. However, it does need to get the admin PUK at this step in order to set the Admin PIN and authenticate.
    func createTSS() {
        let newTssUUID = UUID().uuidString
        self.tssUUID = newTssUUID

        if let responseCreateTSS = clientRequest(
            method: "PUT",
            path: "tss/\(newTssUUID)") {
            createTSSResponse = RequestResponse(responseCreateTSS)
            guard let responseBodyData = Data(base64Encoded: responseCreateTSS.body) else {
                error = "Create TSS response body is not valid base64"
                return
            }
            do {
                let responseBody = try JSONSerialization.jsonObject(with: responseBodyData, options: []) as? [String: Any]
                adminPUK = responseBody?["admin_puk"] as? String
                adminStatus = "No PIN set"
                tssState = "CREATED"
            } catch {
                self.error = "Create TSS response body is not valid JSON: \(error.localizedDescription)"
            }
        }
    }
    
    func personalizeTSS() {
        if let tssUUID = tssUUID {
            personalizeTSSResponse = setTSSState(tssUUID, state: "UNINITIALIZED")
        }
    }
    
    func initializeTSS() {
        if let tssUUID = tssUUID {
            initializeTSSResponse = setTSSState(tssUUID, state: "INITIALIZED")
        }
    }
    
    func changeAdminPIN() {
        if let tssUUID = tssUUID {
            //this has to be at least 6 characters, but there are no other restrictions
            adminPIN = String((0..<10).map{ _ in "0123456789".randomElement()!})
            let changeAdminPinBody = [
                "admin_puk": adminPUK,
                "new_admin_pin": adminPIN
            ]
            if let response = clientRequest(method: "PATCH", path: "tss/\(tssUUID)/admin", body: changeAdminPinBody) {
                changeAdminPINResponse = RequestResponse(response)
                adminStatus = "Logged out"
            }
        }
    }
    
    func logoutAdmin() {
        if let tssUUID = tssUUID {
            if let response = clientRequest(method: "POST", path: "tss/\(tssUUID)/admin/logout", body: nil) {
                logoutAdminResponse = RequestResponse(response)
                adminStatus = "Logged out"
            }
        }
    }
    
    //transaction create/update calls in V2 have a tx_revision parameter starting at 1
    fileprivate func transactionRequest(_ tssUUID: String, _ transactionUUID: String, _ updateTransactionBody: [String : Any]) -> HttpResponse? {
        transactionRevision += 1
        return clientRequest(
            method: "PUT",
            path: "tss/\(tssUUID)/tx/\(transactionUUID)",
            query: ["tx_revision": transactionRevision],
            body: updateTransactionBody)
    }
    
    func createTransaction() {
        guard let tssUUID = tssUUID, let clientUUID = clientUUID else {
            error = "Can't create transaction before creating TSS"
            return
        }
        let transactionBody = [
            "state": "ACTIVE",
            "client_id": clientUUID
        ]
        let transactionUUID = UUID().uuidString
        transactionRevision = 0 //this should be 1 when creating a transaction, but it will be incremented in updateTransaction
        if let response = transactionRequest(tssUUID, transactionUUID, transactionBody) {
            createTransactionResponse = RequestResponse(response)
            self.transactionUUID = transactionUUID
        }
    }
    
    func updateTransaction() {
        guard let clientUUID=clientUUID, let tssUUID=tssUUID, let transactionUUID=transactionUUID else {
            error = "Can't update transaction before creating TSS, client, and transaction"
            return
        }
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
        if let response = transactionRequest(tssUUID, transactionUUID, updateTransactionBody) {
            updateTransactionResponse = RequestResponse(response)
        }
    }
    
    func finishTransaction() {
        guard let clientUUID=clientUUID, let tssUUID=tssUUID, let transactionUUID=transactionUUID else {
            error = "Can't update transaction before creating TSS, client, and transaction"
            return
        }
        let finishTransactionBody: [String: Any] = [
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
        if let response = transactionRequest(tssUUID, transactionUUID, finishTransactionBody) {
            finishTransactionResponse = RequestResponse(response)
            //we can't do anything else with this transaction, so we may as well set it to nil so we don't try to
            self.transactionUUID = nil
        }
    }
    
    func authenticateClient() {
        guard let clientUUID=clientUUID, let tssUUID=tssUUID else {
            error = "Can't authenticate client before creating TSS and client"
            return
        }
        if let response = clientRequest(method: "POST", path: "tss/\(tssUUID)/client/\(clientUUID)/auth") {
            authenticateClientResponse = RequestResponse(response)
        }
    }
    
    func authenticateAdmin() {
        guard let tssUUID = tssUUID, let adminPIN = adminPIN else {
            error = "Can't authenticate as amin before creating TSS and setting Admin PIN"
            return
        }
        if let response = clientRequest(method: "POST", path: "tss/\(tssUUID)/admin/auth", body: ["admin_pin":adminPIN]) {
            adminStatus = "Logged in"
            authenticateAdminResponse = RequestResponse(response)
        }
    }
    
    func disableTSS() {
        if let tssUUID = tssUUID {
            disableTSSResponse = setTSSState(tssUUID, state: "DISABLED")
            self.tssUUID = nil
            adminStatus = "No TSS"
        }
    }
    
    func setTSSState(_ tssUUID:String,state:String) -> RequestResponse? {
        let disableTSSBody = [
            "state" : state
        ]
        if let response = clientRequest(method: "PATCH",
                                                    path: "tss/\(tssUUID)",
                                                    body: disableTSSBody
        ) {
            tssState = state
            return RequestResponse(response)
        }
        return nil
    }
}
