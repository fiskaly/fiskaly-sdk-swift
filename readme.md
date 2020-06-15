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
github "fiskaly/fiskaly-sdk-swift" ~> 1.2.000
```

Run the following command to fetch the SDKs source code and build the `FiskalySDK.framework`:

```bash
$ carthage update
```

Afterwards you will find following files in your project folder:

```
.
├── Cartfile
├── Cartfile.resolved
└── Carthage
    └── Build
        └── iOS
            └── FiskalySDK.framework
```

In order to use the fiskaly SDK you must include `FiskalySDK.framework` in your Xcode project as can be seen in the following screenshot:

![screenshot-xcode-frameworks-integration](../media/screenshot-xcode-frameworks-integration.png?raw=true)

Finally, the SDK can be imported using:

```swift
import FiskalySDK
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
do {
    let response = try client.version()
    print(response)
} catch {
    print("Error while retrieving version: \(error)")
}
```

### Running the Self-Test

```swift
do {
    let response = try client.selfTest()
    print(response)
} catch {
    print("Error while selftesting: \(error)")
}
```

### Client Configuration

The SDK is built on the [fiskaly Client](https://developer.fiskaly.com/en/docs/client-documentation) which can be [configured](https://developer.fiskaly.com/en/docs/client-documentation#configuration) through the SDK.

```swift
do {
    let response = 
        try client.config(
                    debugLevel: -1,
                    debugFile: "tmp/tmp.log",
                    clientTimeout: 1500,
                    smaersTimeout: 1500, 
                    httpProxy: "")
    print(response)
} catch {
    print("Error while setting config: \(error)")
}

```

### Sending HTTP Requests

Please note:

- the body sent in requests needs to be base64 encoded 

```swift
let transactionUUID = UUID().uuidString

do {

    // start Transaction

    let transactionBody = [
        "state": "ACTIVE",
        "client_id": clientUUID
    ]

    let transactionBodyData = try? JSONSerialization.data(withJSONObject: transactionBody)
    let transactionBodyEncoded = transactionBodyData?.base64EncodedString()

    let responseCreateTransaction = try client.request(
        method: "PUT",
        path: "tss/\(tssUUID)/tx/\(transactionUUID)",
        body: transactionBodyEncoded!)

    print(responseCreateTransaction)

} catch {
    print("Error while starting transaction: \(error)")
}



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

do {

    let transactionFinishBodyData = try? JSONSerialization.data(withJSONObject: transactionFinishBody)
    let transactionFinishBodyEncoded = transactionFinishBodyData?.base64EncodedString()

    let responseFinishTransaction = try client.request(
        method: "PUT",
        path: "tss/\(tssUUID)/tx/\(transactionUUID)",
        query: ["last_revision": "1"],
        body: transactionFinishBodyEncoded!)

    print(responseFinishTransaction)

} catch {
    print("Error while finishing transaction: \(error)")
}



```

## Related

* [fiskaly.com](https://fiskaly.com)
* [dashboard.fiskaly.com](https://dashboard.fiskaly.com)
* [kassensichv.io](https://kassensichv.io)
* [kassensichv.net](https://kassensichv.net)
