import Foundation

enum FiskalyError: Error {
    case httpError      (response: ResultRequest)
    case httpTimeout    (message: String)
    case requestError   (message: String)
    case sdkError       (message: String)
}

func getError(error: JsonRpcError) -> FiskalyError {

    switch error.code {
    case -20000:
        if let data = error.data {
            return FiskalyError.httpError(response: data)
        } else {
            return FiskalyError.sdkError(message: "Client HTTP error data not readable.")
        }
    case -21000:
        return FiskalyError.httpTimeout(message: error.message)
    case -7353:
        return FiskalyError.requestError(message: error.message)
    default:
        return FiskalyError.sdkError(message: "JsonRPC Error received: \(error.message).")
    }

}
