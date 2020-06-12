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
            "sdk_version": "iOS SDK 1.1.600"
        ]

        let request = JsonRpcRequest(method: "create-context", params: contextRequestParams)
        let jsonData = fiskalyClientInvoke(String(describing: request))

        if let data = jsonData.data(using: .utf8) {

            let response: JsonRpcResponse<ResultCreateContext>

            do {
                response = try JSONDecoder().decode(JsonRpcResponse<ResultCreateContext>.self, from: data)
            } catch {
                throw FiskalyError.sdkError(message: "Client response not decodable into class.")
            }

            if let result = response.result {
                self.context = result.context
            } else if let error = response.error {
                throw getError(error: error)
            } else {
                throw FiskalyError.sdkError(message: "Client error not readable.")
            }

        } else {
            throw FiskalyError.sdkError(message: "Client response not decodeable into JSON.")
        }

    }

    /*
     Method: Version
     */

    public func version() throws -> ResultVersion {

        let request = JsonRpcRequest(method: "version", params: "")
        let jsonData = fiskalyClientInvoke(String(describing: request))
        if let data = jsonData.data(using: .utf8) {

            let response: JsonRpcResponse<ResultVersion>

            do {
                response = try JSONDecoder().decode(JsonRpcResponse<ResultVersion>.self, from: data)
            } catch {
                throw FiskalyError.sdkError(message: "Client response not decodable into class.")
            }

            if let result = response.result {
                return result
            } else if let error = response.error {
                throw getError(error: error)
            } else {
                throw FiskalyError.sdkError(message: "Client error not readable.")
            }

        } else {
            throw FiskalyError.sdkError(message: "Client response not decodeable into JSON.")
        }

    }

    /*
     Method: Config
     */

    public func config(debugLevel: Int?, debugFile: String?, clientTimeout: Int?, smaersTimeout: Int?) throws -> Config {

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
        let jsonData = fiskalyClientInvoke(String(describing: request))
        if let data = jsonData.data(using: .utf8) {

            let response: JsonRpcResponse<ResultConfig>

            do {
                response = try JSONDecoder().decode(JsonRpcResponse<ResultConfig>.self, from: data)
            } catch {
                throw FiskalyError.sdkError(message: "Client response not decodable into class.")
            }

            if let result = response.result {
                self.context = result.context
                return result.config
            } else if let error = response.error {
                throw getError(error: error)
            } else {
                throw FiskalyError.sdkError(message: "Client error not readable.")
            }

        } else {
            throw FiskalyError.sdkError(message: "Client response not decodeable into JSON.")
        }

    }

    /*
     Method: Echo
     */

    public func echo(data: String) throws -> String {

        let request = JsonRpcRequest(method: "echo", params: data)
        let jsonData = fiskalyClientInvoke(String(describing: request))
        if let data = jsonData.data(using: .utf8) {

            let response: JsonRpcResponse<String>

            do {
                response = try JSONDecoder().decode(JsonRpcResponse<String>.self, from: data)
            } catch {
                throw FiskalyError.sdkError(message: "Client response not decodable into class.")
            }

            if let result = response.result {
                return result
            } else if let error = response.error {
                throw getError(error: error)
            } else {
                throw FiskalyError.sdkError(message: "Client error not readable.")
            }

        } else {
            throw FiskalyError.sdkError(message: "Client response not decodeable into JSON.")
        }

    }

    /*
     Method: Request
     */

    public func request( method: String,
                         path: String = "",
                         query: [String: String]? = nil,
                         headers: [String: String]? = nil,
                         body: String = "") throws -> HttpResponse {

        let requestRequestParams: [String: Any] = [
            "context": self.context,
            "request": [
                "method": method,
                "path": path,
                "body": body as Any,
                "query": query as Any,
                "headers": headers as Any
            ]
        ]

        let request = JsonRpcRequest(method: "request", params: requestRequestParams)
        let jsonData = fiskalyClientInvoke(String(describing: request))
        if let data = jsonData.data(using: .utf8) {

            let response: JsonRpcResponse<ResultRequest>

            do {
                response = try JSONDecoder().decode(JsonRpcResponse<ResultRequest>.self, from: data)
            } catch {
                throw FiskalyError.sdkError(message: "Client response not decodable into class.")
            }

            if let result = response.result {
                if let context = result.context {
                    self.context = context
                    return result.response
                } else {
                    throw FiskalyError.sdkError(message: "Client did not respond with a proper response.")
                }
            } else if let error = response.error {
                throw getError(error: error)
            } else {
                throw FiskalyError.sdkError(message: "Client error not readable.")
            }

        } else {
            throw FiskalyError.sdkError(message: "Client response not decodeable into JSON.")
        }

    }

}
