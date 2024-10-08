//
//  UUID.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

import Foundation

extension UUID: Sendable {
	/// A parser that consumes a hexadecimal UUID from the beginning of a collection of UTF-8 code
	/// units.
	///
	/// ```swift
	/// var input = "deadbeef-dead-beef-dead-beefdeadbeef,"[...]
	/// try UUID.parser().parse(&input)  // DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF
	/// input                            // ","
	/// ```
	///
	/// - Parameter inputType: The collection type of UTF-8 code units to parse.
	/// - Returns: A parser that consumes a hexadecimal UUID from the beginning of a collection of
	///   UTF-8 code units.
	@inlinable
	public static func parser<Input>(of inputType: Input.Type = Input.self) -> Parsers.UUIDParser<Input> {
		.init()
	}
}

extension Parsers {
	/// A parser that consumes a UUID from the beginning of a collection of UTF8 code units.
	///
	/// You will not typically need to interact with this type directly. Instead you will usually use
	/// `UUID.parser()`, which constructs this type.
	public struct UUIDParser<Input: Collection & Sendable>: ParserProtocol where Input.SubSequence == Input, Input.Element == UTF8.CodeUnit {
		@inlinable
		public init() {}
		
		@inlinable
		public func parse(_ input: inout Input) throws -> UUID {
			func parseHelp<C: Collection>(_ bytes: C) throws -> UUID where C.Element == UTF8.CodeUnit {
				var prefix = bytes.prefix(36)
				guard prefix.count == 36 else { throw ParsingError.expectedInput("UUID", at: input) }
				
				@inline(__always)
				func digit(for n: UTF8.CodeUnit) throws -> UTF8.CodeUnit {
					switch n {
						case .init(ascii: "0") ... .init(ascii: "9"):
							return UTF8.CodeUnit(n - .init(ascii: "0"))
						case .init(ascii: "A") ... .init(ascii: "F"):
							return UTF8.CodeUnit(n - .init(ascii: "A") + 10)
						case .init(ascii: "a") ... .init(ascii: "f"):
							return UTF8.CodeUnit(n - .init(ascii: "a") + 10)
						default:
							throw ParsingError.expectedInput("UUID", at: input)
					}
				}
				@inline(__always)
				func nextByte() throws -> UInt8 {
					try digit(for: prefix.removeFirst()) * 16 + digit(for: prefix.removeFirst())
				}
				
				@inline(__always)
				func chompHyphen() throws {
					guard prefix.removeFirst() == .init(ascii: "-") else { throw ParsingError.expectedInput("UUID", at: input) }
				}
				
				let _00 = try nextByte()
				let _01 = try nextByte()
				let _02 = try nextByte()
				let _03 = try nextByte()
				try chompHyphen()
				let _04 = try nextByte()
				let _05 = try nextByte()
				try chompHyphen()
				let _06 = try nextByte()
				let _07 = try nextByte()
				try chompHyphen()
				let _08 = try nextByte()
				let _09 = try nextByte()
				try chompHyphen()
				let _10 = try nextByte()
				let _11 = try nextByte()
				let _12 = try nextByte()
				let _13 = try nextByte()
				let _14 = try nextByte()
				let _15 = try nextByte()
				
				input.removeFirst(36)
				return UUID(
					uuid: (
						_00, _01, _02, _03,
						_04, _05,
						_06, _07,
						_08, _09,
						_10, _11, _12, _13, _14, _15
					)
				)
			}
			return try input.withContiguousStorageIfAvailable(parseHelp) ?? parseHelp(input)
		}
	}
}

extension Parsers.UUIDParser: ParserPrinterProtocol & SendableMarker where Input: PrependableCollectionProtocol {
	@inlinable
	public func print(_ output: UUID, into input: inout Input) {
		input.prepend(contentsOf: output.uuidString.utf8)
	}
}
