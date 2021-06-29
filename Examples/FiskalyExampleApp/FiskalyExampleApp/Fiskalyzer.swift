//
//  Fiskalyzer.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 23.06.21.
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
    private var client:FiskalyHttpClient?
    private var v2client:FiskalyHttpClient?
    @Published var version:String?
    @Published var error:String?
    @Published var tssUUID:String?
    @Published var createTSSResponse:RequestResponse?
    @Published var tssUUIDV2:String?
    @Published var createTSSResponseV2:RequestResponse?
    @Published var clientUUID:String?
    @Published var createClientResponse:RequestResponse?
    @Published var clientUUIDV2:String?
    @Published var createClientResponseV2:RequestResponse?
    @Published var transactionUUID:String?
    @Published var createTransactionResponse:RequestResponse?
    @Published var transactionUUIDV2:String?
    @Published var createTransactionResponseV2:RequestResponse?
    @Published var finishTransactionResponse:RequestResponse?
    @Published var finishTransactionResponseV2:RequestResponse?
    @Published var authenticateResponse:RequestResponse?
    @Published var authenticationToken:String?
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
    
    func clientRequest(method: String, path: String, query: [String : Any]? = nil, body: Any? = nil, client:FiskalyHttpClient? = nil,headers:[String:String]? = nil) -> FiskalySDK.HttpResponse? {
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
                query: query,
                headers: headers,
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
            createTSSResponse = RequestResponse(responseCreateTSS)
        }
    }
    
    //V2 does not need the state
    func createTSSV2() {
        let newTssUUID = UUID().uuidString
        self.tssUUIDV2 = newTssUUID

        if let responseCreateTSS = clientRequest(
            method: "PUT",
            path: "tss/\(newTssUUID)",
            client: v2client,
            headers: authHeader) {
            createTSSResponseV2 = RequestResponse(responseCreateTSS)
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
            createClientResponse = RequestResponse(responseCreateClient)
        }

    }
    
    //this is the same as V1
    func createClientV2() {
        guard let tssID = tssUUIDV2 else {
            error = "Can't create client before creating TSS"
            return
        }
        let newClientUUID = UUID().uuidString
        clientUUIDV2 = newClientUUID

        let clientBody = [
            "serial_number": "iOS Test Client Serial"
        ]

        if let responseCreateClient = clientRequest(
            method: "PUT",
            path: "tss/\(tssID)/client/\(newClientUUID)",
            body: clientBody,client: v2client,headers: authHeader) {
            createClientResponseV2 = RequestResponse(responseCreateClient)
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
    
    //this is the same as V1
    func createTransactionV2() {
        guard let tssID = tssUUIDV2 else {
            error = "Can't create transaction before creating TSS"
            return
        }
        let newTransactionUUID = UUID().uuidString
        transactionUUID = newTransactionUUID

        let transactionBody = [
            "state": "ACTIVE",
            "client_id": clientUUIDV2
        ]

        if let responseCreateTransaction = clientRequest(
            method: "PUT",
            path: "tss/\(tssID)/tx/\(newTransactionUUID)",
            body: transactionBody,
            client: v2client,
            headers: authHeader) {
            createTransactionResponseV2 = RequestResponse(responseCreateTransaction)
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
    
    //this is the same as V1
    func finishTransactionV2() {
        guard let clientID = clientUUIDV2, let tssID = tssUUIDV2, let transactionID=transactionUUIDV2 else {
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
            body: transactionFinishBody,
            client: v2client,
            headers: authHeader) {
            finishTransactionResponseV2 = RequestResponse(responseFinishTransaction)
        }
    }
    
    var authHeader:[String:String]? {
        get {
            if let authenticationToken = authenticationToken {
                return ["Authorization": "Bearer \(authenticationToken)"]
            }
            return nil
        }
    }
    
    func authenticateV2() {
        struct AuthenticationResponse : Codable {
            var accessToken:String
        }
        //not sure if this is needed
        let authenticateBody = [
            "smaers_url": "https://smaers.fiskaly.com"
        ]

        if let responseAuthenticate = clientRequest(
            method: "PUT",
            path: "auth",
            body: authenticateBody,
            client: v2client,
            headers: authHeader) {
            authenticateResponse = RequestResponse(responseAuthenticate)
            if let data = Data(base64Encoded:responseAuthenticate.body) {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    authenticationToken = (try jsonDecoder.decode(AuthenticationResponse.self, from: data)).accessToken
                } catch {
                    self.error = "Error decoding authentication response: \(error.localizedDescription)"
                }
            }
        }
    }
}
