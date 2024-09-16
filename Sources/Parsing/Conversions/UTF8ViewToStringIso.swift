//
//  UTF8ViewToStringIso.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 12.09.24.
//

extension ConversionProtocol where Self == Conversions.UTF8ViewToStringIso {
	@inlinable
	public static var stringUTF8: Self { .init() }
}

extension ConversionProtocol where Output == Substring.UTF8View {
	@inlinable
	public var stringUTF8: Conversions.MapIso<Self, Conversions.UTF8ViewToStringIso> {
		self.map(.stringUTF8)
	}
}

extension Conversions {
	public struct UTF8ViewToStringIso: ConversionProtocol {
		@inlinable
		public init() {}
		
		@inlinable
		public func apply(_ input: Substring.UTF8View) -> String {
			String(Substring(input))
		}
		
		@inlinable
		public func unapply(_ output: String) -> Substring.UTF8View {
			Substring(output).utf8
		}
	}
}
