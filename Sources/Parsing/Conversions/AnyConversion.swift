//
//  AnyConversion.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 31.08.24.
//

import Foundation

extension ConversionProtocol {
	/// A conversion that invokes the given apply and unapply functions.
	///
	/// Useful for experimenting with conversions in a lightweight manner, without the ceremony of
	/// defining a dedicated type.
	///
	/// ```swift
	/// struct Amount {
	///   var cents: Int
	/// }
	///
	/// let amount = Parse(
	///   .convert(
	///     apply: { dollars, cents in Amount(cents: dollars * 100 + cents) },
	///     unapply: { amount in amount.cents.quotientAndRemainder(dividingBy: 100) }
	///   )
	/// ) {
	///   Digits()
	///   "."
	///   Digits(2)
	/// }
	/// ```
	///
	/// If performance is a concern, you should define a custom type that conforms to ``Conversion``
	/// instead, which avoids the overhead of escaping closures, gives the compiler the ability to
	/// better optimize, and puts your in a better position to test the conversion.
	///
	/// ```swift
	/// struct AmountConversion: Conversion {
	///   func apply(_ dollarsAndCents: (Int, Int)) -> Amount {
	///     return Amount(cents: dollarsAndCents.0 * 100 + dollarsAndCents.1)
	///   }
	///
	///   func unapply(_ amount: Amount) -> (Int, Int) {
	///     amount.cents.quotientAndRemainder(dividingBy: 100)
	///   }
	/// }
	///
	/// let amount = Parse(AmountConversion()) {
	///   Digits()
	///   "."
	///   Digits(2)
	/// }
	/// ```
	///
	/// - Parameters:
	///   - apply: A closure that attempts to convert an input into an output. `apply` is executed
	///     each time the ``apply(_:)`` method is called on the resulting conversion. If the closure
	///     returns `nil`, an error is thrown. Otherwise, the value is unwrapped.
	///   - unapply: A closure that attempts to convert an output into an input. `unapply` is executed
	///     each time the ``unapply(_:)`` method is called on the resulting conversion. If the closure
	///     returns `nil`, an error is thrown. Otherwise, the value is unwrapped.
	/// - Returns: A conversion that invokes the given apply and unapply functions.
	@inlinable
	public static func convert<Input: Sendable, Output: Sendable>(apply: @escaping @Sendable (Input) -> Output?, unapply: @escaping @Sendable (Output) -> Input?) -> Self where Self == AnyConversion<Input, Output> {
		.init(apply: apply, unapply: unapply)
	}
}

/// A type-erased ``Conversion``.
///
/// This conversion forwards its ``apply(_:)`` and ``unapply(_:)`` methods to an arbitrary
/// underlying conversion having the same `Input` and `Output` types, hiding the specifics of the
/// underlying ``Conversion``.
///
/// Use `AnyConversion` to wrap a conversion whose type has details you don't want to expose across
/// API boundaries, such as different modules. When you use type erasure this way, you can change
/// the underlying conversion over time without affecting existing clients.
///
/// `AnyConversion` can also be useful for experimenting with ad hoc conversions in a lightweight
/// manner. One can avoid the upfront ceremony of defining a whole new type and instead create a
/// "conformance" inline by specifying the `apply` and `unapply` functions directly
///
/// ```swift
/// Prefix { $0.isNumber }
///   .map(
///     AnyConversion(
///       apply: { Int(String($0)) },
///       unapply: { String($0)[...] {
///     )
///   )
///
/// // vs.
///
/// struct SubstringToInt: Conversion {
///   func apply(_ input: Substring) throws -> Int {
///     guard let int = Int(String(input)) else {
///       struct ConvertingError: Error {}
///       throw ConvertingError()
///     }
///     return int
///   }
///
///   func unapply(_ output: Int) -> Substring {
///     String(output)[...]
///   }
/// }
///
/// Prefix { $0.isNumber }
///   .map(SubstringToInt())
/// ```
///
/// If performance is a consideration of your parser-printer, you should avoid `AnyConversion` and
/// instead create custom types that conform to the ``Conversion`` protocol.
public struct AnyConversion<Input: Sendable, Output: Sendable>: ConversionProtocol {
	public typealias Input = Input
	public typealias Output = Output
	
	@usableFromInline
	let _apply: @Sendable (Input) throws -> Output
	
