//
//  ManyOfOne.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 12.09.24.
//

extension Parsers {
	public struct ManyOfOne<Parser: ParserProtocol>: ParserProtocol {
		public typealias Result = [Parser.Output]
		public let parsers: [Parser]
		public let initialResult: Result
		public let updateAccumulatingResult: @Sendable (inout Result, Parser.Output) throws -> Void

		@inlinable
		public init(_ parsers: [Parser]) {
			self.parsers = parsers
			self.initialResult = [Parser.Output]()
			self.updateAccumulatingResult = { (xs, x) in xs.append(x); }
		}
		
		@inlinable
		public func parse(_ input: inout Parser.Input) throws -> Result where Parser.Input: Sendable {
			let original = input
			var previous = input
			var results = initialResult
			var count = self.parsers.count
			var errors: [Error] = []
			errors.reserveCapacity(count)
			for parser in self.parsers {
				let output: Parser.Output?
				do {
					output = try parser.parse(&input)
				} catch {
					errors.append(error)
					output = nil
					input = previous
				}
				defer { previous = input }
				count -= 1
				//results = results.merging(output) { (_, new) in new }
				if let _ = output { try self.updateAccumulatingResult(&results, output!) }
			}
			guard errors.isEmpty else {
				input = original
				throw ParsingError.manyFailed(errors, at: original)
			}
			return results
		}
	}
}

extension Parsers.ManyOfOne: ParserPrinterProtocol where Parser: ParserPrinterProtocol {
	@inlinable
	public func print(_ output: Result, into input: inout Parser.Input) throws {
		let original = input
		var count = self.parsers.count
		guard count == output.count else { throw PrintingError.failed(summary: "arguments count does not match parsers count", input: input) }
		var errors: [Error] = []
		errors.reserveCapacity(count)
		for (index, parser) in self.parsers.enumerated().reversed() {
			do {
				try parser.print(output[index], into: &input)
			} catch {
				count -= 1
				if count > 0 { input = original }
				//errors.append(error)
				errors.insert(error, at: errors.startIndex)  // TODO: Should this be `append`?
			}
		}
		guard errors.isEmpty else {
			input = original
			throw PrintingError.manyFailed(errors, at: input)
		}
	}
}
