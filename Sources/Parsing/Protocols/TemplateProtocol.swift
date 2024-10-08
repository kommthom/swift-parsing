//
//  TemplateProtocol.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 24.06.24.
//

import Thoms_Foundation

public protocol TemplateProtocol: Sendable & MonoidProtocol & SemigroupProtocol & _EmptyInitializable {
	static var empty: Self { get }
    var isEmpty: Bool { get }
    func render() -> String
}
