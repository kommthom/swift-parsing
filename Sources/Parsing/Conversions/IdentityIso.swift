//
//  IdentityIso.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

import Foundation

extension Conversions {
	public struct IdentityIso<Value: Sendable>: ConversionProtocol {
		@inlinable
		public init() {}
		
		@inlinable
		@inline(__always)
		public func apply(_ input: Value) -> Value {
			input
		}
		
		@inlinable
		@inline(__always)
		public func unapply(_ output: Value) -> Value {
			output
		}
	}
}
