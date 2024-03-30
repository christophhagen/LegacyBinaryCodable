# ⚠️⚠️⚠️ LegacyBinaryCodable ⚠️⚠️⚠️

This package is intended only for migration.
For all other purposes, use [BinaryCodable](https://github.com/christophhagen/BinaryCodable).

This repository is a copy of [BinaryCodable](https://github.com/christophhagen/BinaryCodable) at version 2.0.3, renamed and stripped down to be included alongside newer versions of `BinaryCodable`.
It only provides decoding capabilities and exists to allow re-encoding stored binary data in the new format.

### Migrating from 2.x to 3.0

To convert data from the [legacy format](https://github.com/christophhagen/BinaryCodable/blob/master/LegacyFormat.md) to the new version, the data has to be decoded with version 2 and re-encoded with version 3.

The Swift Package Manager currently doesn't allow to include the same dependency twice (with different versions), so this legacy version has been stripped down to the essentials and is provided as a stand-alone package.
It only allows decoding, and can be integrated as a separate dependency:

```swift
dependencies: [
    .package(url: "https://github.com/christophhagen/BinaryCodable", from: "3.0.0"),
    .package(url: "https://github.com/christophhagen/LegacyBinaryCodable", from: "2.0.0"),
    
],
targets: [
    .target(name: "MyTarget", dependencies: [
        .product(name: "BinaryCodable", package: "BinaryCodable"),
        .product(name: "LegacyBinaryCodable", package: "LegacyBinaryCodable")
    ])
]
```

In the code, you can then decode and re-encode:

```swift
import BinaryCodable
import LegacyBinaryCodable

func reencode<T>(data: Data, as type: T.Type) throws -> Data where T: Codable {
    let decoder = LegacyBinaryDecoder()
    let value = try decoder.decode(T.self, from data: Data)
    let encoder = BinaryEncoder()
    return try encoder.encode(value)
}
```
