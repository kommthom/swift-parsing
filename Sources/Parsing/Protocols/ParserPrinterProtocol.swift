//
//  ParserPrinterProtocol.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 31.08.24.
//

import Thoms_Foundation

/// A ``Parser`` that can incrementally "print" an output value back into an input.
///
/// > Note: Printing is the reverse operation of parsing, so the `Input` is essentially built up
/// > in reverse. As such, new values should be prepended to the front of the input. This allows
/// > parsers to check that the already-printed values match what is expected for any given
/// > ``Parser``.
@rethrows public protocol ParserPrinterProtocol<Input, Output>: ParserProtocol {
	/// Attempts to print a well-structured piece of data into something more nebulous.
	///
	/// - Parameters
	///   - output: A well-structured value to be printed to the given input.
	///   - input: A nebulous, mutable piece of data to be incrementally printed into.
	func print(_ output: Output, into input: inout Input) throws
}

extension ParserPrinterProtocol where Body: ParserPrinterProtocol, Body.Input == Input, Body.Output == Output {
	// NB: This can't be `rethrows` do to a bug that swallows `throws` even when it's needed.
	@inlinable
	public func print(_ output: Output, into input: inout Input) throws {
		try self.body.print(output, into: &input)
	}
}

extension ParserPrinterProtocol where Input: _EmptyInitializable {
	/// Attempts to print a well-structured piece of data to something more nebulous.
	///
	/// - Parameter output: A well-structured piece of data to be printed.
	/// - Returns: A more nebulous value printed from the given output.
	@inlinable
	public func print(_ output: Output) rethrows -> Input {
		var input = Input()
		try self.print(output, into: &input)
		return input
	}
}

extension ParserPrinterProtocol where Output == Void {
	/// Attempts to print into a nebulous piece of data.
	///
	/// - Parameter input: A nebulous, mutable piece of data to be incrementally printed into.
	@inlinable
	public func print(into input: inout Input) rethrows {
		try self.print((), into: &input)
	}
}

extension ParserPrinterProtocol where Input: _EmptyInitializable, Output == Void {
	/// Attempts to print a nebulous piece of data.
	///
	/// - Returns: A nebulous value.
	@inlinable
	public func print() rethrows -> Input {
		try self.print(())
	}
}
