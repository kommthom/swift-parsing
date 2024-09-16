//
//  BytesToStringIso.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 31.08.24.
//

extension ConversionProtocol where Self == Conversions.BytesToStringIso<Substring.UTF8View> {
	/// A conversion from `Substring.UTF8View` to `String`.
	///
	/// Useful for transforming a ``ParserPrinter``'s UTF-8 output into a more general-purpose string.
	///
	/// ```swift
	/// let line = Prefix { $0 != .init(ascii: "\n") }.map(.string)
	/// ```
	@inlinable
	public static var string: Self { .init() }
}

extension ConversionProtocol where Output == Substring.UTF8View {
	/// Transforms this conversion to `Substring.UTF8View` into a conversion to `String`.
	///
	/// A fluent version of ``Conversion/string-swift.type.property-9owth``.
	@inlinable
	public var string: Conversions.MapIso<Self, Conversions.BytesToStringIso<Output>> { self.map(.string) }
}

extension Conversions {
	/// A conversion from a ``PrependableCollection`` of UTF-8 bytes to a string.
	///
	/// You will not typically need to interact with this type directly. Instead you will usually use
	/// the ``Conversion/string-swift.type.property-9owth`` operation, which constructs this type.
	public struct BytesToStringIso<Input: PrependableCollectionProtocol>: ConversionProtocol & SendableMarker where Input.SubSequence == Input, Input.Element == UTF8.CodeUnit	{
		@inlinable
		public init() {}
		
		@inlinable
		public func apply(_ input: Input) -> String {
			String(decoding: input, as: UTF8.self)
		}
		
		@inlinable
		public func unapply(_ output: String) -> Input {
			.init(output.utf8)
		}
	}
}
