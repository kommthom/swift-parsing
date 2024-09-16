//
//  StringKeyValue.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 08.09.24.
//

public struct StringKeyValue<Value: Sendable>: Sendable {
	//public typealias InterpolationValue = String
	public let key: String
	public var value: Value
	
	@inlinable
	public init(_ key: String, _ value: Value) {
		self.key = key
		self.value = value
	}
	
	@inlinable
	public init(_ keyValue: (String, Value)) {
		self.init(keyValue.0, keyValue.1)
	}
	
	public var tuple: (String, Value) {
		(key, value)
	}
}

extension StringKeyValue: Hashable & Equatable where Value: Equatable & Hashable {}

extension Dictionary where Key == String, Value: Sendable {
	@inlinable
	public init(_ keyValueList: [StringKeyValue<Value>]) {
		self.init(uniqueKeysWithValues: keyValueList.lazy.map { ($0.key, $0.value) } )
	}
	
	@inlinable
	public init(_ keyValueList: [[StringKeyValue<Value>]]) {
		self = keyValueList
			.reduce(
				into: [String: Value]()
			) { partialResult, nextResult in
				partialResult = partialResult
					.merging(
						Dictionary(
							nextResult
						)
					) { _, new in
				new
			}
		}
	}
	
	@inlinable
	public mutating func append(_ keyValue: StringKeyValue<Value>) {
		self[keyValue.key] = keyValue.value
	}
	
	@inlinable
	public var keyValueList: [StringKeyValue<Value>] {
		map { .init($0) }
	}
}
