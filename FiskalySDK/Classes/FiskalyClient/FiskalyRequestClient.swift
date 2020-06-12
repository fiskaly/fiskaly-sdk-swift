import Foundation
import FiskalySDK.Client

public protocol RequestClient {
    func invoke(request: JsonRpcRequest) throws -> String
}

public struct FiskalyRequestClient: RequestClient {
    public init() { }

    public func invoke(request: JsonRpcRequest) throws -> String {
        guard let resultRaw = _fiskaly_client_invoke(String(describing: request)) else {
            throw FiskalyError.sdkError(message: "fiskaly_client_invoke returned nothing")
        }
        let result = String(cString: resultRaw)
        _fiskaly_client_free(resultRaw)
        return result
    }
}
