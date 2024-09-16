import Parsing
import XCTest

final class OneOfTests: XCTestCase {
	func testOneOfSingleton() {
		var input = "AB"[...]
		XCTAssertThrowsError(
			try Parse(input: Substring.self) { OneOf { Prefix(2) { $0 == "A" } } }
				.parse(&input)
		)
		XCTAssertEqual("B", Substring(input))
	}
	
	func testOneOfFirstSuccess() {
		var input = "New York, Hello!"[...]
		XCTAssertNoThrow(
			try OneOf {
				"New York"
				"Berlin"
			}
				.parse(&input)
		)
		XCTAssertEqual(", Hello!", Substring(input))
	}
	
	func testOneOfSecondSuccess() {
		var input = "Berlin, Hello!"[...]
		XCTAssertNoThrow(
			try OneOf {
				"New York"
				"Berlin"
			}
				.parse(&input)
		)
		XCTAssertEqual(", Hello!", Substring(input))
	}
	
	func testOneOfFailure() {
		var input = "London, Hello!"[...]
		XCTAssertThrowsError(
			try OneOf {
				"New York"
				"Berlin"
			}
				.parse(&input)
		) { error in
			XCTAssertEqual(
				"""
				error: unexpected input
				 --> input:1:1
				1 | London, Hello!
				  | ^ expected "New York"
				  | ^ expected "Berlin"
				""",
				"\(error)"
			)
		}
		XCTAssertEqual("London, Hello!", Substring(input))
	}
	
	func testOneOfManyFirstSuccess() {
		var input = "New York, Hello!"[...]
		XCTAssertNoThrow(
			try OneOf {
				for city in ["New York", "Berlin"] {
					city
				}
			}
				.parse(&input)
		)
		XCTAssertEqual(", Hello!", Substring(input))
	}
	
	func testOneOfManyLastSuccess() {
		var input = "Berlin, Hello!"[...]
		XCTAssertNoThrow(
			try OneOf {
				for city in ["New York", "Berlin"] {
					city
				}
			}
				.parse(&input)
		)
		XCTAssertEqual(", Hello!", Substring(input))
	}
	
	func testOneOfManyLastPartialFailure() {
		var input = "Berkeley, Hello!"[...]
		XCTAssertThrowsError(
			try OneOf {
				for parser in [
					Parse {
						"New "
						"York"
					},
					Parse {
						"Ber"
						"lin"
					},
				] {
					parser
				}
			}
				.parse(&input)
		) { error in
			XCTAssertEqual(
				"""
				error: multiple failures occurred
				
				error: unexpected input
				 --> input:1:4
				1 | Berkeley, Hello!
				  |    ^ expected "lin"
				
				error: unexpected input
				 --> input:1:1
				1 | Berkeley, Hello!
				  | ^ expected "New "
				""",
				"\(error)"
			)
		}
		XCTAssertEqual("keley, Hello!", Substring(input))
	}
	
	func testOneOfManyFailure() {
		var input = "London, Hello!"[...]
		XCTAssertThrowsError(
			try OneOf {
				"New York"
				"Berlin"
			}
				.parse(&input)
		) { error in
			XCTAssertEqual(
				"""
				error: unexpected input
				 --> input:1:1
				1 | London, Hello!
				  | ^ expected "New York"
				  | ^ expected "Berlin"
				""",
				"\(error)"
			)
		}
		XCTAssertEqual("London, Hello!", Substring(input))
	}
	
	func testRanking() {
		struct IntParser: ParserProtocol {
			var body: some ParserProtocol<Substring.UTF8View, Int> {
				OneOf {
					Int.parser()
					Prefix(2).compactMap { _ in Int?.none }
				}
			}
		}
		
		XCTAssertThrowsError(
			try IntParser().parse("Hello"[...].utf8)
		) { error in
			XCTAssertEqual(
				"""
				error: multiple failures occurred
				
				error: failed to process "Int" from "He"
				 --> input:1:1-2
				1 | Hello
				  | ^^
				
				error: unexpected input
				 --> input:1:1
				1 | Hello
				  | ^ expected integer
				""",
				"\(error)"
			)
		}
	}
	
	func testRanking_2() {
		XCTAssertThrowsError(
			try Parse(input: Substring.UTF8View.self) {
				OneOf {
					Int.parser()
					Prefix(2).compactMap { _ in Int?.none }
				}
			}
				.parse("Hello")
		) { error in
			XCTAssertEqual(
				"""
				error: multiple failures occurred
				
				error: failed to process "Int" from "He"
				 --> input:1:1-2
				1 | Hello
				  | ^^
				
				error: unexpected input
				 --> input:1:1
				1 | Hello
				  | ^ expected integer
				""",
				"\(error)"
			)
		}
	}
	
	func testJSON() {
		let input = #"""
			{
				"hello": true,
				"goodbye": 42.42,
				"whatever": null,
				"xs": [1, "hello, null, false],
				"ys": {
				"0": 2,
				"1": "goodbye"
				}
			}
		"""#
		
		XCTAssertThrowsError(try JSONValue().parse(input)) { error in
			XCTAssertEqual(
	#"""
	error: multiple failures occurred

	error: unexpected input
	 --> input:5:34
	5 | …hello, null, false],
	  |                      ^ expected 1 element satisfying predicate
	  |                      ^ expected "\\"
	  |                      ^ expected "\""

	error: unexpected input
	 --> input:5:13
	5 | 		"xs": [1, "hello, null, false],
	  |             ^ expected "{"
	  |             ^ expected "["
	  |             ^ expected double
	  |             ^ expected "true" or "false"
	  |             ^ expected "null"

	error: unexpected input
	 --> input:5:11
	5 | 		"xs": [1, "hello, null, false],
	  |           ^ expected "]"

	error: unexpected input
	 --> input:5:9
	5 | 		"xs": [1, "hello, null, false],
	  |         ^ expected "{"
	  |         ^ expected "\""
	  |         ^ expected double
	  |         ^ expected "true" or "false"
	  |         ^ expected "null"

	error: unexpected input
	 --> input:4:19
	4 | 		"whatever": null,
	  |                   ^ expected "}"

	error: unexpected input
	 --> input:1:2
	1 | 	{
	  |  ^ expected "["
	  |  ^ expected "\""
	  |  ^ expected double
	  |  ^ expected "true" or "false"
	  |  ^ expected "null"
	"""#,
				"\(error)"
			)
		}
	}
}
