//
//  UnicodeScalarViewToSubstringIso.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

extension ConversionProtocol where Self == Conversions.UnicodeScalarViewToSubstringIso {
	/// A conversion from `Substring.UnicodeScalarView` to `Substring`.
	///
	/// Useful when used with the ``From`` parser-printer to integrate a substring parser into a
	/// parser on unicode scalars.
	@inlinable
	public static var substring: Self { .init() }
}

extension ConversionProtocol where Output == Substring.UnicodeScalarView {
	/// Transforms this conversion to `Substring.UnicodeScalarView` into a conversion to `Substring`.
	///
	/// A fluent version of ``Conversion/substring-swift.type.property-4r1aj``.
	@inlinable
	public var substring: Conversions.MapIso<Self, Conversions.UnicodeScalarViewToSubstringIso> {
		self.map(.substring)
	}
}

extension Conversions {
	/// A conversion from a unicode scalar view to its substring.
	///
	/// You will not typically need to interact with this type directly. Instead you will usually use
	/// the ``Conversion/substring-swift.type.property-1y3u3`` and operation, which constructs this
	/// type under the hood.
	public struct UnicodeScalarViewToSubstringIso: ConversionProtocol {
		@inlinable
		public init() {}
		
		@inlinable
		public func apply(_ input: Substring.UnicodeScalarView) -> Substring {
			Substring(input)
		}
		
		@inlinable
		public func unapply(_ output: Substring) -> Substring.UnicodeScalarView {
			output.unicodeScalars
		}
	}
}
