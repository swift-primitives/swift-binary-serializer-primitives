// UInt16+Serializer.swift
// swift-binary-serializer-primitives
//
// Binary serializer for UInt16 with endianness.

public import Binary_Serializer_Primitives_Core

extension UInt16 {
    /// Returns a serializer for writing `UInt16` in the given endianness.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let serializer = UInt16.serializer(endianness: .little)
    ///
    /// var output: [Byte] = []
    /// serializer.serializeAppending(0x1234, to: &output)
    /// // output == [0x34, 0x12]
    /// ```
    @inlinable
    public static func serializer(endianness: Binary.Endianness) -> Binary.Serializer<UInt16> {
        Binary.Serializer { value, output in
            output.append(contentsOf: value.bytes(endianness: endianness))
        }
    }
}
