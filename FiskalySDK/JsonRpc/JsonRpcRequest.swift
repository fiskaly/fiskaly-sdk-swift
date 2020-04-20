import Foundation

public class JsonRpcRequest: CustomStringConvertible {
    
    public var jsonrpc = "2.0"
    public var id = UUID().uuidString
    public var method: String
    public var params: Any
    
    public var description: String { return self.createString() }
    
    public init(method: String, params: Any) {
        self.method = method
        self.params = params
    }
    
    public func createString() -> String {
        
        let requestDictionary: [String: Any] = [
            "jsonrpc":  self.jsonrpc,
            "method":   self.method,
            "params":   self.params,
            "id":       self.id
        ]
        let data = try? JSONSerialization.data(withJSONObject: requestDictionary)
        let utf8string = String(data: data!, encoding: .utf8)
        return utf8string!
        
    }
    
}
