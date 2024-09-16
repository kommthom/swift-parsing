//
//  ParseableFormatStyle.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
import Foundation

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
public struct Formatted<Style: ParseableFormatStyle & RegexComponent & Sendable>: ParserPrinterProtocol where Style.Strategy.ParseInput == String, Style.Strategy.ParseOutput == Style.RegexOutput, Style.FormatInput: Sendable {
	@usableFromInline
	let style: Style

	@inlinable
	public init(_ style: Style) {
		self.style = style
	}

	@inlinable
	public func parse(_ input: inout Substring) throws -> Style.Strategy.ParseOutput {
		guard let match = input.prefixMatch(of: self.style.regex) else {
			throw ParsingError.failed(
				summary: "failed to process \"\(Output.self)\"",
				at: input
			)
		}
		input.removeFirst(input.distance(from: match.range.lowerBound, to: match.range.upperBound))
		return match.output
	}

	@inlinable
	public func print(_ output: Style.FormatInput, into input: inout Substring) {
		input.prepend(contentsOf: self.style.format(output))
	}
}
#endif
