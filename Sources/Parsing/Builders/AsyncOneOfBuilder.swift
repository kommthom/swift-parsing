//
//  AsyncOneOfBuilder.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 03.09.24.
//

@resultBuilder
public enum AsyncOneOfBuilder<Input: Sendable, Output: Sendable>: Sendable {
	@inlinable
	public static func buildArray<P: AsyncParserProtocol>(_ parsers: [P]) async -> Parsers.OneOfMany<P> where P.Input == Input, P.Output == Output {
		.init(parsers)
	}

	@inlinable
	static public func buildBlock() async -> Fail<Input, Output> {
		Fail()
	}

	@inlinable
	static public func buildBlock<P: AsyncParserProtocol>(_ parser: P) async -> P where P.Input == Input, P.Output == Output {
		parser
	}

	@inlinable
	public static func buildEither<TrueParser, FalseParser>(first parser: TrueParser) async -> Parsers.Conditional<TrueParser, FalseParser> where TrueParser.Input == Input, TrueParser.Output == Output, FalseParser.Input == Input, FalseParser.Output == Output {
		.first(parser)
	}

	@inlinable
	public static func buildEither<TrueParser, FalseParser>(second parser: FalseParser) async -> Parsers.Conditional<TrueParser, FalseParser> where TrueParser.Input == Input, TrueParser.Output == Output, FalseParser.Input == Input, FalseParser.Output == Output {
		.second(parser)
	}

	@inlinable
	public static func buildExpression<P: AsyncParserProtocol>(_ parser: P) async -> P where P.Input == Input, P.Output == Output {
		parser
	}

	@inlinable
	public static func buildIf<P>(_ parser: P?) async -> OptionalOneOf<P> where P.Input == Input {
		await .init(wrapped: parser)
	}

	@inlinable
	public static func buildLimitedAvailability<P>(_ parser: P?) async -> OptionalOneOf<P> where P.Input == Input, P.Output == Output {
		await .init(wrapped: parser)
	}

	@inlinable
	public static func buildPartialBlock<P: AsyncParserProtocol>(first: P) async -> P where P.Input == Input, P.Output == Output {
		first
	}

	@inlinable
	public static func buildPartialBlock<P0: AsyncParserProtocol, P1: AsyncParserProtocol>(accumulated: P0, next: P1) async -> OneOf2<P0, P1> where P0.Input == Input, P0.Output == Output, P1.Input == Input, P1.Output == Output {
		await .init(accumulated, next)
	}

	public struct OneOf2<P0: AsyncParserProtocol, P1: AsyncParserProtocol>: AsyncParserProtocol where P0.Input == P1.Input, P0.Output == P1.Output, P0.Input: Sendable, P0.Output: Sendable {
		public let p0: P0, p1: P1
		@inlinable
		public init(_ p0: P0, _ p1: P1) async {
			self.p0 = p0
			self.p1 = p1
		}

		@inlinable
		public func parse(_ input: inout P0.Input) async rethrows -> P0.Output {
			let original = input
			do {
				return try await self.p0.parse(&input)
			} catch let e0 {
				do {
					input = original
					return try await self.p1.parse(&input)
				} catch let e1 {
					throw ParsingError.manyFailed([e0, e1], at: input)
				}
			}
		}
	}

	public struct OptionalOneOf<Wrapped: AsyncParserProtocol>: AsyncParserProtocol {
		@usableFromInline
		let wrapped: Wrapped?

		@usableFromInline
		init(wrapped: Wrapped?) async {
			self.wrapped = wrapped
		}

		@inlinable
		public func parse(_ input: inout Wrapped.Input) async throws -> Wrapped.Output where Wrapped.Input: Sendable {
			guard let wrapped = self.wrapped else { throw ParsingError.manyFailed([], at: input) }
			return try await wrapped.parse(&input)
		}
	}
}

extension AsyncOneOfBuilder.OneOf2: AsyncParserPrinterProtocol where P0: AsyncParserPrinterProtocol, P1: AsyncParserPrinterProtocol {
	@inlinable
	public func print(_ output: P0.Output, into input: inout P0.Input) async rethrows {
		let original = input
		do {
			try await self.p1.print(output, into: &input)
		} catch let e1 {
			do {
				input = original
				try await self.p0.print(output, into: &input)
			} catch let e0 {
				throw PrintingError.manyFailed([e1, e0], at: input)
			}
		}
	}
}

extension AsyncOneOfBuilder.OptionalOneOf: AsyncParserPrinterProtocol where Wrapped: AsyncParserPrinterProtocol {
	@inlinable
	public func print(_ output: Wrapped.Output, into input: inout Wrapped.Input) async throws {
		guard let wrapped = self.wrapped else { throw PrintingError.manyFailed([], at: input) }
		try await wrapped.print(output, into: &input)
	}
}

extension AsyncOneOfBuilder where Input == Substring {
	@_disfavoredOverload
	public static func buildExpression<P: AsyncParserProtocol>(_ parser: P) async -> From<Conversions.SubstringToUTF8ViewIso, Substring.UTF8View, P> where P.Input == Substring.UTF8View {
		From(.utf8) {
			parser
		}
	}
}

extension AsyncOneOfBuilder where Input == Substring.UTF8View {
	@_disfavoredOverload
	public static func buildExpression<P: AsyncParserProtocol>(_ parser: P) async -> P where P.Input == Substring.UTF8View {
		parser
	}
}
