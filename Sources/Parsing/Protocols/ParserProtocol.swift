//
//  ParserProtocol.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 31.08.24.
//

/// Declares a type that can incrementally parse an `Output` value from an `Input` value.
///
/// A parser attempts to parse a nebulous piece of data, represented by the `Input` associated
/// type, into something more well-structured, represented by the `Output` associated type. The
/// parser implements the ``parse(_:)-76tcw`` method, which is handed an `inout Input`, and its
/// job is to turn this into an `Output` if possible, or throw an error if it cannot.
///
/// The argument of the ``parse(_:)-76tcw`` function is `inout` because a parser will usually
/// consume some of the input in order to produce an output. For example, we can use an
/// `Int.parser()` parser to extract an integer from the beginning of a substring and consume that
/// portion of the string:
///
/// ```swift
/// var input: Substring = "123 Hello world"
///
/// try Int.parser().parse(&input) // 123
/// input // " Hello world"
/// ```
///
/// Note that this parser works on `Substring` rather than `String` because substrings expose
/// efficient ways of removing characters from its beginning. Substrings are "views" into a
/// string, specified by start and end indices. Operations like `removeFirst`, `removeLast` and
/// others can be implemented efficiently on substrings because they simply move the start and end
/// indices, whereas their implementation on strings must make a copy of the string with the
/// characters removed.
@rethrows public protocol ParserProtocol<Input, Output>: Sendable {
	/// The type of values this parser parses from.
	associatedtype Input: Sendable

	/// The type of values parsed by this parser.
	associatedtype Output: Sendable

	// NB: For Xcode to favor autocompleting `var body: Body` over `var body: Never` we must use a
	//     type alias.
	associatedtype _Body: Sendable

	/// A type representing the body of this parser.
	typealias Body = _Body

	/// Attempts to parse a nebulous piece of data into something more well-structured. Typically
	/// you only call this from other `Parser` conformances, not when you want to parse a concrete
	/// input.
	///
	/// - Parameter input: A nebulous, mutable piece of data to be incrementally parsed.
	/// - Returns: A more well-structured value parsed from the given input.
	func parse(_ input: inout Input) throws -> Output

	/// The content and behavior of a parser that is composed from other parsers.
	///
	/// Implement this requirement when you want to incorporate the behavior of other parsers
	/// together.
	///
	/// Do not invoke this property directly.
	@ParserBuilder<Input>
	var body: Body { get }
}

extension ParserProtocol where Body == Never {
	/// A non-existent body.
	///
	/// > Warning: Do not invoke this property directly. It will trigger a fatal error at runtime.
	@_transparent
	public var body: Body {
		fatalError(
			"""
				'\(Self.self)' has no body. …

				Do not access a parser's 'body' property directly, as it may not exist. To run a parser, \
				call 'Parser.parse(_:)', instead.
			"""
		)
	}
}

extension ParserProtocol where Body: ParserProtocol, Body.Input == Input, Body.Output == Output {
	// NB: This can't be `rethrows` do to a bug that swallows `throws` even when it's needed.
	@inlinable
	@inline(__always)
	public func parse(_ input: inout Body.Input) throws -> Body.Output {
		try self.body.parse(&input)
	}
}

extension ParserProtocol {
	/// Parse an input value into an output. This method is more ergonomic to use than
	/// ``parse(_:)-76tcw`` because the input does not need to be inout.
	///
	/// Rather than having to create a mutable input value and feed it to the ``parse(_:)-76tcw``
	/// method like this:
	///
	/// ```swift
	/// var input = ...
	/// let output = try parser.parse(&input)
	/// ```
	///
	/// You can just feed the input directly:
	///
	/// ```swift
	/// let output = try parser.parse(input)
	/// ```
	///
	/// - Parameter input: A nebulous piece of data to be parsed.
	/// - Returns: A more well-structured value parsed from the given input.
	@_disfavoredOverload
	@inlinable
	public func parse(_ input: Input) rethrows -> Output {
		var input = input
		return try self.parse(&input)
	}

