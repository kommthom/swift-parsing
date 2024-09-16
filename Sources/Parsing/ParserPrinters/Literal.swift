//
//  Literal.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

extension Array: ParserProtocol, ParserPrinterProtocol where Element: EquatableMarker {
	@inlinable
	public func parse(_ input: inout ArraySlice<Element>) throws -> () {
		guard input.starts(with: self) else {
			throw ParsingError.expectedInput(self.debugDescription, at: input)
		}
		input.removeFirst(self.count)
	}

	@inlinable
	public func print(_ output: (), into input: inout SubSequence) throws {
		input.prepend(contentsOf: self)
	}
}

extension String: ParserPrinterProtocol {
	@inlinable
	public func parse(_ input: inout Substring) throws {
		guard input.starts(with: self) else {
			throw ParsingError.expectedInput(self.debugDescription, at: input)
		}
		input.removeFirst(self.count)
	}

	@inlinable
	public func print(_ output: (), into input: inout SubSequence) {
		input.prepend(contentsOf: self)
	}
}

extension String.UnicodeScalarView: ParserPrinterProtocol {
	@inlinable
	public func parse(_ input: inout Substring.UnicodeScalarView) throws {
		guard input.starts(with: self) else {
			throw ParsingError.expectedInput(String(self).debugDescription, at: input)
		}
		input.removeFirst(self.count)
	}

	@inlinable
	public func print(_ output: (), into input: inout SubSequence) {
		input.prepend(contentsOf: self)
	}
}

extension String.UTF8View: ParserPrinterProtocol {
	@inlinable
	public func parse(_ input: inout Substring.UTF8View) throws {
		guard input.starts(with: self) else {
			throw ParsingError.expectedInput(String(self).debugDescription, at: input)
		}
		input.removeFirst(self.count)
	}

	@inlinable
	public func print(_ output: (), into input: inout SubSequence) {
		input.prepend(contentsOf: self)
	}
}
