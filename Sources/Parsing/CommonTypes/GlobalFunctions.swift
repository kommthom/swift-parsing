//
//  GlobalFunctions.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 10.09.24.
//

import Thoms_Foundation

@inlinable
public func <<< <A: Sendable, B: Sendable, C: Sendable>(_ b2c: @escaping @Sendable (B) -> C, _ a2b: @escaping @Sendable (A) -> B) -> @Sendable (A) -> C {
	return { a in b2c(a2b(a)) }
}

@inlinable
public func >>> <A: Sendable, B: Sendable, C: Sendable>(_ a2b: @escaping @Sendable (A) -> B, _ b2c: @escaping @Sendable (B) -> C) -> @Sendable (A) -> C {
	return { a in b2c(a2b(a)) }
}

@inlinable
public func >=> <A: Sendable, B: Sendable, C: Sendable>(lhs: @escaping @Sendable  (A) -> B?, rhs: @escaping  @Sendable (B) -> C?) ->  @Sendable (A) -> C? {
	return lhs >>> flatMap(rhs)
}

@inlinable
public func flatMap<A: Sendable, B: Sendable>(_ a2b: @escaping @Sendable (A) -> B?) -> @Sendable (A?) -> B? {
	return { a in
		a.flatMap(a2b)
	}
}

@inlinable
public func <|> <A: Sendable, B: Sendable>(_ f: @escaping @Sendable (A) -> B?, _ g: @escaping @Sendable (A) -> B?) -> @Sendable (A) -> B? {
	return { a in
		return f(a) ?? g(a)
	}
}

@inlinable
public func <|> <A: Sendable, B: Sendable>(_ f: @escaping @Sendable (A) throws -> B?, _ g: @escaping @Sendable (A) throws -> B?) -> @Sendable (A) throws -> B? {
	return { a in
		return  try (try? f(a)) ?? (try g(a))
	}
}

@inlinable
public func <|> <A: Sendable, B: Sendable>(_ f: @escaping @Sendable (inout A) throws -> B, _ g: @escaping @Sendable (inout A) throws -> B) -> @Sendable ( inout A) throws -> B {
	return { (a:  inout A) in
		return  try (try? f(&a)) ?? (try g(&a))
	}
}

@inlinable
public func <|> <A: Sendable, B: Sendable>(_ f: @escaping @Sendable (A, B) throws -> Void, _ g: @escaping @Sendable (A, B) throws -> Void) -> @Sendable (A, B) throws -> Void {
	return { a, b in
		do {
			try f(a, b)
		} catch {
			try g(a, b)
		}
	}
}

@inlinable
public func const<A: Sendable, B: Sendable>(_ a: A) -> @Sendable (inout B) throws -> A {
	return { _ in a }
}

@inlinable
public func const<A: Sendable, B: Sendable>(_ a: B, _ b: inout B) -> @Sendable(A, inout B) throws -> Void {
	return { (_, b: inout B) in b = a }
}

@inlinable
public func id<A: Sendable>(_ a: A) -> A {
	return a
}

@inlinable
func head<A>(_ xs: [A]) -> (A, [A])? {
	guard let x = xs.first else { return nil }
	return (x, Array(xs.dropFirst()))
}
