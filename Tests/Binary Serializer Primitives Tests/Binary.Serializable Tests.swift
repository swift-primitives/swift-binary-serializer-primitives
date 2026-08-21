import Binary_Primitives_Test_Support
import Binary_Serializer_Primitives_Test_Support
import Testing

@testable import Binary_Serializable_Primitives

private struct Greeting: Binary.Serializable {
    let name: String
}

extension Greeting {
    static func serialize<Buffer>(_ greeting: Self, into buffer: inout Buffer)
    where Buffer: RangeReplaceableCollection, Buffer.Element == Byte {
        buffer.append(contentsOf: "Hello, ".utf8)
        buffer.append(contentsOf: greeting.name.utf8)
        buffer.append(Byte(UInt8(ascii: "!")))
    }
}

private struct Element: Binary.Serializable {
    let tag: String
    let content: String
}

extension Element {
    static func serialize<Buffer>(_ element: Self, into buffer: inout Buffer)
    where Buffer: RangeReplaceableCollection, Buffer.Element == Byte {
        buffer.append(Byte(UInt8(ascii: "<")))
        buffer.append(contentsOf: element.tag.utf8)
        buffer.append(Byte(UInt8(ascii: ">")))

        buffer.append(contentsOf: element.content.utf8)

        buffer.append(Byte(UInt8(ascii: "<")))
        buffer.append(Byte(UInt8(ascii: "/")))
        buffer.append(contentsOf: element.tag.utf8)
        buffer.append(Byte(UInt8(ascii: ">")))
    }
}

private struct Container: Binary.Serializable {
    let children: [Element]
}

extension Container {
    static func serialize<Buffer>(_ container: Self, into buffer: inout Buffer)
    where Buffer: RangeReplaceableCollection, Buffer.Element == Byte {
        buffer.append(contentsOf: "<div>".utf8)
        for child in container.children {
            buffer.append(contentsOf: child.bytes)
        }
        buffer.append(contentsOf: "</div>".utf8)
    }
}

private struct LargeContent: Binary.Serializable {
    let lines: [String]
}

extension LargeContent {
    static func serialize<Buffer>(_ content: Self, into buffer: inout Buffer)
    where Buffer: RangeReplaceableCollection, Buffer.Element == Byte {
        for (index, line) in content.lines.enumerated() {
            if index > 0 {
                buffer.append(Byte(UInt8(ascii: "\n")))
            }
            buffer.append(contentsOf: line.utf8)
        }
    }
}

