import Foundation

/*
 Create-Context
 */

public class ResultCreateContext : Codable {
    var context: String
}

/*
 Version
 */

public class ResultVersion : Codable {
    public var client: ClientVersion
    public var smaers: SMAERSVersion
}

public class ClientVersion : Codable {
    public var version: String
    public var source_hash: String
    public var commit_hash: String
}

public class SMAERSVersion : Codable {
    public var version: String
}

/*
 Config
 */

public class ResultConfig : Codable {
    public var context: String
    public var config: Config
}

public class Config : Codable {
    public var debug_level: Int
    public var debug_file: String
    public var client_timeout: Int
    public var smaers_timeout: Int
}

/*
 Request
 */

public class ResultRequest : Codable {
    public var response: HttpResponse
    public var context: String?
}

public class HttpResponse : Codable {
    public var status: Int
    public var body: String
    public var headers: [String: [String]]
}
