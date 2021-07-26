//
//  FiskalyzerV2.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 09.07.21.
//

import Foundation
import FiskalySDK

enum AdminStatus : String {
    case noTSS = "No TSS"
    case noPIN = "No PIN set"
    case loggedOut = "Logged out"
    case loggedIn = "Logged in"
}

class FiskalyzerV2 : Fiskalyzer {
    @Published var adminPUK:String?
    @Published var tssState:String?
    @Published var adminPIN:String?
    @Published var adminStatus:AdminStatus = .noTSS
    @Published var transactionRevision:Int = 0
    @Published var changeAdminPINResponse:RequestResponse?
    @Published var personalizeTSSResponse:RequestResponse?
    @Published var initializeTSSResponse:RequestResponse?
    @Published var logoutAdminResponse:RequestResponse?
    @Published var updateTransactionResponse:RequestResponse?
    @Published var authenticateAdminResponse:RequestResponse?
    @Published var disableTSSResponse:RequestResponse?
    @Published var retrieveTSSResponse:RequestResponse?
    @Published var retrieveTSSMetadataResponse:RequestResponse?
    @Published var updateClientResponse:RequestResponse?
    @Published var registerClient2Response:RequestResponse?
    @Published var clientUUID2:String?
    @Published var deregisterClient2Response:RequestResponse?
    @Published var registerClient2AgainResponse:RequestResponse?
    @Published var retrieveClientResponse:RequestResponse?
    @Published var retrieveTransactionResponse:RequestResponse?
    @Published var retrieveSignedLogOfTransactionResponse:RequestResponse?
    @Published var listTransactionsOfClientResponse:RequestResponse?
    @Published var listTransactionsOfTSSResponse:RequestResponse?
    @Published var listAllTransactionsResponse:RequestResponse?
    @Published var triggerExportResponse:RequestResponse?
    @Published var exportUUID:String?
    @Published var retrieveExportResponse:RequestResponse?
    @Published var listAllExportsResponse:RequestResponse?
    @Published var listExportsOfTSSResponse:RequestResponse?
    @Published var retrieveExportFileResponse:RequestResponse?
    @Published var retrieveExportMetadataResponse:RequestResponse?
    @Published var updateExportMetadataResponse:RequestResponse?
    
    @Published var TSSList:[TSS] = []
    @Published var listTSSResponse:RequestResponse?
    @Published var clientList:[Client] = []
    @Published var listClientsResponse:RequestResponse?

    override func createHttpClient(apiKey: String, apiSecret: String) throws -> FiskalyHttpClient {
        return try FiskalyHttpClient(
            apiKey: apiKey,
            apiSecret: apiSecret,
            baseUrl: "https://kassensichv.fiskaly.dev/api/v2",
            smaersUrl: "http://smaers-gateway:8080",
            miceUrl: "https://kassensichv-middleware.fiskaly.dev"
        )
    }
    
    //V2 does not set the state when creating the TSS; it sets it later. However, it does need to get the admin PUK at this step in order to set the Admin PIN and authenticate.
    func createTSS() {
        let newTssUUID = UUID().uuidString
        self.tssUUID = newTssUUID

        if let responseCreateTSS = clientRequest(
            method: .put,
            path: "tss/\(newTssUUID)") {
            createTSSResponse = RequestResponse(responseCreateTSS)
            guard responseCreateTSS.status == 200 else {
                return
            }
            guard let responseBodyData = Data(base64Encoded: responseCreateTSS.body) else {
                error = "Create TSS response body is not valid base64"
                return
            }
            do {
                let responseBody = try JSONSerialization.jsonObject(with: responseBodyData, options: []) as? [String: Any]
                adminPUK = responseBody?["admin_puk"] as? String
                adminStatus = .noPIN
                tssState = "CREATED"
                //now we don't care about the response for disabling the last TSS; it would just be confusing when we get to that step again with this TSS.
                disableTSSResponse = nil
            } catch {
                self.error = "Create TSS response body is not valid JSON: \(error.localizedDescription)"
            }
        }
    }
    
