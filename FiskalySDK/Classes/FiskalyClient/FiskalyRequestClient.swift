//
//  FiskalyRequestClient.swift
//  FiskalySDK
//
//  Created by Marcel Voß on 09.06.20.
//  Copyright © 2020 fiskaly. All rights reserved.
//

import Foundation
import FiskalySDK.Client

public protocol RequestClient {
    func invoke(request: JsonRpcRequest) -> String
}

public struct FiskalyRequestClient: RequestClient {
    public init() { }

    public func invoke(request: JsonRpcRequest) -> String {
        let resultRaw = _fiskaly_client_invoke(String(describing: request))
        let result = String(cString: resultRaw!)
        _fiskaly_client_free(resultRaw)
        return result
    }
}
