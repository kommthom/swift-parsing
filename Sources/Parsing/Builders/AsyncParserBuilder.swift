//
//  AsyncParserBuilder.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 03.09.24.
//

@resultBuilder
public enum AsyncParserBuilder<Input: Sendable>: Sendable {
	@inlinable
	public static func buildBlock() -> AsyncAlways<Input, Void> {
		AsyncAlways(())
	}

	@inlinable
	public static func buildBlock<P: AsyncParserProtocol>(_ parser: P) -> P where P.Input == Input {
		parser
	}

	@inlinable
	public static func buildEither<TrueParser, FalseParser>(first parser: TrueParser) -> Parsers.Conditional<TrueParser, FalseParser> where TrueParser.Input == Input, FalseParser.Input == Input {
		.first(parser)
	}

	@inlinable
	public static func buildEither<TrueParser, FalseParser>(second parser: FalseParser) -> Parsers.Conditional<TrueParser, FalseParser> where TrueParser.Input == Input, FalseParser.Input == Input {
		.second(parser)
	}

	@inlinable
	public static func buildExpression<P: AsyncParserProtocol>(_ parser: P) -> P where P.Input == Input {
		parser
	}

	@inlinable
	public static func buildIf<P: AsyncParserProtocol>(_ parser: P?) -> P? where P.Input == Input {
		parser
	}

	@inlinable
	public static func buildIf<P>(_ parser: P?) -> Parsers.OptionalVoid<P> where P.Input == Input {
		.init(wrapped: parser)
	}

	@inlinable
	public static func buildLimitedAvailability<P: AsyncParserProtocol>(_ parser: P?) -> P? where P.Input == Input {
		parser
	}

	@inlinable
	public static func buildLimitedAvailability<P>(_ parser: P?) -> Parsers.OptionalVoid<P> where P.Input == Input {
		.init(wrapped: parser)
	}

