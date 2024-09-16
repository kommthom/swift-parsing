//
//  UTF8ViewToStringKeyValueIso.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 12.09.24.
//

extension ConversionProtocol where Self == Conversions.UTF8ViewToStringKeyValueIso {
	@inlinable
	public static var stringKeyValue: Self { .init() }
	
	@inlinable
	public static func stringKeyValue(_ key: String?) -> Self { .init(key: key) }
}

extension ConversionProtocol where Output == Substring.UTF8View {
	@inlinable
	public var stringKeyValue: Conversions.MapIso<Self, Conversions.UTF8ViewToStringKeyValueIso> {
		self.map(.stringKeyValue)
	}
	
	@inlinable
	public func stringKeyValue(_ key: String?) -> Conversions.MapIso<Self, Conversions.UTF8ViewToStringKeyValueIso> {
		self.map(.stringKeyValue(key))
	}
}

extension Conversions {
	public struct UTF8ViewToStringKeyValueIso: ConversionProtocol {
		public let key: String?
		
		@inlinable
		public init(key: String? = nil) {
			self.key = key
		}
		
		@inlinable
		public func apply(_ input: Substring.UTF8View) -> StringKeyValue<String> {
			if let keyNotNil = key {
				return StringKeyValue<String>(keyNotNil, String(Substring(input)))
			}
			return StringKeyValue<String>(String(Substring(input)), String.empty)
		}
		
		@inlinable
		public func unapply(_ output: StringKeyValue<String>) -> Substring.UTF8View {
//			if let _ = output.value {
				return Substring(output.value).utf8
//			}
//			return Substring(output.key).utf8
		}
	}
}
