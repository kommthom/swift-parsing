//
//  CountingRangeProtocol.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

public protocol CountingRangeProtocol {
	var minimum: Int { get }
	var maximum: Int? { get }
}

extension Int: CountingRangeProtocol {
	public var minimum: Int { self }
	public var maximum: Int? { self }
}

extension ClosedRange: CountingRangeProtocol where Bound == Int {
	public var minimum: Int { self.lowerBound }
	public var maximum: Int? { self.upperBound }
}

extension PartialRangeFrom: CountingRangeProtocol where Bound == Int {
	public var minimum: Int { self.lowerBound }
	public var maximum: Int? { nil }
}

extension PartialRangeThrough: CountingRangeProtocol where Bound == Int {
	public var minimum: Int { 0 }
	public var maximum: Int? { self.upperBound }
}
