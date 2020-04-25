import Foundation

public class FiskalyHttpClient {
    
    private var context: String
    
    /*
     Initializer
     */

    public init(apiKey: String, apiSecret: String, baseUrl: String) throws {
        
        // version is hardcorded because using versionNumber from header file strips patch number
        
        let contextRequestParams: [String: String] = [
            "api_key": apiKey,
            "api_secret": apiSecret,
            "base_url": baseUrl,
            "sdk_version": "iOS SDK 1.1.400"
        ]
        
        let request = JsonRpcRequest(method: "create-context", params: contextRequestParams)
        let jsonData = FiskalyClientInvoke(String(describing: request))
        let data = jsonData.data(using: .utf8)
        let response = try JSONDecoder().decode(JsonRpcResponse<ResultCreateContext>.self, from: data!)
        
        if(response.result == nil) {
            throw response.error!
        } else {
            self.context = response.result!.context
        }
        
    }
    
    /*
     Method: Version
     */
    
    public func version(completion: @escaping (Result<ResultVersion, JsonRpcError>) -> Void) throws {
        
        let request = JsonRpcRequest(method: "version", params: "")
        let jsonData = FiskalyClientInvoke(String(describing: request))
        let data = jsonData.data(using: .utf8)
        let response = try JSONDecoder().decode(JsonRpcResponse<ResultVersion>.self, from: data!)
        
        if(response.result == nil) {
            completion(.failure(response.error!))
        } else {
            completion(.success(response.result!))
        }
        
    }
    
    /*
     Method: Config
     */
    
    public func config( debugLevel: Int?,
                        debugFile: String?,
                        clientTimeout: Int?,
                        smaersTimeout: Int?,
                        completion: @escaping (Result<ResultConfig, JsonRpcError>) -> Void) throws {
        
        let configRequestParams: [String: Any] = [
            "context": self.context,
            "config": [
                "debug_level": debugLevel ?? -1,
                "debug_file": debugFile ?? "",
                "client_timeout": clientTimeout ?? 0,
                "smaers_timeout": smaersTimeout ?? 0
            ]
        ]
        
        let request = JsonRpcRequest(method: "config", params: configRequestParams)
        let jsonData = FiskalyClientInvoke(String(describing: request))
        let data = jsonData.data(using: .utf8)
        let response = try JSONDecoder().decode(JsonRpcResponse<ResultConfig>.self, from: data!)
        
        if(response.result == nil) {
            completion(.failure(response.error!))
        } else {
            self.context = response.result!.context
            completion(.success(response.result!))
        }
        
    }
    
    /*
     Method: Echo
     */
    
    public func echo(   data: String,
                        completion: @escaping (Result<String, JsonRpcError>) -> Void) throws {
        
        let request = JsonRpcRequest(method: "echo", params: data)
        let jsonData = FiskalyClientInvoke(String(describing: request))
        let data = jsonData.data(using: .utf8)
        let response = try JSONDecoder().decode(JsonRpcResponse<String>.self, from: data!)
        
        if(response.result == nil) {
            completion(.failure(response.error!))
        } else {
            completion(.success(response.result!))
        }
        
    }
    
    /*
     Method: Request
     */
    
    public func request( method: String,
                         path: String?,
                         completion: @escaping (Result<ResultRequest, JsonRpcError>) -> Void) throws {
        try self.request(method: method, path: path, query: nil, headers: nil, body: "", completion: completion)
    }
    
    public func request( method: String,
                         path: String?,
                         query: [String: String]?,
                         completion: @escaping (Result<ResultRequest, JsonRpcError>) -> Void) throws {
        try self.request(method: method, path: path, query: query, headers: nil, body: "", completion: completion)
    }
    
    public func request( method: String,
                         path: String?,
                         body: String,
                         completion: @escaping (Result<ResultRequest, JsonRpcError>) -> Void) throws {
        try self.request(method: method, path: path, query: nil, headers: nil, body: body, completion: completion)
    }
    
    public func request( method: String,
                         path: String?,
                         query: [String: String]?,
                         body: String,
                         completion: @escaping (Result<ResultRequest, JsonRpcError>) -> Void) throws {
        try self.request(method: method, path: path, query: query, headers: nil, body: body, completion: completion)
    }
    
    public func request( method: String,
                         path: String?,
                         query: [String: String]?,
                         headers: [String: String]?,
                         body: String,
                         completion: @escaping (Result<ResultRequest, JsonRpcError>) -> Void) throws {
        
        let requestRequestParams: [String: Any] = [
            "context": self.context,
            "request": [
                "method": method,
                "path": path ?? "",
                "body": body as Any,
                "query": query as Any,
                "headers": headers as Any
            ]
        ]
        
        let request = JsonRpcRequest(method: "request", params: requestRequestParams)
        let jsonData = FiskalyClientInvoke(String(describing: request))
        let data = jsonData.data(using: .utf8)
        let response = try JSONDecoder().decode(JsonRpcResponse<ResultRequest>.self, from: data!)
        
        if(response.result == nil) {
            completion(.failure(response.error!))
        } else {
            self.context = response.result!.context!
            completion(.success(response.result!))
        }
        
    }
    
}