    func personalizeTSS() {
        if let tssUUID = tssUUID {
            personalizeTSSResponse = setTSSState(tssUUID, state: "UNINITIALIZED")
        }
    }
    
    func initializeTSS() {
        if let tssUUID = tssUUID {
            initializeTSSResponse = setTSSState(tssUUID, state: "INITIALIZED")
        }
    }
    
    func changeAdminPIN() {
        if let tssUUID = tssUUID {
            //this has to be at least 6 characters, but there are no other restrictions
            adminPIN = String((0..<10).map{ _ in "0123456789".randomElement()!})
            let changeAdminPinBody = [
                "admin_puk": adminPUK,
                "new_admin_pin": adminPIN
            ]
            if let response = clientRequest(method: .patch, path: "tss/\(tssUUID)/admin", body: changeAdminPinBody) {
                changeAdminPINResponse = RequestResponse(response)
                adminStatus = .loggedOut
            }
        }
    }
    
    func logoutAdmin() {
        if let tssUUID = tssUUID {
            if let response = clientRequest(method: .post, path: "tss/\(tssUUID)/admin/logout", body: nil) {
                logoutAdminResponse = RequestResponse(response)
                adminStatus = .loggedOut
                authenticateAdminResponse = nil //this is just so that when we get to the second 'authenticate admin' step, it won't look like it's already been done.
            }
        }
    }
    
    //transaction create/update calls in V2 have a tx_revision parameter starting at 1
    fileprivate func transactionRequest(_ tssUUID: String, _ transactionUUID: String, _ updateTransactionBody: [String : Any]) -> HttpResponse? {
        transactionRevision += 1
        return clientRequest(
            method: .put,
            path: "tss/\(tssUUID)/tx/\(transactionUUID)",
            query: ["tx_revision": transactionRevision],
            body: updateTransactionBody)
    }
    
    func createTransaction() {
        guard let tssUUID = tssUUID, let clientUUID = clientUUID else {
            error = "Can't create transaction before creating TSS"
            return
        }
        let transactionBody = [
            "state": "ACTIVE",
            "client_id": clientUUID
        ]
        let transactionUUID = UUID().uuidString
        transactionRevision = 0 //this should be 1 when creating a transaction, but it will be incremented in updateTransaction
        if let response = transactionRequest(tssUUID, transactionUUID, transactionBody) {
            createTransactionResponse = RequestResponse(response)
            self.transactionUUID = transactionUUID
        }
    }
    
    func updateTransaction() {
        guard let clientUUID=clientUUID, let tssUUID=tssUUID, let transactionUUID=transactionUUID else {
            error = "Can't update transaction before creating TSS, client, and transaction"
            return
        }
        let updateTransactionBody: [String: Any] = [
            "schema": [
                "standard_v1": [
                    "receipt": [
                        "receipt_type": "RECEIPT",
                        "amounts_per_vat_rate": [
                            [
                                "vat_rate": "NORMAL",
                                "amount": "21.42"
                            ]
                        ],
                        "amounts_per_payment_type": [
                            [
                                "payment_type": "NON_CASH",
                                "amount": "21.42"
                            ]
                        ]
                    ]
                ]
            ],
            "state": "ACTIVE",
            "client_id": clientUUID
        ]
        if let response = transactionRequest(tssUUID, transactionUUID, updateTransactionBody) {
            updateTransactionResponse = RequestResponse(response)
        }
    }
    
    func finishTransaction() {
        guard let clientUUID=clientUUID, let tssUUID=tssUUID, let transactionUUID=transactionUUID else {
            error = "Can't update transaction before creating TSS, client, and transaction"
            return
        }
        let finishTransactionBody: [String: Any] = [
            "schema": [
                "standard_v1": [
                    "receipt": [
                        "receipt_type": "RECEIPT",
                        "amounts_per_vat_rate": [
                            [
                                "vat_rate": "NORMAL",
                                "amount": "21.42"
                            ]
                        ],
                        "amounts_per_payment_type": [
                            [
                                "payment_type": "NON_CASH",
                                "amount": "21.42"
                            ]
                        ]
                    ]
                ]
            ],
            "state": "FINISHED",
            "client_id": clientUUID
        ]
        if let response = transactionRequest(tssUUID, transactionUUID, finishTransactionBody) {
            finishTransactionResponse = RequestResponse(response)
        }
    }
    
