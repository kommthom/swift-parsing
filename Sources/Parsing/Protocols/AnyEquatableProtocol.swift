//
//  AnyEquatableProtocol.swift
//  swift-parsing
//
//  Created by https://github.com/pointfreeco/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

@usableFromInline
func isEqual(_ lhs: Sendable, _ rhs: Sendable) -> Bool {
	func open<LHS: Sendable>(_: LHS.Type) -> Bool? {
		(Box<LHS>.self as? AnyEquatableProtocol.Type)?.isEqual(lhs, rhs)
	}
	return _openExistential(type(of: lhs), do: open) ?? false
}

private enum Box<T: Sendable> {}

private protocol AnyEquatableProtocol {
	static func isEqual(_ lhs: Sendable, _ rhs: Sendable) -> Bool
}

extension Box: AnyEquatableProtocol where T: Sendable & Equatable {
	fileprivate static func isEqual(_ lhs: Sendable, _ rhs: Sendable) -> Bool {
		lhs as? T == rhs as? T
	}
}
