import Foundation

public class JsonRpcResponse<T: Codable>: Codable {

    public var jsonrpc: String
    public var id: String
    public var result: T?
    public var error: JsonRpcError?

    private enum CodingKeys: String, CodingKey {
        case jsonrpc
        case id
        case result
        case error
    }
}