    func authenticateAdmin() {
        guard let tssUUID = tssUUID, let adminPIN = adminPIN else {
            error = "Can't authenticate as admin before creating TSS and setting Admin PIN"
            return
        }
        if let response = clientRequest(method: .post, path: "tss/\(tssUUID)/admin/auth", body: ["admin_pin":adminPIN]) {
            adminStatus = .loggedIn
            authenticateAdminResponse = RequestResponse(response)
        }
    }
    
    func disableTSS() {
        if let tssUUID = tssUUID {
            disableTSS(id: tssUUID)
            self.tssUUID = nil
            adminStatus = .noTSS
            //remove the responses for the other steps so that it's clearer where we're up to if we go through the process again
            reset()
        }
    }
    
    override func reset() {
        changeAdminPINResponse = nil
        personalizeTSSResponse = nil
        initializeTSSResponse = nil
        logoutAdminResponse = nil
        updateTransactionResponse = nil
        authenticateAdminResponse = nil
        listClientsResponse = nil
        retrieveTSSResponse = nil
        retrieveTSSMetadataResponse = nil
        updateClientResponse = nil
        registerClient2Response = nil
        deregisterClient2Response = nil
        registerClient2AgainResponse = nil
        retrieveClientResponse = nil
        retrieveTransactionResponse = nil
        retrieveSignedLogOfTransactionResponse = nil
        listTransactionsOfClientResponse = nil
        listTransactionsOfTSSResponse = nil
        listAllTransactionsResponse = nil
        triggerExportResponse = nil
        retrieveExportResponse = nil
        listAllExportsResponse = nil
        listExportsOfTSSResponse = nil
        retrieveExportFileResponse = nil
        retrieveExportMetadataResponse = nil
        updateExportMetadataResponse = nil
        adminPUK = nil
        adminPIN = nil
        tssState = nil
        tssUUID = nil
        clientUUID = nil
        clientUUID2 = nil
        super.reset()
    }
    
    func disableTSS(id:String) {
        disableTSSResponse = setTSSState(id, state: "DISABLED")
    }
    
