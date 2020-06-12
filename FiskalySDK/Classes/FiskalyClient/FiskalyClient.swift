import Foundation
import FiskalySDK.Client

func fiskalyClientInvoke(_ request: String) throws -> String {
    guard let resultRaw = _fiskaly_client_invoke(request) else {
        throw FiskalyError.sdkError(message: "fiskaly_client_invoke returned nothing")
    }
    let result = String(cString: resultRaw)
    _fiskaly_client_free(resultRaw)
    return result
}
