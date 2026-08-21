internal import Byte_Primitives
internal import Byte_Primitives_Standard_Library_Integration

extension Binary.Serializable {

    @_disfavoredOverload
    public func serialize<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        var byteBuffer: ContiguousArray<Byte> = []
        Self.serialize(self, into: &byteBuffer)
        buffer.append(contentsOf: byteBuffer.underlying)
    }

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

    @_disfavoredOverload
    public func withSerializedBytes<R, E: Swift.Error>(
        _ body: (borrowing Swift.Span<UInt8>) throws(E) -> R
    ) throws(E) -> R {
        try Self.withSerializedBytes(self, body)
    }
}

extension RangeReplaceableCollection<UInt8> {

    @_disfavoredOverload
    public mutating func append<S: Binary.Serializable>(_ serializable: S) {
        var byteBuffer: ContiguousArray<Byte> = []
        S.serialize(serializable, into: &byteBuffer)
        self.append(contentsOf: byteBuffer.underlying)
    }
}

extension Array where Element == UInt8 {

    @_disfavoredOverload
    public init<S: Binary.Serializable>(_ serializable: S) {
        var typed: [Byte] = []
        S.serialize(serializable, into: &typed)
        self = typed.underlying
    }
}

extension ContiguousArray where Element == UInt8 {

    @_disfavoredOverload
    public init<S: Binary.Serializable>(_ serializable: S) {
        var typed: ContiguousArray<Byte> = []
        S.serialize(serializable, into: &typed)
        self = ContiguousArray(typed.underlying)
    }
}

extension String {

    @_disfavoredOverload
    public init(_ bytes: [UInt8]) {
        self = String(decoding: bytes, as: UTF8.self)
    }

    @_disfavoredOverload
    public init(_ bytes: ArraySlice<UInt8>) {
        self = String(decoding: bytes, as: UTF8.self)
    }
}
