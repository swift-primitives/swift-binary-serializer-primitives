// Binary.Serializable+UInt8.swift
//
// Stdlib-interop UInt8 forwarders for `Binary.Serializable`. Primary byte-domain
// API lives in `Binary Serializable Primitives`; these forwarders bridge stdlib
// callers carrying `[UInt8]` / `ContiguousArray<UInt8>` / `Swift.Span<UInt8>` (e.g.
// network buffers, file-read frames) via `[Byte](uint8s)` / `.underlying`.
// Per [API-BYTE-007] (byte-discipline skill).

internal import Byte_Primitives
internal import Byte_Primitives_Standard_Library_Integration

// MARK: - Serialize into [UInt8] Buffer

extension Binary.Serializable {
    /// Stdlib-interop forwarder: serializes into a `[UInt8]` buffer.
    ///
    /// For a `[UInt8]` view of the serialized bytes, use `self.bytes.underlying`
    /// (BSLI outbound). Property overloads cannot be return-type-discriminated,
    /// so the byte accessor stays single-typed at `[Byte]`.
    @_disfavoredOverload
    public func serialize<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        var byteBuffer: ContiguousArray<Byte> = []
        Self.serialize(self, into: &byteBuffer)
        buffer.append(contentsOf: byteBuffer.underlying)
    }

    /// Stdlib-interop forwarder: zero-copy access via `Swift.Span<UInt8>`.
    ///
    /// Materialises an intermediate `[UInt8]` buffer (via `.underlying` BSLI
    /// outbound) and exposes its span. For zero-copy access in byte-domain,
    /// use the `Swift.Span<Byte>` primary overload.
    @_disfavoredOverload
    public static func withSerializedBytes<R, E: Swift.Error>(
        _ value: Self,
        _ body: (borrowing Swift.Span<UInt8>) throws(E) -> R
    ) throws(E) -> R {
        var byteBuffer: ContiguousArray<Byte> = []
        Self.serialize(value, into: &byteBuffer)
        let uint8Buffer = ContiguousArray<UInt8>(byteBuffer.underlying)
        return try body(uint8Buffer.span)
    }

    /// Stdlib-interop forwarder: instance zero-copy access via `Swift.Span<UInt8>`.
    @_disfavoredOverload
    public func withSerializedBytes<R, E: Swift.Error>(
        _ body: (borrowing Swift.Span<UInt8>) throws(E) -> R
    ) throws(E) -> R {
        try Self.withSerializedBytes(self, body)
    }
}

// MARK: - RangeReplaceableCollection<UInt8> Append

extension RangeReplaceableCollection<UInt8> {
    /// Stdlib-interop forwarder: appends a serializable into a `[UInt8]` buffer.
    @_disfavoredOverload
    public mutating func append<S: Binary.Serializable>(_ serializable: S) {
        var byteBuffer: ContiguousArray<Byte> = []
        S.serialize(serializable, into: &byteBuffer)
        self.append(contentsOf: byteBuffer.underlying)
    }
}

// MARK: - Array<UInt8> / ContiguousArray<UInt8> Initializers

extension Array where Element == UInt8 {
    /// Stdlib-interop forwarder: creates a `[UInt8]` byte array from a serializable.
    @_disfavoredOverload
    public init<S: Binary.Serializable>(_ serializable: S) {
        var typed: [Byte] = []
        S.serialize(serializable, into: &typed)
        self = typed.underlying
    }
}

extension ContiguousArray where Element == UInt8 {
    /// Stdlib-interop forwarder: creates a `ContiguousArray<UInt8>` from a serializable.
    @_disfavoredOverload
    public init<S: Binary.Serializable>(_ serializable: S) {
        var typed: ContiguousArray<Byte> = []
        S.serialize(serializable, into: &typed)
        self = ContiguousArray(typed.underlying)
    }
}

// MARK: - String from [UInt8] / ArraySlice<UInt8>

extension String {
    /// Stdlib-interop forwarder: creates a string by decoding UTF-8 `[UInt8]` bytes.
    @_disfavoredOverload
    public init(_ bytes: [UInt8]) {
        self = String(decoding: bytes, as: UTF8.self)
    }

    /// Stdlib-interop forwarder: creates a string by decoding UTF-8 `ArraySlice<UInt8>` bytes.
    @_disfavoredOverload
    public init(_ bytes: ArraySlice<UInt8>) {
        self = String(decoding: bytes, as: UTF8.self)
    }
}
