# Binary Serializer Primitives Scope

`swift-binary-serializer-primitives` provides the **binary-domain serialization
discipline** over the upstream-owned `Binary` namespace. It is a **discipline
package**: every type it ships extends `Binary` (`Binary.Serializer`,
`Binary.Serializable`) or an integer type with a binary serializer. It therefore
declares **no zero-dep `Binary Serializer Primitive` root** — the `Binary`
namespace is owned upstream by `swift-binary-primitives`, and every declaration
here is external-dep-bearing.

## Per-[MOD-031] shape

The package follows `[MOD-031]` per-sub-namespace decomposition. Because it
extends an upstream namespace, the root-applicability rule (`[AUDIT §7]`) gives
it **no zero-dep root**; Core's content split into one witness sub-namespace
target plus the pre-existing sibling targets. There is no implementation
`Binary Serializer Primitives Core` target — the legacy `[MOD-001]` Core
convention is deprecated. A transitional exports-only shim retains the
`Binary Serializer Primitives Core` **product** so consumers of the dissolved
Core surface keep compiling until the cleanup wave.

## Owner targets

- **Binary Serializer Witness Primitives** — the `Binary.Serializer<Value>`
  closure-based plain witness, its conformance to the canonical
  `Serializer.Protocol`, and the `RawRepresentable` `serializer` defaults that
  return `Binary.Serializer<Self>`. These are mutual collaborators of the witness
  type (`[MOD-026]`) and so live in one sub-namespace. Depends on
  `Witness Primitives`, `Serializer Primitives`, `Binary Primitives`,
  `Byte Primitives`.
- **Binary Serializable Primitives** — the `Binary.Serializable` streaming
  byte-serialization protocol + its convenience/`RawRepresentable`/`Tagged`/byte-
  collection conformances. Relocated from `swift-binary-primitives`.
- **Binary Integer Serializer Primitives** — `{Int,UInt}{8,16,32,64}.serializer(endianness:)`
  factories returning `Binary.Serializer<T>`. Uses the witness sub-namespace.
- **Binary Serializer Primitives** — umbrella; re-exports the witness sub-namespace,
  `Binary Serializable Primitives`, and `Binary Integer Serializer Primitives` so
  consumers needing the union write `import Binary_Serializer_Primitives`.
- **Binary Serializer Primitives Core** — DEPRECATED transitional exports-only shim
  (L1 core-dissolution sweep 2026-06-23). Re-exports the witness sub-namespace plus
  the `Binary_Primitives` and `Serializer_Primitives` modules Core previously
  funneled. Removed in the cleanup wave.
- **Binary Serializer Primitives Test Support** — published test-fixtures product.

## Out of scope

- The `Binary` namespace itself and the byte/endianness vocabulary
  (`Binary.Endianness`, `FixedWidthInteger.bytes(endianness:)`) — owned by
  `swift-binary-primitives`.
- The canonical `Serializer.Protocol` / `Serializer.Serializable` witness vocabulary
  — owned by `swift-serializer-primitives`.
- The `Witness.Protocol` plain-witness vocabulary — owned by `swift-witness-primitives`.
- The `Byte` type and its stdlib-integration bridges — owned by `swift-byte-primitives`.

## Evaluation rule

Sub-target additions are evaluated against this scope. A proposed addition that
serializes a value into the binary (byte) domain — a new witness shape, a new
serializable conformance, an integer/format serializer — belongs here. Anything
that defines the `Binary` namespace, the `Serializer`/`Witness` vocabulary, or the
`Byte` substrate belongs in its owning upstream package, not here.
