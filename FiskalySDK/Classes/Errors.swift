import Foundation

enum FiskalyError: Error {
    case httpError      (response: ResultRequest)
    case httpTimeout    (message: String)
    case requestError   (message: String)
    case sdkError       (message: String)
}
