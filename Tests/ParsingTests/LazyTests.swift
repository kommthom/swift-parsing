import Parsing
import XCTest

final class LazyTests: XCTestCase {
	actor Counter: Sendable {
		var count: Int
		init(count: Int = 0) {
			self.count = count
		}
		
		func increment() {
			count += 1
		}
	}
	func testBasics() async {
		var input = "123 Hello"[...]

		let evaluated: Counter = .init()
		let parser = Lazy<Substring, AsyncAlways<Substring, Int>> {
			await evaluated.increment()
			return AsyncAlways(42)
		}
		var result0: Int = await evaluated.count
		XCTAssertEqual(0, result0, "has not evaluated")
		var result = await parser.parse(&input)
		XCTAssertNotNil(result)
		result0 = await evaluated.count
		XCTAssertEqual(1, result0, "evaluated")
		result = await parser.parse(&input)
		XCTAssertNotNil(result)
		result0 = await evaluated.count
		XCTAssertEqual(1, result0, "did not re-evaluate")
  }
}
