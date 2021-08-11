//
//  FiskalyAPITests.swift
//  FiskalySDKTests
//
//  Created by Angela Brett on 07.07.21.
//  Copyright © 2021 fiskaly. All rights reserved.
//

import Foundation

import XCTest
@testable import FiskalySDK

//Superclass that sets up the client to have verbose logging and outputs the logging from the client into the console so you have more detail if a test fails.
class FiskalyAPITests: XCTestCase {
    var client:FiskalyHttpClient!
    private var logPath:String!

    func setUpLogging(methodName:String) {
        //set up debug logging within the client library so we can show more detail in the test log
        
        //methodName is the full name of the currently running test, Objective-C style, e.g. -[FiskalyAPITestsV2 testTransactionRequest], so we trim it down to just e.g. testTransactionRequest
        let testName = methodName.replacingOccurrences(of: "-[\(String(describing: Self.self)) ", with: "").replacingOccurrences(of: "]", with: "")
        
        logPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("fiskaly-tests-\(testName)").appendingPathExtension("log").path
        
        do {
            //remove the previous log for this test so we can just show the results for this run
            if FileManager.default.fileExists(atPath: logPath) {
                try FileManager.default.removeItem(atPath: logPath)
            }
            
            //set up client logging for this test
            let _ = try client.config(
                debugLevel: 3,
                debugFile: logPath,
                clientTimeout: 1500,
                smaersTimeout: 1500,
                httpProxy: "")
            print("Client log is at \(logPath ?? "")")
        } catch {
            print("Could not set up client logging: \(error)")
            //we can still continue with the test in this case
        }
    }
    func showClientLog() {
        //now show all the logging from the client during this test
        if let logContents = try? String(contentsOfFile: logPath) {
            print("Log contents: \(logContents)")
        }
    }
    
    func clientRequest(method: String, path: String, query: [String : Any]? = nil, body: Any? = nil, headers:[String:String]? = nil) throws -> FiskalySDK.HttpResponse {
        guard let client = self.client else {
            throw FiskalyError.sdkError(message: "Client could not be initialised")
        }
        
        let bodyData = try JSONSerialization.data(withJSONObject: body ?? Dictionary<String, Any>())
        let bodyString = bodyData.base64EncodedString()
        let response = try client.request(
            method: method,
            path: path,
            query: query,
            headers: headers,
            body: bodyString)
        XCTAssertEqual(response.status, 200)
        return response
    }
}
