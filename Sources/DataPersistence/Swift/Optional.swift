//
//  Optional.swift
//  
//
//  Created by Oliver Atkinson on 22/10/2021.
//

import Foundation

public func isNil(_ any: Any?) -> Bool {
    switch any.flattened {
    case .none: return true
    case .some: return false
    }
}

extension Optional {

    func or(throw error: Error) throws -> Wrapped {
        switch self {
        case .none: throw error
        case let o?: return o
        }
    }
}

protocol FlattenOptional {
    var flattened: Any? { get }
}

func flattenOptionality(_ any: Any) -> Any {
    (any as? FlattenOptional)?.flattened ?? any
}

extension Optional: FlattenOptional {

    var flattened: Any? {
        switch self {
        case .none: return self as Any
        case let .some(wrapped): return (wrapped as? FlattenOptional)?.flattened ?? wrapped
        }
    }
}