	@inlinable
	var nillableApply: @Sendable (Input) -> Output? {
		{ try? self.apply($0) }
	}
	
	@usableFromInline
	let _unapply: @Sendable (Output) throws -> Input
	
	@inlinable
	var nillableUnapply: @Sendable (Output) -> Input? {
		{ try? self.unapply($0) }
	}
	
	/// Creates a type-erasing conversion to wrap the given conversion.
	///
	/// - Parameter conversion: A conversion to wrap with a type eraser.
	@inlinable
	public init<C: ConversionProtocol>(_ conversion: C) where C.Input == Input, C.Output == Output {
		self._apply = conversion.apply
		self._unapply = conversion.unapply
	}
	
	/// Creates a conversion that wraps the given closures in its ``apply(_:)`` and ``unapply(_:)``
	/// methods, throwing an error when `nil` is returned.
	///
	/// - Parameters:
	///   - apply: A closure that attempts to convert an input into an output. `apply` is executed
	///     each time the ``apply(_:)`` method is called on the resulting conversion. If the closure
	///     returns `nil`, an error is thrown. Otherwise, the value is unwrapped.
	///   - unapply: A closure that attempts to convert an output into an input. `unapply` is executed
	///     each time the ``unapply(_:)`` method is called on the resulting conversion. If the closure
	///     returns `nil`, an error is thrown. Otherwise, the value is unwrapped.
	@inlinable
	public init(apply: @escaping @Sendable (Input) -> Output?, unapply: @escaping @Sendable (Output) -> Input?) {
		self._apply = {
			guard let value = apply($0) else { throw ConvertingError() }
			return value
		}
		self._unapply = {
			guard let value = unapply($0) else { throw ConvertingError() }
			return value
		}
	}
	
	@inlinable
	public func apply(_ input: Input) throws -> Output {
		try self._apply(input)
	}
	
	@inlinable
	public func unapply(_ output: Output) throws -> Input {
		try self._unapply(output)
	}
	
	@inlinable
	/// Inverts the partial isomorphism.
	public var inverted: AnyConversion<Output, Input> {
		return AnyConversion<Output, Input>(
			apply: self.nillableUnapply,
			unapply: self.nillableApply
		)
	}
	
	@inlinable
	/// Input partial isomorphism between `(Input, Output)` and `(Output, Input)`.
	public static var flip: AnyConversion<(Input, Output), (Output, Input)> {
		return .init(
			apply: { ($1, $0) },
			unapply: { ($1, $0) }
		)
	}
}

extension ConversionProtocol where Self == AnyConversion<Substring.UTF8View, String> {
	@inlinable
	//fileprivate
	public static var unicode: Self {
		Self(
			apply: {
				UInt32(Substring($0), radix: 16)
					.flatMap(UnicodeScalar.init)
					.map(String.init)
			},
			unapply: {
				$0.unicodeScalars.first
					.map { String(UInt32($0), radix: 16)[...].utf8 }
			}
		)
	}
}

extension AnyConversion {
    /// Composes two partial isomorphisms.
	@inlinable
	public static func >>> <C> (lhs: AnyConversion<Input, Output>, rhs: AnyConversion<Output, C>) -> AnyConversion<Input, C> {
        return .init(
			apply: lhs.nillableApply >=> rhs.nillableApply,
            unapply: rhs.nillableUnapply >=> lhs.nillableUnapply
        )
    }

    /// Backwards composes two partial isomorphisms.
	@inlinable
	public static func <<< <C> (lhs: AnyConversion<Output, C>, rhs: AnyConversion<Input, Output>) -> AnyConversion<Input, C> {
        return .init(
            apply: rhs.nillableApply >=> lhs.nillableApply,
            unapply: lhs.nillableUnapply >=> rhs.nillableUnapply
        )
    }
}

extension AnyConversion: SemigroupProtocol & MonoidProtocol where Input: SemigroupProtocol, Output: SemigroupProtocol {
	@inlinable
	public static func <> (lhs: AnyConversion<Input, Output>, rhs: AnyConversion<Input, Output>) -> AnyConversion<Input, Output> {
		return .init(
			apply: { origin in
				guard let lhs = try? lhs.apply(origin) else { return rhs.nillableApply(origin) }
				guard let rhs = try? rhs.apply(origin) else { return lhs }
				return lhs <> rhs
			},
			unapply: { target in
				guard let lhs = try? lhs.unapply(target) else { return rhs.nillableUnapply(target) }
				guard let rhs = try? rhs.unapply(target) else { return lhs }
				return lhs <> rhs
			}
		)
	}

