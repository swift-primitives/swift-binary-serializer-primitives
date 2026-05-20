// UInt32+Serializer.swift
// swift-binary-serializer-primitives
//
// Binary serializer for UInt32 with endianness.

public import Binary_Serializer_Primitives_Core

extension UInt32 {
    /// Returns a serializer for writing `UInt32` in the given endianness.
    @inlinable
    public static func serializer(endianness: Binary.Endianness) -> Binary.Serializer<UInt32> {
        Binary.Serializer { value, output in
            output.append(contentsOf: value.bytes(endianness: endianness))
        }
    }
}
