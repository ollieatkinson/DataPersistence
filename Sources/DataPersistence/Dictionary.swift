//
//  Dictionary.swift
//  
//
//  Created by Oliver Atkinson on 14/04/2021.
//

import struct Foundation.Data
import class Foundation.JSONSerialization

extension Dictionary: DataPersistence where Key == String, Value == Any {
    
    public func read(dataAt path: Path) throws -> Data {
        let data = try self[path].or(throw: "Object at \(path) does not exist".error()) as? Data
        return try data.or(throw: "Object at \(path) is not of type Data".error())
    }
    
    public mutating func write(_ data: Data, to path: Path) throws {
        self[path] = data
    }
    
    public mutating func delete(dataAt path: Path) throws {
        self[path] = nil
    }
    
    public mutating func deleteAll() throws {
        self = [:]
    }
}
