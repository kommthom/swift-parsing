//
//  SemigroupProtocol.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 06.09.24.
//

public protocol SemigroupProtocol: Sendable {
	static func <> (lhs: Self, rhs: Self) -> Self
}

@inlinable
public prefix func <> <S: SemigroupProtocol>(rhs: S) -> @Sendable (S) -> S {
	return { lhs in lhs <> rhs }
}

@inlinable
public postfix func <> <S: SemigroupProtocol>(lhs: S) -> @Sendable (S) -> S {
	return { rhs in lhs <> rhs }
}

extension String: SemigroupProtocol {
	@inlinable
	public static func <> (lhs: String, rhs: String) -> String {
		return lhs + rhs
	}
}

extension Array: SemigroupProtocol where Element == Sendable {
	@inlinable
	public static func <> (lhs: Array, rhs: Array) -> Array {
		return lhs + rhs
	}
}

//@inlinable
//public func <> <A: Sendable>(lhs: @escaping @Sendable (A) -> A, rhs: @escaping @Sendable (A) -> A) -> @Sendable (A) -> A {
//	return lhs >>> rhs
//}
