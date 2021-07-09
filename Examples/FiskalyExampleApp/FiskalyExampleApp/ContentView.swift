//
//  ContentView.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 21.06.21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var fiskalyzerV1:FiskalyzerV1
    @ObservedObject var fiskalyzerV2:FiskalyzerV2
    var body: some View {
        TabView {
            V1View(fiskalyzer: fiskalyzerV1).tabItem {
                Label("V1", systemImage: "1.circle")
            }.tag(0)
            V2View(fiskalyzer: fiskalyzerV2).tabItem {
                Label("V2", systemImage: "2.circle")
            }.tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(fiskalyzerV1: FiskalyzerV1(apiKeyVariableName: "API_KEY", apiSecretVariableName: "API_SECRET"), fiskalyzerV2: FiskalyzerV2(apiKeyVariableName: "API_KEY_V2", apiSecretVariableName: "API_SECRET_V2"))
    }
}