	@inlinable
	public static var empty: AnyConversion<Input, Output> {
		return AnyConversion(
			apply: { ($0 as? Output) },
			unapply: { ($0 as? Input) }
		)
	}
}

extension ConversionProtocol where Output == Input {
	@inlinable
	/// The identity partial isomorphism.
	public static var idIso: AnyConversion<Input, Output> {
		return .init(
			apply: { $0 },
			unapply: { $0 }
		)
	}
}

extension ConversionProtocol where Output == (Input, Unit) {
	@inlinable
	/// An isomorphism between `Input` and `(Input, Unit)`.
    public static var unitIso: AnyConversion<Input, Output> {
        return .init(
			apply: { input in return (input, unit) },
            unapply: { (output, _) in return output }
        )
    }
}

extension Optional where Wrapped: Sendable {
    public enum iso {
		@inlinable
		/// Input partial isomorphism `(Input) -> Input?`
        public static var some: AnyConversion<Wrapped, Wrapped?> {
            return .init(
                apply: { Optional.some($0) },
                unapply: { id($0) }
            )
        }
    }
}

@inlinable
public func opt<Input: Sendable, Output: Sendable>(_ f: AnyConversion<Input, Output>) -> AnyConversion<Input?, Output?> {
    return AnyConversion<Input?, Output?>(
        apply: {
			do {
				return try $0
					.flatMap(
						f
							.apply
					)
			} catch {
				return nil
			}
        },
        unapply: {
			do {
				return try $0
					.flatMap(
						f
							.unapply
					)
			} catch {
				return nil
			}
        }
    )
}

@inlinable
public func req<Input, Output>(_ f: AnyConversion<Input, Output>) -> AnyConversion<Input?, Output> {
    return Optional.iso.some.inverted >>> f
}

extension AnyConversion where Input == String, Output == any Sendable {
	@inlinable
	public static var any: AnyConversion {
		return AnyConversion(
			apply: { $0 },
			unapply: { ($0 as? Input) ?? String(describing: $0) }
		)
	}
}

extension AnyConversion { // where Input == any Sendable, Output == any Sendable { //where Input == any Sendable & Monoid, Output == any Sendable & Monoid {
	@inlinable
	public static var any: AnyConversion {
		return AnyConversion(
			apply: { ($0 as? Output) },
			unapply: { ($0 as? Input) }
		)
	}
}

extension AnyConversion where Input == String, Output == Int {
	@inlinable
	/// An isomorphism between strings and integers.
    public static var int: AnyConversion {
        return AnyConversion(
            apply: { Int.init($0) },
            unapply: { String.init(describing: $0) }
        )
    }
}

extension AnyConversion where Input == String, Output == IntWithDigits {
	@inlinable
	/// An isomorphism between strings and integers.
    public static var int: AnyConversion {
        return AnyConversion(
            apply: { IntWithDigits.init($0) },
            unapply: { String.init(describing: $0) }
        )
    }
}

extension AnyConversion where Input == String, Output == (String, IntWithDigits?) {
	@inlinable
	/// An isomorphism between strings and integer/string combinations.
    public static var intString: AnyConversion {
        return AnyConversion(
            apply: { arg in
                var result = arg
                    .splitByNumber
                let first = result
                    .removeFirst()
                return (
                    result
                        .joined(),
                    IntWithDigits(
                        String(first)
                    )
                )
            },
            unapply: { string, int in
                guard let _ = int else { return string }
                return String(int!) + string
            }
        )
    }
}

extension AnyConversion where Input == String, Output == (String, Int?) {
	@inlinable
	/// An isomorphism between strings and integer/string combinations.
    public static var intString: AnyConversion {
        return AnyConversion(
            apply: {
                let result = $0.lParseNumber
                return (result.rest, result.match)
            },
            unapply: { return String($1!) + $0 }
        )
    }
}

extension AnyConversion where Input == String, Output == Bool {
	@inlinable
	/// An isomorphism between strings and booleans.
    public static var bool: AnyConversion {
        return .init(
            apply: {
                $0 == "true" || $0 == "1" ? true
                    : $0 == "false" || $0 == "0" ? false
                    : nil
        },
            unapply: { $0 ? "true" : "false" }
        )
    }
}

