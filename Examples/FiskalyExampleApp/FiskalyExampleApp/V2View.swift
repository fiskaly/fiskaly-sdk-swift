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
    @State var expandTSS:Bool = false
    @State var expandClient:Bool = false
    @State var expandTransaction:Bool = false
    @State var expandFinishTransaction:Bool = false
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
                    ResponseView(response: $fiskalyzer.authenticateResponse, expanded: $expandAuthenticate, name: "Create Transaction")
                }
                Group {
                    Button("Create TSS") {
                        fiskalyzer.createTSSV2()
                        expandTSS = true
                    }
                    UUIDView(uuid: $fiskalyzer.tssUUIDV2, name: "TSS")
                    ResponseView(response: $fiskalyzer.createTSSResponseV2, expanded: $expandTSS, name: "Create TSS")
                }
                Group {
                    Button("Create Client") {
                        fiskalyzer.createClientV2()
                        expandClient = true
                    }.disabled(fiskalyzer.tssUUID == nil)
                    UUIDView(uuid: $fiskalyzer.clientUUIDV2, name: "Client")
                    ResponseView(response: $fiskalyzer.createClientResponseV2, expanded: $expandClient, name: "Create Client")
                }
                
                Group {
                    Button("Create Transaction") {
                        fiskalyzer.createTransactionV2()
                        expandTransaction = true
                    }.disabled(fiskalyzer.tssUUID == nil)
                    UUIDView(uuid: $fiskalyzer.transactionUUIDV2, name: "Transaction")
                    ResponseView(response: $fiskalyzer.createTransactionResponseV2, expanded: $expandTransaction, name: "Create Transaction")
                }
                
                Group {
                    Button("Finish Transaction") {
                        fiskalyzer.finishTransactionV2()
                        expandFinishTransaction = true
                    }.disabled(fiskalyzer.transactionUUIDV2 == nil)
                    ResponseView(response: $fiskalyzer.finishTransactionResponseV2, expanded: $expandFinishTransaction, name: "Finish Transaction")
                }
            }
        }.frame(maxWidth: .infinity)
    }
    }
}

