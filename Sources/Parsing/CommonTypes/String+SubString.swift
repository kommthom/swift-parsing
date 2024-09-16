//
//  String+SubString.swift
//  CommonParsers
//
//  Created by Thomas Benninghaus on 16.08.24.
//

import Foundation

extension String {
	@inlinable
	public var isNumber: Bool {
        return self.range(
            of: "^[+-]?[0-9]*$", // 1
            options: .regularExpression) != nil
    }
    
	@inlinable
	public func rStr(from position: Int) -> String {
        guard position > 0 && position < count else { return ""}
        let calculateStartIndex = index(endIndex, offsetBy: 0 - position)
        let calculateEndIndex = index(endIndex, offsetBy: -1)
        return String(self[calculateStartIndex...calculateEndIndex])
    }
    
	@inlinable
	public func lStr(from position: Int) -> String {
        guard position > 0 && position < count else { return ""}
        let calculateStartIndex = startIndex
        let calculateEndIndex = index(startIndex, offsetBy: position - 1)
        return String(self[calculateStartIndex...calculateEndIndex])
    }
    
	@inlinable
	public func subStr(from position: Int = 0, length: Int =  0) -> String {
        guard position > 1 - count && position < count else { return ""}
        guard length >= 0 && length < count else { return ""}
        let calculateStartIndex = position <= 0 ? index(endIndex, offsetBy: position - 1) : index(startIndex, offsetBy: position)
        let calculateEndIndex = length == 0 ? index(endIndex, offsetBy: -1) :  index(calculateStartIndex, offsetBy: length - 1)
        return String(self[calculateStartIndex...calculateEndIndex])
    }
    
	@inlinable
	public var splitByNumber: [String] {
        let initialValue: [([Character], Bool)] = []
        return self.reduce(into: initialValue) { accumulatedValue, nextChar in
            guard let lastValue = accumulatedValue.last, lastValue.1 == nextChar.isWholeNumber else {
                return accumulatedValue.append( ( [nextChar], nextChar.isWholeNumber) )
            }
            accumulatedValue.indices.last.map {
                var newValue = accumulatedValue.last!.0
                newValue.append(nextChar)
                return accumulatedValue[$0] = (
                    newValue,
                    nextChar.isWholeNumber
                )
            }
        }
        .map { String($0.0) }
    }
    
	@inlinable
	public var rParseNumber: ParsingResult<Int, String> {
        var array = splitByNumber
        guard !array.isEmpty else { return ParsingResult(self, Optional<Int>.none) }
        guard let match = Int(array.popLast()!) else { return ParsingResult(self, Optional<Int>.none) }
        return ParsingResult(array.joined(), match)
    }
    
	@inlinable
	public var rParseNumberWithDigits: ParsingResult<IntWithDigits, String> {
        var array = splitByNumber
        guard !array.isEmpty else { return ParsingResult(self, Optional<IntWithDigits>.none) }
        guard let match = IntWithDigits(array.popLast()!) else { return ParsingResult(self, Optional<IntWithDigits>.none) }
        return ParsingResult(array.joined(), match)
    }
    
	@inlinable
	public var lParseNumber: ParsingResult<Int, String> {
        var array = splitByNumber
        guard !array.isEmpty else { return ParsingResult(self, Optional<Int>.none) }
        guard let match = Int(array.removeFirst()) else { return ParsingResult(self, Optional<Int>.none) }
        return ParsingResult(array.joined(), match)
    }
    
	@inlinable
	public var lParseNumberWithDigits: ParsingResult<IntWithDigits, String> {
        var array = splitByNumber
        guard !array.isEmpty else { return ParsingResult(self, Optional<IntWithDigits>.none) }
        guard let match = IntWithDigits(array.removeFirst()) else { return ParsingResult(self, Optional<IntWithDigits>.none) }
        return ParsingResult(array.joined(), match)
    }
}
