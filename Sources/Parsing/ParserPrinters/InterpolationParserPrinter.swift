//
//  InterpolationParserPrinter.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 11.09.24.
//

public struct InterpolationParserPrinter: ParserPrinterProtocol {
	public let formatTemplate: StringInterpolationTemplate
	
	public init(formatTemplate: StringInterpolationTemplate) {
		self.formatTemplate = formatTemplate
	}
	
	public var body: some ParserPrinterProtocol<Substring.UTF8View, [InterpolationElementsParserPrinter.Output]> { // String: String]> {
		Many {
			InterpolationElementsParserPrinter(formatTemplate: formatTemplate)
		} separator: {
			String.empty.utf8
		}
	}
}

public struct InterpolationElementsParserPrinter: ParserPrinterProtocol & Sendable {
	public let formatTemplate: StringInterpolationTemplate
	
	public var body: some ParserPrinterProtocol<Substring.UTF8View, [StringKeyValue<String>]> {
		for element in formatTemplate.processElements {
			InterpolationElementParserPrinter(element: element)
		}
	}
}

public struct InterpolationElementParserPrinter: ParserPrinterProtocol & Sendable {
	public let element: StringInterpolationElementPair
	
	public var body: some ParserPrinterProtocol<Substring.UTF8View, StringKeyValue<String>> {
		if let interpolation = element.interpolationKey {
			if let string = element.stringValue {
				PrefixUpTo(string.utf8)
					.map(.stringKeyValue(interpolation))
				string.utf8
			} else {
				Rest()
					.map(.stringKeyValue(interpolation))
				Always(())
			}
		} else if let string = element.stringValue {
			Always(StringKeyValue(String.empty, String.empty))
			string.utf8
		} else {
			Always(StringKeyValue(String.empty, String.empty))
		}
	}
}
