@preconcurrency import Benchmark
import Foundation
import Parsing

/// This benchmark shows how to create a naive JSON parser with combinators.
///
/// It is mostly implemented according to the [spec](https://www.json.org/json-en.html) (we take a
/// shortcut and use `Double.parser()`, which behaves accordingly).
let jsonSuite = BenchmarkSuite(name: "JSON", suiteBuilder: { suite in
	let json = JSONValue()
	let input = #"""
		{
			"hello": true,
			"goodbye": 42.42,
			"whatever": null,
			"xs": [1, "hello", null, false],
			"ys": {
				"0": 2,
				"1": "goodbye\n"
			}
		}
		"""#
    var jsonOutput: JSONValue.Output!
    suite.benchmark("Parser") {
		var input = input[...].utf8
		jsonOutput = try json.parse(&input)
    } tearDown: {
		precondition(
			jsonOutput == .object([
				"hello": .boolean(true),
				"goodbye": .number(42.42),
				"whatever": .null,
				"xs": .array([.number(1), .string("hello"), .null, .boolean(false)]),
				"ys": .object([
				  "0": .number(2),
				  "1": .string("goodbye\n"),
				]),
			])
		)
		precondition(
			try! Substring(json.print(jsonOutput)) == """
				{\
				"goodbye":42.42,\
				"hello":true,\
				"whatever":null,\
				"xs":[1.0,"hello",null,false],\
				"ys":{"0":2.0,"1":"goodbye\\n"}\
			}
			"""
		)
		precondition(try! json.parse(json.print(jsonOutput)) == jsonOutput)
	}

    let dataInput = Data(input.utf8)
    var objectOutput: Any!
    suite.benchmark("JSONSerialization") {
      objectOutput = try JSONSerialization.jsonObject(with: dataInput, options: [])
    } tearDown: {
      precondition(
        (objectOutput as! NSDictionary) == [
          "hello": true,
          "goodbye": 42.42,
          "whatever": NSNull(),
          "xs": [1, "hello", nil, false] as [Any?],
          "ys": [
            "0": 2,
            "1": "goodbye\n",
          ] as [String: Any],
        ]
      )
    }
} )

extension UTF8.CodeUnit {
	fileprivate var isHexDigit: Bool {
		(.init(ascii: "0") ... .init(ascii: "9")).contains(self) ||
		(.init(ascii: "A") ... .init(ascii: "F")).contains(self) ||
		(.init(ascii: "a") ... .init(ascii: "f")).contains(self)
	}
	
	fileprivate var isUnescapedJSONStringByte: Bool {
		self != .init(ascii: "\"") && self != .init(ascii: "\\") && self >= .init(ascii: " ")
	}
}

extension ConversionProtocol where Self == AnyConversion<Substring.UTF8View, String> {
	fileprivate static var unicode: Self {
		Self(
			apply: {
				UInt32(Substring($0), radix: 16)
					.flatMap(UnicodeScalar.init)
					.map(String.init)
			},
			unapply: {
				$0.unicodeScalars.first
					.map { String(UInt32($0), radix: 16)[...].utf8 }
			}
		)
	}
}
