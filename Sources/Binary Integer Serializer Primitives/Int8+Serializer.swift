// Int8+Serializer.swift
// swift-binary-serializer-primitives
//
// Binary serializer for Int8.

public import Binary_Serializer_Primitives_Core

extension Int8 {
    /// Returns a serializer for writing a single byte as `Int8`.
    ///
    /// Although endianness is irrelevant for single-byte values, the parameter
    /// is accepted for API consistency with multi-byte integer serializers.
    @inlinable
    public static func serializer(endianness: Binary.Endianness) -> Binary.Serializer<Int8> {
        Binary.Serializer { value, output in
            output.append(Byte(UInt8(bitPattern: value)))
        }
    }
}
