//
//  JSONValue.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 05.09.24.
//

import CasePaths

public struct JSONValue: ParserPrinterProtocol, SendableMarker {
	@CasePathable
	public enum Output: SendableMarker & Equatable & Hashable {
		case array([Self])
		case boolean(Bool)
		case null
		case number(Double)
		case object([String: Self])
		case string(String)
	}
	
	public var body: some ParserPrinterProtocol<Substring.UTF8View, Output> {
		Whitespace()
		OneOf {
			JSONObject()
				.map(
					.case (\Output.Cases.object)
				)
			JSONArray()
				.map(
					.case (\Output.Cases.array)
				)
			JSONString()
				.map(
					.case (\Output.Cases.string)
				)
			Double
				.parser()
				.map(
					.case (\Output.Cases.number)
				)
			Bool
				.parser()
				.map(
					.case (\Output.Cases.boolean)
				)
			"null".utf8.map { Output.null }
		}
		Whitespace()
	}
	
	public init() {}
}
