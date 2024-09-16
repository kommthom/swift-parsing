//
//  StringFormattingProtocol.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 19.09.24.
//

public protocol StringFormattingProtocol {
	@inlinable
	static var format: String { get }
	@inlinable
	var arg: CVarArguments { get }
}

//extension NSObject: StringFormattingProtocol {
//	static public var format: String { return "@" }
//	public var arg: CVarArguments { return CVarArguments.init(arg: self) }
//}

extension Unit: StringFormattingProtocol {
	@inlinable
	static public var format: String { return "" }
	@inlinable
	public var arg: CVarArguments {
		return CVarArguments.init(arg: "")
	}
}

extension Character: StringFormattingProtocol {
	@inlinable
	static public var format: String { return "c" }
	@inlinable
	public var arg: CVarArguments { return CVarArguments.init(arg: UnicodeScalar(String(self))!.value) }
}

extension String: StringFormattingProtocol {
	@inlinable
	static public var format: String { return "@" }
	@inlinable
	public var arg: CVarArguments { return CVarArguments.init(arg: self) }
}

extension CChar: StringFormattingProtocol {
	@inlinable
	static public var format: String { return "hhd" }
	@inlinable
	public var arg: CVarArguments { return CVarArguments.init(arg: self) }
}

extension CShort: StringFormattingProtocol {
	@inlinable
	static public var format: String { return "hd" }
	@inlinable
	public var arg: CVarArguments { return CVarArguments.init(arg: self) }
}

extension CLong: StringFormattingProtocol {
	@inlinable
	static public var format: String { return "ld" }
	@inlinable
	public var arg: CVarArguments { return CVarArguments.init(arg: self) }
}

extension CLongLong: StringFormattingProtocol {
	@inlinable
	static public var format: String { return "lld" }
	@inlinable
	public var arg: CVarArguments { return CVarArguments.init(arg: self) }
}

extension Double: StringFormattingProtocol {
	@inlinable
	static public var format: String { return "Lf" }
	@inlinable
	public var arg: CVarArguments { return CVarArguments.init(arg: self) }
}

extension AnyConversion where Input == String, Output: StringFormattingProtocol {
	@inlinable
	public var formatted: AnyConversion {
		return AnyConversion(
			apply: { try! apply($0) },
			unapply: { _ in "%\(Output.format)" }
		)
	}

	@inlinable
	public func formatted(index: UInt) -> AnyConversion {
		return AnyConversion(
			apply: { try! apply($0) },
			unapply: { _ in "%\(index)$\(Output.format)" }
		)
	}
}
