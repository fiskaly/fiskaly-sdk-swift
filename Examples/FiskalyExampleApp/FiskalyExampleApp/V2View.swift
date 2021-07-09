//
//  V2View.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 24.06.21.
//

import SwiftUI

struct V2View: View {
    @ObservedObject var fiskalyzer:FiskalyzerV2
    var body: some View {
        //we need a ScrollView or VStack even when there's only one group, otherwise the individual items in the group get put in their own tabs for some reason.
        VStack {
        fiskalyzer.error.map { Text($0).foregroundColor(.red) }
        ScrollView {
            VStack {
                CallAndResponseView(name: "Create TSS", response: $fiskalyzer.createTSSResponse) {
                    fiskalyzer.createTSS()
                } content: {
                    UUIDView(uuid: $fiskalyzer.tssUUID, name: "TSS")
                    Text("TSS PUK: \(fiskalyzer.adminPUK ?? "none")")
                }
                Group {
                    CallAndResponseView(name: "Personalize TSS", response: $fiskalyzer.personalizeTSSResponse) {
                        fiskalyzer.personalizeTSS()
                    } content: {
                        Text("TSS State: \(fiskalyzer.tssState ?? "none")")
                    }
                    CallAndResponseView(name: "Change Admin PIN", response: $fiskalyzer.changeAdminPINResponse) {
                        fiskalyzer.changeAdminPIN()
                    } content: {
                        Text("Admin PIN: \(fiskalyzer.adminPIN ?? "not set")")
                    }
                    CallAndResponseView(name: "Initialize TSS", response: $fiskalyzer.initializeTSSResponse) {
                        fiskalyzer.initializeTSS()
                    } content: {
                    }
                    CallAndResponseView(name: "Create Client", response: $fiskalyzer.createClientResponse) {
                        fiskalyzer.createClient()
                    } content: {
                        UUIDView(uuid: $fiskalyzer.clientUUID, name: "Client")
                    }
                    CallAndResponseView(name: "Logout Admin", response: $fiskalyzer.logoutAdminResponse) {
                        fiskalyzer.logoutAdmin()
                    } content: {
                    }
                    
                    //todo: authenticate client
                    
                    CallAndResponseView(name: "Create Transaction", response: $fiskalyzer.createTransactionResponse) {
                        fiskalyzer.createTransaction()
                    } content: {
                        UUIDView(uuid: $fiskalyzer.transactionUUID, name: "Transaction")
                    }
                    
                    //todo: update transaction
                    
                    CallAndResponseView(name: "Finish Transaction", response: $fiskalyzer.finishTransactionResponse) {
                        fiskalyzer.finishTransaction()
                    } content: {
                    }.disabled(fiskalyzer.transactionUUID == nil)
                    
                    //todo: authenticate admin again, then disable TSS
                }.disabled(fiskalyzer.tssUUID == nil)
            }
        }.frame(maxWidth: .infinity)
    }
    }
}

