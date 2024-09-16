//
//  SubstringToUTF8ViewIso.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

extension ConversionProtocol where Self == Conversions.SubstringToUTF8ViewIso {
	/// A conversion from `Substring` to `Substring.UTF8View`.
	///
	/// Useful when used with the ``From`` parser-printer to integrate a UTF-8 parser into a substring
	/// parser.
	@inlinable
	public static var utf8: Self { .init() }
}

extension ConversionProtocol where Output == Substring {
	/// Transforms this conversion to `Substring` into a conversion to `Substring.UTF8View`.
	///
	/// A fluent version of ``Conversion/utf8-swift.type.property``.
	@inlinable
	public var utf8: Conversions.MapIso<Self, Conversions.SubstringToUTF8ViewIso> { self.map(.utf8) }
}

extension Conversions {
	/// A conversion from a substring to its UTF-8 view.
	///
	/// You will not typically need to interact with this type directly. Instead you will usually use
	/// the ``Conversion/utf8-swift.type.property`` operation, which constructs this type.
	public struct SubstringToUTF8ViewIso: ConversionProtocol {
		@inlinable
		public init() {}
		
		@inlinable
		public func apply(_ input: Substring) -> Substring.UTF8View {
			input.utf8
		}
		
		@inlinable
		public func unapply(_ output: Substring.UTF8View) -> Substring {
			Substring(output)
		}
	}
}
