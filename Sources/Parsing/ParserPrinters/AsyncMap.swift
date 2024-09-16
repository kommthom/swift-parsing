//
//  AsyncMap.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

extension AsyncParserProtocol {
	@_disfavoredOverload
	@inlinable
	public func map<NewOutput: Sendable>(_ transform: @escaping @Sendable (Output) async -> NewOutput) async -> Parsers.AsyncMap<Self, NewOutput> {
		await .init(upstream: self, transform: transform)
	}
	
	@_disfavoredOverload
	@inlinable
	public func map<NewOutput: Sendable>(_ transform: @Sendable () async -> NewOutput) async -> Parsers.AsyncMapConstant<Self, NewOutput> {
		await .init(upstream: self, output: await transform())
	}
	
	@inlinable
	public func map<C: Sendable>(_ conversion: C) async -> Parsers.AsyncMapConversion<Self, C> {
		await .init(upstream: self, downstream: conversion)
	}
}

extension Parsers {
	/// A parser that transforms the output of another parser with a given closure.
	///
	/// You will not typically need to interact with this type directly. Instead you will usually use
	/// the ``Parser/map(_:)-4hsj5`` operation, which constructs this type.
	public struct AsyncMap<Upstream: AsyncParserProtocol, NewOutput: Sendable>: AsyncParserProtocol {
		public let upstream: Upstream
		public let transform: @Sendable (Upstream.Output) async -> NewOutput

		@inlinable
		public init(upstream: Upstream, transform: @escaping @Sendable (Upstream.Output) async -> NewOutput) async {
			self.upstream = upstream
			self.transform = transform
		}

		@inlinable
		@inline(__always)
		public func parse(_ input: inout Upstream.Input) async rethrows -> NewOutput {
			await self.transform(try await self.upstream.parse(&input))
		}
	}

	public struct AsyncMapConstant<Upstream: AsyncParserProtocol, Output: Sendable>: AsyncParserProtocol where Upstream.Output == Void {
		public let upstream: Upstream
		public let output: Output

		@inlinable
		public init(upstream: Upstream, output: Output) async {
			self.upstream = upstream
			self.output = output
		}

		@inlinable
		@inline(__always)
		public func parse(_ input: inout Upstream.Input) async rethrows -> Output {
			try await self.upstream.parse(&input)
			return self.output
		}
  }

  /// A parser that transforms the output of another parser with a given conversion.
  ///
  /// You will not typically need to interact with this type directly. Instead you will usually use
  /// the ``Parser/map(_:)-4hsj5`` operation, which constructs this type.
	public struct AsyncMapConversion<Upstream: AsyncParserPrinterProtocol, Downstream: AsyncConversionProtocol>: AsyncParserPrinterProtocol where Downstream.Input == Upstream.Output {
		public let upstream: Upstream
		public let downstream: Downstream

		@inlinable
		public init(upstream: Upstream, downstream: Downstream) async {
			self.upstream = upstream
			self.downstream = downstream
		}

		@inlinable
		@inline(__always)
		public func parse(_ input: inout Upstream.Input) async rethrows -> Downstream.Output {
			try await self.downstream.apply(try await self.upstream.parse(&input))
		}

		@inlinable
		public func print(_ output: Downstream.Output, into input: inout Upstream.Input) async rethrows {
			try await self.upstream.print(await self.downstream.unapply(output), into: &input)
		}
	}
}

extension Parsers.AsyncMapConstant: AsyncParserPrinterProtocol where Upstream: AsyncParserPrinterProtocol, Output: Sendable & Equatable {
	@inlinable
	public func print(_ output: Output, into input: inout Upstream.Input) async throws {
		guard output == self.output else {
			throw PrintingError.failed(
				summary: """
					expected \(self.output)
				""",
				input: input
			)
		}
		try await self.upstream.print((), into: &input)
	}
}
