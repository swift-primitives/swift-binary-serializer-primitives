// UInt8+Serializer.swift
// swift-binary-serializer-primitives
//
// Binary serializer for UInt8.

public import Binary_Serializer_Primitives_Core

extension UInt8 {
    /// Returns a serializer for writing a single byte as `UInt8`.
    ///
    /// Although endianness is irrelevant for single-byte values, the parameter
    /// is accepted for API consistency with multi-byte integer serializers.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let serializer = UInt8.serializer(endianness: .big)
    ///
    /// var output: [Byte] = []
    /// serializer.serializeAppending(0x42, to: &output)
    /// // output == [0x42]
    /// ```
    @inlinable
    public static func serializer(endianness: Binary.Endianness) -> Binary.Serializer<UInt8> {
        Binary.Serializer { value, output in
            output.append(Byte(value))
        }
    }
}
