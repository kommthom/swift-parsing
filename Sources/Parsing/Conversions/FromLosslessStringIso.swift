//
//  FromLosslessStringIso.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

extension ConversionProtocol {
	/// A conversion from a string to a lossless string-convertible type.
	///
	/// See ``lossless(_:)-swift.method`` for a fluent version of this interface that transforms an
	/// existing conversion.
	///
	/// - Parameter type: A type that conforms to `LosslessStringConvertible`.
	/// - Returns: A conversion from a string to the given type.
	@inlinable
	public static func lossless<NewOutput: Sendable>(_ type: NewOutput.Type) -> Self where Self == Conversions.FromLosslessStringIso<NewOutput> {
		.init()
	}
	
	/// Transforms this conversion to a string into a conversion to the given lossless
	/// string-convertible type.
	///
	/// A fluent version of ``Conversion/lossless(_:)-swift.type.method``. Equivalent to calling
	/// ``map(_:)`` with ``Conversion/lossless(_:)-swift.type.method``:
	///
	/// ```swift
	/// stringConversion.lossless(NewOutput.self)
	/// // =
	/// stringConversion.map(.lossless(NewOutput.self))
	/// ```
	///
	/// - Parameter type: A type that conforms to `LosslessStringConvertible`.
	/// - Returns: A conversion from a string to the given type.
	@inlinable
	public func lossless<NewOutput: Sendable>(_ type: NewOutput.Type) -> Conversions.MapIso<Self, Conversions.FromLosslessStringIso<NewOutput>> {
		self.map(.lossless(NewOutput.self))
	}
}

extension Conversions {
	/// A conversion from a string to a lossless string-convertible type.
	///
	/// You will not typically need to interact with this type directly. Instead you will usually use
	/// the ``Conversion/lossless(_:)-swift.type.method`` operation, which constructs this type.
	public struct FromLosslessStringIso<Output: LosslessStringConvertible & Sendable>: ConversionProtocol {
		@usableFromInline
		init() {}
		
		@inlinable
		public func apply(_ input: String) throws -> Output {
			guard let output = Output(input)
			else {
				throw ConvertingError(
	"""
	lossless: Failed to convert \(input.debugDescription) to \(Output.self).
	"""
				)
			}
			
			return output
		}
		
		@inlinable
		public func unapply(_ output: Output) -> String {
			output.description
		}
	}
}
