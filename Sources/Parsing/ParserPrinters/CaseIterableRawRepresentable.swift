//
//  CaseIterableRawRepresentable.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

extension CaseIterable where Self: RawRepresentable & Sendable, RawValue: FixedWidthInteger {
	/// A parser that consumes a case-iterable, raw representable value from the beginning of a
	/// collection of a substring.
	///
	/// See <doc:CaseIterable> for more info.
	///
	/// - Parameter inputType: The `Substring` type. This parameter is included to mirror the
	///   interface that parses any collection of UTF-8 code units.
	/// - Returns: A parser that consumes a case-iterable, raw representable value from the beginning
	///   of a substring.
	@inlinable
	public static func parser(of inputType: Substring.Type = Substring.self) -> Parsers.CaseIterableRawRepresentableParser<Substring, Self, String> {
		.init(toPrefix: { String($0) }, areEquivalent: { $0 == $1 })
	}

	/// A parser that consumes a case-iterable, raw representable value from the beginning of a
	/// collection of a substring's UTF-8 view.
	///
	/// See <doc:CaseIterable> for more info.
	///
	/// - Parameter inputType: The `Substring.UTF8View` type. This parameter is included to mirror the
	///   interface that parses any collection of UTF-8 code units.
	/// - Returns: A parser that consumes a case-iterable, raw representable value from the beginning
	///   of a substring's UTF-8 view.
	@inlinable
	public static func parser(of inputType: Substring.UTF8View.Type = Substring.UTF8View.self) -> Parsers.CaseIterableRawRepresentableParser<Substring.UTF8View, Self, String.UTF8View> {
		.init(toPrefix: { String($0).utf8 }, areEquivalent: { $0 == $1 })
	}

	/// A parser that consumes a case-iterable, raw representable value from the beginning of a
	/// collection of UTF-8 code units.
	///
	/// - Parameter inputType: The collection type of UTF-8 code units to parse.
	/// - Returns: A parser that consumes a case-iterable, raw representable value from the beginning
	///   of a collection of UTF-8 code units.
	@inlinable
	public static func parser<Input>(of inputType: Input.Type = Input.self) -> Parsers.CaseIterableRawRepresentableParser<Input, Self, String.UTF8View> where Input.SubSequence == Input, Input.Element == UTF8.CodeUnit {
		.init(toPrefix: { String($0).utf8 }, areEquivalent: { $0 == $1 })
	}
}

extension CaseIterable where Self: RawRepresentable & Sendable, RawValue == String {
	/// A parser that consumes a case-iterable, raw representable value from the beginning of a
	/// collection of a substring.
	///
	/// See <doc:CaseIterable> for more info.
	///
	/// - Parameter inputType: The `Substring` type. This parameter is included to mirror the
	///   interface that parses any collection of UTF-8 code units.
	/// - Returns: A parser that consumes a case-iterable, raw representable value from the beginning
	///   of a substring.
	@inlinable
	public static func parser(of inputType: Substring.Type = Substring.self) -> Parsers.CaseIterableRawRepresentableParser<Substring, Self, String> {
		.init(toPrefix: { $0 }, areEquivalent: { $0 == $1 })
	}

	/// A parser that consumes a case-iterable, raw representable value from the beginning of a
	/// collection of a substring's UTF-8 view.
	///
	/// See <doc:CaseIterable> for more info.
	///
	/// - Parameter inputType: The `Substring.UTF8View` type. This parameter is included to mirror the
	///   interface that parses any collection of UTF-8 code units.
	/// - Returns: A parser that consumes a case-iterable, raw representable value from the beginning
	///   of a substring's UTF-8 view.
	@inlinable
	public static func parser(of inputType: Substring.UTF8View.Type = Substring.UTF8View.self) -> Parsers.CaseIterableRawRepresentableParser<Substring.UTF8View, Self, String.UTF8View> {
		.init(toPrefix: { $0.utf8 }, areEquivalent: { $0 == $1 })
	}

	/// A parser that consumes a case-iterable, raw representable value from the beginning of a
	/// collection of UTF-8 code units.
	///
	/// - Parameter inputType: The collection type of UTF-8 code units to parse.
	/// - Returns: A parser that consumes a case-iterable, raw representable value from the beginning
	///   of a collection of UTF-8 code units.
	@inlinable
	public static func parser<Input>(of inputType: Input.Type = Input.self) -> Parsers.CaseIterableRawRepresentableParser<Input, Self, String.UTF8View> where Input.SubSequence == Input, Input.Element == UTF8.CodeUnit {
		.init(toPrefix: { $0.utf8 }, areEquivalent: { $0 == $1 } )
	}
}

extension Parsers {
	public struct CaseIterableRawRepresentableParser<Input: Collection & Sendable, Output: CaseIterable & RawRepresentable & Sendable, Prefix: Collection & Sendable>: ParserProtocol where Input.SubSequence == Input, Output.RawValue: Comparable, Prefix.Element == Input.Element {
		@usableFromInline
		let toPrefix: @Sendable (Output.RawValue) -> Prefix

		@usableFromInline
		let areEquivalent: @Sendable (Input.Element, Input.Element) -> Bool

		@usableFromInline
		let cases: [(case: Output, prefix: Prefix, count: Int)]

		@usableFromInline
		init(toPrefix: @escaping @Sendable (Output.RawValue) -> Prefix, areEquivalent: @escaping @Sendable (Input.Element, Input.Element) -> Bool) {
			self.toPrefix = toPrefix
			self.areEquivalent = areEquivalent
			self.cases = Output.allCases
				.map {
					let prefix = toPrefix($0.rawValue)
					return ($0, prefix, prefix.count)
				}
				.sorted(by:
					{ $0.count > $1.count }
				)
		}

		@inlinable
		public func parse(_ input: inout Input) throws -> Output {
			for (`case`, prefix, count) in self.cases {
				if input.starts(with: prefix, by: self.areEquivalent) {
					input.removeFirst(count)
					return `case`
				}
			}
			throw ParsingError.manyFailed(
				self.cases.map {
						ParsingError.expectedInput(describe($0.prefix)?.debugDescription ?? "\($0.prefix)", at: input)
				},
				at: input
			)
		}
	}
}

extension Parsers.CaseIterableRawRepresentableParser: ParserPrinterProtocol where Input: PrependableCollectionProtocol {
	@inlinable
	public func print(_ output: Output, into input: inout Input) {
		input.prepend(contentsOf: self.toPrefix(output.rawValue))
	}
}
