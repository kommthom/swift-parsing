//
//  AnyParserPrinter.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

extension ParserPrinterProtocol {
	/// Wraps this parser with a type eraser.
	///
	/// This form of _type erasure_ preserves abstraction across API boundaries, such as different
	/// modules.
	///
	/// When you expose your composed parser-printers as the ``AnyParserPrinter`` type, you can change
	/// the underlying implementation over time without affecting existing clients.
	///
	/// Equivalent to passing `self` to ``AnyParserPrinter/init(_:)``.
	///
	/// - Returns: An ``AnyParserPrinter`` wrapping this parser-printer.
	@inlinable
	public func eraseToAnyParserPrinter() -> AnyParserPrinter<Input, Output> where Input: Sendable {
		AnyParserPrinter(self)
	}
}

/// A type-erased parser-printer of `Output` from `Input`.
///
/// This parser-printer forwards its `parse(_:)` and `print(_:to:)` methods to an arbitrary
/// underlying parser-printer having the same `Input` and `Output` types, hiding the specifics of
/// the underlying ``ParserPrinter``.
///
/// Use `AnyParserPrinter` to wrap a parser whose type has details you don't want to expose across
/// API boundaries, such as different modules. When you use type erasure this way, you can change
/// the underlying parser over time without affecting existing clients.
public struct AnyParserPrinter<Input: Sendable, Output: Sendable>: ParserPrinterProtocol {
	@usableFromInline let parser: ParsingAlias<Input, Output>
	@usableFromInline let printer: PrintingAlias<Input, Output>
	
	/// Creates a type-erasing parser-printer to wrap the given parser-printer.
	///
	/// Equivalent to calling ``ParserPrinter/eraseToAnyParserPrinter()`` on the parser-printer.
	///
	/// - Parameter parser: A parser to wrap with a type eraser.
	@inlinable
	public init<P: ParserPrinterProtocol>(_ parserPrinter: P) where P.Input == Input, P.Output == Output {
		self.init(parse: parserPrinter.parse(_:), print: parserPrinter.print(_:into:))
	}
	
	/// Creates a parser-printer that wraps the given closures in its ``parse(_:)`` and
	/// `print(_:to:)` methods.
	///
	/// - Parameters:
	///   - parse: A closure that attempts to parse an output from an input. `parse` is executed each
	///     time the ``parse(_:)`` method is called on the resulting parser-printer.
	///   - print: A closure that attempts to print an output into an input. `print` is executed each
	///     time the ``print(_:)`` method is called on the resulting parser-printer.
	@inlinable
	public init(parse: @escaping ParsingAlias<Input, Output>, print: @escaping PrintingAlias<Input, Output>) {
		self.parser = parse
		self.printer = print
	}
	
	@inlinable
	public func parse(_ input: inout Input) throws -> Output {
		try self.parser(&input)
	}
	
	@inlinable
	public func print(_ output: Output, into input: inout Input) throws {
		try self.printer(output, &input)
	}
}

// Apply (right-associative)
extension AnyParserPrinter {
	/// Processes with the left and right side parsers, and if they succeed returns the pair of their results.
	@inlinable
	public static func <%> <B: Sendable> (lhs: AnyParserPrinter, rhs: AnyParserPrinter<Input, B>) -> AnyParserPrinter<Input, (Output, B)> {
		return AnyParserPrinter<Input, (Output, B)>(
			parse: { input in
				//parse(_ input: inout Input) throws -> Output
				let output = try lhs.parser(&input) //inout Input -> Output
				let b = try rhs.parser(&input) //inout B -> Output
				return (output, b)
			},
			print: { tuple, input in
				let (output, b) = tuple
				//print(_ output: Output, into input: inout Input)
				try lhs.printer(output, &input) // Output -> Input append
				try rhs.printer(b, &input) // B -> Input append
			}
		)
	}

	/// Processes with the left and right side parsers, discarding the result of the left side.
	@inlinable
	public static func %> (lhs: AnyParserPrinter<Unit, Output>, rhs: AnyParserPrinter) -> AnyParserPrinter { // where Input: Monoid {
		return AnyParserPrinter<Input, Output>(
			parse: { input in
				//parse(_ input: inout Input) throws -> Output
				return try rhs.parser(&input) //inout B -> Output
			},
			print: { output, input in
				//print(_ output: Output, into input: inout Input)
				try rhs.printer(output, &input) // Output -> Input append
			}
		)
//		return (
//			AnyConversion
//				.flip
//				.init(
//					apply: { ($1, $0) },
//					unapply: { ($1, $0) }
//				)
//			>>>
//			AnyConversion(
//				apply: { (output, _) in return output },
//				unapply: { input in return (input, unit) }
//				)
//			AnyConversion
//				.unitIso
//				.inverted
//			<¢>
//			lhs
//			<%>
//			rhs
//		)
	}
}

