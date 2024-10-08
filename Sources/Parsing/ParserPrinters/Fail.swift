//
//  Fail.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

/// A parser that always fails, no matter the input.
///
/// While not very useful on its own, this parser can be helpful when combined with other parsers or
/// operators.
///
/// For example, it can be used to conditionally causing parsing to fail when used with
/// ``Parser/flatMap(_:)``:
///
/// ```swift
/// struct OddFailure: Error {}
///
/// let evens = Int.parser().flatMap {
///   if $0.isMultiple(of: 2) {
///     Always($0)
///   } else {
///     Fail<Substring, Int>(throwing: OddFailure())
///   }
/// }
///
/// try evens.parse("42")  // 42
///
/// try evens.parse("123")
/// // error: OddFailure()
/// //  --> input:1:1-3
/// // 1 | 123
/// //   | ^^^
/// ```
public struct Fail<Input: Sendable, Output: Sendable>: ParserPrinterProtocol {
	@usableFromInline
	let error: Error
	
	/// Creates a parser that throws an error when it runs.
	///
	/// - Parameter error: An error to throw when the parser is run.
	@inlinable
	public init(throwing error: Error) {
		self.error = error
	}
	
	@inlinable
	public func parse(_ input: inout Input) throws -> Output {
		switch self.error {
			case is ParsingError:
				throw self.error
			default:
				throw ParsingError.wrap(self.error, at: input)
		}
	}
	
	@inlinable
	public func print(_ output: Output, into input: inout Input) throws {
		switch self.error {
			case is PrintingError:
				throw self.error
			default:
				throw PrintingError.failed(
					summary: """
	\(self.error)
	
	A failing parser-printer attempted to print:
	
	\(output)
	""",
					input: input
				)
		}
	}
}

extension Fail {
	/// Creates a parser that throws an error when it runs.
	@inlinable
	public init() {
		self.init(throwing: DefaultError())
	}
	
	@usableFromInline
	struct DefaultError: Error, CustomDebugStringConvertible {
		@usableFromInline
		init() {}
		
		@usableFromInline
		var debugDescription: String {
			"failed"
		}
	}
}

extension Parsers {
	public typealias Fail = Parsing.Fail  // NB: Convenience type alias for discovery
}