    //runs 'List TSS', puts the raw response in listTSSResponse and puts the TSS UUIDs and states in TSSList
    func listTSS() {
        if let response = clientRequest(method: .get, path: "tss") {
            listTSSResponse = RequestResponse(response)
            if response.status == 200 {
                if let data = Data(base64Encoded:response.body) {
                    do {
                        TSSList = try JSONDecoder().decode(ListOfTSS.self, from: data).data
                    } catch {
                        self.error = "Could not decode list of TSS: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    func listClients() {
        guard let tssUUID = tssUUID else {
            error = "Can't list clients without a TSS"
            return
        }
        listClients(of: tssUUID)
    }
    
    func retrieveTSS() {
        guard let tssUUID = tssUUID else {
            error = "Can't retrieve TSS before creating TSS"
            return
        }
        if let response = clientRequest(method: .get, path: "tss/\(tssUUID)") {
            retrieveTSSResponse = RequestResponse(response)
        }
    }
    
    func retrieveTSSMetadata() {
        guard let tssUUID = tssUUID else {
            error = "Can't retrieve TSS metadata before creating TSS"
            return
        }
        if let response = clientRequest(method: .get, path: "tss/\(tssUUID)/metadata") {
            retrieveTSSMetadataResponse = RequestResponse(response)
        }
    }
    
    func updateClient() {
        guard let clientUUID=clientUUID, let tssUUID=tssUUID else {
            error = "Can't update client before creating TSS and client"
            return
        }
        let body: [String: Any] = [
            "state": "REGISTERED",
            "metadata": [
                "custom_field": "custom_value_2"
            ]
        ]
        if let response = clientRequest(method: .patch, path: "tss/\(tssUUID)/client/\(clientUUID)",body: body) {
            updateClientResponse = RequestResponse(response)
        }
    }
    
    fileprivate func registerClient(_ clientUUID: String, _ tssUUID: String) -> RequestResponse? {
        let body: [String: Any] = [
            "serial_number": "ERS \(clientUUID)",
            "metadata": [
                "custom_field": "client 2"
            ]
        ]
        if let response = clientRequest(method: .put, path: "tss/\(tssUUID)/client/\(clientUUID)",body: body) {
             return RequestResponse(response)
        }
        return nil
    }
    
    func registerClient2() {
        guard let tssUUID=tssUUID else {
            error = "Can't register client 2 before creating TSS"
            return
        }
        let newUUID = UUID().uuidString
        clientUUID2 = newUUID
        registerClient2Response = registerClient(newUUID, tssUUID)
    }
    
    func deregisterClient2() {
        guard let tssUUID = tssUUID, let clientUUID2 = clientUUID2 else {
            error = "Can't deregister client 2 before creating TSS and registering client 2"
            return
        }
        let body: [String: Any] = [
            "state":"DEREGISTERED"
        ]
        if let response = clientRequest(method: .patch, path: "tss/\(tssUUID)/client/\(clientUUID2)",body: body) {
            deregisterClient2Response = RequestResponse(response)
        }
    }
    
    func registerClient2Again() {
        guard let tssUUID=tssUUID, let clientUUID2=clientUUID2 else {
            error = "Can't register client 2 again before creating TSS and registering client 2 the first time"
            return
        }
        let body: [String: Any] = [
            "state":"REGISTERED"
        ]
        if let response = clientRequest(method: .patch, path: "tss/\(tssUUID)/client/\(clientUUID2)",body: body) {
            registerClient2AgainResponse = RequestResponse(response)
        }
    }
    
    func retrieveClient() {
        guard let tssUUID = tssUUID, let clientUUID = clientUUID else {
            error = "Can't retrieve client before creating TSS and client"
            return
        }
        if let response = clientRequest(method: .get, path: "tss/\(tssUUID)/client/\(clientUUID)") {
            retrieveClientResponse = RequestResponse(response)
        }
    }
    
    func retrieveTransaction() {
        guard let tssUUID = tssUUID, let transactionUUID = transactionUUID else {
            error = "Can't retrieve transaction before creating TSS and transaction"
            return
        }
        if let response = clientRequest(method: .get, path: "tss/\(tssUUID)/tx/\(transactionUUID)") {
            retrieveTransactionResponse = RequestResponse(response)
        }
    }
    
    func retrieveSignedLogOfTransaction() {
        guard let tssUUID = tssUUID, let transactionUUID = transactionUUID else {
            error = "Can't retrieve signed log of transaction before creating TSS and transaction"
            return
        }
        if let response = clientRequest(method: .get, path: "tss/\(tssUUID)/tx/\(transactionUUID)/log",query: ["tx_revision":transactionRevision]) {
            retrieveSignedLogOfTransactionResponse = RequestResponse(response)
        }
    }
    
    func listTransactionsOfClient() {
        guard let tssUUID = tssUUID, let clientUUID = clientUUID else {
            error = "Can't list transactions of client before creating TSS and client"
            return
        }
        if let response = clientRequest(method: .get, path: "tss/\(tssUUID)/client/\(clientUUID)/tx") {
            listTransactionsOfClientResponse = RequestResponse(response)
        }
    }
    
    func listTransactionsOfTSS() {
        guard let tssUUID = tssUUID else {
            error = "Can't list transactions of TSS before creating TSS"
            return
        }
        if let response = clientRequest(method: .get, path: "tss/\(tssUUID)/tx") {
            listTransactionsOfTSSResponse = RequestResponse(response)
        }
    }
    
    func listAllTransactions() {
        if let response = clientRequest(method: .get, path: "tx") {
            listAllTransactionsResponse = RequestResponse(response)
        }
    }
    
    func triggerExport() {
        guard let tssUUID = tssUUID else {
            error = "Can't trigger export before creating TSS"
            return
        }
        let newUUID = UUID().uuidString
        self.exportUUID = newUUID
        
        if let response = clientRequest(method: .put, path: "tss/\(tssUUID)/export/\(newUUID)") {
            triggerExportResponse = RequestResponse(response)
        }
    }
    
    func retrieveExport() {
        guard let tssUUID = tssUUID, let exportUUID = exportUUID else {
            error = "Can't retrieve export before creating TSS and triggering export"
            return
        }
        
        if let response = clientRequest(method: .get, path: "tss/\(tssUUID)/export/\(exportUUID)") {
            retrieveExportResponse = RequestResponse(response)
        }
    }
    
    func listAllExports() {
        if let response = clientRequest(method: .get, path: "export") {
            listAllExportsResponse = RequestResponse(response)
        }
    }
    
    func listExportsOfTSS() {
        guard let tssUUID = tssUUID else {
            error = "Can't list exports of TSS before creating TSS"
            return
        }
        if let response = clientRequest(method: .get, path: "tss/\(tssUUID)/export") {
            listExportsOfTSSResponse = RequestResponse(response)
        }
    }
    
    func retrieveExportFile() {
        guard let tssUUID = tssUUID, let exportUUID = exportUUID else {
            error = "Can't retrieve export file before creating TSS and triggering export"
            return
        }
        
        if let response = clientRequest(method: .get, path: "tss/\(tssUUID)/export/\(exportUUID)/file") {
            retrieveExportFileResponse = RequestResponse(response)
        }
    }
    
    func retrieveExportMetadata() {
        guard let tssUUID = tssUUID, let exportUUID = exportUUID else {
            error = "Can't retrieve export metadata before creating TSS and triggering export"
            return
        }
        
        if let response = clientRequest(method: .get, path: "tss/\(tssUUID)/export/\(exportUUID)/metadata") {
            retrieveExportMetadataResponse = RequestResponse(response)
        }
    }
    
    func updateExportMetadata() {
        guard let tssUUID = tssUUID, let exportUUID = exportUUID else {
            error = "Can't update export metadata before creating TSS and triggering export"
            return
        }
        
        let body = [
            "my_property_1": "1234",
            "my_property_2": "https://my-internal-system/path/to/resource/1234"
            ]
        
        if let response = clientRequest(method: .patch, path: "tss/\(tssUUID)/export/\(exportUUID)/metadata", body: body) {
            updateExportMetadataResponse = RequestResponse(response)
        }
    }
    
    func listClients(of tss:String) {
        if let response = clientRequest(method: .get, path: "tss/\(tss)/client") {
            listClientsResponse = RequestResponse(response)
            if let data = Data(base64Encoded:response.body) {
                do {
                    clientList = try JSONDecoder().decode(ListOfClients.self, from: data).data
                } catch {
                    self.error = "Could not decode list of Clients: \(error.localizedDescription)"
                }
            }
        }
    }
    
    //while the other disableTSS just runs the Disable TSS command on the TSS you're currently working with (which requires you to have run Authenticate Client first)
    //this version runs all the necessary steps to disable an arbitrary TSS. It runs all the necessary steps before disabling it, so it can be  It's useful when you forget to disable a TSS after using it and run up against the 'Limit of active TSS reached' error.
    func disableTSS(_ tss:TSS) {
        //todo: move the TSS to state Initialized if possible, if it isn't already
        disableTSS(id: tss._id)
    }
    
    func setTSSState(_ tssUUID:String,state:String) -> RequestResponse? {
        let setTSSStateBody = [
            "state" : state
        ]
        if let response = clientRequest(method: .patch,
                                                    path: "tss/\(tssUUID)",
                                                    body: setTSSStateBody
        ) {
            tssState = state
            return RequestResponse(response)
        }
        return nil
    }
}
