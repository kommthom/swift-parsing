import Parsing
import XCTest

final class ParserBuilderTests: XCTestCase {
	func testBuildIfVoid() {
		let parseComma = true
		var parser = Parse(input: Substring.self) {
			"Hello"
			if parseComma {
				","
			}
			" "
			Prefix { $0 != "!" }
			"!"
		}
		var input = "Hello, world!"[...]
		XCTAssertEqual("world", try parser.parse(&input))
		XCTAssertEqual(input, ""[...])

		input = "Hello world!"[...]
		XCTAssertThrowsError(try parser.parse(&input)) { error in
			XCTAssertEqual(
				"""
				error: unexpected input
				 --> input:1:6
				1 | Hello world!
				  |      ^ expected ","
				""",
				"\(error)"
			)
		}
		XCTAssertEqual(input, " world!"[...])

		let parseComma1 = false
		parser = Parse {
			"Hello"
			if parseComma1 {
				","
			}
			" "
			Prefix { $0 != "!" }
			"!"
		}
		input = "Hello world!"
		XCTAssertEqual("world", try parser.parse(&input))
		XCTAssertEqual(input, ""[...])

		input = "Hello, world!"
		XCTAssertThrowsError(try parser.parse(&input)) { error in
			XCTAssertEqual(
				"""
				error: unexpected input
				 --> input:1:6
				1 | Hello, world!
				  |      ^ expected " "
				""",
				"\(error)"
			)
		}
		XCTAssertEqual(input, ", world!"[...])
	}

	func testBuildIfOutput() throws {
		let parseInt = true
		var parser = Parse(input: Substring.self) {
			if parseInt {
				Int.parser()
				" "
			}
			Rest()
		}
		var input = "42 Blob"[...]
		var (int, string) = try XCTUnwrap(parser.parse(&input))
		XCTAssertEqual(42, int)
		XCTAssertEqual("Blob", string)
		XCTAssertEqual(input, ""[...])

		input = "Blob"
		XCTAssertThrowsError(try parser.parse(&input)) { error in
			XCTAssertEqual(
				"""
				error: unexpected input
				 --> input:1:1
				1 | Blob
				  | ^ expected integer
				""",
				"\(error)"
			)
		}
		XCTAssertEqual(input, "Blob"[...])

		let parseInt1 = false
		parser = Parse {
			if parseInt1 {
				Int.parser()
				" "
			}
			Rest()
		}
		input = "Blob"
		(int, string) = try XCTUnwrap(parser.parse(&input))
		XCTAssertEqual(nil, int)
		XCTAssertEqual("Blob", string)
		XCTAssertEqual(input, ""[...])
	}

	func testWrapsCustomErrors() {
		struct MyParser: ParserProtocol {
			func parse(_ input: inout Substring) throws {
				struct MyError: LocalizedError {
					var errorDescription: String? {
						"whoops!"
					}
				}
				throw MyError()
			}
		}

		var input = "123 Blob"[...]
		XCTAssertThrowsError(
			try Parse(input: Substring.self) {
				Int.parser()
				MyParser()
			}
			.parse(&input)
		) { error in
			XCTAssertEqual(
				"""
				error: whoops!
				 --> input:1:4
				1 | 123 Blob
				  |    ^
				""",
				"\(error)"
			)
		}
		XCTAssertEqual(input, " Blob"[...])

		input = "123 Blob"[...]
		func custom<P>(@ParserBuilder<Substring> _ build: () -> P) -> P {
			build()
		}
		XCTAssertThrowsError(
			try custom {
				Int.parser()
				MyParser()
			}
			.parse(&input)
		) { error in
			XCTAssertEqual(
				"""
				error: whoops!
				 --> input:1:4
				1 | 123 Blob
				  |    ^
				""",
				"\(error)"
			)
		}
		XCTAssertEqual(input, " Blob"[...])
	}
}
