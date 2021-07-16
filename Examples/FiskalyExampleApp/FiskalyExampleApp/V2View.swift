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
        fiskalyzer.error.map { Text($0).foregroundColor(.red) }
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
                    Text("TSS State: \(fiskalyzer.tssState ?? "none")")
                }
                Group {
                    Group {
                        CallAndResponseView(name: "Personalize TSS", response: $fiskalyzer.personalizeTSSResponse) {
                            fiskalyzer.personalizeTSS()
                        }
                        CallAndResponseView(name: "Change Admin PIN", response: $fiskalyzer.changeAdminPINResponse) {
                            fiskalyzer.changeAdminPIN()
                        } content: {
                            Text("Admin PIN: \(fiskalyzer.adminPIN ?? "not set")")
                        }
                        
                        AuthenticateAdminView(fiskalyzer: fiskalyzer)
                        
                        CallAndResponseView(name: "Initialize TSS", response: $fiskalyzer.initializeTSSResponse) {
                            fiskalyzer.initializeTSS()
                        }
                        
                        CallAndResponseView(name: "Retrieve TSS", response: $fiskalyzer.retrieveTSSResponse) {
                            fiskalyzer.retrieveTSS()
                        }
                        
                        CallAndResponseView(name: "Retrieve TSS Metadata", response: $fiskalyzer.retrieveTSSMetadataResponse) {
                            fiskalyzer.retrieveTSSMetadata()
                        }

                        CallAndResponseView(name: "Create Client", response: $fiskalyzer.createClientResponse) {
                            fiskalyzer.createClient()
                        } content: {
                            UUIDView(uuid: $fiskalyzer.clientUUID, name: "Client")
                        }
                    }
                    Group {
                        CallAndResponseView(name: "Update Client", response: $fiskalyzer.updateClientResponse) {
                            fiskalyzer.updateClient()
                        }
                        
                        AuthenticateClientView(fiskalyzer: fiskalyzer)
                        
                        AuthenticateAdminView(fiskalyzer: fiskalyzer)
                        
                        CallAndResponseView(name: "Register Client 2", response: $fiskalyzer.registerClient2Response) {
                            fiskalyzer.registerClient2()
                        } content: {
                            UUIDView(uuid: $fiskalyzer.clientUUID2, name: "Client 2")
                        }
                        
                        CallAndResponseView(name: "Deregister Client 2", response: $fiskalyzer.deregisterClient2Response) {
                            fiskalyzer.deregisterClient2()
                        }
                        
                        CallAndResponseView(name: "Register Client 2 Again", response: $fiskalyzer.registerClient2AgainResponse) {
                            fiskalyzer.registerClient2Again()
                        }
                    }.disabled(fiskalyzer.clientUUID == nil)

                    CallAndResponseView(name: "Logout Admin", response: $fiskalyzer.logoutAdminResponse) {
                        fiskalyzer.logoutAdmin()
                    }
                    
                    AuthenticateAdminView(fiskalyzer: fiskalyzer)
                    
                    
                    CallAndResponseView(name: "List Clients", response: $fiskalyzer.listClientsResponse) {
                        fiskalyzer.listClients()
                    } content: {
                        List(fiskalyzer.clientList, id:\._id) { client in
                            Text("\(client._id)").font(.body.smallCaps()).padding()
                        }
                    }
                    Group {
                        CallAndResponseView(name: "Retrieve Client", response: $fiskalyzer.retrieveClientResponse) {
                            fiskalyzer.retrieveClient()
                        }
                        AuthenticateClientView(fiskalyzer: fiskalyzer)
                        
                        CallAndResponseView(name: "Create Transaction", response: $fiskalyzer.createTransactionResponse) {
                            fiskalyzer.createTransaction()
                        } content: {
                            UUIDView(uuid: $fiskalyzer.transactionUUID, name: "Transaction")
                            Text("Transaction revision: \(fiskalyzer.transactionRevision)")
                        }
                        
                        Group {
                            CallAndResponseView(name: "Update Transaction", response: $fiskalyzer.updateTransactionResponse) {
                                fiskalyzer.updateTransaction()
                            }
                            
                            CallAndResponseView(name: "Finish Transaction", response: $fiskalyzer.finishTransactionResponse) {
                                fiskalyzer.finishTransaction()
                            }
                            CallAndResponseView(name: "Retrieve Transaction", response: $fiskalyzer.retrieveTransactionResponse) {
                                fiskalyzer.retrieveTransaction()
                            }
                            
                            CallAndResponseView(name: "Retrieve Signed Log of Transaction", response: $fiskalyzer.retrieveSignedLogOfTransactionResponse) {
                                fiskalyzer.retrieveSignedLogOfTransaction()
                            }
                            
                        }.disabled(fiskalyzer.transactionUUID == nil)
                        CallAndResponseView(name: "List Transactions of Client", response: $fiskalyzer.listTransactionsOfClientResponse) {
                            fiskalyzer.listTransactionsOfClient()
                        }
                    }.disabled(fiskalyzer.clientUUID == nil)
                    CallAndResponseView(name: "List Transactions of TSS", response: $fiskalyzer.listTransactionsOfTSSResponse) {
                        fiskalyzer.listTransactionsOfTSS()
                    }
                    
                }.disabled(fiskalyzer.tssUUID == nil)
                
                CallAndResponseView(name: "List All Transactions", response: $fiskalyzer.listAllTransactionsResponse) {
                    fiskalyzer.listAllTransactions()
                }
                Group {
                    CallAndResponseView(name: "Trigger Export", response: $fiskalyzer.triggerExportResponse) {
                        fiskalyzer.triggerExport()
                    } content: {
                        UUIDView(uuid: $fiskalyzer.exportUUID, name: "Export")
                    }
                    Group {
                        CallAndResponseView(name: "Retrieve Export", response: $fiskalyzer.retrieveExportResponse) {
                            fiskalyzer.retrieveExport()
                        }
                        CallAndResponseView(name: "Retrieve Export File", response: $fiskalyzer.retrieveExportFileResponse) {
                            fiskalyzer.retrieveExportFile()
                        }
                        CallAndResponseView(name: "Retrieve Export Metadata", response: $fiskalyzer.retrieveExportMetadataResponse) {
                            fiskalyzer.retrieveExportMetadata()
                        }
                        CallAndResponseView(name: "Update Export Metadata", response: $fiskalyzer.updateExportMetadataResponse) {
                            fiskalyzer.updateExportMetadata()
                        }
                        CallAndResponseView(name: "List Exports of TSS", response: $fiskalyzer.listExportsOfTSSResponse) {
                            fiskalyzer.listExportsOfTSS()
                        }
                    }.disabled(fiskalyzer.exportUUID == nil)
                }.disabled(fiskalyzer.tssUUID == nil)
                    CallAndResponseView(name: "List All Exports", response: $fiskalyzer.listAllExportsResponse) {
                        fiskalyzer.listAllExports()
                    }
                Group {
                    AuthenticateAdminView(fiskalyzer: fiskalyzer)
                    
                    CallAndResponseView(name: "Disable TSS", response: $fiskalyzer.disableTSSResponse) {
                        fiskalyzer.disableTSS()
                    }
                }.disabled(fiskalyzer.tssUUID == nil)
            }
        }.frame(maxWidth: .infinity)
    }.navigationBarTitle("Fiskaly Sign V2").toolbar {
        ShowLogView(fiskalyzer: fiskalyzer)
    }
    }
    }
}

