//
//  V1View.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 24.06.21.
//

import SwiftUI

struct V1View: View {
    @ObservedObject var fiskalyzer:FiskalyzerV1
    var body: some View {
        VStack {
        fiskalyzer.error.map { Text($0).foregroundColor(.red) }
        ScrollView {
        VStack {
            Button("Get Version") {
                fiskalyzer.getVersion()
            }
            Text("Version \(fiskalyzer.version ?? "unknown")")
            CallAndResponseView(name: "Create TSS", response: $fiskalyzer.createTSSResponse) {
                fiskalyzer.createTSS()
            } content: {
                UUIDView(uuid: $fiskalyzer.tssUUID, name: "TSS")
            }
            Group {
                CallAndResponseView(name: "Create Client", response: $fiskalyzer.createClientResponse) {
                    fiskalyzer.createClient()
                } content: {
                    UUIDView(uuid: $fiskalyzer.clientUUID, name: "Client")
                }
                CallAndResponseView(name: "Create Transaction", response: $fiskalyzer.createTransactionResponse) {
                    fiskalyzer.createTransaction()
                } content: {
                    UUIDView(uuid: $fiskalyzer.transactionUUID, name: "Transaction")
                }
                CallAndResponseView(name: "Finish Transaction", response: $fiskalyzer.finishTransactionResponse) {
                    fiskalyzer.finishTransaction()
                } content: {
                }.disabled(fiskalyzer.transactionUUID == nil)
            }.disabled(fiskalyzer.tssUUID == nil)
        }
        }.frame(maxWidth: .infinity)
    }
    }
}
