// Binary.Serializer+Serializer.Protocol.swift
// swift-binary-serializer-primitives
//
// Conforms `Binary.Serializer` to the canonical `Serializer.Protocol` from
// `swift-serializer-primitives`. Binds:
// - `Output = Value`
// - `Buffer = [Byte]`
// - `Failure = Never`
// - `Body = Never` (leaf per [API-IMPL-020])

public import Binary_Primitives
internal import Byte_Primitives
public import Serializer_Primitives

extension Binary.Serializer: Serializer.`Protocol` {
    /// The value type this serializer encodes.
    public typealias Output = Value

    /// The byte buffer this serializer appends its output into.
    public typealias Buffer = [Byte]

    /// The error type; binary serialization is infallible.
    public typealias Failure = Never

    /// The composition body; this serializer is a leaf with no sub-body.
    public typealias Body = Never

    /// Serializes a value by appending its byte representation into the buffer.
    @inlinable
    public borrowing func serialize(_ output: Value, into buffer: inout [Byte]) {
        _serialize(output, &buffer)
    }
}
