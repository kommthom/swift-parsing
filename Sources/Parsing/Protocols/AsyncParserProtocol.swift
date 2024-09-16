//
//  AsyncParserProtocol.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 03.09.24.
//


@rethrows public protocol AsyncParserProtocol<Input, Output>: Sendable {
	associatedtype Input: Sendable
	associatedtype Output: Sendable
	associatedtype _Body: Sendable
	typealias Body = _Body

	func parse(_ input: inout Input) async throws -> Output

	@AsyncParserBuilder<Input>
	var body: Body { get }
}

extension AsyncParserProtocol where Body == Never {
	@_transparent
	public var body: Body {
		fatalError(
			"""
				'\(Self.self)' has no body. …

				Do not access a parser's 'body' property directly, as it may not exist. To run a parser, \
				call 'Parser.parse(_:)', instead.
			"""
		)
	}
}

extension AsyncParserProtocol where Body: AsyncParserProtocol, Body.Input == Input, Body.Output == Output {
	@inlinable
	@inline(__always)
	public func parse(_ input: inout Body.Input) async throws -> Body.Output {
		try await self.body.parse(&input)
	}
}

extension AsyncParserProtocol {
	@_disfavoredOverload
	@inlinable
	public func parse(_ input: Input) async rethrows -> Output {
		var input = input
		return try await self.parse(&input)
	}

	@inlinable
	public func parse<C: Collection & Sendable>(_ input: C) async rethrows -> Output where Input == C.SubSequence {
		var input: Input = input[...]
		return try await AsyncParse {
				self
				AsyncEnd<Input>()
			}
			.parse(&input)
	}

	@_disfavoredOverload
	@inlinable
	public func parse<S: StringProtocol>(_ input: S) async rethrows -> Output where Input == S.SubSequence.UTF8View, Self.Input: Sendable {
		var input: Input = input[...].utf8
		return try await AsyncParse {
			self
			AsyncEnd<Input>()
		}
		.parse(&input)
	}
}
