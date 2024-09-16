//
//  String+SubStringTest.swift
//  CommonParsers
//
//  Created by Thomas Benninghaus on 17.08.24.
//

import Foundation
import XCTest
import Parsing

class SubStringTest: XCTestCase, @unchecked Sendable {
    let string1: String = "4711HelloBlob4712"
    let string2: String = "Hello4713Blob4714"
    let string3: String = "Hello4713x4714Blob"
    let empty = ""
    
    func testIsNumber() {
        XCTAssertEqual(false, string1.isNumber)
        XCTAssertEqual(false, string2.isNumber)
        XCTAssertEqual(false, "0234-56789".isNumber)
        XCTAssertEqual(true, "-4711".isNumber)
        XCTAssertEqual(true, "+4711".isNumber)
        XCTAssertEqual(true, "666".isNumber)
        XCTAssertEqual(false, "666.666".isNumber)
    }
    
    func testRStr() {
        //    func rStr(from position: Int) -> String
        XCTAssertEqual("4712", string1.rStr(from: 4))
        XCTAssertEqual("", string2.rStr(from: 0))
        XCTAssertEqual("", string2.rStr(from: -4))
        XCTAssertEqual("Blob", string3.rStr(from: 4))
        XCTAssertEqual("", empty.rStr(from: 4))
        XCTAssertEqual("", empty.rStr(from: 0))
    }
    
    func testLStr() {
        //    func lStr(from position: Int) -> String
        XCTAssertEqual("4711", string1.lStr(from: 4))
        XCTAssertEqual("", string2.lStr(from: 0))
        XCTAssertEqual("", string2.lStr(from: -4))
        XCTAssertEqual("Hello", string3.lStr(from: 5))
        XCTAssertEqual("", empty.lStr(from: 4))
        XCTAssertEqual("", empty.lStr(from: 0))
    }
    
    func testSubStr() {
//    func subStr(from position: Int = 0, length: Int =  0) -> String
        XCTAssertEqual("Hello", string1.subStr(from: 4, length: 5))
        XCTAssertEqual("4", string2.subStr(from: 0, length: 1))
        XCTAssertEqual("4714", string2.subStr(from: -3))
        XCTAssertEqual("4713", string3.subStr(from: 5, length: 4))
        XCTAssertEqual("", empty.subStr(from: 4))
        XCTAssertEqual("", empty.subStr(from: 0))
    }
    
    func testSplitByNumber() {
//    splitByNumber: [String]
        XCTAssertEqual(["4711", "HelloBlob", "4712"], string1.splitByNumber)
        XCTAssertEqual(["Hello", "4713", "Blob", "4714"], string2.splitByNumber)
        XCTAssertEqual(["Hello", "4713", "x", "4714", "Blob"], string3.splitByNumber)
        XCTAssertEqual([], empty.splitByNumber)
    }
    
    func testRParseNumber() {
//    rParseNumber: ParsingResult<Int, String>
        XCTAssertEqual("4711HelloBlob", string1.rParseNumber.tuple.0)
        XCTAssertEqual(4712, string1.rParseNumber.tuple.1)
        XCTAssertEqual("Hello4713Blob", string2.rParseNumber.tuple.0)
        XCTAssertEqual(4714, string2.rParseNumber.tuple.1)
        XCTAssertEqual("Hello4713x4714Blob", string3.rParseNumber.tuple.0)
        XCTAssertEqual(nil, string3.rParseNumber.tuple.1)
        XCTAssertEqual("", empty.rParseNumber.tuple.0)
        XCTAssertEqual(nil, empty.rParseNumber.tuple.1)
    }
    
    func testLParseNumber() {
        //    lParseNumber: ParsingResult<Int, String>
        XCTAssertEqual("HelloBlob4712", string1.lParseNumber.tuple.0)
        XCTAssertEqual(4711, string1.lParseNumber.tuple.1)
        XCTAssertEqual("Hello4713Blob4714", string2.lParseNumber.tuple.0)
        XCTAssertEqual(nil, string2.lParseNumber.tuple.1)
        XCTAssertEqual("Hello4713x4714Blob", string3.lParseNumber.tuple.0)
        XCTAssertEqual(nil, string3.lParseNumber.tuple.1)
        XCTAssertEqual("", empty.lParseNumber.tuple.0)
        XCTAssertEqual(nil, empty.lParseNumber.tuple.1)
    }
}
