//
//  ConvertingError.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 31.08.24.
//

@usableFromInline
struct ConvertingError: Error {
	@usableFromInline
	let message: String
	
	@usableFromInline
	init(_ message: String = "") {
		self.message = message
	}
}
