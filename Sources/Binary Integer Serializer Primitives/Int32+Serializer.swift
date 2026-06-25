// Int32+Serializer.swift
// swift-binary-serializer-primitives
//
// Binary serializer for Int32 with endianness.

public import Binary_Primitives
public import Binary_Serializer_Witness_Primitives

extension Int32 {
    /// Returns a serializer for writing `Int32` in the given endianness.
    @inlinable
    public static func serializer(endianness: Binary.Endianness) -> Binary.Serializer<Int32> {
        Binary.Serializer { value, output in
            output.append(contentsOf: value.bytes(endianness: endianness))
        }
    }
}
