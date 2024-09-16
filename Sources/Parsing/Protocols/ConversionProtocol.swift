//
//  ConversionProtocol.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 31.08.24.
//

/// Declares a type that can transform an `Input` value into an `Output` value *and* transform an
/// `Output` value back into an `Input` value.
///
/// Useful in transforming the output of a parser-printer into some new type while preserving
/// printability via ``Parser/map(_:)-18m9d``.
@rethrows public protocol ConversionProtocol<Input, Output>: Sendable {
	// The type of values this conversion converts from.
	associatedtype Input: Sendable

	// The type of values this conversion converts to.
	associatedtype Output: Sendable

	/// Attempts to transform an input into an output.
	///
	/// See ``Conversion/apply(_:)`` for the reverse process.
	///
	/// - Parameter input: An input value.
	/// - Returns: A transformed output value.
	func apply(_ input: Input) throws -> Output

	/// Attempts to transform an output back into an input.
	///
	/// The reverse process of ``Conversion/apply(_:)``.
	///
	/// - Parameter output: An output value.
	/// - Returns: An "un"-transformed input value.
	func unapply(_ output: Output) throws -> Input
}
