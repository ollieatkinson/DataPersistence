//
//  Dictionary.swift
//  
//
//  Created by Oliver Atkinson on 14/04/2021.
//

import struct Foundation.Data
import class Foundation.JSONSerialization

extension Dictionary: DataPersistence where Key == String, Value == Any {
    
    public func read(at path: CodingPath) throws -> Data {
        let data = try self[path].or(throw: .doesNotExist(path)) as? Data
        return try data.or(throw: .typeMismatch(expected: Data.self, actual: type(of: self[path])))
    }
    
    public mutating func write(_ data: Data, to path: CodingPath) throws {
        self[path] = data
    }
    
    public mutating func delete(at path: CodingPath) throws {
        self[path] = nil
    }
    
    public mutating func deleteAll() throws {
        self = [:]
    }
}
