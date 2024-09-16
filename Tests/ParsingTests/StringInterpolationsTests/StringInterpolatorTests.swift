//
//  StringInterpolatorTests.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 28.09.24.
//

import Foundation
import XCTest
import Parsing

final class StringInterpolatorTests: XCTestCase, @unchecked Sendable {
	let interpolator = StringInterpolator(delimiters: StringInterpolationDelimiters(startingWith: "%(", endingWith: ")"))
	
	func testGetInterpolations() {
		var input = "Hello, world!"
		var output: String = "Hello!"
		let interpolations: @Sendable (_ input: String, _ output: String) -> [String: String]? = { input, output in self.interpolator.getInterpolations(input, with: output) }
		var expectedInterpolations: [String: String] = .init()
		
		// no match
		XCTAssertNil(interpolations(input, output))
		
		// match without interpolations
		output = input
		XCTAssertEqual(expectedInterpolations, interpolations(input, output))
		
		// one interpolation
		input = "Hello, %(name)!"
		expectedInterpolations = ["name": "world"]
		XCTAssertEqual(expectedInterpolations, interpolations(input, output))
		
		// two interpolations
		input = "%(greeting), %(name)!"
		expectedInterpolations = ["greeting": "Hello", "name": "world"]
		XCTAssertEqual(expectedInterpolations, interpolations(input, output))
		
		// three interpolations
		input = "%(greeting) %(name) and %(name2)"
		output = "Hello Foo and Bar"
		expectedInterpolations = ["greeting": "Hello", "name": "Foot", "name2": "Bar"]
		XCTAssertEqual(expectedInterpolations, interpolations(input, output))
	}

	func testInterpolate() {
		var input = "Hello, world!"
		let output: @Sendable (_ input: String, _ interpolations: [String: String]) -> String = { input,interpolations in self.interpolator.interpolate(input, with: interpolations) }
		var expectedOutput = input
		var interpolations: [String: String] = .init()
		
		// match simple
		XCTAssertEqual(expectedOutput, output(input, interpolations))
		
		// one interpolation
		input = "Hello, %(name)!"
		interpolations = ["name": "world"]
		XCTAssertEqual(expectedOutput, output(input, interpolations))
		
		//rawValue if does not match
		interpolations = .init()
		expectedOutput = "Hello, world!"
		XCTAssertEqual(expectedOutput, output(input, interpolations))
		
		// two interpolations
		input = "%(greeting), %(name)!"
		interpolations = ["greeting": "Hello", "name": "world"]
		XCTAssertEqual(expectedOutput, output(input, interpolations))
		
		// three interpolations
		input = "%(greeting) %(name) and %(name2)"
		interpolations = ["greeting": "Hello", "name": "Foot", "name2": "Bar"]
		expectedOutput = "Hello Foo and Bar"
		XCTAssertEqual(expectedOutput, output(input, interpolations))
		
		// many interpolations
		input = "%(greeting) %(name) and %(name2)"
		interpolations = ["greetinga": "Hello", "namea": "Foot", "name2a": "Bar", "greetingb": "Hello", "nameb": "Foot", "name2b": "Bar", "greetingc": "Hello", "namec": "Foot", "name2c": "Bar", "greetingd": "Hello", "named": "Foot", "name2d": "Bar", "greeting": "Hello", "name": "Foot", "name2": "Bar"]
		expectedOutput = "Hello Foo and Bar"
		XCTAssertEqual(expectedOutput, output(input, interpolations))
		
		// many interpolations one missing
		input = "%(greeting) %(name) and %(name3)"
		expectedOutput = input
		XCTAssertEqual(expectedOutput, output(input, interpolations))
	}
}
