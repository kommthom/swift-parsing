//
//  StringTemplate.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 09.09.24.
//

public final class StringTemplate: TemplateProtocol {
	public let template: Template
	public let arguments: CVarArguments
	
	@inlinable
	public convenience init() {
		self.init(template: .empty)
	}

	@inlinable
	public init(template: Template = .empty, arguments: CVarArguments = CVarArguments(args: .empty)) {
		self.template = template
		self.arguments = arguments
	}

	@inlinable
	public var args: [Sendable] { arguments.args }
	public static let empty: StringTemplate = StringTemplate(template: .empty, arguments: .empty )

	@inlinable
	public static func <> (lhs: StringTemplate, rhs: StringTemplate) -> StringTemplate {
		return StringTemplate(template: lhs.template <> rhs.template, arguments: lhs.arguments <> rhs.arguments )
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

public final class CVarArguments: MonoidProtocol { //, CVarArg {
	public let argsProvider: @Sendable () -> [Sendable]
	public var args: [Sendable] { argsProvider() }
	public var arg: Sendable? { args.first }
	
	@inlinable
	public init(argsProvider: @escaping @Sendable () -> [Sendable] = { .init() }) {
		self.argsProvider = argsProvider
	}

	@inlinable
	public init(args: [Sendable]) {
		self.argsProvider = { args }
	}
	
	@inlinable
	public init(arg: Sendable) {
		self.argsProvider = { [arg] }
	}
	
	@inlinable
	public static var empty: CVarArguments { .init() }
	
	@inlinable
	public static func <> (lhs: CVarArguments, rhs: CVarArguments) -> Self {
		.init(args: lhs.args + rhs.args)
	}
}

