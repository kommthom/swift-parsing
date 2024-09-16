//
//  AsyncParserPrinterProtocol.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 11.09.24.
//

@rethrows public protocol AsyncParserPrinterProtocol<Input, Output>: AsyncParserProtocol {
	func print(_ output: Output, into input: inout Input) async throws
}

extension AsyncParserPrinterProtocol where Body: AsyncParserPrinterProtocol, Body.Input == Input, Body.Output == Output {
	@inlinable
	public func print(_ output: Output, into input: inout Input) async throws {
		try await self.body.print(output, into: &input)
	}
}

extension AsyncParserPrinterProtocol where Input: _EmptyInitializable {
	@inlinable
	public func print(_ output: Output) async rethrows -> Input {
		var input = Input()
		try await self.print(output, into: &input)
		return input
	}
}

extension AsyncParserPrinterProtocol where Output == Void {
	@inlinable
	public func print(into input: inout Input) async rethrows {
		try await self.print((), into: &input)
	}
}

extension AsyncParserPrinterProtocol where Input: _EmptyInitializable, Output == Void {
	@inlinable
	public func print() async rethrows -> Input {
		try await self.print(())
	}
}

