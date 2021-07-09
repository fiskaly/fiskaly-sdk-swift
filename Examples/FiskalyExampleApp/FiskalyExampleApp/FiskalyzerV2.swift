//
//  FiskalyzerV2.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 09.07.21.
//

import Foundation
import FiskalySDK

class FiskalyzerV2 : Fiskalyzer {

    override func createHttpClient(apiKey: String, apiSecret: String) throws -> FiskalyHttpClient {
        return try FiskalyHttpClient(
            apiKey: apiKey,
            apiSecret: apiSecret,
            baseUrl: "https://sign.fiskaly.dev/api/v2",
            smaersUrl: "http://smaers-gateway:8080",
            miceUrl: "https://mice.fiskaly.dev"
        )
    }
    
    //V2 does not need the state
    func createTSS() {
        let newTssUUID = UUID().uuidString
        self.tssUUID = newTssUUID

        if let responseCreateTSS = clientRequest(
            method: "PUT",
            path: "tss/\(newTssUUID)") {
            createTSSResponse = RequestResponse(responseCreateTSS)
        }
    }
}
