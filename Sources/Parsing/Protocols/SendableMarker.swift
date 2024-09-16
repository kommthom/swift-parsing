//
//  SendableMarker.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 05.09.24.
//

import CasePaths

public protocol SendableMarker: Sendable {}

extension Bool: SendableMarker {}
extension UInt8: SendableMarker {}
extension Int: SendableMarker {}
extension Float: SendableMarker {}
extension Double: SendableMarker {}
extension String: SendableMarker {}
extension Substring: SendableMarker {}
extension Array: SendableMarker where Element: SendableMarker {}
extension Dictionary: SendableMarker where Key: SendableMarker & Hashable, Value: SendableMarker {}
//Generic struct 'Rest' requires that 'Substring.UTF8View' conform to 'SendableMarker'
extension Substring.UTF8View: SendableMarker {}
//extension AnyCasePath: SendableMarker {}

public protocol EquatableMarker: Sendable, Equatable {}
extension UInt8: EquatableMarker {}
