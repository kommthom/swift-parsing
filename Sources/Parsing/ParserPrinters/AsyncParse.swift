//
//  AsyncParse.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 03.09.24.
//

public struct AsyncParse<Input: Sendable, Parsers: AsyncParserProtocol>: AsyncParserProtocol where Parsers.Input == Input {
	public let parsers: Parsers

	@inlinable
	public init(input inputType: Input.Type = Input.self, @AsyncParserBuilder<Input> with build: @Sendable () -> Parsers) {
		self.parsers = build()
	}

	@inlinable
	public init<Upstream: Sendable, NewOutput: Sendable>(input inputType: Input.Type = Input.self, _ transform: @escaping @Sendable (Upstream.Output) async -> NewOutput, @AsyncParserBuilder<Input> with build: @Sendable () async -> Upstream) async where Parsers == Parsing.Parsers.AsyncMap<Upstream, NewOutput> {
		self.parsers = await build().map(transform)
	}

	@inlinable
	public init<Upstream: Sendable, NewOutput: Sendable> (input inputType: Input.Type = Input.self, _ output: NewOutput, @AsyncParserBuilder<Input> with build: @Sendable () async -> Upstream) async where Parsers == Parsing.Parsers.AsyncMapConstant<Upstream, NewOutput> {
		self.parsers = await build().map { output }
	}

	@inlinable
	public init<Upstream: Sendable, Downstream: Sendable>(input inputType: Input.Type = Input.self, _ conversion: Downstream, @AsyncParserBuilder<Input> with build: @Sendable () async -> Upstream) async where Parsers == Parsing.Parsers.AsyncMapConversion<Upstream, Downstream> {
		self.parsers = await build().map(conversion)
	}

	@inlinable
	public func parse(_ input: inout Parsers.Input) async rethrows -> Parsers.Output {
		try await self.parsers
			.parse(&input)
	}
}

extension AsyncParse: AsyncParserPrinterProtocol where Parsers: AsyncParserPrinterProtocol {
	@inlinable
	public func print(_ output: Parsers.Output, into input: inout Parsers.Input) async rethrows {
		try await self.parsers
			.print(output, into: &input)
	}
}
