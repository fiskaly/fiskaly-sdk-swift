import Foundation

public class JsonRpcError: Error, Codable {

    public var code: Int
    public var message: String
    public var data: ResultRequest?
    
    private enum CodingKeys: String, CodingKey {
        case code
        case message
        case data
    }
}

extension JsonRpcError: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "JSON RPC error \(code): \(message)\n\(data?.response.body ?? "no response body")"
    }
}
