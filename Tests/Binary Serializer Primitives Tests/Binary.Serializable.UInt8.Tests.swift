// Binary.Serializable.UInt8.Tests.swift
//
// Tests for the stdlib-interop UInt8 forwarders on Binary.Serializable. Each
// suite exercises construction agreement between byte-domain primary and
// UInt8 forwarder.

import Binary_Serializable_Primitives
import Binary_Serializer_Primitives_Test_Support
import Testing

private struct Greeting: Binary.Serializable {
    let name: String

    static func serialize<Buffer>(_ greeting: Self, into buffer: inout Buffer)
    where Buffer: RangeReplaceableCollection, Buffer.Element == Byte {
        buffer.append(contentsOf: "Hello, ".utf8)
        buffer.append(contentsOf: greeting.name.utf8)
        buffer.append(Byte(UInt8(ascii: "!")))
    }
}

@Suite("Binary.Serializable UInt8 forwarder")
struct BinarySerializableUInt8Tests {

    @Test
    func `serialize(into: [UInt8])`() {
        let greeting = Greeting(name: "UInt8")
        var buffer: [UInt8] = []
        greeting.serialize(into: &buffer)
        #expect(buffer == Array("Hello, UInt8!".utf8))
    }

    @Test
    func `serialize(into: ContiguousArray<UInt8>)`() {
        let greeting = Greeting(name: "Cont")
        var buffer: ContiguousArray<UInt8> = []
        greeting.serialize(into: &buffer)
        #expect(Array(buffer) == Array("Hello, Cont!".utf8))
    }

    @Test
    func `RangeReplaceableCollection<UInt8>.append(serializable)`() {
        let greeting = Greeting(name: "Append")
        var buffer: [UInt8] = []
        buffer.append(greeting)
        #expect(buffer == Array("Hello, Append!".utf8))
    }

    @Test
    func `Array<UInt8>.init(serializable)`() {
        let greeting = Greeting(name: "Init")
        let buffer = [UInt8](greeting)
        #expect(buffer == Array("Hello, Init!".utf8))
    }

    @Test
    func `ContiguousArray<UInt8>.init(serializable)`() {
        let greeting = Greeting(name: "CInit")
        let buffer = ContiguousArray<UInt8>(greeting)
        #expect(Array(buffer) == Array("Hello, CInit!".utf8))
    }

    @Test
    func `withSerializedBytes(Span<UInt8>)`() {
        let greeting = Greeting(name: "Span")
        let count = Greeting.withSerializedBytes(greeting) { (span: borrowing Span<UInt8>) in
            span.count
        }
        #expect(count == "Hello, Span!".utf8.count)
    }

    @Test
    func `instance withSerializedBytes(Span<UInt8>)`() {
        let greeting = Greeting(name: "Span2")
        let count = greeting.withSerializedBytes { (span: borrowing Span<UInt8>) in
            span.count
        }
        #expect(count == "Hello, Span2!".utf8.count)
    }

    @Test
    func `String(_ bytes: [UInt8]) decodes UTF-8`() {
        let bytes: [UInt8] = Array("Hello".utf8)
        let s = String(bytes)
        #expect(s == "Hello")
    }

    @Test
    func `String(_ bytes: ArraySlice<UInt8>) decodes UTF-8`() {
        let bytes: [UInt8] = Array("Hello, World!".utf8)
        let slice = bytes[7..<12]
        let s = String(slice)
        #expect(s == "World")
    }
}
