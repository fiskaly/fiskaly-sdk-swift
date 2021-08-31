//
//  Fiskalyzer.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 23.06.21.
//

import Foundation
import FiskalySDK

class FiskalyzerV1 : Fiskalyzer {
    
    override func createHttpClient(apiKey: String, apiSecret: String) throws -> FiskalyHttpClient {
        return try FiskalyHttpClient(
            apiKey: apiKey,
            apiSecret: apiSecret,
            baseUrl: "https://kassensichv.io/api/v1/"
        )
    }
    
    func getVersion() {
        do {
            if let response = try client?.version() {
                version = response.client.version
            } else {
                self.error = "Client could not be initialised"
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func createTSS() {
        let newTssUUID = UUID().uuidString
        self.tssUUID = newTssUUID
        
        let tssBody = [
            "description": "iOS Test TSS",
            "state": "INITIALIZED"
        ]

        if let responseCreateTSS = clientRequest(
            method: .put,
            path: "tss/\(newTssUUID)",
            body: tssBody) {
            createTSSResponse = RequestResponse(responseCreateTSS)
        }
    }
    
    func createTransaction() {
        guard let tssID = tssUUID else {
            error = "Can't create transaction before creating TSS"
            return
        }
        let newTransactionUUID = UUID().uuidString
        transactionUUID = newTransactionUUID

        let transactionBody = [
            "state": "ACTIVE",
            "client_id": clientUUID
        ]

        if let responseCreateTransaction = clientRequest(
            method: .put,
            path: "tss/\(tssID)/tx/\(newTransactionUUID)",
            body: transactionBody) {
            createTransactionResponse = RequestResponse(responseCreateTransaction)
        }
    }

    func finishTransaction() {
        guard let clientID = clientUUID, let tssID = tssUUID, let transactionID=transactionUUID else {
            error = "Can't finish transaction before creating TSS, client, and transaction"
            return
        }
        let transactionFinishBody: [String: Any] = [
            "state": "FINISHED",
            "client_id": clientID,
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

        if let responseFinishTransaction = clientRequest(
            method: .put,
            path: "tss/\(tssID)/tx/\(transactionID)",
            query: ["last_revision": "1"],
            body: transactionFinishBody) {
            finishTransactionResponse = RequestResponse(responseFinishTransaction)
        }
    }
    
}
