//
//  Skip.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

/// A parser that discards the output of another parser.
public struct Skip<Input: Sendable, Parsers: ParserProtocol>: ParserProtocol where Parsers.Input == Input {
	/// The parser from which this parser receives output.
	public let parsers: Parsers
	
	@inlinable
	public init(@ParserBuilder<Input> _ build: () -> Parsers) {
		self.parsers = build()
	}
	
	@inlinable
	public func parse(_ input: inout Parsers.Input) rethrows {
		_ = try self.parsers.parse(&input)
	}
}

extension Skip: ParserPrinterProtocol & SendableMarker where Parsers: ParserPrinterProtocol, Parsers.Output == Void {
	@inlinable
	public func print(_ output: (), into input: inout Parsers.Input) rethrows {
		try self.parsers.print(into: &input)
	}
}

extension Parsers {
	public typealias Skip = Parsing.Skip  // NB: Convenience type alias for discovery
}
