//
//  WithTranslationProtocol.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 22.09.24.
//

public protocol WithTranslationProtocol: Sendable {
	var arguments: @Sendable () -> [String: Sendable] { get }
	var translated: Template { get }
	
	func update(with translation: @escaping @Sendable () -> [String: Sendable]) -> Self
}
