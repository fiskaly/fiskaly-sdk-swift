//
//  V2View.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 24.06.21.
//

import SwiftUI

struct V2View: View {
    @ObservedObject var fiskalyzer:FiskalyzerV2
    @State var expandAuthenticate:Bool = false
    @State var expandTSS:Bool = false
    @State var expandPersonalizeTSS:Bool = false
    @State var expandClient:Bool = false
    @State var expandTransaction:Bool = false
    @State var expandFinishTransaction:Bool = false
    @State var expandChangeAdminPIN:Bool = false
    @State var expandInitializeTSS:Bool = false
    @State var expandLogoutAdmin:Bool = false
    var body: some View {
        //we need a ScrollView or VStack even when there's only one group, otherwise the individual items in the group get put in their own tabs for some reason.
        VStack {
        fiskalyzer.error.map { Text($0).foregroundColor(.red) }
        ScrollView {
            VStack {
                Group {
                    Button("Create TSS") {
                        fiskalyzer.createTSS()
                        expandTSS = true
                    }
                    UUIDView(uuid: $fiskalyzer.tssUUID, name: "TSS")
                    Text("TSS PUK: \(fiskalyzer.adminPUK ?? "none")")
                    ResponseView(response: $fiskalyzer.createTSSResponse, expanded: $expandTSS, name: "Create TSS")
                }
                Group {
                    Group {
                        Button("Personalize TSS") {
                            fiskalyzer.personalizeTSS()
                            expandPersonalizeTSS = true
                        }
                        Text("TSS State: \(fiskalyzer.tssState ?? "none")")
                        ResponseView(response: $fiskalyzer.personalizeTSSResponse, expanded: $expandPersonalizeTSS, name: "Personalize TSS")
                    }
                    Group {
                        Button("Change Admin PIN") {
                            fiskalyzer.changeAdminPIN()
                            expandChangeAdminPIN = true
                        }
                        Text("Admin PIN: \(fiskalyzer.adminPIN ?? "not set")")
                        ResponseView(response: $fiskalyzer.changeAdminPINResponse, expanded: $expandChangeAdminPIN, name: "Change Admin PIN")
                    }
                    Group {
                        Button("Initialize TSS") {
                            fiskalyzer.initializeTSS()
                            expandInitializeTSS = true
                        }
                        ResponseView(response: $fiskalyzer.initializeTSSResponse, expanded: $expandInitializeTSS, name: "Initialize TSS")
                    }
                    Group {
                        Button("Create Client") {
                            fiskalyzer.createClient()
                            expandClient = true
                        }
                        UUIDView(uuid: $fiskalyzer.clientUUID, name: "Client")
                        ResponseView(response: $fiskalyzer.createClientResponse, expanded: $expandClient, name: "Create Client")
                    }
                    
                    Group {
                        Button("Logout Admin") {
                            fiskalyzer.logoutAdmin()
                            expandLogoutAdmin = true
                        }
                        ResponseView(response: $fiskalyzer.logoutAdminResponse, expanded: $expandLogoutAdmin, name: "Logout Admin")
                    }
                    
                    Group {
                        Button("Create Transaction") {
                            fiskalyzer.createTransaction()
                            expandTransaction = true
                        }
                        UUIDView(uuid: $fiskalyzer.transactionUUID, name: "Transaction")
                        ResponseView(response: $fiskalyzer.createTransactionResponse, expanded: $expandTransaction, name: "Create Transaction")
                    }
                    
                    Group {
                        Button("Finish Transaction") {
                            fiskalyzer.finishTransaction()
                            expandFinishTransaction = true
                        }.disabled(fiskalyzer.transactionUUID == nil)
                        ResponseView(response: $fiskalyzer.finishTransactionResponse, expanded: $expandFinishTransaction, name: "Finish Transaction")
                    }
                }.disabled(fiskalyzer.tssUUID == nil)
            }
        }.frame(maxWidth: .infinity)
    }
    }
}

