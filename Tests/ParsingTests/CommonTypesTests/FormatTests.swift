//
//  FormatTests.swift
//  CommonParsers
//
//  Created by Thomas Benninghaus on 20.08.24.
//

//import Foundation
//import XCTest
//import Parsing
//
//extension Routes {
//	enum iso {
//		static let echo = PartialIso(
//			apply: { (_: Prelude.Unit) -> Routes? in
//				return .echo
//			},
//			unapply: { (r: Routes) -> Prelude.Unit? in
//				return Prelude.unit
//		})
//
//		static let hello = PartialIso(
//			apply: { (s: String) -> Routes? in
//				return .hello(s)
//			},
//			unapply: { (r: Routes) -> String? in
//				guard case let .hello(str) = r else { return nil }
//				return str
//		})
//	}
//}
//
//final class FormatTests: XCTestCase, @unchecked Sendable {
//	enum Routes: CaseAccessible {
//        case echo
//        case hello(_ value: String)
//    }
//
//    func testMatch() {
//        let formats: URLFormat = scheme("https")
//            </>
//            host("me.com")
//            </>
//            [
//                path("echo"), // matches URLs with "/echo" path
//                path("hello") // matches URLs with "/hello" path
//            ]
//            .reduce(
//                .empty,
//                <|>
//            )
//        
//        var result: Parsing.Unit? = formats.match(URLComponents(string: "https://me.com/echo")!) // Prelude.unit
//        XCTAssertNil(result)
//        result = formats.match(URLComponents(string: "https://me.com/hello")!) // Prelude.unit
//        XCTAssertNil(result)
//        result = formats.match(URLComponents(string: "https://me.com/echo/hello")!) // nil
//        XCTAssertNil(result)
//        
//    }
//    
//    func testIso() {
//        let formats: URLFormat =
//            scheme("https")
//            </>
//            host("me.com")
//            </>
//            [
//                iso(
//					Routes
//						.echo
//				)
//                <¢>
//                path("echo"), // matches URLs with "/echo" path
//                iso(
//					Routes
//						.hello
//                )
//                <¢>
//                path("hello")
//                </>
//                path(.string) // matches URLs with "/hello/:string" path
//            ]
//            .reduce(.empty, <|>)
//        
////        var result  = formats.match(URLComponents(string: "https://me.com/echo")!)
//        var result  = switch formats.match(URLComponents(string: "https://me.com/echo")!) { // Routes.echo
//            case .echo: "echo"
//            case .hello(let route): route
//            case .none: ""
//        }
//        XCTAssertEqual("echo", result)
//        result  = switch formats.match(URLComponents(string: "https://me.com/echo")!) { // Routes.hello("world")
//            case .echo: "echo"
//            case .hello(let route): route
//            case .none: ""
//        }
////        result  = formats.match(URLComponents(string: "https://me.com/echo")!)
//		result  = switch formats.match(URLComponents(string: "https://me.com/echo")!) { // Routes.echo
//			case .echo: "echo"
//			case .hello(let route): route
//			case .none: ""
//		}
//		XCTAssertEqual("world", result)
////        result  = formats.match(URLComponents(string: "https://me.com/echo/hello/world")!)
//		result  = switch formats.match(URLComponents(string: "https://me.com/echo/hello/world")!) { // nil
//			case .echo: "echo"
//			case .hello(let route): route
//			case .none: ""
//		}
//        XCTAssertEqual("", result)
//    }
//}
