//Input
//  Format.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 06.09.24.
//
//

import Thoms_Foundation

public struct Format<Output: Sendable>: FormatProtocol, ExpressibleByStringLiteral {
	public typealias Input = Template
	public typealias Output = Output
	public typealias Parser = AnyParserPrinter<Input, Output>
	public typealias StringLiteralType = String //_ExpressibleByBuiltinStringLiteral
	
	public let parser: Parser

	@inlinable
	public init() {
		self.init(stringLiteral: .empty)
	}
	
	@inlinable
	public init(_ parser: Parser) {
		self.parser = parser
	}

	@inlinable
	public init(stringLiteral value: StringLiteralType) {
		self.init(
			lit(
				String(
					value
				)
			)
			.map(
				AnyConversion
					.any
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
	public func match(_ template: Template) throws -> Output {
		return try (
				self
				<%
				Format
					.end
			)
			.parser
			.parse(
				template
			)
	}

	@inlinable
	public func render(_ output: Output) throws -> String {
		var template: Template = Template.empty
		try self
			.parser
			.print(
				output,
				into: &template
			)
		return template.render()
	}

}

extension Format: ExpressibleByStringInterpolation {
	public init(stringInterpolation: StringInterpolation) {
		if stringInterpolation.parsers.isEmpty {
			self.init()
		} else {
			if let parser: AnyParserPrinter<Template, Sendable> = reduce(
				parsers: stringInterpolation
					.parsers
			) {
				self.init(
					parser
						.map(
							.any
						)
				)
			}  else { self.init() }
		}
	}

	public class StringInterpolation: StringInterpolationProtocol {
		private(set) var parsers: [(AnyParserPrinter<Template, Sendable>, Any.Type)] = []

		@inlinable
		public required init(literalCapacity: Int, interpolationCount: Int) {}

		public func appendParser(_ parser: AnyParserPrinter<Template, Output>) {
			if let parser = parser as? AnyParserPrinter<Template, Sendable> {
				parsers
					.append(
						(
							parser,
							Output.self
						)
					)
			} else {
				parsers
					.append(
						(
							parser
								.map(
									.any
								),
							Output.self
						)
					)
			}
		}

		@inlinable
		public func appendLiteral(_ literal: String) {
			guard literal.isEmpty == false else { return }
			appendParser(
				lit(
					literal
				)
				.map(
					.any
				)
			)
		}

		@inlinable
		public func appendInterpolation(_ paramIso: AnyConversion<String, Output>) throws -> Void {
			appendParser(
				try param(
					paramIso
				)
			)
		}
	}
}

extension Format {
	/// Processes with the left and right side Formats, and if they succeed returns the pair of their results.
	@inlinable
	public static func <%> <B> (lhs: Format, rhs: Format<B>) -> Format<(Output, B)> {
		return .init(lhs.parser <%> rhs.parser)
	}

	/// Processes with the left and right side Formats, discarding the result of the left side.
	@inlinable
	public static func %> (x: Format, y: Format<Unit>) -> Format {
		return .init(
			x.parser
//			%>
//			y.parser
		)
	}
}

extension Format where Output == Unit {
	/// Processes with the left and right Formats, discarding the result of the right side.
	@inlinable
	public static func <% <B>(x: Format<B>, y: Format) -> Format<B> {
		return .init(
			x.parser
//			<%
//			y.parser
		)
	}
}

extension Format {
	public static var end: Format<Unit> {
		return Format<Unit>(
			AnyParserPrinter<Template, Unit>(
				parse: { template throws in
					guard !template.isEmpty else { throw ParsingError.expectedInput("template nil", at: template) }
					return unit
				},
				print: { _, template in
					template = .empty
				}
			)
		)
	}
}

@inlinable
public func any() -> AnyParserPrinter<Template, Sendable> {
	let f = AnyConversion<String, Sendable>.any
	return try! param(
		f
	)
}

@inlinable
public func any() -> Format<Sendable> {
	return Format(
		any()
	)
}

//extension Format {
//    public func render<A1, B>(_ a: A1, _ b: B) -> String? where Output == (A1, B) {
//        return self.render(
//            (a, b)
//        )
//    }
//
//    public func render<A1: Sendable, B: Sendable>(templateFor a: A1, _ b: B) -> String? where Output == (A1, B) {
//        return self.parser.template((a, b)).flatMap { $0.render() }
//    }
//}
//
//extension Format {
//	public func render<A1: Sendable, B: Sendable, C: Sendable>(_ a: A1, _ b: B, _ c: C) -> String? where Output == (A1, (B, C)) {
//		return self.render(
//			parenthesize(
//				a,
//				b, c
//			)
//		)
//	}
//
//	public func render<A1: Sendable, B: Sendable, C: Sendable>(_ a: (A1, B, C)) -> String? where Output == (A1, (B, C)) {
//		return self.render(
//			parenthesize(
//				a.0,
//				a.1,
//				a.2
//			)
//		)
//	}
//
//    public func template<A1: Sendable, B: Sendable, C: Sendable>(for a: A1, _ b: B, _ c: C) -> Template? where Output == (A1, (B, C)) {
//        return self.format(
//            parenthesize(
//                a,
//                b,
//                c
//            )
//        )
//    }
//
//    public func template<A1: Sendable, B: Sendable, C: Sendable>(for a: (A1, B, C)) -> Template? where Output == (A1, (B, C)) {
//        return self.format(
//            parenthesize(
//                a.0,
//                a.1,
//                a.2
//            )
//        )
//    }
//
//    public func render<A1: Sendable, B: Sendable, C: Sendable>(templateFor a: A1, _ b: B, _ c: C) -> String? where Output == (A1, (B, C)) {
//        return self.parser
//            .template(
//                parenthesize(
//                    a,
//                    b,
//                    c
//                )
//            )
//            .flatMap { $0.render() }
//    }
//
//    public func render<A1: Sendable, B: Sendable, C: Sendable>(templateFor a: (A1, B, C)) -> String? where Output == (A1, (B, C)) {
//        return self.parser
//            .template(
//                parenthesize(
//                    a.0,
//                    a.1,
//                    a.2
//                )
//            )
//            .flatMap { $0.render() }
//    }
//
//	public func match<A1: Sendable, B: Sendable, C: Sendable>(_ template: Template) -> (A1, B, C)? where Output == (A1, (B, C)) {
//		return match(
//			template
//		)
//		.flatMap(flatten)
//	}
//
//}
//
//extension Format {
//	public func render<A1: Sendable, B: Sendable, C: Sendable, D: Sendable>(_ a: A1, _ b: B, _ c: C, _ d: D) -> String? where Output == (A1, (B, (C, D))) {
//		return self.render(
//			parenthesize(
//				a,
//				b,
//				c,
//				d
//			)
//		)
//	}
//
//	public func render<A1: Sendable, B: Sendable, C: Sendable, D: Sendable>(_ a: (A1, B, C, D)) -> String? where Output == (A1, (B, (C, D))) {
//		return self.render(
//			parenthesize(
//				a.0,
//				a.1,
//				a.2,
//				a.3
//			)
//		)
//	}
//
//    public func template<A1: Sendable, B: Sendable, C: Sendable, D: Sendable>(for a: A1, _ b: B, _ c: C, _ d: D) -> Template? where Output == (A1, (B, (C, D))) {
//        return self.format(
//            parenthesize(
//                a,
//                b,
//                c,
//                d
//            )
//        )
//    }
//
//    public func template<A1: Sendable, B: Sendable, C: Sendable, D: Sendable>(for a: (A1, B, C, D)) -> Template? where Output == (A1, (B, (C, D))) {
//        return self.format(
//            parenthesize(
//                a.0,
//                a.1,
//                a.2,
//                a.3
//            )
//        )
//    }
//
//    public func render<A1: Sendable, B: Sendable, C: Sendable, D: Sendable>(templateFor a: A1, _ b: B, _ c: C, _ d: D) -> String? where Output == (A1, (B, (C, D))) {
//        return self.parser
//            .template(
//                parenthesize(
//                    a,
//                    b,
//                    c,
//                    d
//                )
//            )
//            .flatMap { $0.render() }
//    }
//
//    public func render<A1: Sendable, B: Sendable, C: Sendable, D: Sendable>(templateFor a: (A1, B, C, D)) -> String? where Output == (A1, (B, (C, D))) {
//        return self.parser
//            .template(
//                parenthesize(
//                    a.0,
//                    a.1,
//                    a.2,
//                    a.3
//                )
//            )
//            .flatMap { $0.render() }
//    }
//
//	public func match<A1: Sendable, B: Sendable, C: Sendable, D: Sendable>(_ template: Template) -> (A1, B, C, D)? where Output == (A1, (B, (C, D))) {
//		return match(
//			template
//		)
//		.flatMap(flatten)
//	}
//
//}
