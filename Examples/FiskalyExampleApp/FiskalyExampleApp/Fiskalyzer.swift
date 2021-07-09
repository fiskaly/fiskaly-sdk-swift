//
//  Fiskalyzer.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 09.07.21.
//

import Foundation
import FiskalySDK

struct RequestResponse {
    var response:String?
    var status:Int
    init(_ httpResponse:FiskalySDK.HttpResponse) {
        status = httpResponse.status
        response = httpResponse.body.base64Decoded
    }
}

class Fiskalyzer : ObservableObject {
    var client:FiskalyHttpClient?
    @Published var version:String?
    @Published var error:String?
    @Published var tssUUID:String?
    @Published var createTSSResponse:RequestResponse?
    @Published var clientUUID:String?
    @Published var createClientResponse:RequestResponse?
    @Published var transactionUUID:String?
    @Published var createTransactionResponse:RequestResponse?
    @Published var finishTransactionResponse:RequestResponse?
    var apiKeyVariableName:String
    var apiSecretVariableName:String
    
    init(apiKeyVariableName:String,apiSecretVariableName:String) {
        self.apiKeyVariableName = apiKeyVariableName
        self.apiSecretVariableName = apiSecretVariableName
        if let apiKey = apiKey, let apiSecret = apiSecret {
            client = try? createHttpClient(
                apiKey: apiKey,
                apiSecret: apiSecret
            )
        } else {
            self.error = "No API key or secret supplied. Set \(apiKeyVariableName) and \(apiSecretVariableName) in the environment variables."
        }
    }
    
    func createHttpClient(apiKey:String, apiSecret:String) throws -> FiskalyHttpClient {
        fatalError("createClient needs to be overridden in the subclass")
    }
    
    var apiKey:String? {
        get {
            return ProcessInfo.processInfo.environment[apiKeyVariableName]
        }
    }
    
    var apiSecret:String? {
        get {
            return ProcessInfo.processInfo.environment[apiSecretVariableName]
        }
    }
    
    func clientRequest(method: String, path: String, query: [String : Any]? = nil, body: Any? = nil) -> FiskalySDK.HttpResponse? {
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: body ?? Dictionary<String, Any>())
            let bodyString = bodyData.base64EncodedString()
            if let response = try client?.request(
                method: method,
                path: path,
                query: query,
                body: bodyString) {
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
    
    //these methods are exactly the same between V1 and V2
    
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
            createClientResponse = RequestResponse(responseCreateClient)
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
            createTransactionResponse = RequestResponse(responseCreateTransaction)
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
            finishTransactionResponse = RequestResponse(responseFinishTransaction)
        }
    }
    
}
