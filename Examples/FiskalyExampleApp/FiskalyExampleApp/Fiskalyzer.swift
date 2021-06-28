//
//  Fiskalyzer.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 23.06.21.
//

import Foundation
import FiskalySDK

class Fiskalyzer : ObservableObject {
    private var client:FiskalyHttpClient?
    private var v2client:FiskalyHttpClient?
    @Published var version:String?
    @Published var error:String?
    @Published var KSVStatus:Int?
    @Published var KSVResponse:String?
    @Published var tssUUID:String?
    @Published var createTSSStatus:Int?
    @Published var createTSSResponse:String?
    @Published var clientUUID:String?
    @Published var createClientStatus:Int?
    @Published var createClientResponse:String?
    @Published var transactionUUID:String?
    @Published var createTransactionStatus:Int?
    @Published var createTransactionResponse:String?
    @Published var finishTransactionStatus:Int?
    @Published var finishTransactionResponse:String?
    @Published var authenticateStatus:Int?
    @Published var authenticateResponse:String?
    static var apiKeyVariableName = "API_KEY"
    static var apiSecretVariableName = "API_SECRET"
    init() {
        if let apiKey = apiKey, let apiSecret = apiSecret {
        client = try? FiskalyHttpClient(
            apiKey: apiKey,
            apiSecret: apiSecret,
            baseUrl: "https://kassensichv.io/api/v1/"
        )
        v2client = try? FiskalyHttpClient(
            apiKey: apiKey,
            apiSecret: apiSecret,
            baseUrl: "https://localhost:3000/api/v2/"
        )
        } else {
            self.error = "No API key or secret supplied. Set \(Self.apiKeyVariableName) and \(Self.apiSecretVariableName) in the environment variables."
        }
    }
    
    var apiKey:String? {
        get {
            return ProcessInfo.processInfo.environment[Self.apiKeyVariableName]
        }
    }
    
    var apiSecret:String? {
        get {
            return ProcessInfo.processInfo.environment[Self.apiSecretVariableName]
        }
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
    
    func clientRequest(method: String, path: String, query: [String : Any]? = nil, body: Any? = nil, client:FiskalyHttpClient? = nil) -> FiskalySDK.HttpResponse? {
        let client = client ?? self.client
        do {
            var bodyString = ""
            if let body = body,
               let bodyData = try? JSONSerialization.data(withJSONObject: body) {
                bodyString = bodyData.base64EncodedString()
            }
            if let response = try client?.request(
                method: method,
                path: path,
                query: query, body: bodyString) {
                self.error = nil
                return response
            } else {
                self.error = "Client could not be initialised"
            }
        } catch {
            self.error = error.localizedDescription
        }
        return nil
    }

    
    func createTSS() {
        let newTssUUID = UUID().uuidString
        self.tssUUID = newTssUUID
        
        let tssBody = [
            "description": "iOS Test TSS",
            "state": "INITIALIZED"
        ]

        if let responseCreateTSS = clientRequest(
            method: "PUT",
            path: "tss/\(newTssUUID)",
            body: tssBody) {
            createTSSStatus = responseCreateTSS.status
            createTSSResponse = responseCreateTSS.body.base64Decoded
        }
    }
    
    func createClient() {
        guard let tssID = tssUUID else {
            error = "Can't create client before creating TSS"
            return
        }
        let newClientUUID = UUID().uuidString
        clientUUID = newClientUUID

        let clientBody = [
            "serial_number": "iOS Test Client Serial"
        ]

        if let responseCreateClient = clientRequest(
            method: "PUT",
            path: "tss/\(tssID)/client/\(newClientUUID)",
            body: clientBody) {
            createClientStatus = responseCreateClient.status
            createClientResponse = responseCreateClient.body.base64Decoded
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
            method: "PUT",
            path: "tss/\(tssID)/tx/\(newTransactionUUID)",
            body: transactionBody) {
            createTransactionStatus = responseCreateTransaction.status
            createTransactionResponse = responseCreateTransaction.body.base64Decoded
        }
    }
    
    func finishTransaction() {
        guard let clientID = clientUUID, let tssID = tssUUID, let transactionID=transactionUUID else {
            error = "Can't finish transaction before creating client, TSS, and transaction"
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
            method: "PUT",
            path: "tss/\(tssID)/tx/\(transactionID)",
            query: ["last_revision": "1"],
            body: transactionFinishBody) {
            finishTransactionStatus = responseFinishTransaction.status
            finishTransactionResponse = responseFinishTransaction.body.base64Decoded
        }
    }
    
    func authenticateV2() {
        //not sure if this is needed
        let authenticateBody = [
            "smaers_url": "https://smaers.fiskaly.com"
        ]

        if let responseAuthenticate = clientRequest(
            method: "PUT",
            path: "auth",
            body: authenticateBody,
            client: v2client) {
            authenticateStatus = responseAuthenticate.status
            authenticateResponse = responseAuthenticate.body.base64Decoded
        }
    }
}
