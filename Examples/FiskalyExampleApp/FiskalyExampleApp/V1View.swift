//
//  V1View.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 24.06.21.
//

import SwiftUI

struct V1View: View {
    @ObservedObject var fiskalyzer:Fiskalyzer
    @State var expandTSS:Bool = false
    @State var expandClient:Bool = false
    @State var expandTransaction:Bool = false
    @State var expandFinishTransaction:Bool = false
    var body: some View {
        VStack {
        fiskalyzer.error.map { Text($0).foregroundColor(.red) }
        ScrollView {
        VStack {
        Button("Get Version") {
            fiskalyzer.getVersion()
        }
        Text("Version \(fiskalyzer.version ?? "unknown")")
        
        Group {
            Button("Create TSS") {
                fiskalyzer.createTSS()
                expandTSS = true
            }
            UUIDView(uuid: $fiskalyzer.tssUUID, name: "TSS")
            ResponseView(status: $fiskalyzer.createTSSStatus, response: $fiskalyzer.createTSSResponse, expanded: $expandTSS, name: "Create TSS")
        }
        Group {
            Button("Create Client") {
                fiskalyzer.createClient()
                expandClient = true
            }.disabled(fiskalyzer.tssUUID == nil)
            UUIDView(uuid: $fiskalyzer.clientUUID, name: "Client")
            ResponseView(status: $fiskalyzer.createClientStatus, response: $fiskalyzer.createClientResponse, expanded: $expandClient, name: "Create Client")
        }
        
        Group {
            Button("Create Transaction") {
                fiskalyzer.createTransaction()
                expandTransaction = true
            }.disabled(fiskalyzer.tssUUID == nil)
            UUIDView(uuid: $fiskalyzer.transactionUUID, name: "Transaction")
            ResponseView(status: $fiskalyzer.createTransactionStatus, response: $fiskalyzer.createTransactionResponse, expanded: $expandTransaction, name: "Create Transaction")
        }
        
        Group {
            Button("Finish Transaction") {
                fiskalyzer.finishTransaction()
                expandFinishTransaction = true
            }.disabled(fiskalyzer.transactionUUID == nil)
            ResponseView(status: $fiskalyzer.finishTransactionStatus, response: $fiskalyzer.finishTransactionResponse, expanded: $expandFinishTransaction, name: "Finish Transaction")
        }
        
        }
        }.frame(maxWidth: .infinity)
    }
    }
}
