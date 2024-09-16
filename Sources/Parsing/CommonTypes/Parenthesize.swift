//
//  Parenthesize.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 19.09.24.
//  Based on:
//  https://github.com/pointfreeco/swift-web/blob/master/Sources/ApplicativeRouter/PartialIso.swift
//

// MARK: A, B

@inlinable
public func parenthesize<A: Sendable, B: Sendable, U: Sendable>(_ f: AnyConversion<(A, B), U>) -> AnyConversion<(A, B), U> {
	return f
}

@inlinable
public func parenthesize<A: Sendable, B: Sendable, U: Sendable>(_ a: A, _ b: B, _ u: U) -> (A, (B, U)) {
	return (a, (b, u))
}

@inlinable
public func flatten<A: Sendable, B: Sendable, U: Sendable>() -> AnyConversion<(A, (B, U)), (A, B, U)> {
	return .init(
		apply: { flatten($0) },
		unapply: { parenthesize($0, $1, $2) }
	)
}

@inlinable
public func flatten<A: Sendable, B: Sendable, U: Sendable>(_ f: (A, (B, U))) -> (A, B, U) {
	return (f.0, f.1.0, f.1.1)
}

// MARK: A, B, C

@inlinable
public func parenthesize<A: Sendable, B: Sendable, C: Sendable, U: Sendable>(_ f: AnyConversion<(A, B, C), U>) -> AnyConversion<(A, (B, C)), U> {
	return flatten() >>> f
}

@inlinable
public func parenthesize<A: Sendable, B: Sendable, C: Sendable, U: Sendable>(_ a: A, _ b: B, _ c: C, _ u: U) -> (A, (B, (C, U))) {
	return (a, (b, (c, u)))
}

@inlinable
public func flatten<A: Sendable, B: Sendable, C: Sendable, U: Sendable>() -> AnyConversion<(A, (B, (C, U))), (A, B, C, U)> {
	return .init(
		apply: { flatten($0) },
		unapply: { parenthesize($0, $1, $2, $3) }
	)
}

@inlinable
public func flatten<A: Sendable, B: Sendable, C: Sendable, U: Sendable>(_ f: (A, (B, (C, U)))) -> (A, B, C, U) {
	return (f.0, f.1.0, f.1.1.0, f.1.1.1)
}
