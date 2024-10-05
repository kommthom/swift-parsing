//
//  StringFormat.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 09.09.24.
//

import Thoms_Foundation

public struct StringFormat<Output: Sendable>: FormatProtocol {
	public typealias Input = StringTemplate
	public typealias Parser = AnyParserPrinter<Input, Output>
	public typealias Output = Output
	
	public let parser: Parser
	public let format: Format<Output>

	@inlinable
	public init() {
		self.init(stringLiteral: String.empty)
	}
	
	@inlinable
	public init(_ parser: Parser) {
		self.parser = parser
		self.format = Format<Output>(
			AnyParserPrinter<Template, Output>(
				parse: { template in
					var stringTemplate = StringTemplate(
						template: template
					)
					let match = try parser.parse(
						&stringTemplate
					)
					template = stringTemplate.template
					return match
				},
				print: { output, template  in
					var stringTemplate = StringTemplate(
						template: template
					)
					try parser.print(output, into: &stringTemplate)
					template = stringTemplate.template
				}
			)
		)
	}

	@inlinable
	public func parse(_ input: inout Input) throws -> Output {
		return try parser.parse(input)
	}

	@inlinable
	public func print(_ output: Output, into input: inout Input) throws -> Void {
		try self.parser.print(output, into: &input)
	}
	
	@inlinable
	public func match(_ template: Input) throws -> Output? {
		try (
				self
				 <%
				 StringFormat
				.end!
			)
			.parser
			.parse(
				template
			)
	}

	@inlinable
	public func render(_ output: Output) throws -> String? {
		var input: StringTemplate = .empty
		try self
			.print(
				output,
				into: &input
			)
		return input.render()
	}
}

extension StringFormat: ExpressibleByStringInterpolation {
	@inlinable
	public init(stringLiteral value: String) {
		self.init( // from parser
			slit(
				String(
					value
				)
			)
			.map(.any))
	}

	public init(stringInterpolation: StringInterpolation) {
		if stringInterpolation
			.parsers
			.isEmpty {
			self.init(stringLiteral: .empty)
		} else {
			let parser: AnyParserPrinter<StringTemplate, Sendable> = reduce( //<Output: Sendable>(parsers: [(AnyParserPrinter<Template, Output>, Any.Type)]) -> AnyParserPrinter<StringTemplate, Output>
				parsers: stringInterpolation.parsers
			)!
			self.init(
				parser
					.map(
						.any
					)
			)
		}
	}

	public class StringInterpolation: StringInterpolationProtocol {
		private(set) var parsers: [(AnyParserPrinter<StringTemplate, Sendable>, Any.Type)] = []

		@inlinable
		public required init(literalCapacity: Int, interpolationCount: Int) {}

		public func appendParser(_ parser: AnyParserPrinter<StringTemplate, Output>) {
			parsers
				.append(
					(
						parser
							.map(
								.any
							)
						,
						Output.self
						)
				)
		}

		@inlinable
		public func appendLiteral(_ literal: String) {
			appendParser(
				slit(
					literal
				)
				.map(
					.any
				)
			)
		}

		@inlinable
		public func appendInterpolation(_ paramIso: AnyConversion<String, Output>) where Output: StringFormattingProtocol {
			appendParser(
				sparam(
					paramIso
				)
			)
		}

		@inlinable
		public func appendInterpolation(_ paramIso: AnyConversion<String, Output>, index: UInt) where Output: StringFormattingProtocol {
			appendParser(
				sparam(
					paramIso,
					index: index
				)
			)
		}
	}

}

extension StringFormat {
	@inlinable
	/// Processes with the left and right side Formats, and if they succeed returns the pair of their results.
	public static func <%> <B: Sendable> (lhs: StringFormat, rhs: StringFormat<B>) -> StringFormat<(Output, B)> {
		return .init(
			lhs.parser
			<%>
			rhs.parser
		)
	}

	@inlinable
	/// Processes with the left and right side Formats, discarding the result of the left side.
	public static func %> (x: StringFormat<Unit>, y: StringFormat) -> StringFormat {
		return .init(
//			x.parser
//			%>
			y.parser
		)
	}
}

extension StringFormat where Output == Unit {
	@inlinable
	/// Processes with the left and right Formats, discarding the result of the right side.
	public static func <% <B>(x: StringFormat<B>, y: StringFormat) -> StringFormat<B> {
		return .init(
			x.parser
//			<%
//			y.parser
		)
	}
}

extension StringFormat {
	@inlinable
	public static var end: StringFormat<Unit>? {
		return StringFormat<Unit>(
			AnyParserPrinter<StringTemplate, Unit>(
				parse: { template in
					template = .empty
					return unit
				},
				print: { _, template in
					template = .empty
				}
			)
		)
	}
}

extension StringFormat {
	@inlinable
	public func render<A1: Sendable, B: Sendable>(_ a: A1, _ b: B) throws -> String? where Output == (A1, B) {
		return try render(
			(
				a,
				b
			)
		)
	}
}

extension StringFormat {
	@inlinable
	public func render<A1: Sendable, B: Sendable, C: Sendable>(_ a: A1, _ b: B, _ c: C) throws -> String? where Output == (A1, (B, C)) {
	return try render(
		parenthesize(
			a,
			b,
			c
		)
	)
	}
}
