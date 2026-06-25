// Serializable+RawRepresentable.swift
// swift-binary-serializer-primitives
//
// Default canonical Serializable conformances for RawRepresentable types,
// ported from the OLD Binary.Serializable default impl extensions. These let
// consumers write `extension X: Serializable {}` (empty) when their type is
// RawRepresentable over a serializable raw value, just like the OLD form.
//
// The four parallel where-clauses mirror the OLD Binary.Serializable defaults:
// - RawRepresentable<StringProtocol>     — UTF-8 bytes of the string
// - RawRepresentable<[Byte]>             — direct byte append
// - RawRepresentable<[UInt8]>            — bridge via BSLI to Byte
// - RawRepresentable<FixedWidthInteger>  — native-endian bytes

public import Binary_Primitives
internal import Byte_Primitives
public import Serializer_Primitives

// MARK: - StringProtocol-backed default

extension Serializable where Self: RawRepresentable, Self.RawValue: StringProtocol {
    /// Serializer that encodes a string-backed raw value as UTF-8 bytes.
    public static var serializer: Binary.Serializer<Self> {
        Binary.Serializer { value, buffer in
            let raw = value.rawValue
            buffer.append(contentsOf: [Byte](raw.utf8))
        }
    }
}

// MARK: - [Byte]-backed default

extension Serializable where Self: RawRepresentable, Self.RawValue == [Byte] {
    /// Serializer that appends a byte-array-backed raw value directly.
    public static var serializer: Binary.Serializer<Self> {
        Binary.Serializer { value, buffer in
            buffer.append(contentsOf: value.rawValue)
        }
    }
}

// MARK: - [UInt8]-backed default (stdlib-interop)

extension Serializable where Self: RawRepresentable, Self.RawValue == [UInt8] {
    /// Serializer that bridges a `[UInt8]`-backed raw value to bytes for stdlib interop.
    public static var serializer: Binary.Serializer<Self> {
        Binary.Serializer { value, buffer in
            buffer.append(contentsOf: [Byte](value.rawValue))
        }
    }
}

// MARK: - FixedWidthInteger-backed default (native endian)

extension Serializable where Self: RawRepresentable, Self.RawValue: FixedWidthInteger {
    /// Serializer that encodes an integer-backed raw value in native byte order.
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
