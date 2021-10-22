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
        let data = try self[path].or(throw: "Object at \(path) does not exist".error()) as? Data
        return try data.or(throw: "Object at \(path) is not of type Data".error())
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

public class StringAnyDataPersistenceObject: DataPersistenceObject, ExpressibleByDictionaryLiteral {

    private var __: [String: Any] = [:]

    public init() { }

    public required init(dictionaryLiteral elements: (String, Any)...) {
        __ = Dictionary(elements, uniquingKeysWith: { $1 })
    }

    public func read(at path: CodingPath) throws -> Data {
        try __.read(at: path)
    }

    public func write(_ data: Data, to path: CodingPath) throws {
        try __.write(data, to: path)
    }

    public func delete(at path: CodingPath) throws {
        try __.delete(at: path)
    }

    public func deleteAll() throws {
        __ = [:]
    }
}
