//
//  BytesToDataIso.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 01.09.24.
//

import Foundation

extension ConversionProtocol where Self == Conversions.BytesToDataIso<Substring.UTF8View> {
	/// A conversion from `Substring.UTF8View` to `Data`.
	@inlinable
	public static var data: Self { .init() }
}

extension ConversionProtocol where Output == Substring.UTF8View {
	/// Transforms this conversion to `Substring.UTF8View` into a conversion to `Data`.
	///
	/// A fluent version of ``Conversion/data-swift.type.property-8z7qz``.
	@inlinable
	public var data: Conversions.MapIso<Self, Conversions.BytesToDataIso<Output>> {
		self.map(.data)
	}
}

extension ConversionProtocol where Self == Conversions.BytesToDataIso<ArraySlice<UInt8>> {
	/// A conversion from `ArraySlice<UInt8>` to `Data`.
	@inlinable
	public static var data: Self { .init() }
}

extension ConversionProtocol where Output == ArraySlice<UInt8> {
	/// Transforms this conversion to `ArraySlice<UInt8>` into a conversion to `Data`.
	///
	/// A fluent version of ``Conversion/data-swift.type.property-7g9sj``.
	@inlinable
	public var data: Conversions.MapIso<Self, Conversions.BytesToDataIso<Output>> {
		self.map(.data)
	}
}

extension Conversions {
	/// A conversion from a ``PrependableCollection`` of UTF-8 bytes to `Data`.
	///
	/// You will not typically need to interact with this type directly. Instead you will usually use
	/// the ``Conversion/data-swift.type.property-8z7qz`` and
	/// ``Conversion/data-swift.type.property-7g9sj`` operations, which constructs this type.
	public struct BytesToDataIso<Input: PrependableCollectionProtocol>: ConversionProtocol where Input.Element == UInt8 {
		@usableFromInline
		init() {}

		@inlinable
		public func apply(_ input: Input) -> Data {
			.init(input)
		}

		@inlinable
		public func unapply(_ output: Data) -> Input {
			.init(output)
		}
	}
}
