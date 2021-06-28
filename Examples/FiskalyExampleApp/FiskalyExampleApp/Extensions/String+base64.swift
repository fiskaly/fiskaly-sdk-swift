//
//  String+base64.swift
//  FiskalyExampleApp
//
//  Created by Angela Brett on 24.06.21.
//

import Foundation

extension String {
    var base64Decoded:String? {
        get {
            if let decodedData = Data(base64Encoded: self) {
                return String(data: decodedData, encoding: .utf8)
            }
            return nil
        }
    }
}
