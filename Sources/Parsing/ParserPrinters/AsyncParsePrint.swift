//
//  AsyncParsePrint.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 03.09.24.
//

public struct AsyncParsePrint<Input: Sendable, ParserPrinters: AsyncParserPrinterProtocol>: AsyncParserPrinterProtocol where Input == ParserPrinters.Input {
	public let parserPrinters: ParserPrinters

	@inlinable
	public init(
		input inputType: Input.Type = Input.self,
		@AsyncParserBuilder<Input> with build: @Sendable () async -> ParserPrinters
	) async {
		self.parserPrinters = await build()
	}

	@inlinable
	public init<Upstream: Sendable, NewOutput: Sendable>(
		input inputType: Input.Type = Input.self,
		_ output: NewOutput,
		@AsyncParserBuilder<Input> with build: @Sendable () async -> Upstream
	) async where ParserPrinters == Parsers.AsyncMapConstant<Upstream, NewOutput> {
		self.parserPrinters = await build().map { output }
	}

	@inlinable
	public init<Upstream: Sendable, Downstream: Sendable>(
		input inputType: Input.Type = Input.self,
		_ conversion: Downstream,
		@AsyncParserBuilder<Input> with build: @Sendable () async -> Upstream
	) async where ParserPrinters == Parsers.AsyncMapConversion<Upstream, Downstream> {
		self.parserPrinters = await build().map(conversion)
	}

	@inlinable
	public func parse(_ input: inout ParserPrinters.Input) async rethrows -> ParserPrinters.Output {
		try await self.parserPrinters.parse(&input)
	}

	@inlinable
	public func print(
		_ output: ParserPrinters.Output, into input: inout ParserPrinters.Input
	) async throws {
		try await self.parserPrinters.print(output, into: &input)
	}
}
