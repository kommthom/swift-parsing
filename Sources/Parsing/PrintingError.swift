//
//  PrintingError.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 31.08.24.
//

@usableFromInline
enum PrintingError: Error {
	case failed(Context)
	case manyFailed([Error], Context)

	@available(*, deprecated)
	@usableFromInline
	init() {
		self = .failed(.init(input: "", debugDescription: ""))
	}

	@usableFromInline
	static func failed(summary: String, input: Sendable) -> Self {
		.failed(.init(input: input, debugDescription: summary))
	}

	@usableFromInline
	static func manyFailed(_ errors: [Error], at input: Sendable) -> Self {
		.manyFailed(errors, .init(input: input, debugDescription: ""))
	}

	@usableFromInline
	var context: Context {
		switch self {
			case let .failed(context), let .manyFailed(_, context):	return context
		}
	}

	@usableFromInline
	func flattened() -> Self {
		@Sendable func flatten(_ depth: Int = 0) -> @Sendable (Error) -> [(depth: Int, error: Error)] {
		  { error in
			switch error {
				case let PrintingError.manyFailed(errors, _):
					return errors.flatMap(flatten(depth + 1))
				default:
					return [(depth, error)]
				}
			}
		}

		return switch self {
			case .failed: self
			case let .manyFailed(errors, context):
				.manyFailed(
					errors.flatMap(flatten()
				)
				.sorted {
					switch ($0.error, $1.error) {
						case let (lhs as PrintingError, rhs as PrintingError):
							return lhs.context > rhs.context
						default:
							return $0.depth > $1.depth
					}
				}
				.map { $0.error },
				context
			)
		}
	}

	@usableFromInline
	struct Context {
		@usableFromInline
		var debugDescription: String

		@usableFromInline
		var input: Sendable

		@usableFromInline
		var underlyingError: Error?

		@usableFromInline
		init(input: Sendable, debugDescription: String, underlyingError: Error? = nil) {
			self.input = input
			self.debugDescription = debugDescription
			self.underlyingError = underlyingError
		}
	}
}

extension PrintingError: CustomDebugStringConvertible {
	@usableFromInline
	var debugDescription: String {
	return switch self.flattened() {
		case let .failed(context):
			"error: \(context.debugDescription)"
		case let .manyFailed(errors, _):
			errors.count == 1 ? "\(errors[0])" : """
				error: multiple failures occurred

				\(errors.map { "\($0)" }.joined(separator: "\n\n"))
				"""
		}
	}
}

extension PrintingError.Context: Sendable {
	fileprivate static func > (lhs: Self, rhs: Self) -> Bool {
		return switch (describe(lhs.input), describe(rhs.input)) {
			case let (lhsInput?, rhsInput?): lhsInput.count > rhsInput.count
			default: false
		}
	}
}

@usableFromInline
func describe(_ input: Any) -> String? {
	// TODO: Use `_openExistential` for `C: Collection`?
	return switch input {
		case let input as Substring: input.base
		case let input as Substring.UnicodeScalarView: describe(Substring(input))
		case let input as Substring.UTF8View: describe(Substring(input))
		case let input as String: input
		case let input as String.UTF8View: String(input)
		default: nil
	}
}
