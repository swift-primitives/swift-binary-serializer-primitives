// Binary.Serializer.swift
// swift-binary-serializer-primitives
//
// Plain witness for binary serialization — the canonical institute
// Serializer witness for the binary domain. Mirrors Binary.Coder<Output>'s
// shape: a closure-based struct that conforms to the canonical
// Serializer.Protocol from swift-serializer-primitives.
//
// Binary.Serializer<Value> is the binary-domain twin of Binary.Coder<Output>'s
// encode direction. Where Binary.Coder<Output> is a bidirectional coder
// (parse + serialize), Binary.Serializer<Value> is one-direction serialize.
// Consumers conforming to the canonical Serializable (from
// swift-serializer-primitives) declare:
//
//   static var serializer: Binary.Serializer<Self>
//
// The Buffer is fixed to [Byte] (the byte-domain canonical buffer per
// [API-BYTE-003] / the W2 byte-typing discipline).

public import Binary_Primitives
internal import Byte_Primitives
public import Witness_Primitives

extension Binary {
    /// A witness for binary serialization as a closure-based plain witness.
    ///
    /// `Binary.Serializer<Value>` is the canonical institute witness for
    /// `Serializable` conformance in the binary domain. It conforms to
    /// ``Serializer/Protocol`` with `Output = Value`, `Buffer = [Byte]`,
    /// `Failure = Never`, and `Body = Never` (leaf per [API-IMPL-020]).
    ///
    /// ## Example
    ///
    /// ```swift
    /// let serializer = Binary.Serializer<UInt16> { value, buffer in
    ///     buffer.append(Byte(UInt8(truncatingIfNeeded: value)))
    ///     buffer.append(Byte(UInt8(truncatingIfNeeded: value >> 8)))
    /// }
    ///
    /// var buffer: [Byte] = []
    /// serializer.serialize(0x1234, into: &buffer)
    /// // buffer == [0x34, 0x12]
    /// ```
    public struct Serializer<Value>: Witness.`Protocol` {
        @usableFromInline
        let _serialize: (Value, inout [Byte]) -> Void

        /// Creates a serializer with the given serialize closure.
        ///
        /// - Parameter serialize: A closure that appends `value`'s byte
        ///   representation to the buffer.
        @inlinable
        public init(
            serialize: @escaping (Value, inout [Byte]) -> Void
        ) {
            self._serialize = serialize
        }
    }
}

// MARK: - Execution Helpers

extension Binary.Serializer {
    /// Serializes a value to a new byte array.
    ///
    /// - Parameter value: The value to serialize.
    /// - Returns: The serialized bytes.
    @inlinable
    public func serializeToArray(_ value: Value) -> [Byte] {
        var out: [Byte] = []
        _serialize(value, &out)
        return out
    }

    /// Serializes a value by appending to an existing byte buffer.
    ///
    /// - Parameters:
    ///   - value: The value to serialize.
    ///   - buffer: The buffer to append to.
    @inlinable
    public func serializeAppending(_ value: Value, to buffer: inout [Byte]) {
        _serialize(value, &buffer)
    }
}
