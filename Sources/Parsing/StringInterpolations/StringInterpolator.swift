//
//  StringInterpolator.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 06.09.24.
//

public final class StringInterpolator: Sendable {
	public typealias Output = String
	@usableFromInline
	let delimiters: StringInterpolationDelimiters
	
	@inlinable
	public init(delimiters: StringInterpolationDelimiters = StringInterpolationDelimiters(startingWith: "%(", endingWith: ")")) {
		self.delimiters = delimiters
	}
	
	@inlinable
	public func interpolate(_ rawString: Output, with interpolations: [String: String]) -> Output {
		do {
			let template = try self.parseTemplateString(rawString, delimiters: self.delimiters)
			let parser = InterpolationParserPrinter(formatTemplate: template)
				.map ( .dict )
			return String(Substring(try parser.print(interpolations)))
			//.map(.string)
		} catch {
			return rawString
		}
	}
	
	@usableFromInline
	func parseTemplateString(_ templateString: String, delimiters: StringInterpolationDelimiters) throws -> StringInterpolationTemplate {
		let template = InterpolationFormatTemplateParserPrinter(delimiters: delimiters)
			.map(.stringInterpolationTemplate)
			.map { pairs in
				StringInterpolationTemplate.init(templateStringPairs: pairs, delimiters: delimiters)
			}
		return try template.parse(templateString)
	}
	
	@inlinable
	public func getInterpolations(_ rawString: String, with output: Output) -> [String: String]? {
		do {
			let template = try self.parseTemplateString(rawString, delimiters: self.delimiters)
			let parser = InterpolationParserPrinter(formatTemplate: template)
				.map ( .dict )
			return try parser.parse(output)
		} catch {
			return nil
		}
	}
}
