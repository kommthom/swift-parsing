//
//  ParsingResult.swift
//  CommonParsers
//
//  Created by Thomas Benninghaus on 21.08.24.
//

public struct ParsingResult<Input: Sendable, Output: Sendable> {
    public let rest: Output
    public let match: Input?
    
	@inlinable
	public init(_ rest: Output, _ match: Input? = nil) {
        self.rest = rest
        self.match = match
    }
    
	@inlinable
	public var tuple: (Output, Input?) { (self.rest, self.match) }
	@inlinable
	public var inverted: (Input?, Output) { (self.match, self.rest) }
}

extension ParsingResult where Output: MonoidProtocol {
	@inlinable
	public static var empty: ParsingResult<Input, Output> {
        return ParsingResult(Output.empty, Optional<Input>.none)
    }
}
