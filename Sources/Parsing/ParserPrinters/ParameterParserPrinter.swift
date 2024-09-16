//
//  ParameterParserPrinter.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 22.09.24.
//

@inlinable
public func param<Output>(_ f: AnyConversion<String, Output>) throws -> AnyParserPrinter<Template, Output> {
	return AnyParserPrinter<Template, Output>(
		parse: { template in
			//parse(_ input: inout Input) throws -> Output
			guard let (p, ps) = head(
				template
					.parts
				),
				let newTemplate = try? f
					.apply(
						p
					)
			else { throw ParsingError.failed(summary: "template.parts not valid or conversion failed", at: template) }
			template = Template(
					parts: ps
				)
			return newTemplate
		},
		print: { output, template in
			//print(_ output: Output, into input: inout Input)
			let newTemplate = try f
				.unapply(output) as String
			template = Template(parts: [newTemplate])
		}
	)
}

@inlinable
public func param<Output>(_ f: AnyConversion<String, Output>) throws -> Format<Output> {
	return Format<Output>(
		try param(
			f
		)
	)
}

@usableFromInline
func _sparam<Output: StringFormattingProtocol>(_ f: AnyConversion<String, Output>) -> AnyParserPrinter<StringTemplate, Output> {
	return AnyParserPrinter<StringTemplate, Output>(
		parse: { template in
			guard let (p, ps) = head(
					template
					.template
					.parts
				),
				let newTemplate = try? f
					.apply(
						p
					)
			else { throw ParsingError.failed(summary: "template.parts not valid or conversion failed", at: template) }
			template = StringTemplate(
				template: Template(
					parts: ps
				),
				arguments:
					CVarArguments(args: [newTemplate])
			)
			return newTemplate
		},
		print: { output, template in
			let newTemplate = try f
				.unapply(output) as String
			template = StringTemplate(
				template: Template(
						parts: [String(
							  format: newTemplate,
							  newTemplate.arg as! CVarArg
							  )
						  ]
					),
				arguments: CVarArguments(args: [newTemplate.arg])
				)
			}
	)
	//.map(AnyConversion<Output, StringTemplate>.any)
}

@inlinable
public func sparam<Output: StringFormattingProtocol>(_ f: AnyConversion<String, Output>) -> AnyParserPrinter<StringTemplate, Output> {
	return _sparam(
		f
			.formatted
	)
}

@inlinable
public func sparam<Output: StringFormattingProtocol>(_ f: AnyConversion<String, Output>, index: UInt) -> AnyParserPrinter<StringTemplate, Output> {
	return _sparam(
		f
		.formatted(index: index)
	)
}

@inlinable
public func sparam<Output: StringFormattingProtocol>(_ f: AnyConversion<String, Output>) -> StringFormat<Output> {
	return StringFormat<Output>(
		sparam(
			f
		)
	)
}

@inlinable
public func sparam<Output: StringFormattingProtocol>(_ f: AnyConversion<String, Output>, index: UInt) -> StringFormat<Output> {
	return StringFormat<Output>(
		sparam(
			f,
			index: index
		)
	)
}
