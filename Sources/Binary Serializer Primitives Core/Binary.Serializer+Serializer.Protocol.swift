// Binary.Serializer+Serializer.Protocol.swift
// swift-binary-serializer-primitives
//
// Conforms `Binary.Serializer` to the canonical `Serializer.Protocol` from
// `swift-serializer-primitives`. Binds:
// - `Output = Value`
// - `Buffer = [Byte]`
// - `Failure = Never`
// - `Body = Never` (leaf per [API-IMPL-020])

public import Byte_Primitives

extension Binary.Serializer: Serializer.`Protocol` {
    public typealias Output = Value
    public typealias Buffer = [Byte]
    public typealias Failure = Never
    public typealias Body = Never

    @inlinable
    public borrowing func serialize(_ output: Value, into buffer: inout [Byte]) {
        _serialize(output, &buffer)
    }
}
