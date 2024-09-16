//
//  Template.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 24.06.24.
//

public final class Template: Sendable, ExpressibleByStringLiteral {
    public let parts: [String]

	@inlinable
	public init(parts: [String]) {
        self.parts = parts
    }

	@inlinable
	public init(stringLiteral value: String) {
        self.parts = [value]
    }

	@inlinable
	public init() {
		self.parts = .init()
	}
    
	@inlinable
	public func render() -> String {
        return parts.joined()
    }
}

extension Template: TemplateProtocol {
    public static let empty: Template = .init()

	@inlinable
	public static func <>(lhs: Template, rhs: Template) -> Template {
        return .init(
            parts: lhs.parts + rhs.parts
        )
    }

	@inlinable
	public var isEmpty: Bool {
        return parts.isEmpty
    }
}

extension Template: ExpressibleByStringInterpolation {
    public convenience init(stringInterpolation: Template.StringInterpolation) {
        self.init(parts: stringInterpolation.parts)
    }

    public class StringInterpolation: StringInterpolationProtocol {
        private(set) var parts: [String]

        required public init(literalCapacity: Int, interpolationCount: Int) {
            self.parts = []
            self.parts.reserveCapacity( 2 * interpolationCount + 1 )
        }

        public func appendLiteral(_ literal: String) {
            guard literal.isEmpty == false else { return }
			self.parts.append(literal)
		}

		@inlinable
		public func appendInterpolation(_ literal: String) {
            appendLiteral(literal)
        }

		@inlinable
		public func appendInterpolation<T: CustomStringConvertible>(_ literal: T) {
            appendLiteral(literal.description)
        }

		@inlinable
		public func appendInterpolation(_ literal: String?, `default`: String = "") {
            appendLiteral(literal ?? `default`)
        }

		@inlinable
		public func appendInterpolation(_ template: @autoclosure () -> Template) {
            appendLiteral(template().parts.joined())
        }
    }
}
