//
//  CaseAccessible.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 09.09.24.
//

import Foundation

public protocol CaseAccessible: Sendable & MatchableProtocol {
	var label: String { get }
	
	func associatedValue<AssociatedValue>(matching pattern: @Sendable (AssociatedValue) -> Self) -> AssociatedValue?
	mutating func update<AssociatedValue>(value: AssociatedValue, matching pattern: @Sendable (AssociatedValue) -> Self)
}

public extension CaseAccessible {
	var label: String {
		return Mirror(reflecting: self).children.first?.label ?? String(describing: self)
	}
	
	func associatedValue<AssociatedValue>(matching pattern: @Sendable (AssociatedValue) -> Self) -> AssociatedValue? {
		guard let decomposed: (String, AssociatedValue) = decompose(),
			  let patternLabel = Mirror(reflecting: pattern(decomposed.1)).children.first?.label,
			  decomposed.0 == patternLabel else { return nil }
		
		return decomposed.1
	}
	
	mutating func update<AssociatedValue>(value: AssociatedValue, matching pattern: @Sendable (AssociatedValue) -> Self) {
		guard associatedValue(matching: pattern) != nil else { return }
		self = pattern(value)
	}
	
	private func decompose<AssociatedValue>() -> (label: String, value: AssociatedValue)? {
		for case let (label?, value) in Mirror(reflecting: self).children {
			if let result = (value as? AssociatedValue) ?? (Mirror(reflecting: value).children.first?.value as? AssociatedValue) {
				return (label, result)
			}
		}
		return nil
	}
	
	subscript<AssociatedValue>(case pattern: @Sendable (AssociatedValue) -> Self) -> AssociatedValue? {
		get {
			return associatedValue(matching: pattern)
		} set {
			guard let value = newValue else { return }
			update(value: value, matching: pattern)
		}
	}
	
	subscript<AssociatedValue>(case pattern: @Sendable (AssociatedValue) -> Self, default value: AssociatedValue) -> AssociatedValue {
		get {
			return associatedValue(matching: pattern) ?? value
		} set {
			update(value: newValue, matching: pattern)
		}
	}

	func match<AssociatedValue: Sendable>(_ constructor: @Sendable (AssociatedValue) -> Self) -> AssociatedValue? {
		return self.associatedValue<A>(matching: constructor) //-> A?
	}
}