extension AnyParserPrinter where Input == Unit {
	/// Processes with the left and right parsers, discarding the result of the right side.
	@inlinable
	public static func <% <B: Sendable>(lhs: AnyParserPrinter<Input, B>, rhs: AnyParserPrinter) -> AnyParserPrinter<Input, B> { // (lhs: AnyParserPrinter, rhs: AnyParserPrinter<Output, Unit>) -> AnyParserPrinter {
		return AnyParserPrinter<Input, B>(
			parse: { input in
				//parse(_ input: inout Input) throws -> Output
				let output = try lhs.parser(&input) //inout Input -> Output
				return output
			},
			print: { output, input in
				//print(_ output: Output, into input: inout Input)
				try lhs.printer(output, &input) // Output -> Input append
			}
		)
//		return AnyConversion
//			.unitIso
//			.inverted
//			<¢>
//			lhs
//			<%>
//			rhs
	}
}

// Functor
extension AnyParserPrinter {
	@inlinable
	public func map<B: Sendable>(_ f: AnyConversion<Output, B>) -> AnyParserPrinter<Input, B> { // B: & Monoid
		return f <¢> self
	}
	
	@inlinable
	public static func <¢> <B: Sendable> (lhs: AnyConversion<Output, B>, rhs: AnyParserPrinter) -> AnyParserPrinter<Input, B> {
		return AnyParserPrinter<Input, B>(
			parse: { input throws in
				//parse(_ input: inout Input) throws -> Output
				let result = try rhs.parse(&input)
				return try lhs
						.apply(
							result
						)
			},
			print: { output, input throws in
				//@Sendable (Output, inout Input) throws -> Void
				let newOutput = try lhs.unapply(output)
				try rhs.print(newOutput, into: &input)
			}
		)
	}
	
	@inlinable
	public static func <¢> <B: Sendable> (lhs: AnyConversion<Input, B>, rhs: AnyParserPrinter) -> AnyParserPrinter<B, Output> {
		return AnyParserPrinter<B, Output>(
			parse: { input throws in
				//parse(_ input: inout Input) throws -> Output
				var newInput = try lhs.unapply(input)
				let result = try rhs.parse(&newInput)
				input = try lhs.apply(newInput)
				return result
			},
			print: { output, input throws in
				//@Sendable (Output, inout Input) throws -> Void
				var newInput: Input = try! lhs.unapply(input)
				try rhs.print(output, into: &newInput)
				input = try lhs.apply(newInput)
			}
		)
	}
}

// Alt
@inlinable
public func <|> <A, B>(_ f: @escaping @Sendable (A) throws -> B?, _ g: @escaping @Sendable (A) throws -> B?) -> @Sendable (A) throws -> B? {
	return { a in
		var b: B?
		do {
			b = try f(a)
		} catch {
			return try g(a)
		}
		return try b ?? g(a)
	}
}

extension AnyParserPrinter {
	@inlinable
	public static func <|> (lhs: AnyParserPrinter, rhs: AnyParserPrinter) -> AnyParserPrinter {
		return OneOf {
			lhs
			rhs
		} .eraseToAnyParserPrinter()
	}
	
}
//
//@inlinable
//public func reduce<Output: Sendable>(parsers: [(AnyParserPrinter<Template, Output>, Any.Type)]) -> AnyParserPrinter<Template, Output>? { //where Output: MonoidProtocol { //}, Input: MonoidProtocol {
//	guard var (composed, lastType) = parsers.last else { return nil }
//	parsers
//		.dropLast()
//		.reversed()
//		.forEach { (f, prevType) in
//			if lastType == Unit.self { // A <% ()
//				(composed, lastType) = ( //f
////										<%
////										(
////											.any
////											 <¢>
//											 composed,
////										),
//										prevType
//				)
//			} else
//			if prevType == Unit.self { // () %> A
//				composed = //.any
////					<¢>
////					f
////					%>
//					composed
//			} else { // A <%> B
//				(composed, lastType) = (
//						.any
//						<¢>
//						f
//						<%>
//						composed,
//					prevType)
//			}
//		}
//	return composed
//}

@inlinable
public func reduce<Input: Sendable, Output: Sendable>(parsers: [(AnyParserPrinter<Input, Output>, Any.Type)]) -> AnyParserPrinter<Input, Output>? {
	guard var (composed, lastType) = parsers.last else { return nil }
	parsers
		.dropLast()
		.reversed()
		.forEach { (f, prevType) in
			if lastType == Unit.self { // A <% ()
				(composed, lastType) = (
											 composed,
										prevType
				)
			} else if prevType == Unit.self { // () %> A
				composed = composed
			} else { // A <%> B
				(composed, lastType) = (
						.any
						<¢>
						f
						<%>
						composed,
					prevType)
			}
		}
	return composed
}

// Semigroup
extension AnyParserPrinter: SemigroupProtocol where Output: SemigroupProtocol, Input: SemigroupProtocol {
	@inlinable
	public static func <> (lhs: AnyParserPrinter<Input, Output>, rhs: AnyParserPrinter<Input, Output>) -> AnyParserPrinter<Input, Output> {
		return OneOf {
			lhs
			rhs
		} .eraseToAnyParserPrinter()
	}
}

// Monoid
	extension AnyParserPrinter: MonoidProtocol where Output: MonoidProtocol, Input: MonoidProtocol {
	/// A Parser that always fails and doesn't print anything.
	public static var empty: AnyParserPrinter {
		return AnyParserPrinter(
			parse: const(.empty),
			print: { output, input in
				//input = .empty
				throw PrintingError.failed(summary: "Output not printable", input: output)
			}
		)
	}
}
