//
//  First.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

/// A parser that consumes the first element from a collection.
///
/// This parser is named after `Sequence.first`, and attempts to parse the first element from a
/// collection of input by calling this property under the hood.
///
/// For example, it can parse the leading character off a substring:
///
/// ```swift
/// var input = "Hello"[...]
/// try First().parse(&input)  // "H"
/// input                      // "ello"
/// ```
///
/// This parser fails if the input collection is empty:
///
/// ```swift
/// input = ""
/// try First().parse(&input)
/// // error: unexpected input
/// //  --> input:1:1
/// // 1 |
/// //   | ^ expected element
/// ```
public struct First<Input: Collection & Sendable>: ParserProtocol where Input.SubSequence == Input, Input.Element: Sendable{
	@inlinable
	public init() {}

	@inlinable
	public func parse(_ input: inout Input) throws -> Input.Element where Input: Sendable {
		guard let first = input.first else {
			throw ParsingError.expectedInput("element", at: input)
		}
		input.removeFirst()
		return first
	}
}

extension First: ParserPrinterProtocol where Input: PrependableCollectionProtocol {
	@inlinable
	public func print(_ output: Input.Element, into input: inout Input) {
		input.prepend(contentsOf: CollectionOfOne(output))
	}
}

extension Parsers {
	public typealias First = Parsing.First  // NB: Convenience type alias for discovery
}
