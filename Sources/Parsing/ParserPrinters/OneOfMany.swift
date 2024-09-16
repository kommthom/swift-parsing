//
//  OneOfMany.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

extension Parsers {
	/// A parser that attempts to run a number of parsers till one succeeds.
	///
	/// You will not typically need to interact with this type directly. Instead you will usually loop
	/// over each parser in a builder block:
	///
	/// ```swift
	/// enum Role: String, CaseIterable {
	///   case admin
	///   case guest
	///   case member
	/// }
	///
	/// let roleParser = OneOf {
	///   for role in Role.allCases {
	///     role.rawValue.map { role }
	///   }
	/// }
	/// ```
	public struct OneOfMany<Parsers: ParserProtocol>: ParserProtocol {
		public let parsers: [Parsers]
		
		@inlinable
		public init(_ parsers: [Parsers]) {
			self.parsers = parsers
		}
		
		@inlinable
		@inline(__always)
		public func parse(_ input: inout Parsers.Input) throws -> Parsers.Output where Parsers.Input : Sendable {
			let original = input
			var count = self.parsers.count
			var errors: [Error] = []
			errors.reserveCapacity(count)
			for parser in self.parsers {
				do {
					return try parser.parse(&input)
				} catch {
					count -= 1
					if count > 0 { input = original }
					errors.append(error)
				}
			}
			throw ParsingError.manyFailed(errors, at: original)
		}
	}
}

extension Parsers.OneOfMany: ParserPrinterProtocol where Parsers: ParserPrinterProtocol {
	@inlinable
	public func print(_ output: Parsers.Output, into input: inout Parsers.Input) throws {
		let original = input
		var count = self.parsers.count
		var errors: [Error] = []
		errors.reserveCapacity(count)
		for parser in self.parsers.reversed() {
			do {
				try parser.print(output, into: &input)
				return
			} catch {
				count -= 1
				if count > 0 { input = original }
				errors.insert(error, at: errors.startIndex)  // TODO: Should this be `append`?
			}
		}
		throw PrintingError.manyFailed(errors, at: input)
	}
}
