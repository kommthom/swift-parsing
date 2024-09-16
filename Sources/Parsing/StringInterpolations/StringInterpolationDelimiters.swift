//
//  StringInterpolationDelimiters.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 09.09.24.
//

public struct StringInterpolationDelimiters: Sendable {
	public let startingWith: String
	public let endingWith: String
	
	@inlinable
	public init(startingWith: String = "%(", endingWith: String = ")") {
		self.startingWith = startingWith
		self.endingWith = endingWith
	}
}
