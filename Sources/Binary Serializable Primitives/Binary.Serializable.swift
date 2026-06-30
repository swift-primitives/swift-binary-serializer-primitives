// Binary.Serializable.swift
// Streaming byte serialization protocol.
//
// Substrate: `Buffer.Element == Byte` and `Bytes.Element == Byte` (byte-domain
// typed per the broader L2/L3 byte-typing gap W2 retype, 2026-05-19). Stdlib-
// interop UInt8 forwarders live in `Binary Primitives Standard Library
// Integration` per [API-BYTE-007] (byte-discipline skill); internal bridges go
// through the BSLI helpers in `Byte_Primitives_Standard_Library_Integration`
// (`Array<Byte>(uint8s)` inbound, `bytes.underlying` outbound).

@_spi(Internal) import Tagged_Primitives

extension Binary {
    /// Protocol for types that can serialize to byte streams.
    ///
    /// Conforming types write their byte representation directly into any byte
    /// collection, enabling efficient composition and streaming output. Use this
    /// for building complex binary formats, HTML rendering, or protocol buffers.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct Packet: Binary.Serializable {
    ///     let type: Byte
    ///     let length: UInt16
    ///     let data: [Byte]
    ///
    ///     static func serialize<Buffer: RangeReplaceableCollection>(
    ///         _ packet: Self,
    ///         into buffer: inout Buffer
    ///     ) where Buffer.Element == Byte {
    ///         buffer.append(packet.type)
    ///         buffer.append(contentsOf: packet.length.bytes(endianness: .big))
    ///         buffer.append(contentsOf: packet.data)
    ///     }
    /// }
    ///
    /// var output: [Byte] = []
    /// let packet = Packet(type: 1, length: 4, data: [0xDE, 0xAD, 0xBE, 0xEF])
    /// packet.serialize(into: &output)
    /// ```
    public protocol Serializable: Sendable {
        /// Serializes a value into a byte buffer.
        ///
        /// Appends the byte representation to the buffer without clearing existing content.
        /// Implementations must be deterministic and infallible for valid values.
        ///
        /// - Parameters:
        ///   - serializable: The value to serialize
        ///   - buffer: The buffer to append bytes to
        static func serialize<Buffer: RangeReplaceableCollection>(
            _ serializable: borrowing Self,
            into buffer: inout Buffer
        ) where Buffer.Element == Byte
    }
}

// MARK: - Convenience Extensions

extension Binary.Serializable {
    /// Serializes to a new byte array.
    ///
    /// Creates a new array and serializes into it. For repeated serialization,
    /// prefer `serialize(into:)` with a reusable buffer for better performance.
    public var bytes: [Byte] {
        var buffer: [Byte] = []
        Self.serialize(self, into: &buffer)
        return buffer
    }

    /// Serializes this value into a byte buffer.
    ///
    /// Instance method convenience that delegates to the static `serialize(_:into:)`.
    public func serialize<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        Self.serialize(self, into: &buffer)
    }
}

// MARK: - Static Returning Convenience

extension Binary.Serializable {
    /// Serializes to a new collection of the inferred type.
    ///
    /// Creates a new buffer and serializes into it. The return type is inferred
    /// from context, allowing serialization into any `RangeReplaceableCollection`.
    public static func serialize<Bytes: RangeReplaceableCollection>(
        _ serializable: Self
    ) -> Bytes where Bytes.Element == Byte {
        var buffer = Bytes()
        Self.serialize(serializable, into: &buffer)
        return buffer
    }
}

// MARK: - Zero-Copy Span Access

extension Binary.Serializable {
    /// Provides zero-copy access to serialized bytes via a Span.
    ///
    /// Default implementation creates a temporary ContiguousArray. Types with
    /// contiguous storage can override for true zero-copy access.
    ///
    /// - Parameters:
    ///   - value: The value to serialize
    ///   - body: Closure receiving borrowing access to the serialized bytes
    /// - Throws: Any error thrown by `body`.
    /// - Returns: The result of the body closure
    public static func withSerializedBytes<R, E: Swift.Error>(
        _ value: Self,
        _ body: (borrowing Swift.Span<Byte>) throws(E) -> R
    ) throws(E) -> R {
        var buffer: ContiguousArray<Byte> = []
        Self.serialize(value, into: &buffer)
        return try body(buffer.span)
    }

