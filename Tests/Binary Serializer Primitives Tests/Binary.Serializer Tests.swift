import Binary_Integer_Serializer_Primitives
import Binary_Serializer_Primitives_Test_Support
import Testing

@testable import Binary_Serializer_Primitives_Core

// MARK: - Binary.Serializer Tests
//
// Note: Binary.Serializer<Value> is generic, so per [TEST-004] we use
// parallel namespace pattern instead of type extension pattern.

@Suite("Binary.Serializer")
struct BinarySerializerTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension BinarySerializerTests.Unit {

    @Test
    func `serializeToArray produces expected bytes`() {
        let serializer = Binary.Serializer<UInt16> { value, buffer in
            buffer.append(Byte(UInt8(truncatingIfNeeded: value)))
            buffer.append(Byte(UInt8(truncatingIfNeeded: value >> 8)))
        }

        let bytes = serializer.serializeToArray(0x1234)
        #expect(bytes == [Byte(0x34), Byte(0x12)])
    }

    @Test
    func `serializeAppending appends to existing buffer`() {
        let serializer = Binary.Serializer<UInt8> { value, buffer in
            buffer.append(Byte(value))
        }

        var buffer: [Byte] = [Byte(0xAA)]
        serializer.serializeAppending(0x42, to: &buffer)
        #expect(buffer == [Byte(0xAA), Byte(0x42)])
    }

    @Test
    func `UInt8 serializer writes one byte`() {
        let serializer = UInt8.serializer(endianness: .big)
        let bytes = serializer.serializeToArray(0x42)
        #expect(bytes == [Byte(0x42)])
    }

    @Test
    func `UInt16 little-endian serializer writes low byte first`() {
        let serializer = UInt16.serializer(endianness: .little)
        let bytes = serializer.serializeToArray(0x1234)
        #expect(bytes == [Byte(0x34), Byte(0x12)])
    }

    @Test
    func `UInt16 big-endian serializer writes high byte first`() {
        let serializer = UInt16.serializer(endianness: .big)
        let bytes = serializer.serializeToArray(0x1234)
        #expect(bytes == [Byte(0x12), Byte(0x34)])
    }

    @Test
    func `UInt32 little-endian serializer writes 4 bytes low-first`() {
        let serializer = UInt32.serializer(endianness: .little)
        let bytes = serializer.serializeToArray(0x12345678)
        #expect(bytes == [Byte(0x78), Byte(0x56), Byte(0x34), Byte(0x12)])
    }

    @Test
    func `UInt64 big-endian serializer writes 8 bytes high-first`() {
        let serializer = UInt64.serializer(endianness: .big)
        let bytes = serializer.serializeToArray(0x0102030405060708)
        #expect(bytes == [Byte(0x01), Byte(0x02), Byte(0x03), Byte(0x04),
                          Byte(0x05), Byte(0x06), Byte(0x07), Byte(0x08)])
    }

    @Test
    func `Int8 serializer writes sign-extended byte`() {
        let serializer = Int8.serializer(endianness: .big)
        let bytes = serializer.serializeToArray(-1)
        #expect(bytes == [Byte(0xFF)])
    }
}

// MARK: - Edge Case Tests

extension BinarySerializerTests.EdgeCase {

    @Test
    func `serializing UInt16 zero produces two zero bytes`() {
        let serializer = UInt16.serializer(endianness: .little)
        let bytes = serializer.serializeToArray(0)
        #expect(bytes == [Byte(0x00), Byte(0x00)])
    }

    @Test
    func `serializing UInt16 max big-endian produces two FF bytes`() {
        let serializer = UInt16.serializer(endianness: .big)
        let bytes = serializer.serializeToArray(UInt16.max)
        #expect(bytes == [Byte(0xFF), Byte(0xFF)])
    }
}

// MARK: - Integration Tests

extension BinarySerializerTests.Integration {

    @Test
    func `multiple serializers compose into one buffer`() {
        let u16 = UInt16.serializer(endianness: .little)
        let u32 = UInt32.serializer(endianness: .big)

        var buffer: [Byte] = []
        u16.serializeAppending(0x1234, to: &buffer)
        u32.serializeAppending(0xCAFEBABE, to: &buffer)

        #expect(buffer == [Byte(0x34), Byte(0x12),  // UInt16 little-endian
                          Byte(0xCA), Byte(0xFE), Byte(0xBA), Byte(0xBE)]) // UInt32 big-endian
    }
}
