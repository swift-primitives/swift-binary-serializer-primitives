// Int64+Serializer.swift
// swift-binary-serializer-primitives
//
// Binary serializer for Int64 with endianness.

public import Binary_Serializer_Primitives_Core

extension Int64 {
    /// Returns a serializer for writing `Int64` in the given endianness.
    @inlinable
    public static func serializer(endianness: Binary.Endianness) -> Binary.Serializer<Int64> {
        Binary.Serializer { value, output in
            output.append(contentsOf: value.bytes(endianness: endianness))
        }
    }
}
