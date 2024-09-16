//
//  MonoidProtocol.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 06.09.24.

public protocol MonoidProtocol: SemigroupProtocol {
	static var empty: Self { get }
}

extension MonoidProtocol where Self: _EmptyInitializable {
	@inlinable
	public static var empty: Self { Self.init() }
}
extension String: MonoidProtocol {}

extension Array: MonoidProtocol where Element == Sendable {
	public static let empty: Array = .init()
}

@inlinable
public func joined<M: MonoidProtocol>(_ s: M) -> @Sendable ([M]) -> M {
	return { xs in
		if let head = xs.first {
			return xs.dropFirst().reduce(head) { accum, x in accum <> s <> x }
		}
		return .empty
	}
}
