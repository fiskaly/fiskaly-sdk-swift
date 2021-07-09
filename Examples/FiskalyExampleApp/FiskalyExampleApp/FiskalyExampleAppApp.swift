//
//  FiskalyExampleAppApp.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 21.06.21.
//

import SwiftUI

@main
struct FiskalyExampleAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(fiskalyzerV1: FiskalyzerV1(apiKeyVariableName: "API_KEY", apiSecretVariableName: "API_SECRET"), fiskalyzerV2: FiskalyzerV2(apiKeyVariableName: "API_KEY_V2", apiSecretVariableName: "API_SECRET_V2"))
        }
    }
}
