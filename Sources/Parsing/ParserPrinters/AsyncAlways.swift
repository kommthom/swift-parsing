//
//  AsyncAlways.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 10.09.24.
//

public struct AsyncAlways<Input: Sendable, Output: Sendable>: AsyncParserPrinterProtocol {
	public let output: Output

	@inlinable
	public init(_ output: Output) {
		self.output = output
	}

	@inlinable
	public func parse(_ input: inout Input) async -> Output {
		self.output
	}

	@inlinable
	public func print(_ output: Output, into input: inout Input) async {}
}

extension Parsers {
	public typealias AsyncAlways = Parsing.AsyncAlways
}

