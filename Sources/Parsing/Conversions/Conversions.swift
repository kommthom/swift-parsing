//
//  Conversions.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 31.08.24.
//

/// A namespace for types that serve as conversions.
///
/// The various operators defined as extensions on ``Conversion`` implement their functionality as
/// classes or structures that extend this enumeration. For example, the ``Conversion/map(_:)``
/// operator returns a ``Map`` conversion.
public enum Conversions {}
