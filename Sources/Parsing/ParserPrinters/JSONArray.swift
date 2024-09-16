//
//  JSONArray.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 05.09.24.
//

public struct JSONArray: ParserPrinterProtocol & Sendable {
	public var body: some ParserPrinterProtocol<Substring.UTF8View, [JSONValue.Output]> {
		"[".utf8
		Many {
			JSONValue()
		} separator: {
			",".utf8
		} terminator: {
			"]".utf8
		}
	}
}
