public import Binary_Primitives
public import Binary_Serializer_Witness_Primitives
internal import Byte_Primitives

extension Int8 {

    @inlinable
    public static func serializer(endianness: Binary.Endianness) -> Binary.Serializer<Int8> {
        Binary.Serializer { value, output in
            output.append(Byte(UInt8(bitPattern: value)))
        }
    }
}
