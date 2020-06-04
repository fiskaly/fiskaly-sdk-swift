import Foundation

/*
 Create-Context
 */

public class ResultCreateContext: Codable {
    var context: String
}

/*
 Version
 */

public class ResultVersion: Codable {
    public var client: ClientVersion
    public var smaers: SMAERSVersion
}

public class ClientVersion: Codable {
    public var version: String
    public var sourceHash: String
    public var commitHash: String

    enum CodingKeys: String, CodingKey {
        case version
        case sourceHash = "source_hash"
        case commitHash = "commit_hash"
    }

}

public class SMAERSVersion: Codable {
    public var version: String
}

/*
 Config
 */

public class ResultConfig: Codable {
    public var context: String
    public var config: Config
}

public class Config: Codable {
    public var debugLevel: Int
    public var debugFile: String
    public var clientTimeout: Int
    public var smaersTimeout: Int

    enum CodingKeys: String, CodingKey {
        case debugLevel =       "debug_level"
        case debugFile  =       "debug_file"
        case clientTimeout =    "client_timeout"
        case smaersTimeout =    "smaers_timeout"
    }

}

/*
 Request
 */

public class ResultRequest: Codable {
    public var response: HttpResponse
    public var context: String?
}

public class HttpResponse: Codable {
    public var status: Int
    public var body: String
    public var headers: [String: [String]]
}
