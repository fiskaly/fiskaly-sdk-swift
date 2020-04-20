import Foundation

public class JsonRpcResponse<T: Codable>: Codable {
    
    public var jsonrpc: String
    public var id: String
    public var result: T?
    public var error: JsonRpcError?
    
    private enum CodingKeys : String, CodingKey {
        case jsonrpc    = "jsonrpc"
        case id         = "id"
        case result     = "result"
        case error      = "error"
    }

    public required init(from decoder: Decoder) throws {
        
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        self.jsonrpc    = try container.decode(String.self, forKey: .jsonrpc)
        self.id         = try container.decode(String.self, forKey: .id)
        
        if let result   = try container.decodeIfPresent(T.self, forKey: .result) {
            self.result = result
        }
        if let error    = try container.decodeIfPresent(JsonRpcError.self, forKey: .error) {
            self.error = error
        }
        
    }
    
}
