//
//  TemplateTest.swift
//
//
//  Created by Thomas Benninghaus on 13.08.24.
//

import XCTest
import Parsing

final class TemplateTest: XCTestCase, @unchecked Sendable {
    func testRender() {
        let t: Template = "Hello world!"
        XCTAssertEqual(t.render(), "Hello world!")
    }
    
    func testDefault() {
        let name: String? = nil
        let t: Template = "Hello \(name, default: "world")!"
        XCTAssertEqual(t.render(), "Hello world!")
    }
    
    func testAppend() {
        var stringTemplate: Template = .empty
        XCTAssertTrue(stringTemplate.isEmpty)
        
        stringTemplate = Template(stringLiteral: "Hello")
        XCTAssertFalse(stringTemplate.isEmpty)
        XCTAssertEqual("Hello", stringTemplate.render())

        let newTemplate = stringTemplate
            <>
            Template(stringLiteral: ", ")
            <>
            Template(stringLiteral: "Blob")
            <>
            Template(stringLiteral: "!")
        XCTAssertEqual("Hello, Blob!", newTemplate.render())
        
        stringTemplate = Template.init(parts: ["Goodbye", ", ", "Blob", "!"])
        XCTAssertEqual("Goodbye, Blob!", stringTemplate.render())
    }

    func testInclude() {
        let t1: Template = "Hello"
        let t2: Template = "\(t1) world!"
        XCTAssertEqual(t2.render(), "Hello world!")
    }

    func testExtension() {
        let now = Date()
        let df = DateFormatter()
        df.dateFormat = "y-MM-dd"
        let date = df.string(from: now)

        let t: Template = "\(h1: "Today is \(date: now, format: "y-MM-dd")")"
        XCTAssertEqual(t.render(), "<h1>Today is \(date)</h1>")
    }

}

extension Template.StringInterpolation {
    static let dateFormatter = DateFormatter()
    func appendInterpolation(date: Date = Date(), format: String) {
        Template.StringInterpolation.dateFormatter.dateFormat = format
        appendLiteral(Template.StringInterpolation.dateFormatter.string(from: date))
    }

    func appendInterpolation(h1 body: Template) {
        appendInterpolation("<h1>\(body)</h1>" as Template)
    }
}
