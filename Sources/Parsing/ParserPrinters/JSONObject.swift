//
//  JSONObject.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 05.09.24.
//

public struct JSONObject: ParserPrinterProtocol, Sendable {
	public var body: some ParserPrinterProtocol<Substring.UTF8View, [String: JSONValue.Output]> {
		"{".utf8
		Many(into: [String: JSONValue.Output]()) { (xs, x) throws in
			let nameValue: (String, JSONValue.Output) = x
			xs[nameValue.0] = nameValue.1
		} decumulator: { object in
			(object.sorted(by: { $0.key < $1.key }) as [(String, JSONValue.Output)])
				.reversed()
				.makeIterator()
		} element: {
			Whitespace()
			JSONString()
			Whitespace()
			":".utf8
			JSONValue()
		} separator: {
			",".utf8
		} terminator: {
			"}".utf8
		}
	}
}
