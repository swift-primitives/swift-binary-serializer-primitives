public import Binary_Primitives
internal import Byte_Primitives
public import Serializer_Primitives

extension Serializable where Self: RawRepresentable, Self.RawValue: StringProtocol {

    public static var serializer: Binary.Serializer<Self> {
        Binary.Serializer { value, buffer in

            let raw = value.rawValue
            buffer.append(contentsOf: [Byte](raw.utf8))
        }
    }
}

extension Serializable where Self: RawRepresentable, Self.RawValue == [Byte] {

    public static var serializer: Binary.Serializer<Self> {
        Binary.Serializer { value, buffer in

            buffer.append(contentsOf: value.rawValue)
        }
    }
}

extension Serializable where Self: RawRepresentable, Self.RawValue == [UInt8] {

    public static var serializer: Binary.Serializer<Self> {
        Binary.Serializer { value, buffer in

            buffer.append(contentsOf: [Byte](value.rawValue))
        }
    }
}

extension Serializable where Self: RawRepresentable, Self.RawValue: FixedWidthInteger {

    public static var serializer: Binary.Serializer<Self> {
        Binary.Serializer { value, buffer in

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
}
