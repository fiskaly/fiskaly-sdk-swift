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

### Client Configuration

The SDK is built on the [fiskaly Client](https://developer.fiskaly.com/en/docs/client-documentation) which can be [configured](https://developer.fiskaly.com/en/docs/client-documentation#configuration) through the SDK.

## Related

* [fiskaly.com](https://fiskaly.com)
* [dashboard.fiskaly.com](https://dashboard.fiskaly.com)
* [kassensichv.io](https://kassensichv.io)
* [kassensichv.net](https://kassensichv.net)