	/// Parse a collection into an output using a parser that works on the collection's `SubSequence`.
	/// This method is more ergnomic to use than ``parse(_:)-76tcw`` because it accepts a
	/// collection directly rather than its subsequence, and the input does not need to be `inout`.
	///
	/// Rather than having to create a mutable subsequence value, such as a `Substring`, and feed it
	/// to the ``parse(_:)-76tcw`` method like this:
	///
	/// ```swift
	/// var input = "123,true"[...]
	/// let output = try Parse {
	///   Int.parser()
	///   ","
	///   Bool.parser()
	/// }
	/// .parse(&input) // (123, true)
	/// ```
	///
	/// You can just feed a plain `String` input directly:
	///
	/// ```swift
	/// let output = try Parse {
	///   Int.parser()
	///   ","
	///   Bool.parser()
	/// }
	/// .parse("123,true") // (123, true)
	/// ```
	///
	/// This method will fail if the parser does not consume the entirety of the input.
	/// For example:
	///
	/// ```swift
	/// let output = try Parse {
	///  Int.parser()
	///  ","
	///  Bool.parser()
	/// }
	/// .parse("123,true    ")
	///
	/// // error: unexpected input
	/// //  --> input:1:9
	/// // 1 | 123,true␣␣␣␣
	/// //   |         ^ expected end of input
	/// ```
	///
	/// > Tip: If your input can have trailing whitespace that you would like to consume and discard
	/// > you can do so like this:
	/// > ```swift
	/// > let output = try Parse {
	/// >   Int.parser()
	/// >   ",".utf8
	/// >   Bool.parser()
	/// >   Whitespace()
	/// > }
	/// > .parse("123,true    ") // (123, true)
	/// > ```
	///
	/// - Parameter input: A nebulous collection of data to be parsed.
	/// - Returns: A more well-structured value parsed from the given input.
	@inlinable
	public func parse<C: Collection & Sendable>(_ input: C) rethrows -> Output where Input == C.SubSequence {
		var input = input[...]
		return try Parse {
			self
			End<Input>()
		}.parse(&input)
	}

	/// Parse a `String` into an output using a UTF-8 parser. This method is more ergnomic to use
	/// than ``parse(_:)-76tcw`` because it accepts a plain string rather than a collection of
	/// UTF-8 code units, and the input does not need to be `inout`.
	///
	/// Rather than having to create a mutable UTF-8 value and feed it to the ``parse(_:)-76tcw``
	/// method like this:
	///
	/// ```swift
	/// var input = "123,true"[...].utf8
	/// let output = try Parse {
	///   Int.parser()
	///   ",".utf8
	///   Bool.parser()
	/// }
	/// .parse(&input) // (123, true)
	/// ```
	///
	/// You can just feed a plain `String` input directly:
	///
	/// ```swift
	/// let output = try Parse {
	///   Int.parser()
	///   ",".utf8
	///   Bool.parser()
	/// }
	/// .parse("123,true") // (123, true)
	/// ```
	///
	/// This method will fail if the parser does not consume the entirety of the input.
	/// For example:
	///
	/// ```swift
	/// let output = try Parse {
	///   Int.parser()
	///   ",".utf8
	///   Bool.parser()
	/// }
	/// .parse("123,true    ")
	///
	/// // error: unexpected input
	/// //  --> input:1:9
	/// // 1 | 123,true␣␣␣␣
	/// //   |         ^ expected end of input
	/// ```
	///
	/// > Tip: If your input can have trailing whitespace that you would like to consume and discard
	/// > you can do so like this:
	/// > ```swift
	/// > let output = try Parse {
	/// >  Int.parser()
	/// >  ",".utf8
	/// >  Bool.parser()
	/// >  Whitespace()
	/// > }
	/// > .parse("123,true    ") // (123, true)
	/// > ```
	///
	/// - Parameter input: A nebulous collection of data to be parsed.
	/// - Returns: A more well-structured value parsed from the given input.
	@_disfavoredOverload
	@inlinable
	public func parse<S: StringProtocol>(_ input: S) rethrows -> Output where Input == S.SubSequence.UTF8View, Self.Input: Sendable {
		var input: Input = input[...].utf8
		return try Parse {
			self
			End<Input>()
			}
			.parse(&input)
	}
}
