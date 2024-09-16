//
//  URLFormat.swift
//  CommonParsers
//
//  Created by Thomas Benninghaus on 18.08.24.
//

import Foundation

//infix operator </>: infixr4
//infix operator <?>: infixr4
//infix operator <&>: infixr4
//
//public struct URLFormat<Output: Sendable>: FormatProtocol, ExpressibleByStringLiteral {
//	public typealias Input = URLComponents
//	public typealias Parser = AnyParserPrinter<Input, Output>
//	public typealias Output = Output
//	
//    public let parser: Parser
//
//	@inlinable
//	public init(_ parser: Parser) {
//        self.parser = parser
//    }
//
//	@inlinable
//	public init(stringLiteral value: String) {
//        self.init(
//            path(
//                String(
//                    value
//                )
//            )
//            .map(
//                .any
//            )
//        )
//    }
//
//	@inlinable
//	public func parse(_ input: inout Input) throws -> Output {
//		return try parser.parse(input)
//	}
//
//	@inlinable
//	public func print(_ output: Output, into input: inout Input) throws -> Void {
//		try self.parser.print(output, into: &input)
//	}
//	
//	public func render(_ output: Output) throws-> String? {
//		var input: StringTemplate = .empty
//		try self
//			.print(
//				output,
//				into: &input
//			)
//		return input.render()
//		
//        return self.parser
//			.print(
//				output
//			)
//			.flatMap {
//				$0.render()
//			}
//    }
//
//    public func match(_ template: Input) throws -> Output? {
//        return (
//            self
//            </>
//            URLFormat
//                .end
//        )
//        .parser
//        .parse(
//            template
//        )
//        .match
//    }
//
//}
//
//extension URLFormat: ExpressibleByStringInterpolation {
//    public init(stringInterpolation: StringInterpolation) {
//        if stringInterpolation.parsers.isEmpty {
//            self.init(
//                .empty
//            )
//        } else {
//            let parser = reduce(
//                parsers: stringInterpolation
//                    .parsers
//            )
//            self.init(
//                parser
//                    .map(
//                        .any
//                    )
//            )
//        }
//    }
//
//    public class StringInterpolation: StringInterpolationProtocol {
//        private(set) var parsers: [(Parser<Sendable, URLComponents>, Any.Type)] = []
//
//        public required init(literalCapacity: Int, interpolationCount: Int) {}
//
//        public func appendParser(_ parser: Parser<Origin, URLComponents>) {
//            if let parser = parser as? Parser<Sendable, URLComponents> {
//                parsers
//                    .append(
//                        (
//                            parser,
//                            Target.self
//                        )
//                    )
//            } else {
//                parsers.append(
//                    (
//                        parser
//                            .map(
//                                .any
//                            ),
//                        Target.self
//                    )
//                )
//            }
//        }
//
//        public func appendLiteral(_ literal: String) {
//            guard literal.isEmpty == false else { return }
//            appendParser(
//                path(
//                    literal
//                ) //as? Parser<Prelude.Unit/Origin, URLComponents>!
//                .map(.any)
//            )
//        }
//
//        public func appendInterpolation(_ paramIso: AnyConversion<String, Origin>) {
//            appendParser(
//                path(
//                    paramIso
//                )
//            )
//        }
//    }
//}
//
//extension URLFormat {
//    /// Processes with the left and right side Formats, and if they succeed returns the pair of their results.
//    public static func </> <B: Sendable> (lhs: URLFormat, rhs: URLFormat<B>) -> URLFormat<(Origin, B)> {
//        return .init(
//            lhs.parser
//            <%>
//            rhs.parser
//        )
//    }
//
//    /// Processes with the left and right side Formats, discarding the result of the left side.
//    public static func </> (x: URLFormat<Prelude.Unit>, y: URLFormat) -> URLFormat {
//        return .init(
//            x.parser
//            %>
//            y.parser
//        )
//    }
//
//    public static func <?> <B: Sendable> (lhs: URLFormat, rhs: URLFormat<B>) -> URLFormat<(Origin, B)> {
//        return .init(
//            lhs.parser
//            <%>
//            rhs.parser
//        )
//    }
//
//    public static func <?> (x: URLFormat<Prelude.Unit>, y: URLFormat) -> URLFormat {
//        return .init(
//            x.parser
//            %>
//            y.parser
//        )
//    }
//
//    public static func <&> <B: Sendable> (lhs: URLFormat, rhs: URLFormat<B>) -> URLFormat<(Origin, B)> {
//        return .init(
//            lhs.parser
//            <%>
//            rhs.parser
//        )
//    }
//
//    public static func <&> (x: URLFormat<Prelude.Unit>, y: URLFormat) -> URLFormat {
//        return .init(
//            x.parser
//            %>
//            y.parser)
//    }
//}
//
//extension URLFormat where Origin == Prelude.Unit {
//    /// Processes with the left and right Formats, discarding the result of the right side.
//    public static func </> <B: Sendable>(x: URLFormat<B>, y: URLFormat) -> URLFormat<B> {
//        return .init(
//            x.parser
//            <%
//            y.parser
//        )
//    }
//    
//    public static func <?> <B: Sendable>(x: URLFormat<B>, y: URLFormat) -> URLFormat<B> {
//        return .init(
//            x.parser
//            <%
//            y.parser
//        )
//    }
//
//    public static func <&> <B: Sendable>(x: URLFormat<B>, y: URLFormat) -> URLFormat<B> {
//        return .init(
//            x.parser
//            <%
//            y.parser
//        )
//    }
//}
//
//extension URLFormat {
//    public static var end: URLFormat<Prelude.Unit> {
//        return URLFormat<Prelude.Unit>(
//            Parser(
//                parse: {
//                    $0.isEmpty
//                    ?
//                    ParsingResult(
//                        .empty,
//                        unit
//                    )
//                    :
//                    ParsingResult.empty
//                },
//                format: const(.empty)
//                //template: const(.empty)
//            )
//        )
//    }
//}
//
//public func path(_ str: String) -> Parser<Prelude.Unit, URLComponents> {
//    return Parser<Prelude.Unit, URLComponents>(
//        parse: { format in
//            return head(
//                format
//                    .pathComponents
//            )
//            .flatMap { (p, ps) in
//                return p == str
//                ?
//                ParsingResult(
//                    format
//                        .with {
//                            $0.pathComponents = ps
//                        },
//                    unit
//                )
//                :
//                .empty
//            }!
//        },
//        format: { _ in
//            URLComponents()
//                .with {
//                    $0.path = str
//                }
//        }
//        //template: { _ in URLComponents().with { $0.path = str } }
//    )
//}
//
//public func path(_ str: String) -> URLFormat<Prelude.Unit> {
//    return URLFormat<Prelude.Unit>(path(str))
//}
//
//public func path<Origin>(_ f: AnyConversion<String, Origin>) -> Parser<Origin, URLComponents> {
//    return Parser<Origin, URLComponents>(
//        parse: { format in
//            guard let (p, ps) = head(
//                format
//                    .pathComponents
//                ),
//                let v = f
//                    .apply(
//                        p
//                    ) else { return .empty }
//            return ParsingResult(
//                format
//                    .with
//                        { $0.pathComponents = ps },
//                v
//            )
//        },
//        format: { a in
//            f
//                .unapply(
//                    a
//                )
//                .flatMap { s in
//                URLComponents()
//                        .with {
//                            $0.path = s
//                        }
//            }
//        }
////        template: { a in
////            try f.unapply(a).flatMap { s in
////                return URLComponents().with { $0.path = ":" + "\(type(of: a))" }
////            }
////        }
//    )
//}
//
//public func path<Origin>(_ f: AnyConversion<String, Origin>) -> URLFormat<Origin> {
//    return URLFormat<Origin>(
//        path(
//            f
//        )
//    )
//}
//
//public func query<Origin>(_ key: String, _ f: AnyConversion<String, Origin>) -> Parser<Origin, URLComponents> {
//    return Parser<Origin, URLComponents>(
//        parse: { format in
//            guard
//                let queryItems = format
//                    .queryItems,
//                let p = queryItems
//                    .first(
//                        where: {
//                            $0.name == key
//                        }
//                    )?
//                    .value,
//                let v = f.apply(p)
//            else { return .empty }
//            return ParsingResult(format, v)
//        },
//        format: { a in
//            f
//				.unapply(a)
//				.flatMap { s in
//					URLComponents()
//						.with {
//							$0.queryItems = [URLQueryItem(name: key, value: s)]
//						}
//            }
//        }
////        template: { a in
////            try f.unapply(a).flatMap { s in
////                URLComponents().with { $0.queryItems = [URLQueryItem(name: key, value: ":" + "\(type(of: a))")] }
////            }
////    }
//    )
//}
//
//public func query<Origin>(_ key: String, _ f: AnyConversion<String, Origin>) -> URLFormat<Origin> {
//    return URLFormat<Origin>(
//        query(
//            key,
//            f
//        )
//    )
//}
//
//public func scheme(_ str: String) -> Parser<Prelude.Unit, URLComponents> {
//    return Parser<Prelude.Unit, URLComponents>(
//        parse: { format in
//            format
//                .scheme
//                .flatMap { (scheme) in
//                    return scheme == str
//                    ?
//                    ParsingResult(
//                        format
//                        .with
//                             { $0.scheme = nil },
//                             unit
//                    )
//                    :
//                    .empty
//                }!
//    },
//        format: { _ in URLComponents().with { $0.scheme = str } }
////        template: { _ in URLComponents().with { $0.scheme = str } }
//    )
//}
//
//public func scheme(_ str: String) -> URLFormat<Prelude.Unit> {
//    return URLFormat<Prelude.Unit>(
//        scheme(
//            str
//        )
//    )
//}
//
//public func host(_ str: String) -> Parser<Prelude.Unit, URLComponents> {
//    return Parser<Prelude.Unit, URLComponents>(
//        parse: { format in
//            format
//                .host
//                .flatMap { (host) in
//                    return host == str
//                    ?
//                    ParsingResult(format
//                        .with
//                            { $0.host = nil },
//                            unit
//                    )
//                    :
//                    .empty
//                }!
//        },
//        format: { _ in
//            URLComponents()
//                .with
//                { $0.host = str }
//        }
////        template: { _ in URLComponents().with { $0.host = str } }
//    )
//}
//
//public func host(_ str: String) -> URLFormat<Unit> {
//    return URLFormat<Unit>(
//            (host(
//                str
//            )
//        )
//    )
//}
//
//public func host(_ f: AnyConversion<String, String>) -> AnyParserPrinter<String, URLComponents> {
//    return AnyParserPrinter<String, URLComponents>(
//        parse: { format in
//            format
//                .host
//                .flatMap { (host) in
//                    (
//                        f
//                        .apply(
//                            host
//                        )
//                        .flatMap { v in
//                            ParsingResult(format
//                                .with
//                                    { $0.host = nil },
//                                v
//                            )
//                        }
//                    )
//                }!
//        },
//        format: { a in
//            f
//                .unapply(
//                    a
//                )
//                .flatMap { s in
//                    URLComponents()
//                        .with
//                    { $0.host = s }
//                }
//        }
//    )
//}