    /// Provides zero-copy access to this value's serialized bytes via a Span.
    ///
    /// Instance method convenience that delegates to the static `withSerializedBytes(_:_:)`.
    public func withSerializedBytes<R, E: Swift.Error>(
        _ body: (borrowing Swift.Span<Byte>) throws(E) -> R
    ) throws(E) -> R {
        try Self.withSerializedBytes(self, body)
    }
}

// MARK: - RangeReplaceableCollection Append

extension RangeReplaceableCollection<Byte> {
    /// Appends a serializable value to the collection.
    ///
    /// Serializes the value and appends its bytes to the collection.
    /// `@_disfavoredOverload` so stdlib's same-element `append(_:Element)` wins
    /// when the argument is a `Byte` literal (e.g., `buffer.append(0xFE)`).
    @_disfavoredOverload
    public mutating func append<S: Binary.Serializable>(_ serializable: S) {
        S.serialize(serializable, into: &self)
    }
}

// MARK: - Collection Initializers

extension Array where Element == Byte {
    /// Creates a byte array from a serializable value.
    ///
    /// Serializes the value into a new array. `@_disfavoredOverload` so stdlib's
    /// same-type `Array.init<S: Sequence>(_:)` wins when the source already has
    /// `Byte` Element (e.g., `Array<Byte>(contiguousByteArray)`).
    @_disfavoredOverload
    public init<S: Binary.Serializable>(_ serializable: S) {
        self = []
        S.serialize(serializable, into: &self)
    }
}

extension ContiguousArray where Element == Byte {
    /// Creates a contiguous byte array from a serializable value.
    ///
    /// Serializes the value into a new contiguous array for better cache locality.
    /// `@_disfavoredOverload` so stdlib's same-type init wins on matching Element.
    @_disfavoredOverload
    public init<S: Binary.Serializable>(_ serializable: S) {
        self = []
        S.serialize(serializable, into: &self)
    }
}

// Stdlib-interop UInt8 forwarders for serialize(into:) / withSerializedBytes /
// Array/ContiguousArray/RangeReplaceableCollection<UInt8>.init/append live in
// `Binary Primitives Standard Library Integration` per [API-BYTE-007].

// MARK: - String Conversion

extension StringProtocol {
    /// Creates a string by decoding a serializable value's UTF-8 output.
    ///
    /// Serializes the value to bytes and decodes as UTF-8.
    public init<T: Binary.Serializable>(_ value: T) {
        let typed: [Byte] = value.bytes
        self = Self(decoding: typed.underlying, as: UTF8.self)
    }
}

// Direct Byte Array Conversions — String([Byte]) and String(ArraySlice<Byte>)
// extensions were relocated to swift-binary-primitives' Binary Primitives Core
// (String+Bytes.swift) when Binary Serializable Primitives moved here.
// Stdlib-interop UInt8 init forwarders ([UInt8] / ArraySlice<UInt8>) live in
// swift-binary-primitives' Binary Primitives Standard Library Integration
// per [API-BYTE-007].

// MARK: - RawRepresentable Default Implementations

extension Binary.Serializable where Self: RawRepresentable, Self.RawValue: StringProtocol {
    /// Default serialization for string-backed `RawRepresentable` types.
    ///
    /// Serializes the raw value as UTF-8 bytes.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ serializable: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        let raw = serializable.rawValue
        buffer.append(contentsOf: [Byte](raw.utf8))
    }
}

extension Binary.Serializable where Self: RawRepresentable, Self.RawValue == [Byte] {
    /// Default serialization for byte-array-backed `RawRepresentable` types.
    ///
    /// Serializes the raw value directly as bytes.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ serializable: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: serializable.rawValue)
    }
}

extension Binary.Serializable where Self: RawRepresentable, Self.RawValue == [UInt8] {
    /// Stdlib-interop default serialization for legacy `[UInt8]`-backed `RawRepresentable` types.
    ///
    /// Bridges through `Array<Byte>(uint8s)` (BSLI inbound).
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ serializable: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: [Byte](serializable.rawValue))
    }
}

// MARK: - Zero-Copy Optimization for RawRepresentable Types

