public import Binary_Primitives
public import Binary_Serializer_Witness_Primitives

extension UInt64 {

    @inlinable
    public static func serializer(endianness: Binary.Endianness) -> Binary.Serializer<UInt64> {
        Binary.Serializer { value, output in
            output.append(contentsOf: value.bytes(endianness: endianness))
        }
    }
}
