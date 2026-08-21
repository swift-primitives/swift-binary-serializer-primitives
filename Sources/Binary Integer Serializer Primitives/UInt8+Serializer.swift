public import Binary_Primitives
public import Binary_Serializer_Witness_Primitives
internal import Byte_Primitives

extension UInt8 {

    @inlinable
    public static func serializer(endianness: Binary.Endianness) -> Binary.Serializer<UInt8> {
        Binary.Serializer { value, output in
            output.append(Byte(value))
        }
    }
}
