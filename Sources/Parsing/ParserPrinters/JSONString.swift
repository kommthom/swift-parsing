//
//  JSONString.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 05.09.24.
//

public struct JSONString: ParserPrinterProtocol & Sendable {
	public var body: some ParserPrinterProtocol<Substring.UTF8View, String> {
		"\"".utf8
		Many(into: "") { string, fragment in
			string.append(contentsOf: fragment)
		} decumulator: { string in
			string.map(String.init).reversed().makeIterator()
		} element: {
			OneOf {
				Prefix(1) { $0.isUnescapedJSONStringByte }.map(.string)
				Parse {
					"\\".utf8
					OneOf {
						"\"".utf8.map { "\"" }
						"\\".utf8.map { "\\" }
						"/".utf8.map { "/" }
						"b".utf8.map { "\u{8}" }
						"f".utf8.map { "\u{c}" }
						"n".utf8.map { "\n" }
						"r".utf8.map { "\r" }
						"t".utf8.map { "\t" }
						ParsePrint {
							Prefix(4) { $0.isHexDigit }
								.map(.unicode)
						}
					}
				}
			}
		} terminator: {
			"\"".utf8
		}
	}
}
