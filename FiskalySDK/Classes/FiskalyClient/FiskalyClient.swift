import Foundation
import FiskalySDK.Client

func fiskalyClientInvoke(_ request: String) -> String {
    let resultRaw = _fiskaly_client_invoke(request)
    let result = String(cString: resultRaw!)
    _fiskaly_client_free(resultRaw)
    return result
}