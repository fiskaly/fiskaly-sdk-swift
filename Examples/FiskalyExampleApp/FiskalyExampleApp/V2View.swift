//
//  V2View.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 24.06.21.
//

import SwiftUI

struct V2View: View {
    @ObservedObject var fiskalyzer:Fiskalyzer
    @State var expandAuthenticate:Bool = false
    var body: some View {
        //we need a ScrollView or VStack even when there's only one group, otherwise the individual items in the group get put in their own tabs for some reason.
        VStack {
        fiskalyzer.error.map { Text($0).foregroundColor(.red) }
        ScrollView {
            VStack {
                Group {
                    Button("Authenticate") {
                        fiskalyzer.authenticateV2()
                        expandAuthenticate = true
                    }
                    UUIDView(uuid: $fiskalyzer.transactionUUID, name: "Transaction")
                    ResponseView(status: $fiskalyzer.authenticateStatus, response: $fiskalyzer.authenticateResponse, expanded: $expandAuthenticate, name: "Create Transaction")
                }
            }
        }.frame(maxWidth: .infinity)
    }
    }
}

