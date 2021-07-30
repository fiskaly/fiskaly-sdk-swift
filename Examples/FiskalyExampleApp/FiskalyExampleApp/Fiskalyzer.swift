//
//  Fiskalyzer.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 09.07.21.
//

import Foundation
import FiskalySDK

struct RequestResponse {
    var response:String?
    var status:Int
    init(_ httpResponse:FiskalySDK.HttpResponse) {
        status = httpResponse.status
        response = httpResponse.body.base64Decoded
    }
}

enum RequestMethod : String {
    case get = "GET"
    case put = "PUT"
    case patch = "PATCH"
    case post = "POST"
}

class Fiskalyzer : ObservableObject {
    var client:FiskalyHttpClient?
    @Published var version:String?
    @Published var error:String?
    @Published var tssUUID:String?
    @Published var createTSSResponse:RequestResponse?
    @Published var clientUUID:String?
    @Published var createClientResponse:RequestResponse?
    @Published var transactionUUID:String?
    @Published var createTransactionResponse:RequestResponse?
    @Published var finishTransactionResponse:RequestResponse?
    var apiKeyVariableName:String
    var apiSecretVariableName:String
    
    init(apiKeyVariableName:String,apiSecretVariableName:String) {
        self.apiKeyVariableName = apiKeyVariableName
        self.apiSecretVariableName = apiSecretVariableName
        if let apiKey = apiKey, let apiSecret = apiSecret {
            do {
                client = try createHttpClient(
                    apiKey: apiKey,
                    apiSecret: apiSecret
                )
                setUpLogging()
            } catch let createClientError {
                self.error = "Could not create client: \(createClientError.localizedDescription)"
                if let error = createClientError as? JsonRpcError {
                    self.error = error.data?.response.body
                    print("error response = \(error.data?.response.body ?? "nothing")")
                }
                
            }
        } else {
            self.error = "No API key or secret supplied. Set \(apiKeyVariableName) and \(apiSecretVariableName) in the environment variables."
        }
    }
    

    func createHttpClient(apiKey:String, apiSecret:String) throws -> FiskalyHttpClient {
        fatalError("createClient needs to be overridden in the subclass")
    }
    
    var apiKey:String? {
        get {
            return ProcessInfo.processInfo.environment[apiKeyVariableName]
        }
    }
    
    var apiSecret:String? {
        get {
            return ProcessInfo.processInfo.environment[apiSecretVariableName]
        }
    }
    
    func clientRequest(method: RequestMethod, path: String, query: [String : Any]? = nil, body: Any? = nil) -> FiskalySDK.HttpResponse? {
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: body ?? Dictionary<String, Any>())
            let bodyString = bodyData.base64EncodedString()
            if let response = try client?.request(
                method: method.rawValue,
                path: path,
                query: query,
                body: bodyString) {
                self.error = nil
                return response
            } else {
                self.error = "Client could not be initialised"
            }
        } catch {
            self.error = error.localizedDescription
            return (error as? JsonRpcError)?.data?.response
        }
        return nil
    }
    
    //these methods are exactly the same between V1 and V2
    
    func createClient() {
        guard let tssID = tssUUID else {
            error = "Can't create client before creating TSS"
            return
        }
        let newClientUUID = UUID().uuidString
        clientUUID = newClientUUID

        let clientBody = [
            "serial_number": "iOS Test Client Serial"
        ]

        if let responseCreateClient = clientRequest(
            method: .put,
            path: "tss/\(tssID)/client/\(newClientUUID)",
            body: clientBody) {
            createClientResponse = RequestResponse(responseCreateClient)
        }
    }
    
    // MARK: Logging
    
    private var logPath:String?
    var log:String {
        get {
            do {
                if let logPath = logPath, FileManager.default.fileExists(atPath: logPath) {
                    return try String(contentsOfFile: logPath)
                } else {
                    return ""
                }
            } catch {
                return "Could not load log: \(error.localizedDescription)"
            }
        }
    }
    
    func clearLog() {
        if let logPath=logPath, FileManager.default.fileExists(atPath: logPath) {
            try? FileManager.default.removeItem(atPath: logPath)
            objectWillChange.send()
        }
    }
    
    private func setUpLogging() {
        logPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("fiskaly-example-app").appendingPathExtension("log").path
        do {
        let _ = try client?.config(
            debugLevel: 3,
            debugFile: logPath,
            clientTimeout: 15000,
            smaersTimeout: 15000,
            httpProxy: "")
        } catch {
            print("Error setting up logging at \(logPath ?? ""): \(error.localizedDescription)")
        }
        print("Client log is at \(logPath ?? "")")
    }
    
    func reset() {
        self.tssUUID = nil
        createTSSResponse = nil
        clientUUID = nil
        createClientResponse = nil
        transactionUUID = nil
        createTransactionResponse = nil
        finishTransactionResponse = nil
    }
    
}
