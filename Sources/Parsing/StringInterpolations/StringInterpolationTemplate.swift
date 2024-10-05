//
//  StringInterpolationTemplate.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 06.09.24.
//

import Thoms_Foundation

public final class StringInterpolationTemplate: Sendable, ExpressibleByStringLiteral {
	public let processElements: [StringInterpolationElementPair]
	public let delimiters: StringInterpolationDelimiters
	public let template: Template
	// StringInterpolation value provider
	public let arguments: @Sendable () -> [String: Sendable]
	
	@inlinable
	public init(processElements: [StringInterpolationElementPair], delimiters: StringInterpolationDelimiters = StringInterpolationDelimiters(), template: Template, arguments: @autoclosure @escaping @Sendable () -> [String: Sendable]) {
		self.processElements = processElements
		self.delimiters = delimiters
		self.template = template
		self.arguments = arguments
	}
	
	@inlinable
	public convenience init() {
		self.init(stringLiteral: String.empty)
	}
	
	@inlinable
	public convenience init(stringLiteral value: String) {
		self.init(templateStringPairs: [StringInterpolationElementPair(stringValue: value)])
	}
	
	@inlinable
	public convenience init(template: Template = .empty, delimiters: StringInterpolationDelimiters = StringInterpolationDelimiters(), arguments: @autoclosure @escaping @Sendable () -> [String: Sendable]) {
		self.init(
			templateStringPairs: StringInterpolationTemplate.elementsFromTemplate(template, delimiters: delimiters),
			delimiters: delimiters,
			arguments: arguments()
		)
	}
	
	@inlinable
	public convenience init(templateStringPairs: [StringInterpolationElementPair], delimiters: StringInterpolationDelimiters = StringInterpolationDelimiters(), arguments: @autoclosure @Sendable @escaping () -> [String: Sendable] = [:]) {
		self.init(
			processElements: templateStringPairs,
			delimiters: delimiters,
			template: StringInterpolationTemplate.templateFromPairs(templateStringPairs, delimiters: delimiters),
			arguments: arguments()
		)
	}
}

extension StringInterpolationTemplate: WithTranslationProtocol {
	@inlinable
	public var translated: Template {
		let arguments: [String: Sendable] = self.arguments()
		return Template(parts: self.processElements.reduce(into: [String]()) { result, pair in
				if !(pair.interpolationKey ?? .empty).isEmpty {
					result.append((arguments[pair.interpolationKey!] as! String?) ?? pair.interpolationKey!)
				}
				if !(pair.stringValue ?? .empty).isEmpty {
					result.append(pair.stringValue!)
				}
			}
		)
	}
	
	@inlinable
	public func update(with translation: @escaping @Sendable () -> [String: Sendable]) -> Self {
		.init(processElements: self.processElements, delimiters: self.delimiters, template: self.template, arguments: translation())
	}
}

extension StringInterpolationTemplate: TemplateProtocol {
	public static let empty: StringInterpolationTemplate = StringInterpolationTemplate()
	
	@inlinable
	public static func <>(lhs: StringInterpolationTemplate, rhs: StringInterpolationTemplate) -> StringInterpolationTemplate {
		return .init(
			processElements: lhs.processElements + rhs.processElements,
			delimiters: lhs.delimiters,
			template: lhs.template <> rhs.template,
			arguments: lhs.arguments()
		)
	}

	@inlinable
	public var isEmpty: Bool {
		return template.isEmpty
	}
	
	@inlinable
	public func render() -> String {
		return template.render()
	}
}

extension StringInterpolationTemplate {
	@usableFromInline
	static func templateFromPairs(_ elements: [StringInterpolationElementPair], delimiters: StringInterpolationDelimiters) -> Template {
		return Template(parts: elements.reduce(into: [String]()) { result, pair in
				if !(pair.interpolationKey ?? .empty).isEmpty {
					result.append(delimiters.startingWith + pair.interpolationKey! + delimiters.endingWith)
				}
				if !(pair.stringValue ?? .empty).isEmpty {
					result.append(pair.stringValue!)
				}
			}
		)
	}
	
	@usableFromInline
	static func elementsFromTemplate(_ template: Template, delimiters: StringInterpolationDelimiters) -> [StringInterpolationElementPair] {
		let pairs: [StringInterpolationElement] = template
			.parts
			.map { part in
				if part.hasPrefix(delimiters.startingWith) && part.hasSuffix(delimiters.endingWith) {
					return .interpolation(
						String(
							part
								.dropFirst(delimiters.startingWith.count)
								.dropLast(delimiters.endingWith.count)
						)
					)
				} else {
					return .string(
						part
					)
				}
			}
		return Conversions.StringInterpolationTemplateIso<[StringInterpolationElement]>().apply(pairs)
	}
}
//private extension StringInterpolationTemplate {
//	static func parseArgs(argumentsString: String, delimiters: StringInterpolationDelimiters) -> [StringInterpolationElement] {
//		let interpolationCount = argumentsString.count(where: { $0 == delimiters.endingWith.first} )
//		let interpolation = StringInterpolation(literalCapacity: 1000, interpolationCount: interpolationCount)
//		try? interpolation.appendInterpolations(argumentsString, delimiters: delimiters)
//		return interpolation.parts
//	}
//	
//	static func buildTemplate(pairs: [StringInterpolationElement]) -> Template {
//		return Template(parts: pairs.map { arg in
//				return switch arg {
//					case .empty: String.empty
//					case .string(let string): string
//					case .interpolation(let interpolation): interpolation.value!
//				}
//			}
//		)
//	}
//}

//extension StringInterpolationTemplate: ExpressibleByStringInterpolation {
//	public convenience init(stringInterpolation: StringInterpolation) {
//		self.init(template: StringInterpolationTemplate.buildTemplate(pairs: stringInterpolation.parts), pairs: stringInterpolation.parts)
//	}
//}
