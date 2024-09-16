//
//  ParserBuilder.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 31.08.24.
//

import Foundation

/// A custom parameter attribute that constructs parsers from closures. The constructed parser
/// runs a number of parsers, one after the other, and accumulates their outputs.
///
/// The ``Parse`` parser acts as an entry point into `@ParserBuilder` syntax, where you can list
/// all of the parsers you want to run. For example, to parse two comma-separated integers:
///
/// ```swift
/// try Parse {
///   Int.parser()
///   ","
///   Int.parser()
/// }
/// .parse("123,456") // (123, 456)
/// ```
@resultBuilder
public enum ParserBuilder<Input: Sendable>: Sendable {
	@inlinable
	public static func buildBlock() -> Always<Input, Void> {
		Always(())
	}

	@inlinable
	public static func buildBlock<P: ParserProtocol>(_ parser: P) -> P where P.Input == Input {
		parser
	}

	@inlinable
	public static func buildArray<P: ParserProtocol>(_ parsers: [P]) -> Parsers.ManyOfOne<P> where P.Input == Input {
		.init(parsers)
	}
	
	/// Provides support for `if`-`else` statements in ``ParserBuilder`` blocks, producing a
	/// conditional parser for the `if` branch.
	///
	/// ```swift
	/// Parse {
	///   "Hello"
	///   if shouldParseComma {
	///     ", "
	///   } else {
	///     " "
	///   }
	///   Rest()
	/// }
	/// ```
	@inlinable
	public static func buildEither<TrueParser, FalseParser>(first parser: TrueParser) -> Parsers.Conditional<TrueParser, FalseParser> where TrueParser.Input == Input, FalseParser.Input == Input {
		.first(parser)
	}

	/// Provides support for `if`-`else` statements in ``ParserBuilder`` blocks, producing a
	/// conditional parser for the `else` branch.
	///
	/// ```swift
	/// Parse {
	///   "Hello"
	///   if shouldParseComma {
	///     ", "
	///   } else {
	///     " "
	///   }
	///   Rest()
	/// }
	/// ```
	@inlinable
	public static func buildEither<TrueParser, FalseParser>(second parser: FalseParser) -> Parsers.Conditional<TrueParser, FalseParser> where TrueParser.Input == Input, FalseParser.Input == Input {
		.second(parser)
	}

	@inlinable
	public static func buildExpression<P: ParserProtocol>(_ parser: P) -> P where P.Input == Input {
		parser
	}

	/// Provides support for `if` statements in ``ParserBuilder`` blocks, producing an optional
	/// parser.
	@inlinable
	public static func buildIf<P: ParserProtocol>(_ parser: P?) -> P? where P.Input == Input {
		parser
	}

	/// Provides support for `if` statements in ``ParserBuilder`` blocks, producing a void parser for
	/// a given void parser.
	///
	/// ```swift
	/// Parse {
	///   "Hello"
	///   if shouldParseComma {
	///     ","
	///   }
	///   " "
	///   Rest()
	/// }
	/// ```
	@inlinable
	public static func buildIf<P>(_ parser: P?) -> Parsers.OptionalVoid<P> where P.Input == Input {
		.init(wrapped: parser)
	}

	/// Provides support for `if #available` statements in ``ParserBuilder`` blocks, producing an
	/// optional parser.
	@inlinable
	public static func buildLimitedAvailability<P: ParserProtocol>(_ parser: P?) -> P? where P.Input == Input {
		parser
	}

	/// Provides support for `if #available` statements in ``ParserBuilder`` blocks, producing a void
	/// parser for a given void parser.
	@inlinable
	public static func buildLimitedAvailability<P>(_ parser: P?) -> Parsers.OptionalVoid<P> where P.Input == Input {
		.init(wrapped: parser)
	}

