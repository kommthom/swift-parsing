//
//  Array2DOfStringKeyValueToDictIso.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 26.09.24.
//

import Thoms_Foundation

extension ConversionProtocol where Self == Conversions.Array2DOfStringKeyValueToDictIso {
	@inlinable
	public static var dict: Self { .init() }
}

extension ConversionProtocol where Output == [[StringKeyValue<String>]] {
	@inlinable
	public var dict: Conversions.MapIso<Self, Conversions.Array2DOfStringKeyValueToDictIso> { self.map(.dict) }
}

extension Conversions {
	public struct Array2DOfStringKeyValueToDictIso: ConversionProtocol {
		@inlinable
		public init() {}
		
		@inlinable
		public func apply(_ input: [[StringKeyValue<String>]]) -> [String: String] {
			Dictionary(input)
		}
		
		@inlinable
		public func unapply(_ output: [String: String]) -> [[StringKeyValue<String>]] {
			[output.keyValueList]
		}
	}
}
