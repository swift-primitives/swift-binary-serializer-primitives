public import Binary_Primitives
internal import Byte_Primitives
public import Serializer_Primitives

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
