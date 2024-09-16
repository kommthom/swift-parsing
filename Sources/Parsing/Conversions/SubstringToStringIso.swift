//
//  SubstringToStringIso.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 31.08.24.
//

extension ConversionProtocol where Self == Conversions.SubstringToStringIso {
	/// A conversion from `Substring` to `String`.
	///
	/// Useful for transforming a ``ParserPrinter``'s substring output into a more general-purpose
	/// string.
	///
	/// ```swift
	/// let line = Prefix { $0 != "\n" }.map(.string)
	/// ```
	@inlinable
	public static var string: Self { .init() }
}

extension ConversionProtocol where Output == Substring {
	/// Transforms this conversion to `Substring` into a conversion to `String`.
	///
	/// A fluent version of ``Conversion/string-swift.type.property-3u2b5``.
	@inlinable
	public var string: Conversions.MapIso<Self, Conversions.SubstringToStringIso> { self.map(.string) }
}

extension Conversions {
	/// A conversion from a substring to a string.
	///
	/// You will not typically need to interact with this type directly. Instead you will usually use
	/// the ``Conversion/string-swift.type.property-3u2b5`` operation, which constructs this type.
	public struct SubstringToStringIso: ConversionProtocol {
		@inlinable
		public init() {}
		
		@inlinable
		public func apply(_ input: Substring) -> String {
			String(input)
		}
		
		@inlinable
		public func unapply(_ output: String) -> Substring {
			Substring(output)
		}
	}
}
