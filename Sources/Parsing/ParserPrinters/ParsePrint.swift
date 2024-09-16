//
//  ParsePrint.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 03.09.24.
//

/// An entry to ``ParserBuilder`` syntax that requires the builder to be a printer.
///
/// Although you can build printers with the ``Parse`` entry point, as long as everything in the
/// builder context is a printer, it doesn't proper connote its intentions. By using ``ParsePrint``
/// you can make your intentions clearer:
///
/// ```swift
/// let welcoming = ParsePrint {
///   "Hello "
///   Int.parser()
///   "!"
/// }
///
/// try welcoming.parse("Hello 42!") // 42
/// try welcoming.print(1729) // "Hello 1729"
/// ```
///
/// The ``ParsePrint`` entry point can also help you catch errors earlier if you accidentally use
/// an operator that is not printer-friendly:
///
/// ```swift
/// let welcoming = ParsePrint {
///   "Hello "
///   Prefix { $0 != "!" }.map(String.init)
///   "!"
/// }
/// ```
///
/// > Generic struct `ParsePrint` requires that `Parsers.Map<Prefix<Substring>, String>` conform
/// > to `ParserPrinter`
///
/// `ParsePrint` is a type alias for the ``Parse`` parser with its underlying parser constrained to
/// ``ParserPrinter``.
public struct ParsePrint<Input: Sendable, ParserPrinters: ParserPrinterProtocol>: ParserPrinterProtocol where Input == ParserPrinters.Input {
	public let parserPrinters: ParserPrinters

	@inlinable
	public init(
		input inputType: Input.Type = Input.self,
		@ParserBuilder<Input> with build: @Sendable () -> ParserPrinters
	) {
		self.parserPrinters = build()
	}

	@inlinable
	public init<Upstream: Sendable, NewOutput: Sendable>(input inputType: Input.Type = Input.self, _ output: NewOutput, @ParserBuilder<Input> with build: @Sendable () -> Upstream) where ParserPrinters == Parsers.MapConstant<Upstream, NewOutput> {
		self.parserPrinters = build().map { output }
	}

	@inlinable
	public init<Upstream: SendableMarker, Downstream: SendableMarker>(input inputType: Input.Type = Input.self, _ conversion: Downstream, @ParserBuilder<Input> with build: @Sendable () -> Upstream) where ParserPrinters == Parsers.MapConversion<Upstream, Downstream> {
		self.parserPrinters = build().map(conversion)
	}

	@inlinable
	public func parse(_ input: inout ParserPrinters.Input) rethrows -> ParserPrinters.Output {
		try self.parserPrinters.parse(&input)
	}

	@inlinable
	public func print(_ output: ParserPrinters.Output, into input: inout ParserPrinters.Input) throws {
		try self.parserPrinters.print(output, into: &input)
	}
}
