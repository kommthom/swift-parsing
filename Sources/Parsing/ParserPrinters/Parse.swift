//
//  Parse.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 31.08.24.
//

/// A parser that attempts to run a number of parsers to accumulate their outputs.
///
/// A general entry point into ``ParserBuilder`` syntax, which can be used to build complex parsers
/// from simpler ones.
///
/// ```swift
/// let point = Parse {
///   "("
///   Int.parser()
///   ","
///   Int.parser()
///   ")"
/// }
///
/// try point.parse("(2,-4)")  // (2, -4)
///
/// try point.parse("(42,blob)")
/// // error: unexpected input
/// //  --> input:1:5
/// // 1 | (42,blob)
/// //   |     ^ expected integer
/// ```
public struct Parse<Input: Sendable, Parsers: ParserProtocol>: ParserProtocol where Parsers.Input == Input {
	public let parsers: Parsers

	/// An entry point into ``ParserBuilder`` syntax.
	///
	/// Used to combine the non-void outputs from multiple parsers into a single output by running
	/// each parser in sequence and bundling the results up into a tuple.
	///
	/// For example, the following parser parses a double, skips a comma, and then parses another
	/// double before returning a tuple of each double.
	///
	/// ```swift
	/// let coordinate = Parse {
	///   Double.parser()
	///   ","
	///   Double.parser()
	/// }
	///
	/// try coordinate.parse("1,2")  // (1.0, 2.0)
	/// ```
	///
	/// - Parameter with: A parser builder that will accumulate non-void outputs in a tuple.
	@inlinable
	public init(input inputType: Input.Type = Input.self, @ParserBuilder<Input> with build: @Sendable () -> Parsers) {
		self.parsers = build()
	}

	/// A parser builder that bakes in a transformation of the tuple output.
	///
	/// Equivalent to calling ``Parser/map(_:)-4hsj5`` on the result of a `Parse.init` builder.
	///
	/// For example, the following parser:
	///
	/// ```swift
	/// Parse {
	///   Double.parser()
	///   ","
	///   Double.parser()
	/// }
	/// .map(Coordinate.init(x:y:))
	/// ```
	///
	/// Can be rewritten as:
	///
	/// ```swift
	/// Parse(Coordinate.init(x:y:)) {
	///   Double.parser()
	///   ","
	///   Double.parser()
	/// }
	/// ```
	///
	/// - Parameters:
	///   - transform: A transform to apply to the output of the parser builder.
	///   - with: A parser builder that will accumulate non-void outputs in a tuple.
	@inlinable
	public init<Upstream: Sendable, NewOutput: Sendable>(input inputType: Input.Type = Input.self, _ transform: @escaping @Sendable (Upstream.Output) -> NewOutput, @ParserBuilder<Input> with build: @Sendable () -> Upstream) where Parsers == Parsing.Parsers.Map<Upstream, NewOutput> {
		self.parsers = build().map(transform)
	}

	/// A parser builder that replaces a void output with a given value.
	///
	/// Equivalent to calling ``Parser/map(_:)-2e6si`` on the result of a `Parse.init` builder.
	///
	/// For example, the following parser:
	///
	/// ```swift
	/// Parse { "admin" }.map { Role.admin }
	/// ```
	///
	/// Can be rewritten as:
	///
	/// ```swift
	/// Parse(Role.admin) { "admin" }
	/// ```
	@inlinable
	public init<Upstream: Sendable, NewOutput: Sendable>(input inputType: Input.Type = Input.self, _ output: NewOutput, @ParserBuilder<Input> with build: @Sendable () -> Upstream) where Parsers == Parsing.Parsers.MapConstant<Upstream, NewOutput> {
		self.parsers = build().map { output }
	}

	/// A parser builder that bakes in a conversion of the tuple output.
	///
	/// Equivalent to calling ``Parser/map(_:)-18m9d`` on the result of a `Parse.init` builder.
	///
	/// For example, the following parser:
	///
	/// ```swift
	/// ParsePrint {
	///   Double.parser()
	///   ","
	///   Double.parser()
	/// }
	/// .map(.memberwise(Coordinate.init(x:y:)))
	/// ```
	///
	/// Can be rewritten as:
	///
	/// ```swift
	/// ParsePrint(.memberwise(Coordinate.init(x:y:))) {
	///   Double.parser()
	///   ","
	///   Double.parser()
	/// }
	/// ```
	///
	/// - Parameters:
	///   - conversion: A conversion to apply to the output of the parser builder.
	///   - with: A parser builder that will accumulate non-void outputs in a tuple.
	@inlinable
	public init<Upstream: Sendable, Downstream: Sendable>(input inputType: Input.Type = Input.self, _ conversion: Downstream, @ParserBuilder<Input> with build: @Sendable () -> Upstream) where Parsers == Parsing.Parsers.MapConversion<Upstream, Downstream> {
		self.parsers = build().map(conversion)
	}

	@inlinable
	public func parse(_ input: inout Parsers.Input) rethrows -> Parsers.Output {
		try self.parsers.parse(&input)
	}
}

extension Parse: ParserPrinterProtocol where Parsers: ParserPrinterProtocol {
	@inlinable
	public func print(_ output: Parsers.Output, into input: inout Parsers.Input) rethrows {
		try self.parsers.print(output, into: &input)
	}
}
