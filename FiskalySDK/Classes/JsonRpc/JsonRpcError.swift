import Foundation

public class JsonRpcError: Error, Codable {
    
    public var code: Int
    public var message: String
    public var data: ResultRequest?
    
    private enum CodingKeys : String, CodingKey {
        case code       = "code"
        case message    = "message"
        case data       = "data"
    }

    public required init(from decoder: Decoder) throws {
        
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        self.code       = try container.decode(Int.self, forKey: .code)
        self.message    = try container.decode(String.self, forKey: .message)
        
        if let data     = try container.decodeIfPresent(ResultRequest.self, forKey: .data) {
            self.data = data
        }
        
    }
    
}
