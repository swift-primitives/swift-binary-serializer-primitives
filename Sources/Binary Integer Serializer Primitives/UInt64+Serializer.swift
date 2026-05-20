// UInt64+Serializer.swift
// swift-binary-serializer-primitives
//
// Binary serializer for UInt64 with endianness.

public import Binary_Serializer_Primitives_Core

extension UInt64 {
    /// Returns a serializer for writing `UInt64` in the given endianness.
    @inlinable
    public static func serializer(endianness: Binary.Endianness) -> Binary.Serializer<UInt64> {
        Binary.Serializer { value, output in
            output.append(contentsOf: value.bytes(endianness: endianness))
        }
    }
}
