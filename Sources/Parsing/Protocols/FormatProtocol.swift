//
//  FormatProtocol.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 06.09.24.
//

public typealias PrintingAlias<Input, Output> = @Sendable (Output, inout Input) throws -> Void // @Sendable (_ arg: Output) -> Input?
public typealias ParsingAlias<Input, Output> = @Sendable (inout Input) throws -> Output //@Sendable (_ arg: Input) -> ParsingResult<Input, Output>

public protocol FormatProtocol: ExpressibleByArrayLiteral, Sendable, _EmptyInitializable {
	associatedtype Input: TemplateProtocol
	associatedtype Output: Sendable // & _EmptyInitializable // & MonoidProtocol
	associatedtype Parser: ParserPrinterProtocol //AnyParserPrinter<Input, Output>

	var parser: Parser { get }
	
	init(_ parser: Parser)

	func parse(_ input: inout Input) throws -> Output
	func print(_ output: Output, into input: inout Input) throws -> Void
}

extension FormatProtocol where Parser == AnyParserPrinter<Input, Output> {
	@inlinable
	public init(parse: @escaping ParsingAlias<Input, Output>, print: @escaping PrintingAlias<Input, Output>) {
		self.init(
			AnyParserPrinter(
				parse: parse,
				print: print
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
}

extension FormatProtocol {
	/// A Format that always fails and doesn't print anything.
	public static var empty: Self {
		return .init()
	}

	@inlinable
	public static func <|> (lhs: Self, rhs: Self) -> Self {
		return .init(
			OneOf {
				lhs.parser
				rhs.parser
			} as! Self.Parser
		)
	}
	
	@inlinable
	public func map<Format: FormatProtocol, C: Sendable>(_ f: AnyConversion<Output, C>) -> Format where Format.Output == C, Format.Input == Input, Self.Parser.Output == Output {
		return .init(
			self.parser
				.map( // Parsers.MapConversion<Self, C> with parse and print
					f
				) as! Format.Parser
		)
	}
	
	@inlinable
	public static func <¢> <Format: FormatProtocol, B> (lhs: AnyConversion<Input, B>, rhs: Self) -> Format where Format.Input == B, Format.Output == Output, Self.Parser == AnyParserPrinter<Input, Output> {
		//<¢> <B: Sendable> (lhs: AnyConversion<Input, B>, rhs: AnyParserPrinter) -> AnyParserPrinter<B, Output>
		let parser = lhs
			<¢>
			rhs.parser
		return .init(parser as! Format.Parser)
	}
}

extension FormatProtocol {
	@inlinable
	public init(arrayLiteral elements: Self...) {
		self = elements
			.reduce(
				.empty,
				<|>
			)
	}
}
