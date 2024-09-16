//
//  CasePath.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

import CasePaths

extension ConversionProtocol where Self: Sendable {
	/// Converts the associated values of an enum case into the case, and an enum case into its
	/// associated values.
	///
	/// Useful for transforming the output of a ``ParserPrinter`` into an enum:
	///
	/// ```swift
	/// @CasePathable
	/// enum Expression {
	///   case add(Int, Int)
	///   ...
	/// }
	///
	/// struct Add: ParserPrinter{
	///   var body: some ParserPrinter<Substring, Expression> {
	///     ParsePrint(.case(\Expression.Cases.add)) {
	///       Int.parser()
	///       "+"
	///       Int.parser()
	///     }
	///   }
	/// }
	///
	/// try Add().parse("1+2")  // Expression.add(1, 2)
	/// ```
	///
	/// To transform the output of a ``ParserPrinter`` into a struct, see ``memberwise(_:)``.
	///
	/// - Parameter embed: An embed function where `Values` directly maps to the memory
	///   layout of `Enum`, for example the internal, default initializer that is automatically
	///   synthesized for structs.
	/// - Returns: A conversion that can embed the associated values of an enum case into the case,
	///   and extract the associated values from the case.
	@inlinable
	public static func `case`<Values, Enum: CasePathable>(_ keyPath: CaseKeyPath<Enum, Values>) -> Self where Self == AnyCasePath<Enum, Values> {
		AnyCasePath(keyPath)
	}

//	@inlinable
//	public static func `case`<Values: Sendable, Enum: Sendable>(_ initializer: @escaping (Values) -> Enum) -> Self where Self == AnyCasePath<Enum, Values> {
//		/initializer
//	}

//	@inlinable
//	public static func `case`<Enum>(_ initializer: Enum) -> Self where Self == AnyCasePath<Enum, Void> {
//		/initializer
//	}
//	@inlinable
//	public static func `case`<Values: Sendable, Enum: Sendable>(_ initializer: @escaping @Sendable (Values) -> Enum) -> Self where Self == CasePath<Enum, Values> { // ConversionProtocol‚
//		/initializer
//	}
	
//	@inlinable
//	public static func `case`<Enum: SendableMarker>(_ initializer: Enum) -> Self {
//		/initializer as! Self
//	}
	
}

extension AnyCasePath: ConversionProtocol where Root: SendableMarker, Value: SendableMarker, Self: Sendable {
	@inlinable
	public func apply(_ input: Value) -> Root {
		self.embed(input)
	}

	@inlinable
	public func unapply(_ output: Root) throws -> Value {
		guard let value = self.extract(from: output) else {
				throw ConvertingError(
					"""
					case: Failed to extract \(Value.self) from \(output).
					"""
				)
		}
		return value
	}
}
