//
//  Stream.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 31.08.24.
//

/// A parser that can parse streams of input.
///
/// For example, the following parser can parse an integer followed by a newline from a collection
/// of UTF8 bytes:
///
/// ```swift
/// Parse {
///   Int.parser(of: ArraySlice<UInt8>.self)
///   StartsWith("\n".utf8)
/// }
/// ```
///
/// This parser can be transformed into one that processes an incoming stream of UTF8 bytes:
///
/// ```swift
/// Stream {
///   Parse {
///     Int.parser(of: ArraySlice<UInt8>.self)
///     StartsWith("\n".utf8)
///   }
/// }
/// ```
///
/// And then it can be used on a stream, such as values coming from standard in:
///
/// ```swift
/// var stdin = AnyIterator {
///   readLine().map { ArraySlice($0.utf8) }
/// }
///
/// try newlineSeparatedIntegers.parse(&stdin)
/// ```
public struct Stream<Input: RangeReplaceableCollection, Parsers: ParserProtocol>: ParserProtocol where Parsers.Input == Input, Parsers.Input: Sendable {
	public let parsers: Parsers

	@inlinable
	public init(@ParserBuilder<Input> build: @Sendable () -> Parsers) {
		self.parsers = build()
	}

	@inlinable
	public func parse(_ input: inout AnyIterator<Parsers.Input>) rethrows -> [Parsers.Output] {
		var buffer = Parsers.Input()
		var outputs: Output = []
		while let chunk = input.next() {
			buffer.append(contentsOf: chunk)
			outputs.append(try self.parsers.parse(&buffer))
		}
		return outputs
	}
}

extension AnyIterator: @unchecked @retroactive Sendable {}

extension Parsers {
	public typealias Stream = Parsing.Stream  // NB: Convenience type alias for discovery
}
