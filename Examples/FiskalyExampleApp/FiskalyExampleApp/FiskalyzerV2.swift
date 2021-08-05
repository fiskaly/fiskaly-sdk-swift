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
    @Published var tssState:TSSState?
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
    
    public func use(tss:TSS) {
        tssUUID = tss._id
        tssState = tss.state
        adminPUK = adminPUK(for:tss._id)
        adminPIN = adminPIN(for:tss._id)
        adminStatus = adminPIN == nil ? .noPIN : .loggedOut
        objectWillChange.send()
    }
    
    var keepLastTSSID = false

    override func createHttpClient(apiKey: String, apiSecret: String) throws -> FiskalyHttpClient {
        return try FiskalyHttpClient(
            apiKey: apiKey,
            apiSecret: apiSecret,
            baseUrl: "https://kassensichv.fiskaly.dev/api/v2",
            miceUrl: "https://kassensichv-middleware.fiskaly.dev"
        )
    }
    
    //V2 does not set the state when creating the TSS; it sets it later. However, it does need to get the admin PUK at this step in order to set the Admin PIN and authenticate.
    fileprivate func createTSS(_ newTssUUID: String) {
        //reset these in case they are set up for a previous TSS
        adminPUK = nil
        adminPIN = nil
        tssState = nil
        adminStatus = .noTSS
        guard let responseCreateTSS = clientRequest(
            method: .put,
            path: "tss/\(newTssUUID)") else {
            return
        }
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
            if let puk = responseBody?["admin_puk"] as? String {
                saveAdminPUK(puk, for: newTssUUID)
                adminPUK = puk
            }
            adminStatus = .noPIN
            tssState = .created
            //now we don't care about the response for disabling the last TSS; it would just be confusing when we get to that step again with this TSS.
            disableTSSResponse = nil
        } catch {
            self.error = "Create TSS response body is not valid JSON: \(error.localizedDescription)"
        }
    }
    
    func canCreateTSS() -> Bool {
        return client != nil
    }
    
    func createTSS() {
        var newTssUUID = UUID().uuidString
        if (keepLastTSSID) {
            newTssUUID = self.tssUUID ?? newTssUUID
            keepLastTSSID = false
        }
        self.tssUUID = newTssUUID
        //todo: return stuff like adminPUK, tssState, etc. and set it here, so that recreating a TSS in order to disable it doesn't mean forgetting about whatever else we're doing with a TSS on the main screen.
        createTSS(newTssUUID)
        if createTSSResponse == nil {
            //there may have been an http timeout, but the TSS was still created.
            //Next time the user tries to create a TSS, we should use the same UUID so we can get a response and use the TSS.
            keepLastTSSID = true
        }
    }
    
    fileprivate func personalizeTSS(id: String) {
        personalizeTSSResponse = setTSSState(id, state: .uninitialized)
    }
    
    /*updateTss makes TSS state transitions possible. The following state transitions are allowed:
     CREATED to UNINITIALIZED,
     UNINITIALIZED to INITIALIZED,
     UNINITIALIZED to DISABLED,
     INITIALIZED to DISABLED.
     */
    func canPersonalizeTSS() -> Bool {
        return tssUUID != nil && tssState == .created
    }
    
    func personalizeTSS() {
        if let tssUUID = tssUUID {
            personalizeTSS(id:tssUUID)
        }
    }
    
    fileprivate func initializeTSS(id: String) {
        initializeTSSResponse = setTSSState(id, state: .initialized)
    }
    
    //Requires Admin Authentication for state change to INITIALIZED and DISABLED
    func canInitializeTSS() -> Bool {
        return tssUUID != nil &&
            tssState == .uninitialized &&
            adminStatus == .loggedIn
    }
    
    func initializeTSS() {
        if let tssUUID = tssUUID {
            initializeTSS(id:tssUUID)
        }
    }
    
    fileprivate func changeAdminPIN(_ adminPUK: String, _ tssUUID: String) {
        //this has to be at least 6 characters, but there are no other restrictions
        let newAdminPIN = String((0..<10).map{ _ in "0123456789".randomElement()!})
        adminPIN = newAdminPIN
        let changeAdminPinBody = [
            "admin_puk": adminPUK,
            "new_admin_pin": newAdminPIN
        ]
        if let response = clientRequest(method: .patch, path: "tss/\(tssUUID)/admin", body: changeAdminPinBody) {
            changeAdminPINResponse = RequestResponse(response)
            if response.status == 200 {
                adminStatus = .loggedOut
                saveAdminPIN(newAdminPIN,for:tssUUID)
            }
        }
    }
    
    //Requires Admin Authentication
    override func canCreateClient() -> Bool {
        return super.canCreateClient() &&
            adminStatus == .loggedIn
    }
    
    func canChangeAdminPIN() -> Bool {
        return tssUUID != nil && tssState == .initialized && adminPUK != nil
    }
    
    func changeAdminPIN() {
        if let tssUUID = tssUUID {
            if let adminPUK = adminPUK {
                changeAdminPIN(adminPUK, tssUUID)
            }
        }
    }
    
    //This operation can be called safely even if no admin is authenticated, so no need to check adminStatus
    func canLogoutAdmin() -> Bool {
        return tssUUID != nil &&
            tssState == .initialized
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
    
    //Requires Admin Authentication
    //Only an ERS associated with a TSS as a "REGISTERED" client may use the TSS. A newly created client automatically has the status "REGISTERED"
    //since we never set the status of the main client to anything other than "REGISTERED", we don't need to check for this.
    func canCreateTransaction() -> Bool {
        return tssUUID != nil &&
            tssState == .initialized &&
            clientUUID != nil &&
            adminStatus == .loggedIn
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
    
    // A DISABLED TSS can no longer be used for signing transactions, but the export of data remains possible.
    //An INITIALIZED TSS can be used for signing transactions.
    func canUpdateTransaction() -> Bool {
        return tssUUID != nil &&
            tssState == .initialized &&
            clientUUID != nil &&
        transactionUUID != nil
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
    
    func canFinishTransaction() -> Bool {
        return canUpdateTransaction()
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
    
    fileprivate func authenticateAdmin(_ tssUUID: String, pin adminPIN: String) {
        if let response = clientRequest(method: .post, path: "tss/\(tssUUID)/admin/auth", body: ["admin_pin":adminPIN]) {
            if response.status == 200 {
                adminStatus = .loggedIn
            }
            authenticateAdminResponse = RequestResponse(response)
        }
    }
    
    func canAuthenticateAdmin() -> Bool {
        return tssUUID != nil &&
            adminPIN != nil &&
            tssState == .initialized
        //it's okay to authenticate admin again if we're already logged in, so no need to check adminStatus
    }
    
    func authenticateAdmin() {
        guard let tssUUID = tssUUID, let adminPIN = adminPIN else {
            error = "Can't authenticate as admin before creating TSS and setting Admin PIN"
            return
        }
        authenticateAdmin(tssUUID, pin:adminPIN)
    }
    
    //Requires Admin Authentication for state change to INITIALIZED and DISABLED
    func canDisableTSS() -> Bool {
        return tssUUID != nil &&
            [.uninitialized, .initialized].contains(tssState) &&
            adminStatus == .loggedIn
    }
    
    func disableTSS() {
        if let tssUUID = tssUUID {
            disableTSS(id: tssUUID)
            //self.tssUUID = nil
            adminStatus = .noTSS
            //remove the responses for the other steps so that it's clearer where we're up to if we go through the process again
            //reset()
        }
    }
    
    func disableTSS(id:String) {
        disableTSSResponse = setTSSState(id, state: .disabled)
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
    
    func canListClients() -> Bool {
        return tssUUID != nil
    }
    
    func listClients() {
        guard let tssUUID = tssUUID else {
            error = "Can't list clients without a TSS"
            return
        }
        listClients(of: tssUUID)
    }
    
    func canRetrieveTSS() -> Bool {
        return tssUUID != nil
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
    
    func canRetrieveTSSMetadata() -> Bool {
        return tssUUID != nil
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
    
    //Requires Admin Authentication
    func canUpdateClient() -> Bool {
        return tssUUID != nil &&
            clientUUID != nil &&
            adminStatus == .loggedIn
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
    
    func canRegisterClient2() -> Bool {
        return canCreateClient()
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
    
    func canDeregisterClient2() -> Bool {
        return canUpdateClient()
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
    
    func canRegisterClient2Again() -> Bool {
        return canUpdateClient()
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
    
    func canRetrieveClient() -> Bool {
        return tssUUID != nil &&
            clientUUID != nil
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
    
    func canRetrieveTransaction() -> Bool {
        return tssUUID != nil &&
            clientUUID != nil &&
            transactionUUID != nil
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
    
    func canRetrieveSignedLogOfTransaction() -> Bool {
        return canRetrieveTransaction()
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
    
    func canListTransactionsOfClient() -> Bool {
        return canRetrieveClient()
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
    
    func canListTransactionsOfTSS() -> Bool {
        return canRetrieveTSS()
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
    
    func canListAllTransactions() -> Bool {
        return true
    }
    
    func listAllTransactions() {
        if let response = clientRequest(method: .get, path: "tx") {
            listAllTransactionsResponse = RequestResponse(response)
        }
    }
    
    func canTriggerExport() -> Bool {
        return canRetrieveTSS()
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
    
    func canRetrieveExport() -> Bool {
        return tssUUID != nil &&
            exportUUID != nil
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
    
    func canListAllExports() -> Bool {
        return true
    }
    
    func listAllExports() {
        if let response = clientRequest(method: .get, path: "export") {
            listAllExportsResponse = RequestResponse(response)
        }
    }
    
    func canListExportsOfTSS() -> Bool {
        return tssUUID != nil
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
    
    func canRetrieveExportFile() -> Bool {
        return canRetrieveExport()
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
    
    func canRetrieveExportMetadata() -> Bool {
        return canRetrieveExport()
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
    
    func canUpdateExportMetadata() -> Bool {
        return canRetrieveExport()
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
    
    func canDisable(_ tss:TSS) -> Bool {
        return [.created,.initialized,.uninitialized].contains(tss.state)
    }
    
    func canUse(_ tss:TSS) -> Bool {
        return true //was tss.state != .disabled, but some actions (e.g. exports, retrieve TSS, list clients or transactions) are still possible with a disabled TSS
    }
    
    func adminPUKKey(for tss:String) -> String {
        return "Admin PUK for TSS \(tss)"
    }
    
    func saveAdminPUK(_ puk:String, for tss:String) {
        UserDefaults.standard.setValue(puk, forKey: adminPUKKey(for:tss))
    }
    
    func adminPUK(for tss:String) -> String? {
        return UserDefaults.standard.string(forKey: adminPUKKey(for:tss))
    }
    
    func adminPINKey(for tss:String) -> String {
        return "Admin PIN for TSS \(tss)"
    }
    
    func saveAdminPIN(_ pin:String, for tss:String) {
        UserDefaults.standard.setValue(pin, forKey: adminPINKey(for:tss))
    }
    
    func adminPIN(for tss:String) -> String? {
        return UserDefaults.standard.string(forKey: adminPINKey(for:tss))
    }
    
    //while the other disableTSS just runs the Disable TSS command on the TSS you're currently working with (which requires you to have run Authenticate Client first)
    //this version runs all the necessary steps to disable an arbitrary TSS. It runs all the necessary steps before disabling it, so it can be  It's useful when you forget to disable a TSS after using it and run up against the 'Limit of active TSS reached' error.
    func disableTSS(_ tss:TSS) {
        //TSS must be in state UNINITIALIZED or INITIALIZED to transition to DISABLED. If it is in state CREATED, we can personalize it first to move it to UNINITIALIZED.
        if (tss.state == .created) {
            //if this TSS is created but we don't know the PUK for it (because the original response timed out or we didn't save the PUK) then we can create it again. The create command is idempotent so it should return the PUK without any other side effects.
            if adminPUK(for:tss._id) == nil {
                createTSS(tss._id)
            }
            personalizeTSS(id: tss._id)
            guard personalizeTSSResponse?.status == 200 else {
                self.error = "Could not personalize TSS"
                return
            }
            //change PIN
            guard let puk = adminPUK(for:tss._id) else {
                self.error = "Could not get PUK for TSS"
                return
            }
            changeAdminPIN(puk, tss._id)
        }
        if let pin = adminPIN(for:tss._id) {
            authenticateAdmin(tss._id, pin: pin)
            guard authenticateAdminResponse?.status == 200 else {
                self.error = "Could not authenticate admin"
                return
            }
            disableTSS(id: tss._id)
        } else {
            self.error = "Admin PIN for this TSS is not known"
        }
        listTSS()
    }
    
    func setTSSState(_ tssUUID:String,state:TSSState) -> RequestResponse? {
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
}
