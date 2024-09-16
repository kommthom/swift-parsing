//
//  StringInterpolationElement.swift
//  swift-parsing
//
//  Created by Thomas Benninghaus on 23.09.24.
//

import CasePaths

@CasePathable
public enum StringInterpolationElement : SendableMarker & Equatable & Hashable {
	case interpolation(_ key: String)
	case string(_ string: String)
	case empty
}
