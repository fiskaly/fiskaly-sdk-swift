//
//  ResponseBodyTypes.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 15.07.21.
//

import Foundation

public enum TSSState : String, Codable {
    case created = "CREATED"
    case uninitialized = "UNINITIALIZED"
    case initialized = "INITIALIZED"
    case disabled = "DISABLED"
}

struct TSS : Codable {
    var _id:String
    var state:TSSState
}

struct ListOfTSS : Codable {
    var data:[TSS]
}

struct Client : Codable {
    var _id:String
}

struct ListOfClients : Codable {
    var data:[Client]
}
