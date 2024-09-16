//
//  StringInterpolationElementPair.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 19.09.24.
//

import CasePaths

public struct StringInterpolationElementPair: Sendable {
	public var interpolationKey: String?
	public var stringValue: String?
	
	@inlinable
	public init(interpolationKey: String? = nil, stringValue: String? = nil) {
		self.interpolationKey = interpolationKey
		self.stringValue = stringValue
	}
}
