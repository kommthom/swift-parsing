//
//  StringInterpolation.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 07.09.24.
//

public class StringInterpolation: StringInterpolationProtocol {
	private(set) var parts: [StringInterpolationElement]

	required public init(literalCapacity: Int, interpolationCount: Int) {
		self.parts = []
		self.parts.reserveCapacity( 2 * interpolationCount + 1 )
	}

	public func appendLiteral(_ literal: String) {
		guard literal.isEmpty == false else { return }
		self.parts.append(.string(literal))
	}

//	public func appendInterpolation(_ interpolation: StringKeyValue<String>) {
//		guard interpolation.key.isEmpty == false else { return }
//		self.parts.append(.interpolation(interpolation))
//	}

	@inlinable
	public func appendInterpolation<T: CustomStringConvertible>(_ literal: T) {
		appendLiteral(literal.description)
	}

//	@inlinable
//	public func appendInterpolation(_ literal: String, `default`: String = "") {
//		appendInterpolation(StringKeyValue<String>(literal, `default`))
//	}

//	public func appendInterpolation(_ template: @autoclosure () -> StringInterpolationTemplate) {
//		self.parts.append(contentsOf: template().processElements)
//	}
	
//	public func appendInterpolations(_ formatString: String, delimiters: StringInterpolationDelimiters = StringInterpolationDelimiters(startingWith: "%(", endingWith: ")")) throws {
//		let parser = StringInterpolationParserPrinter(delimiters: delimiters)
//		self.parts = try parser.parse(formatString)
//	}
}
