//
//  FlatMap.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 31.08.24.
//

extension ParserProtocol {
	/// Returns a parser that transforms the output of this parser into a new parser.
	///
	/// This method is similar to `Sequence.flatMap`, `Optional.flatMap`, and `Result.flatMap` in the
	/// Swift standard library, as well as `Publisher.flatMap` in the Combine framework.
	///
	/// ## Printability
	///
	/// `Parser.flatMap` is _not_ printable, as the logic contained inside its transform operation to
	/// some new parser is not reversible.
	///
	/// If you are building a parser-printer, avoid uses of `flatMap` and instead prefer the use of
	/// ``Parser/map(_:)-4hsj5`` with conversions that preserve printability.
	///
	/// - Parameter transform: A closure that transforms values of this parser's output and returns a
	///   new parser.
	/// - Returns: A parser that transforms output from an upstream parser into a new parser.
	@inlinable
	public func flatMap<Input, NewParser>(@ParserBuilder<Input> _ transform: @escaping @Sendable (Output) -> NewParser) -> Parsers.FlatMap<NewParser, Self> where Self.Input == Input {
		.init(upstream: self, transform: transform)
	}
}

extension Parsers {
	/// A parser that transforms the output of another parser into a new parser.
	///
	/// You will not typically need to interact with this type directly. Instead you will usually use
	/// the ``Parser/flatMap(_:)`` operation, which constructs this type.
	public struct FlatMap<NewParser: ParserProtocol, Upstream: ParserProtocol>: ParserProtocol where NewParser.Input == Upstream.Input {
		public let upstream: Upstream
		public let transform: @Sendable (Upstream.Output) -> NewParser
		
		@inlinable
		public init(upstream: Upstream, transform: @escaping @Sendable (Upstream.Output) -> NewParser) {
			self.upstream = upstream
			self.transform = transform
		}
		
		@inlinable
		public func parse(_ input: inout Upstream.Input) rethrows -> NewParser.Output where Upstream.Input: Sendable {
			let original = input
			do {
				return try self.transform(self.upstream.parse(&input)).parse(&input)
			} catch let ParsingError.failed(reason, context) {
				throw ParsingError.failed(
					reason,
					.init(
						originalInput: original,
						remainingInput: input,
						debugDescription: context.debugDescription,
						underlyingError: ParsingError.failed(reason, context)
					)
				)
			}
		}
	}
}
