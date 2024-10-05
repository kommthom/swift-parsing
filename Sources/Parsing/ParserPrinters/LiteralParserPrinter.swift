//
//  LiteralParserPrinter.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 22.09.24.
//

import Thoms_Foundation

@inlinable
public func lit(_ str: String) -> AnyParserPrinter<Template, Unit> {
	return AnyParserPrinter<Template, Unit>(
		parse: { template throws in //Template
			try head(
				template
				.parts
			).flatMap { (p, ps) in
				guard p == str else { throw ParsingError.expectedInput(str, at: format) }
				template = Template(
					parts: ps
				   )
				return unit
			}!
		},
		print: { _, template in
			template = .init(
				parts: [str]
			)
		}
	)
}

@inlinable
public func lit(_ str: String) -> Format<Unit> {
	return Format<Unit>( //_ parser:
		lit(str)
	)
}

@inlinable
public func slit(_ str: String) -> AnyParserPrinter<StringTemplate, Unit> {
	return AnyParserPrinter<StringTemplate, Unit>(
		parse: { template throws in
			try head(
				template
					.template
					.parts
			)
			.flatMap { (p, ps) in
				guard p == str else { throw ParsingError.expectedInput(str, at: format) }
				template = StringTemplate(
					template: Template(
									parts: ps),
									arguments: CVarArguments()
							)
				return unit
			}!
		},
		print: { _, template in
			template = StringTemplate(
				template: Template(
					parts: [str]
				),
				arguments: CVarArguments()
			)
		}
	)
}

@inlinable
public func slit(_ str: String) -> StringFormat<Unit> {
	return StringFormat<Unit>(slit(str))
}
