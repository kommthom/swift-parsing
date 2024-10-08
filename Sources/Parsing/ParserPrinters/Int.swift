//
//  Int.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

extension FixedWidthInteger {
	/// A parser that consumes an integer (with an optional leading `+` or `-` sign for signed integer
	/// types) from the beginning of a collection of UTF-8 code units.
	///
	/// See <doc:Int> for more information about this parser.
	///
	/// - Parameters:
	///   - inputType: The collection type of UTF-8 code units to parse.
	///   - radix: The radix, or base, to use for converting text to an integer value. `radix` must be
	///     in the range `2...36`.
	/// - Returns: A parser that consumes an integer from the beginning of a collection of UTF-8 code
	///   units.
	@inlinable
	public static func parser<Input: Sendable>(of inputType: Input.Type = Input.self, radix: Int = 10) -> Parsers.IntParser<Input, Self> {
		.init(radix: radix)
	}
}

extension Parsers {
	/// A parser that consumes an integer (with an optional leading `+` or `-` sign for signed integer
	/// types) from the beginning of a collection of UTF8 code units.
	///
	/// You will not typically need to interact with this type directly. Instead you will usually use
	/// the static `parser()` method on the `FixedWidthInteger` of your choice, e.g. `Int.parser()`,
	/// `UInt8.parser()`, etc., all of which construct this type.
	///
	/// See <doc:Int> for more information about this parser.
	public struct IntParser<Input: Collection & Sendable, Output: FixedWidthInteger & Sendable>: ParserProtocol where Input.SubSequence == Input, Input.Element == UTF8.CodeUnit {
	/// The radix, or base, to use for converting text to an integer value.
		public let radix: Int

		@inlinable
		public init(radix: Int = 10) {
			precondition((2...36).contains(radix), "Radix not in range 2...36")
			self.radix = radix
		}

		@inlinable
		public func parse(_ input: inout Input) throws -> Output where Input: Sendable {
			@inline(__always)
			func digit(for n: UTF8.CodeUnit) -> Output? {
				let output: Output
				switch n {
				case .init(ascii: "0") ... .init(ascii: "9"):
				  output = Output(n - .init(ascii: "0"))
				case .init(ascii: "A") ... .init(ascii: "Z"):
				  output = Output(n - .init(ascii: "A") + 10)
				case .init(ascii: "a") ... .init(ascii: "z"):
				  output = Output(n - .init(ascii: "a") + 10)
				default:
				  return nil
				}
				return output < self.radix ? output : nil
			}
			var length = 0
			var iterator = input.makeIterator()
			guard let first = iterator.next() else { throw ParsingError.expectedInput("integer", at: input) }
			let isPositive: Bool
			let parsedSign: Bool
			var overflow = false
			var output: Output
			switch (Output.isSigned, first) {
				case (true, .init(ascii: "-")):
					parsedSign = true
					isPositive = false
					output = 0
				case (true, .init(ascii: "+")):
					parsedSign = true
					isPositive = true
					output = 0
				case let (_, n):
					guard let n = digit(for: n) else { throw ParsingError.expectedInput("integer", at: input) }
					parsedSign = false
					isPositive = true
					output = n
			}
			let original = input
			input.removeFirst()
			length += 1
			let radix = Output(self.radix)
			while let next = iterator.next(), let n = digit(for: next) {
				input.removeFirst()
				(output, overflow) = output.multipliedReportingOverflow(by: radix)
				func overflowError() -> ParsingError {
					ParsingError.failed(
						summary: "failed to process \"\(Output.self)\"",
						label: "overflowed \(Output.max)",
						from: original,
						to: input
					)
				}
				guard !overflow else { throw overflowError() }
				(output, overflow) = isPositive ? output.addingReportingOverflow(n) : output.subtractingReportingOverflow(n)
				guard !overflow else { throw overflowError() }
				length += 1
			}
			guard length > (parsedSign ? 1 : 0) else { throw ParsingError.expectedInput("integer", at: input) }
			return output
		}
	}
}

extension Parsers.IntParser: ParserPrinterProtocol where Input: PrependableCollectionProtocol {
	@inlinable
	public func print(_ output: Output, into input: inout Input) {
		input.prepend(contentsOf: String(output, radix: self.radix).utf8)
	}
}
