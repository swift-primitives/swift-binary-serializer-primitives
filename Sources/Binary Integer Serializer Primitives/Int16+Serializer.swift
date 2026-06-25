// Int16+Serializer.swift
// swift-binary-serializer-primitives
//
// Binary serializer for Int16 with endianness.

public import Binary_Primitives
public import Binary_Serializer_Witness_Primitives

extension Int16 {
    /// Returns a serializer for writing `Int16` in the given endianness.
    @inlinable
    public static func serializer(endianness: Binary.Endianness) -> Binary.Serializer<Int16> {
        Binary.Serializer { value, output in
            output.append(contentsOf: value.bytes(endianness: endianness))
        }
    }
}