	@inlinable
	public static func buildPartialBlock<P: ParserProtocol>(first: P) -> P where P.Input == Input {
		first
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: ParserProtocol, P1: ParserProtocol>(accumulated: P0, next: P1) -> SkipFirst<P0, P1> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@inlinable
	public static func buildPartialBlock<P0: ParserProtocol, P1: ParserProtocol>(accumulated: P0, next: P1) -> SkipSecond<P0, P1> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: ParserProtocol, P1: ParserProtocol>(accumulated: P0, next: P1) -> Take2<P0, P1> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: ParserProtocol, P1: ParserProtocol, O0, O1>(accumulated: P0, next: P1) -> Take3<P0, P1, O0, O1> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: ParserProtocol, P1: ParserProtocol, O0, O1, O2>(accumulated: P0, next: P1) -> Take4<P0, P1, O0, O1, O2> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: ParserProtocol, P1: ParserProtocol, O0, O1, O2, O3>(accumulated: P0, next: P1) -> Take5<P0, P1, O0, O1, O2, O3> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: ParserProtocol, P1: ParserProtocol, O0, O1, O2, O3, O4>(accumulated: P0, next: P1) -> Take6<P0, P1, O0, O1, O2, O3, O4> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: ParserProtocol, P1: ParserProtocol, O0, O1, O2, O3, O4, O5>(accumulated: P0, next: P1) -> Take7<P0, P1, O0, O1, O2, O3, O4, O5> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: ParserProtocol, P1: ParserProtocol, O0, O1, O2, O3, O4, O5, O6>(accumulated: P0, next: P1) -> Take8<P0, P1, O0, O1, O2, O3, O4, O5, O6> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: ParserProtocol, P1: ParserProtocol, O0, O1, O2, O3, O4, O5, O6, O7>(accumulated: P0, next: P1) -> Take9<P0, P1, O0, O1, O2, O3, O4, O5, O6, O7> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	@_disfavoredOverload
	@inlinable
	public static func buildPartialBlock<P0: ParserProtocol, P1: ParserProtocol, O0, O1, O2, O3, O4, O5, O6, O7, O8>(accumulated: P0, next: P1) -> Take10<P0, P1, O0, O1, O2, O3, O4, O5, O6, O7, O8> where P0.Input == Input, P1.Input == Input {
		.init(accumulated, next)
	}

	public struct SkipFirst<P0: ParserProtocol, P1: ParserProtocol>: ParserProtocol where P0.Input == P1.Input, P0.Output == Void {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
			self.p0 = p0
			self.p1 = p1
		}

		@inlinable
		public func parse(_ input: inout P0.Input) rethrows -> P1.Output where P0.Input: Sendable {
			do {
				try self.p0.parse(&input)
				return try self.p1.parse(&input)
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct SkipSecond<P0: ParserProtocol, P1: ParserProtocol>: ParserProtocol where P0.Input == P1.Input, P1.Output == Void {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
			self.p0 = p0
			self.p1 = p1
		}

		@inlinable
		public func parse(_ input: inout P0.Input) rethrows -> P0.Output where P0.Input: Sendable {
			do {
				let o0 = try self.p0.parse(&input)
				try self.p1.parse(&input)
				return o0
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct Take2<P0: ParserProtocol, P1: ParserProtocol>: ParserProtocol
	where P0.Input == P1.Input {
		@usableFromInline let p0: P0, p1: P1

		@usableFromInline init(_ p0: P0, _ p1: P1) {
		  self.p0 = p0
		  self.p1 = p1
		}

		@inlinable public func parse(_ input: inout P0.Input) rethrows -> (P0.Output, P1.Output) where P0.Input: Sendable {
			do {
				return try (
					self.p0.parse(&input),
					self.p1.parse(&input)
				)
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct Take3<P0: ParserProtocol, P1: ParserProtocol, O0, O1>: ParserProtocol where P0.Input == P1.Input, P0.Output == (O0, O1) {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
			self.p0 = p0
			self.p1 = p1
		}

		@inlinable
		public func parse(_ input: inout P0.Input) rethrows -> (O0, O1, P1.Output) where P0.Input: Sendable {
			do {
				let (o0, o1) = try self.p0.parse(&input)
				return try (o0, o1, self.p1.parse(&input))
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct Take4<P0: ParserProtocol, P1: ParserProtocol, O0, O1, O2>: ParserProtocol where P0.Input == P1.Input, P0.Output == (O0, O1, O2) {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
			self.p0 = p0
			self.p1 = p1
		}

		@inlinable
		public func parse(_ input: inout P0.Input) rethrows -> (O0, O1, O2, P1.Output) where P0.Input: Sendable {
			do {
				let (o0, o1, o2) = try self.p0.parse(&input)
				return try (o0, o1, o2, self.p1.parse(&input))
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct Take5<P0: ParserProtocol, P1: ParserProtocol, O0, O1, O2, O3>: ParserProtocol where P0.Input == P1.Input, P0.Output == (O0, O1, O2, O3) {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
			self.p0 = p0
			self.p1 = p1
		}

		@inlinable
		public func parse(_ input: inout P0.Input) rethrows -> (O0, O1, O2, O3, P1.Output) where P0.Input: Sendable {
			do {
				let (o0, o1, o2, o3) = try self.p0.parse(&input)
				return try (o0, o1, o2, o3, self.p1.parse(&input))
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct Take6<P0: ParserProtocol, P1: ParserProtocol, O0, O1, O2, O3, O4>: ParserProtocol where P0.Input == P1.Input, P0.Output == (O0, O1, O2, O3, O4) {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
			self.p0 = p0
			self.p1 = p1
		}

		@inlinable
		public func parse(_ input: inout P0.Input) rethrows -> (O0, O1, O2, O3, O4, P1.Output) where P0.Input: Sendable {
			do {
				let (o0, o1, o2, o3, o4) = try self.p0.parse(&input)
				return try (o0, o1, o2, o3, o4, self.p1.parse(&input))
				} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct Take7<P0: ParserProtocol, P1: ParserProtocol, O0, O1, O2, O3, O4, O5>: ParserProtocol where P0.Input == P1.Input, P0.Output == (O0, O1, O2, O3, O4, O5) {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
				self.p0 = p0
				self.p1 = p1
		}

		@inlinable
		public func parse(_ input: inout P0.Input) rethrows -> (O0, O1, O2, O3, O4, O5, P1.Output) where P0.Input: Sendable {
			do {
				let (o0, o1, o2, o3, o4, o5) = try self.p0.parse(&input)
				return try (o0, o1, o2, o3, o4, o5, self.p1.parse(&input))
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct Take8<P0: ParserProtocol, P1: ParserProtocol, O0, O1, O2, O3, O4, O5, O6>: ParserProtocol where P0.Input == P1.Input, P0.Output == (O0, O1, O2, O3, O4, O5, O6) {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
			self.p0 = p0
			self.p1 = p1
		}

		@inlinable public func parse(_ input: inout P0.Input) rethrows -> (O0, O1, O2, O3, O4, O5, O6, P1.Output)  where P0.Input: Sendable {
			do {
				let (o0, o1, o2, o3, o4, o5, o6) = try self.p0.parse(&input)
				return try (o0, o1, o2, o3, o4, o5, o6, self.p1.parse(&input))
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct Take9<P0: ParserProtocol, P1: ParserProtocol, O0, O1, O2, O3, O4, O5, O6, O7>: ParserProtocol where P0.Input == P1.Input, P0.Output == (O0, O1, O2, O3, O4, O5, O6, O7) {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
			self.p0 = p0
			self.p1 = p1
		}

		@inlinable public func parse(_ input: inout P0.Input) rethrows -> (O0, O1, O2, O3, O4, O5, O6, O7, P1.Output) where P0.Input: Sendable {
			do {
				let (o0, o1, o2, o3, o4, o5, o6, o7) = try self.p0.parse(&input)
				return try (o0, o1, o2, o3, o4, o5, o6, o7, self.p1.parse(&input))
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}

	public struct Take10<P0: ParserProtocol, P1: ParserProtocol, O0, O1, O2, O3, O4, O5, O6, O7, O8>: ParserProtocol where P0.Input == P1.Input, P0.Output == (O0, O1, O2, O3, O4, O5, O6, O7, O8) {
		@usableFromInline
		let p0: P0, p1: P1
		@usableFromInline
		init(_ p0: P0, _ p1: P1) {
			self.p0 = p0
			self.p1 = p1
		}

		@inlinable
		public func parse(_ input: inout P0.Input) rethrows -> (O0, O1, O2, O3, O4, O5, O6, O7, O8, P1.Output)  where P0.Input: Sendable {
			do {
				let (o0, o1, o2, o3, o4, o5, o6, o7, o8) = try self.p0.parse(&input)
				return try (o0, o1, o2, o3, o4, o5, o6, o7, o8, self.p1.parse(&input))
			} catch { throw ParsingError.wrap(error, at: input) }
		}
	}
}

extension ParserBuilder.SkipFirst: ParserPrinterProtocol & SendableMarker where P0: ParserPrinterProtocol, P1: ParserPrinterProtocol {
	@inlinable
	public func print(_ output: P1.Output, into input: inout P0.Input) rethrows {
		try self.p1.print(output, into: &input)
		try self.p0.print(into: &input)
	}
}

extension ParserBuilder.SkipSecond: ParserPrinterProtocol & SendableMarker where P0: ParserPrinterProtocol, P1: ParserPrinterProtocol {
	@inlinable
	public func print(_ output: P0.Output, into input: inout P0.Input) rethrows {
		try self.p1.print(into: &input)
		try self.p0.print(output, into: &input)
	}
}

extension ParserBuilder.Take2: ParserPrinterProtocol  & SendableMarker where P0: ParserPrinterProtocol, P1: ParserPrinterProtocol {
	@inlinable
	public func print(_ output: (P0.Output, P1.Output), into input: inout P0.Input) rethrows {
		try self.p1.print(output.1, into: &input)
		try self.p0.print(output.0, into: &input)
	}
}

extension ParserBuilder.Take3: ParserPrinterProtocol & SendableMarker where P0: ParserPrinterProtocol, P1: ParserPrinterProtocol {
	@inlinable
	public func print(_ output: (O0, O1, P1.Output), into input: inout P0.Input) rethrows {
		try self.p1.print(output.2, into: &input)
		try self.p0.print((output.0, output.1), into: &input)
	}
}

extension ParserBuilder.Take4: ParserPrinterProtocol & SendableMarker where P0: ParserPrinterProtocol, P1: ParserPrinterProtocol {
	@inlinable
	public func print(_ output: (O0, O1, O2, P1.Output), into input: inout P0.Input) rethrows {
		try self.p1.print(output.3, into: &input)
		try self.p0.print((output.0, output.1, output.2), into: &input)
	}
}

extension ParserBuilder.Take5: ParserPrinterProtocol & SendableMarker where P0: ParserPrinterProtocol, P1: ParserPrinterProtocol {
	@inlinable
	public func print(_ output: (O0, O1, O2, O3, P1.Output), into input: inout P0.Input) rethrows {
		try self.p1.print(output.4, into: &input)
		try self.p0.print((output.0, output.1, output.2, output.3), into: &input)
	}
}

extension ParserBuilder.Take6: ParserPrinterProtocol & SendableMarker where P0: ParserPrinterProtocol, P1: ParserPrinterProtocol {
	@inlinable
	public func print(_ output: (O0, O1, O2, O3, O4, P1.Output), into input: inout P0.Input) rethrows {
		try self.p1.print(output.5, into: &input)
		try self.p0.print((output.0, output.1, output.2, output.3, output.4), into: &input)
	}
}

extension ParserBuilder.Take7: ParserPrinterProtocol & SendableMarker where P0: ParserPrinterProtocol, P1: ParserPrinterProtocol {
	@inlinable
	public func print(_ output: (O0, O1, O2, O3, O4, O5, P1.Output), into input: inout P0.Input) rethrows {
		try self.p1.print(output.6, into: &input)
		try self.p0.print((output.0, output.1, output.2, output.3, output.4, output.5), into: &input)
	}
}

extension ParserBuilder.Take8: ParserPrinterProtocol & SendableMarker where P0: ParserPrinterProtocol, P1: ParserPrinterProtocol {
	@inlinable
	public func print(_ output: (O0, O1, O2, O3, O4, O5, O6, P1.Output), into input: inout P0.Input) rethrows {
		try self.p1.print(output.7, into: &input)
		try self.p0.print(
			(output.0, output.1, output.2, output.3, output.4, output.5, output.6),
			into: &input
		)
	}
}

extension ParserBuilder.Take9: ParserPrinterProtocol & SendableMarker where P0: ParserPrinterProtocol, P1: ParserPrinterProtocol {
	@inlinable
	public func print(_ output: (O0, O1, O2, O3, O4, O5, O6, O7, P1.Output), into input: inout P0.Input) rethrows {
		try self.p1.print(output.8, into: &input)
		try self.p0.print(
			(output.0, output.1, output.2, output.3, output.4, output.5, output.6, output.7),
			into: &input
		)
	}
}

extension ParserBuilder.Take10: ParserPrinterProtocol & SendableMarker where P0: ParserPrinterProtocol, P1: ParserPrinterProtocol {
	@inlinable
	public func print(_ output: (O0, O1, O2, O3, O4, O5, O6, O7, O8, P1.Output), into input: inout P0.Input) rethrows {
		try self.p1.print(output.9, into: &input)
		try self.p0.print(
			(output.0, output.1, output.2, output.3, output.4, output.5, output.6, output.7, output.8),
			into: &input
		)
	}
}

extension ParserBuilder where Input == Substring {
	@_disfavoredOverload
	public static func buildExpression<P: ParserProtocol>(_ expression: P) -> From<Conversions.SubstringToUTF8ViewIso, Substring.UTF8View, P> where P.Input == Substring.UTF8View {
		From(.utf8) {
			expression
		}
	}
}

extension ParserBuilder where Input == Substring.UTF8View {
	@_disfavoredOverload
	public static func buildExpression<P: ParserProtocol>(_ expression: P) -> P where P.Input == Substring.UTF8View {
		expression
	}
}
