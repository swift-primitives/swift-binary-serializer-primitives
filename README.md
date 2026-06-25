# Binary Serializer Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Binary-domain serialization for Swift — the `Binary.Serializable` streaming protocol, the `Binary.Serializer<Value>` closure witness, and endianness-aware fixed-width integer serializers, with zero platform dependencies.

---

## Quick Start

`Binary.Serializable` is a streaming protocol: a conforming type writes its own bytes directly into any byte buffer. There is no intermediate `Data`, no per-field allocation — a value appends straight onto the caller's buffer, so nested values compose into one contiguous write.

```swift
import Binary_Serializer_Primitives

// A length-prefixed frame that serializes itself into any byte buffer.
struct Frame: Binary.Serializable {
    let opcode: Byte
    let payload: [Byte]

    static func serialize<Buffer: RangeReplaceableCollection>(
        _ frame: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(frame.opcode)
        buffer.append(contentsOf: UInt16(frame.payload.count).bytes(endianness: .big))
        buffer.append(contentsOf: frame.payload)
    }
}

var out: [Byte] = []
Frame(opcode: 0x01, payload: [0xDE, 0xAD]).serialize(into: &out)
// out == [0x01, 0x00, 0x02, 0xDE, 0xAD]
```

Every `Binary.Serializable` type also gains a `bytes` array, a `withSerializedBytes { span in … }` zero-copy borrow, and `String(value)` UTF-8 decoding for free. Default conformances cover `RawRepresentable` (string-, byte-array-, and integer-backed), `Tagged`, and the `[Byte]` / `ContiguousArray<Byte>` / `ArraySlice<Byte>` collections.

For the common case of writing a fixed-width integer, each integer type ships a ready-made serializer parameterised by endianness — a `Binary.Serializer<Value>`, the binary-domain plain witness:

```swift
import Binary_Serializer_Primitives

let bigEndian = UInt32.serializer(endianness: .big)
let littleEndian = UInt32.serializer(endianness: .little)

bigEndian.serializeToArray(0xCAFE_BABE)     // [0xCA, 0xFE, 0xBA, 0xBE]
littleEndian.serializeToArray(0xCAFE_BABE)  // [0xBE, 0xBA, 0xFE, 0xCA]
```

A `Binary.Serializer<Value>` is just a closure over `(Value, inout [Byte])`; build one inline for any type, then `serializeToArray(_:)` or `serializeAppending(_:to:)` to drive it.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-binary-serializer-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Binary Serializer Primitives", package: "swift-binary-serializer-primitives"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

Import the `Binary Serializer Primitives` umbrella for the full union, or a single sub-product for a narrower surface.

| Product | Target | Purpose |
|---------|--------|---------|
| `Binary Serializer Primitives` | `Sources/Binary Serializer Primitives/` | Umbrella; re-exports the witness, serializable, and integer-serializer sub-products. |
| `Binary Serializer Witness Primitives` | `Sources/Binary Serializer Witness Primitives/` | The `Binary.Serializer<Value>` closure witness, its `Serializer.Protocol` conformance, and the `RawRepresentable` `serializer` defaults. |
| `Binary Serializable Primitives` | `Sources/Binary Serializable Primitives/` | The `Binary.Serializable` streaming protocol plus its convenience, `RawRepresentable`, `Tagged`, and byte-collection conformances. |
| `Binary Integer Serializer Primitives` | `Sources/Binary Integer Serializer Primitives/` | `{Int,UInt}{8,16,32,64}.serializer(endianness:)` factories returning `Binary.Serializer<T>`. |
| `Binary Serializer Primitives Test Support` | `Tests/Support/` | Re-exports the umbrella for test consumers. |

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
