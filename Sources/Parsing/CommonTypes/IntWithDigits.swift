//
//  IntWithDigits.swift
//  CommonParsers
//
//  Created by Thomas Benninghaus on 22.08.24.
//

import Foundation

public struct IntWithDigits: Sendable, LosslessStringConvertible {
	public var value: Int
	public var digits: Int
    
	@inlinable
	public init?(_ description: String) {
        guard let value = Int(description) else { return nil }
        self.value = value
        self.digits = description.count
    }
    
	@inlinable
	public var description: String { String(format: "%0\(digits)d", value) }
}
