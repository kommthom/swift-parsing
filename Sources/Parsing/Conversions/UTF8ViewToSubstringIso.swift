//
//  UTF8ViewToSubstringIso.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

extension ConversionProtocol where Self == Conversions.UTF8ViewToSubstringIso {
	/// A conversion from `Substring.UTF8View` to `Substring`.
	///
	/// Useful when used with the ``From`` parser-printer to integrate a substring parser into a
	/// parser on UTF-8 bytes.
	///
	/// For example:
	///
	/// ```swift
	/// Parse {
	///   "caf".utf8
	///   From(.substring) {
	///     "é"
	///   }
	/// }
	/// ```
	@inlinable
	public static var substring: Self { .init() }
}

extension ConversionProtocol where Output == Substring.UTF8View {
	/// Transforms this conversion to `Substring.UTF8View` into a conversion to `Substring`.
	///
	/// A fluent version of ``Conversion/substring-swift.type.property-1y3u3``.
	@inlinable
	public var substring: Conversions.MapIso<Self, Conversions.UTF8ViewToSubstringIso> {
		self.map(.substring)
	}
}

extension Conversions {
	/// A conversion from a UTF-8 view to its substring.
	///
	/// You will not typically need to interact with this type directly. Instead you will usually use
	/// the ``Conversion/substring-swift.type.property-4r1aj`` operation, which constructs this type.
	public struct UTF8ViewToSubstringIso: ConversionProtocol & SendableMarker {
		@inlinable
		public init() {}
		
		@inlinable
		public func apply(_ input: Substring.UTF8View) -> Substring {
			Substring(input)
		}
		
		@inlinable
		public func unapply(_ output: Substring) -> Substring.UTF8View {
			output.utf8
		}
	}
}
