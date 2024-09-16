//
//  Consumed.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

/// A parser that returns the subsequence of input consumed by another parser.
public struct Consumed<Input: Collection, Upstream: ParserProtocol>: ParserProtocol where Upstream.Input == Input, Upstream.Input: Collection, Input.SubSequence == Input {
	public let upstream: Upstream
	
	@inlinable
	public init(@ParserBuilder<Input> _ build: () -> Upstream) {
		self.upstream = build()
	}
	
	@inlinable
	public func parse(_ input: inout Upstream.Input) rethrows -> Upstream.Input {
		let original = input
		_ = try self.upstream.parse(&input)
		return original[..<input.startIndex]
	}
}

extension Consumed: ParserPrinterProtocol where Upstream.Input: PrependableCollectionProtocol {
	@inlinable
	public func print(_ output: Upstream.Input, into input: inout Upstream.Input) rethrows {
		do {
			_ = try self.upstream.parse(output)
			input.prepend(contentsOf: output)
		} catch {
			throw PrintingError.failed(summary: "TODO", input: input)
		}
	}
}
