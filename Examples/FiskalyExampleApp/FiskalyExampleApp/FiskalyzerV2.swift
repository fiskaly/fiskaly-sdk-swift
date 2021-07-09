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
    @Published var changeAdminPINResponse:RequestResponse?
    @Published var personalizeTSSResponse:RequestResponse?
    @Published var initializeTSSResponse:RequestResponse?
    @Published var logoutAdminResponse:RequestResponse?

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
            }
        }
    }
    
    func logoutAdmin() {
        if let tssUUID = tssUUID {
            if let response = clientRequest(method: "POST", path: "tss/\(tssUUID)/admin/logout", body: nil) {
                logoutAdminResponse = RequestResponse(response)
            }
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
