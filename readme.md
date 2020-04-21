# fiskaly SDK for Swift/iOS

The fiskaly SDK includes an HTTP client that is needed<sup>[1](#fn1)</sup> for accessing the [kassensichv.io](https://kassensichv.io) API that implements a cloud-based, virtual **CTSS** (Certified Technical Security System) / **TSE** (Technische Sicherheitseinrichtung) as defined by the German **KassenSichV** ([Kassen­sich­er­ungsver­ord­nung](https://www.bundesfinanzministerium.de/Content/DE/Downloads/Gesetze/2017-10-06-KassenSichV.pdf)).

## Features

- [X] Automatic authentication handling (fetch/refresh JWT and re-authenticate upon 401 errors).
- [X] Automatic retries on failures (server errors or network timeouts/issues).
- [ ] Automatic JSON parsing and serialization of request and response bodies.
- [X] Future: [<a name="fn1">1</a>] compliance regarding [BSI CC-PP-0105-2019](https://www.bsi.bund.de/SharedDocs/Downloads/DE/BSI/Zertifizierung/Reporte/ReportePP/pp0105b_pdf.pdf?__blob=publicationFile&v=7) which mandates a locally executed SMA component for creating signed log messages. 
- [ ] Future: Automatic offline-handling (collection and documentation according to [Anwendungserlass zu § 146a AO](https://www.bundesfinanzministerium.de/Content/DE/Downloads/BMF_Schreiben/Weitere_Steuerthemen/Abgabenordnung/AO-Anwendungserlass/2019-06-17-einfuehrung-paragraf-146a-AO-anwendungserlass-zu-paragraf-146a-AO.pdf?__blob=publicationFile&v=1))

## Integration

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate the fiskaly SDK into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "fiskaly/fiskaly-sdk-swift" "master"
```

## Usage

### Creating a Client Instance 

```swift
let client = try FiskalyHttpClient (
    apiKey:     ProcessInfo.processInfo.environment["API_KEY"]!,
    apiSecret:  ProcessInfo.processInfo.environment["API_SECRET"]!,
    baseUrl:    "https://kassensichv.io/api/v1/"
)
```

### Retrieving the Version of the Client and the SMAERS

```swift
try client.version(
    completion: { (result) in
        switch result {
        case .success(let response):
            print(response.client.version)
            print(response.smaers.version)
            break;
        case .failure(let error):
            print("JsonRpcError: \(error.code) \(error.message)")
            break;
        }
})
```

### Client Configuration

The SDK is built on the [fiskaly Client](https://developer.fiskaly.com/en/docs/client-documentation) which can be [configured](https://developer.fiskaly.com/en/docs/client-documentation#configuration) through the SDK.

```swift
try client.config(
    debugLevel: 3,
    debugFile: "tmp/tmp.log",
    clientTimeout: 1500,
    smaersTimeout: 1500,
    completion: { (result) in
        switch result {
        case .success(let _):
            break;
        case .failure(let error):
            print("JsonRpcError: \(error.code) \(error.message)")
            break;
        }
})
```

### Sending HTTP Requests

Please note:

- the fiskaly client currently only allows UUIDs in lowercase
- the body sent in requests needs to be base64 encoded 

```swift
let transactionUUID = UUID().uuidString.lowercased()

let transactionBody = [
    "state": "ACTIVE",
    "client_id": clientUUID
]
let transactionBodyData = try? JSONSerialization.data(withJSONObject: transactionBody)
let transactionBodyEncoded = transactionBodyData?.base64EncodedString()

try client.request(
    method: "PUT",
    path: "tss/\(tssUUID)/tx/\(transactionUUID)",
    body: transactionBodyEncoded!,
    completion: { (result) in
        switch result {
        case .success(let response):
            print(response.response.status)
            print(response.response.body)
            break;
        case .failure(let error):
            print("JsonRpcError: \(error.code) \(error.message) \(error.data!.response.body)")
            break;
        }
})

// finish Transaction

let transactionFinishBody: [String: Any] = [
    "state": "ACTIVE",
    "client_id": clientUUID,
    "schema": [
        "standard_v1": [
            
            "receipt": [
                "receipt_type": "RECEIPT",
                "amounts_per_vat_rate": [
                    ["vat_rate": "19", "amount": "14.28"]
                ],
                "amounts_per_payment_type": [
                    ["payment_type": "NON_CASH", "amount": "14.28"]
                ]
            ]
            
        ]
    ]
]
let transactionFinishBodyData = try? JSONSerialization.data(withJSONObject: transactionFinishBody)
let transactionFinishBodyEncoded = transactionFinishBodyData?.base64EncodedString()

try client.request(
    method: "PUT",
    path: "tss/\(tssUUID)/tx/\(transactionUUID)",
    query: ["last_revision": "1"],
    body: transactionFinishBodyEncoded!,
    completion: { (result) in
        switch result {
        case .success(let response):
            print(response.response.status)
            print(response.response.body)
            break;
        case .failure(let error):
            print("JsonRpcError: \(error.code) \(error.message) \(error.data!.response.body)")
            break;
        }
})
```

## Related

* [fiskaly.com](https://fiskaly.com)
* [dashboard.fiskaly.com](https://dashboard.fiskaly.com)
* [kassensichv.io](https://kassensichv.io)
* [kassensichv.net](https://kassensichv.net)
