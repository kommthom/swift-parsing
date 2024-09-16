//
//  InterpolationFormatTemplateParserPrinter.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 07.09.24.
//

import CasePaths

public struct InterpolationFormatTemplateParserPrinter: ParserPrinterProtocol {
	public let delimiters: StringInterpolationDelimiters
	public var body: some ParserPrinterProtocol<Substring.UTF8View, [StringInterpolationElement]> {
		return Many {
			OneOf {
				//Always((StringInterpolationElement.empty))
				RestString()
				MatchString(delimiters: delimiters)
				MatchInterpolation(delimiters: delimiters)
			}
		} separator: {
			//Always(())
			String.empty.utf8
		}
	}
}

public struct RestString: ParserPrinterProtocol & Sendable {
	public var body: some ParserPrinterProtocol<Substring.UTF8View, StringInterpolationElement> {
		Rest().map(.string)
			.map (
				.case (
					\StringInterpolationElement.Cases.string
				)
			)
	}
}

public struct MatchString: ParserPrinterProtocol & Sendable {
	public let delimiters: StringInterpolationDelimiters
	
	public var body: some ParserPrinterProtocol<Substring.UTF8View, StringInterpolationElement> {
		PrefixUpTo(delimiters.startingWith.utf8)
			.map(.string)
			.map (
				.case (
					\StringInterpolationElement.Cases.string
				)
			)
	}
}

public struct MatchInterpolation: ParserPrinterProtocol & Sendable {
	public let delimiters: StringInterpolationDelimiters
	
	public var body: some ParserPrinterProtocol<Substring.UTF8View, StringInterpolationElement> {
		ParsePrint {
			delimiters.startingWith.utf8
			PrefixUpTo(delimiters.endingWith.utf8)
				.map(.string)
				.map (
					.case (
						\StringInterpolationElement.Cases.interpolation
					)
				)
			delimiters.endingWith.utf8
		}
	}
}
