//
//  Parsers.swift
//  swift-parsing
//
//  Created by https://github.com/stephencelis
//  Updated by Thomas Benninghaus on 31.08.24.
//

/// A namespace for types that serve as parsers.
///
/// The various operators defined as extensions on ``Parser`` implement their functionality as
/// classes or structures that extend this enumeration. For example, the ``Parser/map(_:)-4hsj5``
/// operator returns a ``Parsers/Map`` parser.
public enum Parsers: Sendable {}
