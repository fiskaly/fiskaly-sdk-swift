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
        NavigationView {
        VStack {
            fiskalyzer.error.map { Text($0).foregroundColor(.red) }.padding([.leading, .trailing], 10)
        ScrollView {
            VStack {
                NavigationLink(
                    destination: ListTSSView(fiskalyzer: fiskalyzer)) {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("List TSS")
                    }
                }.padding()
                CallAndResponseView(name: "Create TSS", response: $fiskalyzer.createTSSResponse) {
                    fiskalyzer.createTSS()
                } content: {
                    UUIDView(uuid: $fiskalyzer.tssUUID, name: "TSS")
                    Text("TSS PUK: \(fiskalyzer.adminPUK ?? "none")")
                    Text("TSS State: \(fiskalyzer.tssState?.rawValue ?? "none")")
                }.disabled(!fiskalyzer.canCreateTSS())
                Group {
                    Group {
                        CallAndResponseView(name: "Personalize TSS", response: $fiskalyzer.personalizeTSSResponse) {
                            fiskalyzer.personalizeTSS()
                        }.disabled(!fiskalyzer.canPersonalizeTSS())
                        CallAndResponseView(name: "Change Admin PIN", response: $fiskalyzer.changeAdminPINResponse) {
                            fiskalyzer.changeAdminPIN()
                        } content: {
                            Text("Admin PIN: \(fiskalyzer.adminPIN ?? "not set")")
                        }.disabled(!fiskalyzer.canChangeAdminPIN())
                        
                        AuthenticateAdminView(fiskalyzer: fiskalyzer)
                        
                        CallAndResponseView(name: "Initialize TSS", response: $fiskalyzer.initializeTSSResponse) {
                            fiskalyzer.initializeTSS()
                        }.disabled(!fiskalyzer.canInitializeTSS())
                        
                        CallAndResponseView(name: "Retrieve TSS", response: $fiskalyzer.retrieveTSSResponse) {
                            fiskalyzer.retrieveTSS()
                        }.disabled(!fiskalyzer.canRetrieveTSS())
                        
                        CallAndResponseView(name: "Retrieve TSS Metadata", response: $fiskalyzer.retrieveTSSMetadataResponse) {
                            fiskalyzer.retrieveTSSMetadata()
                        }.disabled(!fiskalyzer.canRetrieveTSSMetadata())

                        CallAndResponseView(name: "Create Client", response: $fiskalyzer.createClientResponse) {
                            fiskalyzer.createClient()
                        } content: {
                            UUIDView(uuid: $fiskalyzer.clientUUID, name: "Client")
                        }.disabled(!fiskalyzer.canCreateClient())
                    }
                    Group {
                        CallAndResponseView(name: "Update Client", response: $fiskalyzer.updateClientResponse) {
                            fiskalyzer.updateClient()
                        }.disabled(!fiskalyzer.canUpdateClient())
                        
                        AuthenticateAdminView(fiskalyzer: fiskalyzer)
                        
                        CallAndResponseView(name: "Register Client 2", response: $fiskalyzer.registerClient2Response) {
                            fiskalyzer.registerClient2()
                        } content: {
                            UUIDView(uuid: $fiskalyzer.clientUUID2, name: "Client 2")
                        }.disabled(!fiskalyzer.canRegisterClient2())
                        
                        CallAndResponseView(name: "Deregister Client 2", response: $fiskalyzer.deregisterClient2Response) {
                            fiskalyzer.deregisterClient2()
                        }.disabled(!fiskalyzer.canDeregisterClient2())
                        
                        CallAndResponseView(name: "Register Client 2 Again", response: $fiskalyzer.registerClient2AgainResponse) {
                            fiskalyzer.registerClient2Again()
                        }.disabled(!fiskalyzer.canRegisterClient2Again())
                    }

                    CallAndResponseView(name: "Logout Admin", response: $fiskalyzer.logoutAdminResponse) {
                        fiskalyzer.logoutAdmin()
                    }.disabled(!fiskalyzer.canLogoutAdmin())
                    
                    AuthenticateAdminView(fiskalyzer: fiskalyzer)
                    
                    CallAndResponseView(name: "List Clients", response: $fiskalyzer.listClientsResponse) {
                        fiskalyzer.listClients()
                    } content: {
                        List(fiskalyzer.clientList, id:\._id) { client in
                            Text("\(client._id)").font(.body.smallCaps()).padding()
                        }
                    }.disabled(!fiskalyzer.canListClients())
                    Group {
                        CallAndResponseView(name: "Retrieve Client", response: $fiskalyzer.retrieveClientResponse) {
                            fiskalyzer.retrieveClient()
                        }.disabled(!fiskalyzer.canRetrieveClient())
                        
                        CallAndResponseView(name: "Create Transaction", response: $fiskalyzer.createTransactionResponse) {
                            fiskalyzer.createTransaction()
                        } content: {
                            UUIDView(uuid: $fiskalyzer.transactionUUID, name: "Transaction")
                            Text("Transaction revision: \(fiskalyzer.transactionRevision)")
                        }.disabled(!fiskalyzer.canCreateTransaction())
                        
                        Group {
                            CallAndResponseView(name: "Update Transaction", response: $fiskalyzer.updateTransactionResponse) {
                                fiskalyzer.updateTransaction()
                            }.disabled(!fiskalyzer.canUpdateTransaction())
                            
                            CallAndResponseView(name: "Finish Transaction", response: $fiskalyzer.finishTransactionResponse) {
                                fiskalyzer.finishTransaction()
                            }.disabled(!fiskalyzer.canFinishTransaction())
                            CallAndResponseView(name: "Retrieve Transaction", response: $fiskalyzer.retrieveTransactionResponse) {
                                fiskalyzer.retrieveTransaction()
                            }.disabled(!fiskalyzer.canRetrieveTransaction())
                            
                            CallAndResponseView(name: "Retrieve Signed Log of Transaction", response: $fiskalyzer.retrieveSignedLogOfTransactionResponse) {
                                fiskalyzer.retrieveSignedLogOfTransaction()
                            }.disabled(!fiskalyzer.canRetrieveSignedLogOfTransaction())
                            
                        }
                        CallAndResponseView(name: "List Transactions of Client", response: $fiskalyzer.listTransactionsOfClientResponse) {
                            fiskalyzer.listTransactionsOfClient()
                        }.disabled(!fiskalyzer.canListTransactionsOfClient())
                    }
                    CallAndResponseView(name: "List Transactions of TSS", response: $fiskalyzer.listTransactionsOfTSSResponse) {
                        fiskalyzer.listTransactionsOfTSS()
                    }.disabled(!fiskalyzer.canListTransactionsOfTSS())
                }
                
                CallAndResponseView(name: "List All Transactions", response: $fiskalyzer.listAllTransactionsResponse) {
                    fiskalyzer.listAllTransactions()
                }.disabled(!fiskalyzer.canListAllTransactions())
                Group {
                    CallAndResponseView(name: "Trigger Export", response: $fiskalyzer.triggerExportResponse) {
                        fiskalyzer.triggerExport()
                    } content: {
                        UUIDView(uuid: $fiskalyzer.exportUUID, name: "Export")
                    }.disabled(!fiskalyzer.canTriggerExport())
                    Group {
                        CallAndResponseView(name: "Retrieve Export", response: $fiskalyzer.retrieveExportResponse) {
                            fiskalyzer.retrieveExport()
                        }.disabled(!fiskalyzer.canRetrieveExport())
                        CallAndResponseView(name: "Retrieve Export File", response: $fiskalyzer.retrieveExportFileResponse) {
                            fiskalyzer.retrieveExportFile()
                        }.disabled(!fiskalyzer.canRetrieveExportFile())
                        CallAndResponseView(name: "Retrieve Export Metadata", response: $fiskalyzer.retrieveExportMetadataResponse) {
                            fiskalyzer.retrieveExportMetadata()
                        }.disabled(!fiskalyzer.canRetrieveExportMetadata())
                        CallAndResponseView(name: "Update Export Metadata", response: $fiskalyzer.updateExportMetadataResponse) {
                            fiskalyzer.updateExportMetadata()
                        }.disabled(!fiskalyzer.canUpdateExportMetadata())
                        CallAndResponseView(name: "List Exports of TSS", response: $fiskalyzer.listExportsOfTSSResponse) {
                            fiskalyzer.listExportsOfTSS()
                        }.disabled(!fiskalyzer.canListExportsOfTSS())
                    }
                }
                    CallAndResponseView(name: "List All Exports", response: $fiskalyzer.listAllExportsResponse) {
                        fiskalyzer.listAllExports()
                    }.disabled(!fiskalyzer.canListAllExports())
                Group {
                    AuthenticateAdminView(fiskalyzer: fiskalyzer)
                    
                    CallAndResponseView(name: "Disable TSS", response: $fiskalyzer.disableTSSResponse) {
                        fiskalyzer.disableTSS()
                    }.disabled(!fiskalyzer.canDisableTSS())
                }
            }
        }.frame(maxWidth: .infinity)
    }.navigationBarTitle("Fiskaly Sign V2").toolbar {
        ShowLogView(fiskalyzer: fiskalyzer)
    }
    }
    }
}

