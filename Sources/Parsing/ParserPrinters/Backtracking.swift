//
//  Backtracking.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

/// A parser that attempts to run another parser and if it fails the input will be restored to its
/// original value.
///
/// Use this parser if you want to manually manage the backtracking behavior of your parsers.
/// Another tool for managing backtracking is the ``OneOf`` parser. Also see the
/// <doc:Backtracking> article for more information on backtracking.
public struct Backtracking<Input: Sendable, Upstream: ParserProtocol>: ParserProtocol where Upstream.Input == Input {
	public let upstream: Upstream
	
	public init(
		@ParserBuilder<Input> upstream: () -> Upstream
	) {
		self.upstream = upstream()
	}
	
	public func parse(_ input: inout Upstream.Input) throws -> Upstream.Output {
		let original = input
		do {
			return try self.upstream.parse(&input)
		} catch {
			input = original
			throw error
		}
	}
}

extension Backtracking: ParserPrinterProtocol & SendableMarker where Upstream: ParserPrinterProtocol {
	public func print(_ output: Upstream.Output, into input: inout Upstream.Input) throws {
		try self.upstream.print(output, into: &input)
	}
}