@Suite
struct `Binary.Serializable Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

extension `Binary.Serializable Tests`.Unit {

    @Test
    func `serialize into byte array using serialize(into:)`() {
        let greeting = Greeting(name: "World")

        var buffer: [Byte] = []
        greeting.serialize(into: &buffer)

        #expect(buffer == [Byte]("Hello, World!".utf8))
    }

    @Test
    func `get bytes using .bytes property`() {
        let greeting = Greeting(name: "Swift")

        let bytes = greeting.bytes

        #expect(bytes == [Byte]("Hello, Swift!".utf8))
    }

    @Test
    func `get bytes from static serialize`() {
        let content = LargeContent(lines: ["Line 1", "Line 2", "Line 3"])

        let bytes: [Byte] = LargeContent.serialize(content)

        #expect(bytes == [Byte]("Line 1\nLine 2\nLine 3".utf8))
    }

    @Test
    func `convert to String`() {
        let element = Element(tag: "p", content: "Hello")

        let string = String(element)

        #expect(string == "<p>Hello</p>")
    }

    @Test
    func `use static serialize function`() {
        let greeting = Greeting(name: "API")

        let bytes: [Byte] = Greeting.serialize(greeting)

        #expect(bytes == [Byte]("Hello, API!".utf8))
    }

    @Test
    func `nested streaming types compose naturally`() {
        let container = Container(children: [
            Element(tag: "h1", content: "Title"),
            Element(tag: "p", content: "Paragraph"),
        ])

        let result = String(container)

        #expect(result == "<div><h1>Title</h1><p>Paragraph</p></div>")
    }

    @Test
    func `serialize multiple values into same buffer`() {
        let header = Element(tag: "header", content: "Header")
        let main = Element(tag: "main", content: "Content")
        let footer = Element(tag: "footer", content: "Footer")

        var buffer: [Byte] = []
        header.serialize(into: &buffer)
        main.serialize(into: &buffer)
        footer.serialize(into: &buffer)

        let result = String(buffer)
        #expect(result == "<header>Header</header><main>Content</main><footer>Footer</footer>")
    }

    @Test
    func `serialize into ContiguousArray`() {
        let greeting = Greeting(name: "Contiguous")

        var buffer: ContiguousArray<Byte> = []
        greeting.serialize(into: &buffer)

        #expect([Byte](buffer) == [Byte]("Hello, Contiguous!".utf8))
    }

    @Test
    func `append to existing buffer content`() {
        let greeting = Greeting(name: "Append")

        var buffer: [Byte] = [Byte]("Prefix: ".utf8)
        greeting.serialize(into: &buffer)

        #expect(buffer == [Byte]("Prefix: Hello, Append!".utf8))
    }

    @Test
    func `withSerializedBytes provides correct bytes`() {
        let greeting = Greeting(name: "Span")

        var capturedCount = 0
        Greeting.withSerializedBytes(greeting) { span in
            capturedCount = span.count
        }

        #expect(capturedCount == "Hello, Span!".utf8.count)
    }

    @Test
    func `withSerializedBytes instance method works`() {
        let element = Element(tag: "div", content: "test")

        var capturedCount = 0
        element.withSerializedBytes { span in
            capturedCount = span.count
        }

        #expect(capturedCount == "<div>test</div>".utf8.count)
    }

    @Test
    func `withSerializedBytes returns closure result`() {
        let greeting = Greeting(name: "Result")

        let count = greeting.withSerializedBytes { span in
            span.count
        }

        #expect(count == "Hello, Result!".utf8.count)
    }

    @Test
    func `withSerializedBytes provides borrowing access to bytes`() {
        let greeting = Greeting(name: "Test")

        let firstByte = greeting.withSerializedBytes { span in
            span[0]
        }

        #expect(firstByte == Byte(UInt8(ascii: "H")))
    }
}

extension `Binary.Serializable Tests`.`Edge Case` {

    @Test
    func `empty content serializes correctly`() {
        let empty = Element(tag: "br", content: "")

        #expect(empty.bytes == [Byte]("<br></br>".utf8))
    }

    @Test
    func `unicode content serializes as UTF-8`() {
        let unicode = Element(tag: "span", content: "Hello 👋 World 🌍")

        let bytes = unicode.bytes
        let roundTrip = String(bytes)

        #expect(roundTrip == "<span>Hello 👋 World 🌍</span>")
    }

    @Test
    func `large content doesn't overflow`() {
        let lines = (1...10000).map { "Line number \($0) with some content" }
        let content = LargeContent(lines: lines)

        let bytes = content.bytes

        #expect(bytes.count > 100000)
    }

    @Test
    func `integer literal appends raw byte not ASCII decimal`() {

        var buffer: [Byte] = []
        buffer.append(0xFE)
        buffer.append(0xFF)

        #expect(buffer == [254, 255], "Should append raw bytes, not ASCII decimal strings")
        #expect(buffer != [50, 53, 52, 50, 53, 53], "Must not serialize as ASCII '254255'")
    }

    @Test
    func `high byte literals append correctly`() {
        var buffer: [Byte] = []
        buffer.append(0x00)
        buffer.append(0x7F)
        buffer.append(0x80)
        buffer.append(0xFF)

        #expect(buffer == [0, 127, 128, 255])
    }

    @Test
    func `withSerializedBytes propagates typed errors`() throws {
        enum Fault: Swift.Error { case test }
        let greeting = Greeting(name: "Swift.Error")

        #expect(throws: Fault.self) {
            try greeting.withSerializedBytes { _ in
                throw Fault.test
            }
        }
    }
}

extension `Binary.Serializable Tests`.Integration {

    @Test
    func `pre-allocate buffer for efficiency`() {
        let lines = (1...100).map { "Line \($0)" }
        let content = LargeContent(lines: lines)

        var buffer: [Byte] = []
        buffer.reserveCapacity(1000)
        content.serialize(into: &buffer)

        #expect(buffer.count > 500)
        #expect(String(buffer).hasPrefix("Line 1\nLine 2"))
    }

    @Test
    func `direct buffer writing for maximum control`() {
        var buffer: [Byte] = []
        buffer.reserveCapacity(256)

        let parts = [
            Element(tag: "a", content: "Link"),
            Element(tag: "b", content: "Bold"),
        ]

        for part in parts {
            part.serialize(into: &buffer)
        }

        #expect(buffer == [Byte]("<a>Link</a><b>Bold</b>".utf8))
    }

    @Test
    func `reusable buffer for repeated serialization`() {
        var buffer: [Byte] = []

        let elements = ["one", "two", "three"].map { Element(tag: "li", content: $0) }
        var results: [String] = []

        for element in elements {
            buffer.removeAll(keepingCapacity: true)
            element.serialize(into: &buffer)
            results.append(String(buffer))
        }

        #expect(results == ["<li>one</li>", "<li>two</li>", "<li>three</li>"])
    }
}
