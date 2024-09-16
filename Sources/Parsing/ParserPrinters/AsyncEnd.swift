//
//  AsyncEnd.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 03.09.24.
//

public struct AsyncEnd<Input: Sequence & Sendable>: AsyncParserPrinterProtocol {
	@inlinable
	public init() {}

	@inlinable
	public func parse(_ input: inout Input) async throws {
		var iterator = input.makeIterator()
		guard iterator.next() == nil else { throw ParsingError.expectedInput("end of input", at: input) }
	}

	@inlinable
	public func print(_ output: (), into input: inout Input) async throws {
		var iterator = input.makeIterator()
		guard iterator.next() == nil else {
			let description = describe(input).map { "\n\n\($0.debugDescription)" } ?? ""
			throw PrintingError.failed(
				summary: """
				round-trip expectation failed

				An "End" parser-printer expected no more input, but more was printed.\(description)

				During a round-trip, the "End" parser-printer would have failed to parse at this \
				remaining input.
				""",
				input: input
			)
		}
	}
}

extension Parsers {
	public typealias End = Parsing.End  // NB: Convenience type alias for discovery
}
