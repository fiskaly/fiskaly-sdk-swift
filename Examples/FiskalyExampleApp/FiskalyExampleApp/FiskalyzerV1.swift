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
            method: "PUT",
            path: "tss/\(newTssUUID)",
            body: tssBody) {
            createTSSResponse = RequestResponse(responseCreateTSS)
        }
    }
    
}
