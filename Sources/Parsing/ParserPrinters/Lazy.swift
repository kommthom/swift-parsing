//
//  Lazy.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

/// A parser that waits for a call to its ``parse(_:)`` method before running the given closure to
/// create a parser for the given input.
@available(
	iOS,
	deprecated: 9999,
	message: """
		Lazily evaluate a parser by specifying it in a computed 'Parser.body' property, instead.
		"""
)
@available(
	macOS,
	deprecated: 9999,
	message: """
		Lazily evaluate a parser by specifying it in a computed 'Parser.body' property, instead.
		"""
)
@available(
	tvOS,
	deprecated: 9999,
	message: """
		Lazily evaluate a parser by specifying it in a computed 'Parser.body' property, instead.
		"""
)
@available(
	watchOS,
	deprecated: 9999,
	message: """
		Lazily evaluate a parser by specifying it in a computed 'Parser.body' property, instead.
		"""
)
public final class Lazy<Input: Sendable, LazyParser: AsyncParserProtocol>: AsyncParserProtocol, @unchecked Sendable where Input == LazyParser.Input {
	@usableFromInline
	internal var lazyParser: LazyParser?

	public let createParser: @Sendable () async -> LazyParser

	@inlinable
	public init(@ParserBuilder<Input> createParser: @escaping @Sendable () async -> LazyParser) {
		self.createParser = createParser
	}

	@inlinable
	public func parse(_ input: inout LazyParser.Input) async rethrows -> LazyParser.Output {
		guard let parser = self.lazyParser else {
			let parser = await self.createParser()
			self.lazyParser = parser
			return try await parser.parse(&input)
		}
		return try await parser.parse(&input)
	}
}

extension Lazy: AsyncParserPrinterProtocol where LazyParser: AsyncParserPrinterProtocol {
	@inlinable
	public func print(_ output: LazyParser.Output, into input: inout LazyParser.Input) async rethrows {
		guard let parser = self.lazyParser else {
			let parser = await self.createParser()
				self.lazyParser = parser
				try await parser.print(output, into: &input)
				return
		}
		try await parser.print(output, into: &input)
	}
}

extension Parsers {
	public typealias Lazy = Parsing.Lazy  // NB: Convenience type alias for discovery
}
