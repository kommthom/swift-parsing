//
//  AsyncConversionProtocol.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 04.09.24.
//

@rethrows public protocol AsyncConversionProtocol<Input, Output>: Sendable {
	associatedtype Input: Sendable
	associatedtype Output: Sendable

	func apply(_ input: Input) async throws -> Output
	func unapply(_ output: Output) async throws -> Input
}