	@inlinable
	public static func buildPartialBlock<P: AsyncParserProtocol>(first: P) -> P where P.Input == Input {
		first
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: AsyncParserProtocol, P1: AsyncParserProtocol>(accumulated: P0, next: P1) -> SkipFirst<P0, P1> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@inlinable
	public static func buildPartialBlock<P0: AsyncParserProtocol, P1: AsyncParserProtocol>(accumulated: P0, next: P1) -> SkipSecond<P0, P1> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: AsyncParserProtocol, P1: AsyncParserProtocol>(accumulated: P0, next: P1) -> Take2<P0, P1> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: AsyncParserProtocol, P1: AsyncParserProtocol, O0, O1>(accumulated: P0, next: P1) -> Take3<P0, P1, O0, O1> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: AsyncParserProtocol, P1: AsyncParserProtocol, O0, O1, O2>(accumulated: P0, next: P1) -> Take4<P0, P1, O0, O1, O2> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: AsyncParserProtocol, P1: AsyncParserProtocol, O0, O1, O2, O3>(accumulated: P0, next: P1) -> Take5<P0, P1, O0, O1, O2, O3> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: AsyncParserProtocol, P1: AsyncParserProtocol, O0, O1, O2, O3, O4>(accumulated: P0, next: P1) -> Take6<P0, P1, O0, O1, O2, O3, O4> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: AsyncParserProtocol, P1: AsyncParserProtocol, O0, O1, O2, O3, O4, O5>(accumulated: P0, next: P1) -> Take7<P0, P1, O0, O1, O2, O3, O4, O5> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: AsyncParserProtocol, P1: AsyncParserProtocol, O0, O1, O2, O3, O4, O5, O6>(accumulated: P0, next: P1) -> Take8<P0, P1, O0, O1, O2, O3, O4, O5, O6> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: AsyncParserProtocol, P1: AsyncParserProtocol, O0, O1, O2, O3, O4, O5, O6, O7>(accumulated: P0, next: P1) -> Take9<P0, P1, O0, O1, O2, O3, O4, O5, O6, O7> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: AsyncParserProtocol, P1: AsyncParserProtocol, O0, O1, O2, O3, O4, O5, O6, O7, O8>(accumulated: P0, next: P1) -> Take10<P0, P1, O0, O1, O2, O3, O4, O5, O6, O7, O8> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	public struct SkipFirst<P0: AsyncParserProtocol, P1: AsyncParserProtocol>: AsyncParserProtocol where P0.Input == P1.Input, P0.Output == Void {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
			self.p0 = p0
			self.p1 = p1
		}

		@inlinable
		public func parse(_ input: inout P0.Input) async rethrows -> P1.Output where P0.Input: Sendable {
			do {
				try await self.p0.parse(&input)
				return try await self.p1.parse(&input)
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct SkipSecond<P0: AsyncParserProtocol, P1: AsyncParserProtocol>: AsyncParserProtocol where P0.Input == P1.Input, P1.Output == Void {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
			self.p0 = p0
			self.p1 = p1
		}

		@inlinable
		public func parse(_ input: inout P0.Input) async rethrows -> P0.Output where P0.Input: Sendable {
			do {
				let o0 = try await self.p0.parse(&input)
				try await self.p1.parse(&input)
				return o0
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct Take2<P0: AsyncParserProtocol, P1: AsyncParserProtocol>: AsyncParserProtocol
	where P0.Input == P1.Input {
		@usableFromInline let p0: P0, p1: P1

		@usableFromInline init(_ p0: P0, _ p1: P1) {
		  self.p0 = p0
		  self.p1 = p1
		}

		@inlinable public func parse(_ input: inout P0.Input) async rethrows -> (P0.Output, P1.Output) where P0.Input: Sendable {
			do {
				return try await (
					self.p0.parse(&input),
					self.p1.parse(&input)
				)
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct Take3<P0: AsyncParserProtocol, P1: AsyncParserProtocol, O0, O1>: AsyncParserProtocol where P0.Input == P1.Input, P0.Output == (O0, O1) {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
			self.p0 = p0
			self.p1 = p1
		}

		@inlinable
		public func parse(_ input: inout P0.Input) async rethrows -> (O0, O1, P1.Output) where P0.Input: Sendable {
			do {
				let (o0, o1) = try await self.p0.parse(&input)
				return try await (o0, o1, self.p1.parse(&input))
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct Take4<P0: AsyncParserProtocol, P1: AsyncParserProtocol, O0, O1, O2>: AsyncParserProtocol where P0.Input == P1.Input, P0.Output == (O0, O1, O2) {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
			self.p0 = p0
			self.p1 = p1
		}

		@inlinable
		public func parse(_ input: inout P0.Input) async rethrows -> (O0, O1, O2, P1.Output) where P0.Input: Sendable {
			do {
				let (o0, o1, o2) = try await self.p0.parse(&input)
				return try await (o0, o1, o2, self.p1.parse(&input))
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct Take5<P0: AsyncParserProtocol, P1: AsyncParserProtocol, O0, O1, O2, O3>: AsyncParserProtocol where P0.Input == P1.Input, P0.Output == (O0, O1, O2, O3) {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
			self.p0 = p0
			self.p1 = p1
		}

		@inlinable
		public func parse(_ input: inout P0.Input) async rethrows -> (O0, O1, O2, O3, P1.Output) where P0.Input: Sendable {
			do {
				let (o0, o1, o2, o3) = try await self.p0.parse(&input)
				return try await (o0, o1, o2, o3, self.p1.parse(&input))
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct Take6<P0: AsyncParserProtocol, P1: AsyncParserProtocol, O0, O1, O2, O3, O4>: AsyncParserProtocol where P0.Input == P1.Input, P0.Output == (O0, O1, O2, O3, O4) {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
			self.p0 = p0
			self.p1 = p1
		}

		@inlinable
		public func parse(_ input: inout P0.Input) async rethrows -> (O0, O1, O2, O3, O4, P1.Output) where P0.Input: Sendable {
			do {
				let (o0, o1, o2, o3, o4) = try await self.p0.parse(&input)
				return try await (o0, o1, o2, o3, o4, self.p1.parse(&input))
				} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct Take7<P0: AsyncParserProtocol, P1: AsyncParserProtocol, O0, O1, O2, O3, O4, O5>: AsyncParserProtocol where P0.Input == P1.Input, P0.Output == (O0, O1, O2, O3, O4, O5) {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
				self.p0 = p0
				self.p1 = p1
		}

		@inlinable
		public func parse(_ input: inout P0.Input) async rethrows -> (O0, O1, O2, O3, O4, O5, P1.Output) where P0.Input: Sendable {
			do {
				let (o0, o1, o2, o3, o4, o5) = try await self.p0.parse(&input)
				return try await (o0, o1, o2, o3, o4, o5, self.p1.parse(&input))
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct Take8<P0: AsyncParserProtocol, P1: AsyncParserProtocol, O0, O1, O2, O3, O4, O5, O6>: AsyncParserProtocol where P0.Input == P1.Input, P0.Output == (O0, O1, O2, O3, O4, O5, O6) {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
			self.p0 = p0
			self.p1 = p1
		}

		@inlinable public func parse(_ input: inout P0.Input) async rethrows -> (O0, O1, O2, O3, O4, O5, O6, P1.Output)  where P0.Input: Sendable {
			do {
				let (o0, o1, o2, o3, o4, o5, o6) = try await self.p0.parse(&input)
				return try await (o0, o1, o2, o3, o4, o5, o6, self.p1.parse(&input))
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct Take9<P0: AsyncParserProtocol, P1: AsyncParserProtocol, O0, O1, O2, O3, O4, O5, O6, O7>: AsyncParserProtocol where P0.Input == P1.Input, P0.Output == (O0, O1, O2, O3, O4, O5, O6, O7) {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
			self.p0 = p0
			self.p1 = p1
		}

		@inlinable public func parse(_ input: inout P0.Input) async rethrows -> (O0, O1, O2, O3, O4, O5, O6, O7, P1.Output) where P0.Input: Sendable {
			do {
				let (o0, o1, o2, o3, o4, o5, o6, o7) = try await self.p0.parse(&input)
				return try await (o0, o1, o2, o3, o4, o5, o6, o7, self.p1.parse(&input))
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct Take10<P0: AsyncParserProtocol, P1: AsyncParserProtocol, O0, O1, O2, O3, O4, O5, O6, O7, O8>: AsyncParserProtocol where P0.Input == P1.Input, P0.Output == (O0, O1, O2, O3, O4, O5, O6, O7, O8) {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
			self.p0 = p0
			self.p1 = p1
		}

		@inlinable
		public func parse(_ input: inout P0.Input) async rethrows -> (O0, O1, O2, O3, O4, O5, O6, O7, O8, P1.Output)  where P0.Input: Sendable {
			do {
				let (o0, o1, o2, o3, o4, o5, o6, o7, o8) = try await self.p0.parse(&input)
				return try await (o0, o1, o2, o3, o4, o5, o6, o7, o8, self.p1.parse(&input))
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}
}

extension AsyncParserBuilder.SkipFirst: AsyncParserPrinterProtocol where P0: AsyncParserPrinterProtocol, P1: AsyncParserPrinterProtocol {
	@inlinable
	public func print(_ output: P1.Output, into input: inout P0.Input) async rethrows {
		try await self.p1.print(output, into: &input)
		try await self.p0.print(into: &input)
	}
}

extension AsyncParserBuilder.SkipSecond: AsyncParserPrinterProtocol where P0: AsyncParserPrinterProtocol, P1: AsyncParserPrinterProtocol {
	@inlinable
	public func print(_ output: P0.Output, into input: inout P0.Input) async rethrows {
		try await self.p1.print(into: &input)
		try await self.p0.print(output, into: &input)
	}
}

extension AsyncParserBuilder.Take2: AsyncParserPrinterProtocol where P0: AsyncParserPrinterProtocol, P1: AsyncParserPrinterProtocol {
	@inlinable
	public func print(_ output: (P0.Output, P1.Output), into input: inout P0.Input) async rethrows {
		try await self.p1.print(output.1, into: &input)
		try await self.p0.print(output.0, into: &input)
	}
}

extension AsyncParserBuilder.Take3: AsyncParserPrinterProtocol where P0: AsyncParserPrinterProtocol, P1: AsyncParserPrinterProtocol {
	@inlinable
	public func print(_ output: (O0, O1, P1.Output), into input: inout P0.Input) async rethrows {
		try await self.p1.print(output.2, into: &input)
		try await self.p0.print((output.0, output.1), into: &input)
	}
}

extension AsyncParserBuilder.Take4: AsyncParserPrinterProtocol where P0: AsyncParserPrinterProtocol, P1: AsyncParserPrinterProtocol {
	@inlinable
	public func print(_ output: (O0, O1, O2, P1.Output), into input: inout P0.Input) async rethrows {
		try await self.p1.print(output.3, into: &input)
		try await self.p0.print((output.0, output.1, output.2), into: &input)
	}
}

extension AsyncParserBuilder.Take5: AsyncParserPrinterProtocol where P0: AsyncParserPrinterProtocol, P1: AsyncParserPrinterProtocol {
	@inlinable
	public func print(_ output: (O0, O1, O2, O3, P1.Output), into input: inout P0.Input) async rethrows {
		try await self.p1.print(output.4, into: &input)
		try await self.p0.print((output.0, output.1, output.2, output.3), into: &input)
	}
}

extension AsyncParserBuilder.Take6: AsyncParserPrinterProtocol where P0: AsyncParserPrinterProtocol, P1: AsyncParserPrinterProtocol {
	@inlinable
	public func print(_ output: (O0, O1, O2, O3, O4, P1.Output), into input: inout P0.Input) async rethrows {
		try await self.p1.print(output.5, into: &input)
		try await self.p0.print((output.0, output.1, output.2, output.3, output.4), into: &input)
	}
}

extension AsyncParserBuilder.Take7: AsyncParserPrinterProtocol where P0: AsyncParserPrinterProtocol, P1: AsyncParserPrinterProtocol {
	@inlinable
	public func print(_ output: (O0, O1, O2, O3, O4, O5, P1.Output), into input: inout P0.Input) async rethrows {
		try await self.p1.print(output.6, into: &input)
		try await self.p0.print((output.0, output.1, output.2, output.3, output.4, output.5), into: &input)
	}
}

extension AsyncParserBuilder.Take8: AsyncParserPrinterProtocol where P0: AsyncParserPrinterProtocol, P1: AsyncParserPrinterProtocol {
	@inlinable
	public func print(_ output: (O0, O1, O2, O3, O4, O5, O6, P1.Output), into input: inout P0.Input) async rethrows {
		try await self.p1.print(output.7, into: &input)
		try await self.p0.print(
			(output.0, output.1, output.2, output.3, output.4, output.5, output.6),
			into: &input
		)
	}
}

extension AsyncParserBuilder.Take9: AsyncParserPrinterProtocol where P0: AsyncParserPrinterProtocol, P1: AsyncParserPrinterProtocol {
	@inlinable
	public func print(_ output: (O0, O1, O2, O3, O4, O5, O6, O7, P1.Output), into input: inout P0.Input) async rethrows {
		try await self.p1.print(output.8, into: &input)
		try await self.p0.print(
			(output.0, output.1, output.2, output.3, output.4, output.5, output.6, output.7),
			into: &input
		)
	}
}

extension AsyncParserBuilder.Take10: AsyncParserPrinterProtocol where P0: AsyncParserPrinterProtocol, P1: AsyncParserPrinterProtocol {
	@inlinable
	public func print(_ output: (O0, O1, O2, O3, O4, O5, O6, O7, O8, P1.Output), into input: inout P0.Input) async rethrows {
		try await self.p1.print(output.9, into: &input)
		try await self.p0.print(
			(output.0, output.1, output.2, output.3, output.4, output.5, output.6, output.7, output.8),
			into: &input
		)
	}
}

extension AsyncParserBuilder where Input == Substring {
	@_disfavoredOverload
	public static func buildExpression<P: AsyncParserProtocol>(_ expression: P) async -> From<Conversions.SubstringToUTF8ViewIso, Substring.UTF8View, P> where P.Input == Substring.UTF8View {
		From(.utf8) {
			expression
		}
	}
}

extension AsyncParserBuilder where Input == Substring.UTF8View {
	@_disfavoredOverload
	public static func buildExpression<P: AsyncParserProtocol>(_ expression: P) async -> P where P.Input == Substring.UTF8View {
		expression
	}
}
