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

    public required init(from decoder: Decoder) throws {

        let container   = try decoder.container(keyedBy: CodingKeys.self)

        self.code       = try container.decode(Int.self, forKey: .code)
        self.message    = try container.decode(String.self, forKey: .message)

        if let data     = try container.decodeIfPresent(ResultRequest.self, forKey: .data) {
            self.data = data
        }

    }

}

extension JsonRpcError: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "JSON RPC error \(code): \(message)\n\(data?.context ?? "no additional context")\nbody:\(data?.response.body ?? "")"
    }
}
