//
//  StringInterpolationTemplateIso.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 23.09.24.
//

extension ConversionProtocol where Self == Conversions.StringInterpolationTemplateIso<[StringInterpolationElement]> {
	@inlinable
	public static var stringInterpolationTemplate: Self { .init() }
}

extension ConversionProtocol where Output == [StringInterpolationElement] {
	@inlinable
	public var stringInterpolationTemplate: Conversions.MapIso<Self, Conversions.StringInterpolationTemplateIso<Output>> { self.map(.stringInterpolationTemplate) }
}

extension Conversions {
	public struct StringInterpolationTemplateIso<Value: Sendable>: ConversionProtocol {
		@usableFromInline
		init() {}
		
		@inlinable
		public func apply(_ input: [StringInterpolationElement]) ->  [StringInterpolationElementPair] {
			var returnElements: [StringInterpolationElementPair] = .init()
			var firstElement: StringInterpolationElementPair? = nil
			
			for element in input {
				if let _ = firstElement {
					switch element {
						case .empty:
							returnElements.append(firstElement!)
							return returnElements
						case .interpolation(let interpolation):
							returnElements.append(firstElement!)
							firstElement = StringInterpolationElementPair(interpolationKey: interpolation)
						case .string(let string):
							returnElements.append(StringInterpolationElementPair(interpolationKey: firstElement!.interpolationKey, stringValue: string))
							firstElement = nil
					}
				} else if case .string(let string) = element {
					returnElements.append(StringInterpolationElementPair(stringValue: string))
					firstElement = nil
				} else if case .interpolation(let interpolation) = element {
					firstElement = StringInterpolationElementPair(interpolationKey: interpolation)
				}
			}
			if let _ = firstElement { returnElements.append(firstElement!) } // one left
			return returnElements
		}

		@inlinable
		public func unapply(_ output: [StringInterpolationElementPair]) throws -> [StringInterpolationElement] {
			output.reduce(into: [StringInterpolationElement]()) { accumulatedValue, nextValue in
				if let next = nextValue.interpolationKey {
					accumulatedValue.append(.interpolation(next))
				} else {
					accumulatedValue.append(.empty)
				}
				if let next = nextValue.stringValue {
					accumulatedValue.append(.interpolation(next))
				} else {
					accumulatedValue.append(.empty)
				}
			}
		}
	}
}
