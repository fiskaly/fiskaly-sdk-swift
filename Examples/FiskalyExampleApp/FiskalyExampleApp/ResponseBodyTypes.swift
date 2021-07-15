//
//  ResponseBodyTypes.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 15.07.21.
//

import Foundation

struct TSS : Codable {
    var _id:String
    var state:String
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
