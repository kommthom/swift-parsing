//
//  BinaryFloatingPointToFixedWidthIntegerIso.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

extension ConversionProtocol where Self == Conversions.BinaryFloatingPointToFixedWidthIntegerIso<Double, Int> {
	/// A conversion from a `Double` to an `Int`.
	///
	/// This conversion can be used to transform a ``ParserPrinter``'s double output into an integer
	/// output, rounding toward zero.
	///
	/// ```swift
	/// Double.parser().map(.int).parse("123.45")  // 123
	/// ```
	@inlinable
	public static var int: Self { .init() }
}

extension ConversionProtocol where Output == Double {
	/// Transforms this conversion to `Double` into a conversion to `Int`.
	///
	/// A fluent version of ``Conversion/int-swift.type.property``. Equivalent to calling ``map(_:)``
	/// with ``Conversion/int-swift.type.property``:
	///
	/// ```swift
	/// doubleConversion.int
	/// // =
	/// doubleConversion.map(.int)
	/// ```
	@inlinable
	public var int: Conversions.MapIso<Self, Conversions.BinaryFloatingPointToFixedWidthIntegerIso<Double, Int>> {
		self.map(.int)
	}
}

extension Conversions {
	/// A conversion from a `Double` to an `Int`.
	///
	/// You will not typically need to interact with this type directly. Instead you will usually use
	/// the ``Conversion/int-swift.type.property`` operation, which constructs this type.
	public struct BinaryFloatingPointToFixedWidthIntegerIso<Input: BinaryFloatingPoint & Sendable, Output: FixedWidthInteger & Sendable>: ConversionProtocol {
		@usableFromInline
		init() {}

		@inlinable
		public func apply(_ input: Input) -> Output {
			.init(input)
		}

		@inlinable
		public func unapply(_ output: Output) -> Input {
			.init(output)
		}
	}
}
