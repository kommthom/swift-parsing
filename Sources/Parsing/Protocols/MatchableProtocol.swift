//
//  MatchableProtocol.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 09.09.24.
//

import Thoms_Foundation
import Foundation

public protocol MatchableProtocol: Sendable {
	func match<AssociatedValue: Sendable>(_ constructor: @Sendable (AssociatedValue) -> Self) -> AssociatedValue?
}

@inlinable
public func iso<U: MatchableProtocol>(_ f: U) -> AnyConversion<Thoms_Foundation.Unit, U> {
	return AnyConversion<Thoms_Foundation.Unit, U>(
		apply: { _ in f },
		unapply: { $0.match({ _ in f }) }
	)
}

@inlinable
public func iso<AssociatedValue: Sendable, U: MatchableProtocol>(_ f: @escaping @Sendable (AssociatedValue) -> U) -> AnyConversion<AssociatedValue, U> {
	return AnyConversion<AssociatedValue, U>(
		apply: f,
		unapply: { $0.match(f) }
	)
}

@inlinable
// see: https://github.com/pointfreeco/swift-case-paths/blob/master/Sources/CasePaths/EnumReflection.swift#L44
public func extract<Root: Sendable, Value: Sendable>(case embed: @Sendable (Value) -> Root, from root: Root) -> Value? {
	func extractHelp(from root: Root) -> ([String?], Value)? {
		if let value = root as? Value {
			let otherRoot = embed(value)
			let root = root
			return withUnsafePointer(to: root) { root in
				return withUnsafePointer(to: otherRoot) { otherRoot in
					if memcmp(root, otherRoot, MemoryLayout<Root>.size) == 0 {
						return ([], value)
					}
					return ([nil], value)
				}
			}
		}
		var path: [String?] = []
		var any: Any = root
		
		while case let (label?, anyChild)? = Mirror(reflecting: any).children.first {
			path.append(label)
			path.append(String(describing: type(of: anyChild)))
			if let child = anyChild as? Value {
				return (path, child)
			}
			any = anyChild
		}
		if MemoryLayout<Value>.size == 0 {
			return (["\(root)"], unsafeBitCast((), to: Value.self))
		}
		return nil
	}
	
	if let (rootPath, child) = extractHelp(from: root),
		let (otherPath, _) = extractHelp(from: embed(child)),
		rootPath == otherPath {
		return child
	}
	return nil
}