extension AnyConversion where Input == String, Output == String {
	@inlinable
	/// The identity isomorphism between strings.
    public static var string: AnyConversion {
        return .idIso
    }
}

extension AnyConversion where Input == String, Output == [String] {
	@inlinable
	/// An isomorphism between strings (array).
    public static var split: AnyConversion {
        return AnyConversion(
            apply: { $0.splitByNumber },
            unapply:{ return $0.joined() }
        )
    }
}

extension AnyConversion where Input == String, Output == Character {
	@inlinable
	/// The identity isomorphism between strings.
    public static var char: AnyConversion {
        return AnyConversion(
            apply: { Character.init($0) },
            unapply: { String.init($0) }
        )
    }
}

extension AnyConversion where Input == String, Output == Double {
	@inlinable
	/// An isomorphism between strings and doubles.
    public static var double: AnyConversion {
        return AnyConversion(
            apply: { Double.init($0) },
            unapply: { String.init(describing: $0) }
        )
    }
}

extension AnyConversion where Input == String, Output: LosslessStringConvertible {
	@inlinable
	public static var losslessStringConvertible: AnyConversion {
        return AnyConversion(
            apply: { Output.init($0) },
            unapply: { String.init($0) }
        )
    }
}

extension AnyConversion where Output: RawRepresentable, Output.RawValue == Input {
	@inlinable
	public static var rawRepresentable: AnyConversion {
        return .init(
            apply: { Output.init(rawValue: $0) },
            unapply: { $0.rawValue }
        )
    }
}

extension AnyConversion where Input == String, Output == UUID {
	@inlinable
	public static var uuid: AnyConversion<String, UUID> {
        return AnyConversion(
            apply: { UUID.init(uuidString: $0) },
            unapply: { $0.uuidString }
        )
    }
}

extension AnyConversion where Input: Codable, Output == Data {
	@inlinable
	public static func codableToJsonData(_ type: Input.Type, encoder: JSONEncoder = .init(), decoder: JSONDecoder = .init()) -> AnyConversion {
        return .init(
            apply: {
                try? encoder.encode($0)
            },
            unapply: {
                try? decoder.decode(type, from: $0)
            }
        )
    }
}

public let jsonDictionaryToData = AnyConversion<[String: String], Data>(
    apply: { try? JSONSerialization.data(withJSONObject: $0) },
    unapply: {
        (try? JSONSerialization.jsonObject(with: $0))
            .flatMap { $0 as? [String: String] }
})

extension Array<String> {
	@inlinable
	public init(_ one: String) {
        self = []; self.append(one)
    }
}

extension AnyConversion where Input == String, Output == Array<String> {
	@inlinable
	public static func array() -> AnyConversion {
        return AnyConversion(
            apply: { (string) in
                return Output.init(string)
            },
            unapply: { (l) -> String? in return String(describing: l) }
        )
    }
}

@inlinable
public func array<Input>() -> AnyConversion<String, [Input]> {
    return AnyConversion<String, [Input]>(
        apply: { (string) -> [Input]? in return nil },
        unapply: { (array) -> String? in return nil }
    )
}

@inlinable
public func first<Input>(where predicate: @escaping @Sendable (Input) -> Bool) -> AnyConversion<[Input], Input> {
    return AnyConversion<[Input], Input>(
        apply: { $0.first(where: predicate) },
        unapply: { [$0] }
    )
}

@inlinable
public func filter<Input>(_ isIncluded: @escaping @Sendable (Input) -> Bool) -> AnyConversion<[Input], [Input]> {
    return AnyConversion<[Input], [Input]>(
        apply: { $0.filter(isIncluded) },
        unapply: { id($0) }
    )
}

@inlinable
public func key<K, V>(_ key: K) -> AnyConversion<[K: V], V> {
    return AnyConversion<[K: V], V>(
        apply: { $0[key] },
        unapply: { [key: $0] }
    )
}

@inlinable
public func keys<K, V>(_ keys: [K]) -> AnyConversion<[K: V], [K: V]> {
    return .init(
        apply: { $0.filter { key, _ in keys.contains(key) } },
		unapply: { id($0) }
    )
}

extension Collection {
	@inlinable
    public func head() -> (Self.Element, Self.SubSequence)? {
        guard let x = self.first else { return nil }
        return (x, self.dropFirst())
    }
}