extension Binary.Serializable where Self: RawRepresentable, Self.RawValue == [Byte] {
    /// Optimized zero-copy access for `[Byte]`-backed types.
    ///
    /// Borrows the raw value's storage directly, avoiding any intermediate copy.
    public static func withSerializedBytes<R, E: Swift.Error>(
        _ value: Self,
        _ body: (borrowing Swift.Span<Byte>) throws(E) -> R
    ) throws(E) -> R {
        let bytes = value.rawValue
        return try body(bytes.span)
    }
}

extension Binary.Serializable where Self: RawRepresentable, Self.RawValue: StringProtocol {
    /// Optimized access for `StringProtocol`-backed types via UTF-8.
    ///
    /// Materializes the raw value's UTF-8 view into a contiguous buffer and exposes its span.
    public static func withSerializedBytes<R, E: Swift.Error>(
        _ value: Self,
        _ body: (borrowing Swift.Span<Byte>) throws(E) -> R
    ) throws(E) -> R {
        let raw = value.rawValue
        let utf8 = ContiguousArray<Byte>(raw.utf8)
        return try body(utf8.span)
    }
}

// MARK: - RawRepresentable<FixedWidthInteger> Default Implementation

extension Binary.Serializable where Self: RawRepresentable, Self.RawValue: FixedWidthInteger {
    /// Default serialization for integer-backed `RawRepresentable` types.
    ///
    /// Serializes the raw value in native byte order for optimal performance.
    /// For cross-platform serialization, use `rawValue.bytes(endianness:)` explicitly.
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        let raw = value.rawValue
        let bytes: [Byte]
        #if _endian(little)
            bytes = raw.bytes(endianness: .little)
        #else
            bytes = raw.bytes(endianness: .big)
        #endif
        buffer.append(contentsOf: bytes)
    }
}

// MARK: - Tagged Conformance
extension Tagged: Binary.Serializable where Underlying: Binary.Serializable {
    /// Serializes a tagged value by serializing its underlying raw value.
    ///
    /// Delegates to the raw value's serialization implementation.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        Underlying.serialize(value.underlying, into: &buffer)
    }

    /// Provides zero-copy access to a tagged value's serialized bytes.
    ///
    /// Delegates to the underlying raw value's `withSerializedBytes(_:_:)` for optimal performance.
    public static func withSerializedBytes<R, E: Swift.Error>(
        _ value: Self,
        _ body: (borrowing Swift.Span<Byte>) throws(E) -> R
    ) throws(E) -> R {
        try Underlying.withSerializedBytes(value.underlying, body)
    }
}

// MARK: - Byte Collection Conformances

extension Array: Binary.Serializable where Element == Byte {
    /// Serializes a byte array by appending its contents directly.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: value)
    }

    /// Provides zero-copy access to the array's bytes.
    public static func withSerializedBytes<R, E: Swift.Error>(
        _ value: Self,
        _ body: (borrowing Swift.Span<Byte>) throws(E) -> R
    ) throws(E) -> R {
        try body(value.span)
    }
}

extension ContiguousArray: Binary.Serializable where Element == Byte {
    /// Serializes a contiguous byte array by appending its contents directly.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: value)
    }

    /// Provides zero-copy access to the contiguous array's bytes.
    public static func withSerializedBytes<R, E: Swift.Error>(
        _ value: Self,
        _ body: (borrowing Swift.Span<Byte>) throws(E) -> R
    ) throws(E) -> R {
        try body(value.span)
    }
}

extension ArraySlice: Binary.Serializable where Element == Byte {
    /// Serializes a byte array slice by appending its contents directly.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: value)
    }
}

// MARK: - Stdlib-Interop Note
//
// Swift permits only one protocol conformance per generic type even with
// disjoint conditional bounds. The Byte conformances above are canonical;
// `[UInt8]`, `ContiguousArray<UInt8>`, and `ArraySlice<UInt8>` consumers
// bridge to `[Byte]` via the BSLI inbound `init<S>(_:) where S.Element == UInt8`
// (`Array<Byte>(uint8s)`) before serializing. The stdlib-interop UInt8
// forwarders for `bytes`, `serialize(into:)`, `Array.init(_:)`,
// `ContiguousArray.init(_:)`, and `RangeReplaceableCollection.append(_:)` live
// in `Binary Primitives Standard Library Integration` per [API-BYTE-007]; that
// module covers the consumer-side ergonomics without requiring a second
// conformance.
