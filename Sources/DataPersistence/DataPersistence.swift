//
//  DataPersistence.swift
//
//
//  Created by Oliver Atkinson on 14/04/2021.
//

@_exported import Eumorphic

import struct Foundation.Data
import class Foundation.JSONDecoder
import class Foundation.JSONEncoder

public protocol DataPersistence {
    func read(dataAt path: Path) throws -> Data
    mutating func write(_ data: Data, to path: Path) throws
    mutating func delete(dataAt path: Path) throws
    mutating func deleteAll() throws
}

extension DataPersistence {
    public func read<P>(dataAt path: P) throws -> Data where P: RandomAccessCollection, P.Element == Path.Crumb { try read(dataAt: Path(path)) }
    public mutating func write<P>(_ data: Data, to path: P) throws where P: RandomAccessCollection, P.Element == Path.Crumb { try write(data, to: Path(path)) }
    public mutating func delete<P>(dataAt path: P) throws where P: RandomAccessCollection, P.Element == Path.Crumb { try delete(dataAt: Path(path)) }
}

public protocol DataPersistenceObject: AnyObject, DataPersistence {
    func read(dataAt path: Path) throws -> Data
    func write(_ data: Data, to path: Path) throws
    func delete(dataAt path: Path) throws
    func deleteAll() throws
}

extension DataPersistenceObject {
    public func read<P>(dataAt path: P) throws -> Data where P: RandomAccessCollection, P.Element == Path.Crumb { try read(dataAt: Path(path)) }
    public func write<P>(_ data: Data, to path: P) throws where P: RandomAccessCollection, P.Element == Path.Crumb { try write(data, to: Path(path)) }
    public func delete<P>(dataAt path: P) throws where P: RandomAccessCollection, P.Element == Path.Crumb { try delete(dataAt: Path(path)) }
}

extension DataPersistence {
    
    public func read(dataAt first: Path.Crumb, _ rest: Path.Crumb...) throws -> Data { try read(dataAt: [first] + rest) }
    public mutating func write(_ data: Data, to first: Path.Crumb, _ rest: Path.Crumb...) throws { try write(data, to: [first] + rest) }
    public mutating func delete(dataAt first: Path.Crumb, _ rest: Path.Crumb...) throws { try delete(dataAt: [first] + rest) }
    
    public mutating func write<T>(
        _ value: T,
        to path: Path.Crumb...,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where T: Encodable {
        try write(value, to: path, using: encoder)
    }
    
    public mutating func write<T, P>(
        _ value: T,
        to path: P,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where T: Encodable, P: RandomAccessCollection, P.Element == Path.Crumb {
        try write(value, to: Path(path), using: encoder)
    }
    
    public mutating func write<T>(
        _ value: T,
        to path: Path,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where T: Encodable {
        try write(encoder.encode(value), to: path)
    }
    
    public func read<T>(
        _: T.Type = T.self,
        at path: Path.Crumb...,
        using decoder: JSONDecoder = JSONDecoder()
    ) throws -> T where T: Decodable {
        try read(T.self, at: path, using: decoder)
    }
    
    public func read<T, P>(
        _: T.Type = T.self,
        at path: P,
        using decoder: JSONDecoder = JSONDecoder()
    ) throws -> T where T: Decodable, P: RandomAccessCollection, P.Element == Path.Crumb {
        try read(T.self, at: Path(path), using: decoder)
    }
    
    public func read<T>(
        _: T.Type = T.self,
        at path: Path,
        using decoder: JSONDecoder = JSONDecoder()
    ) throws -> T where T: Decodable {
        try decoder.decode(T.self, from: read(dataAt: path))
    }
}

extension DataPersistenceObject {

    public func write(_ data: Data, to first: Path.Crumb, _ rest: Path.Crumb...) throws {
        try write(data, to: [first] + rest)
    }
    
    public func delete(dataAt first: Path.Crumb, _ rest: Path.Crumb...) throws {
        try delete(dataAt: [first] + rest)
    }
    
    public func write<T>(
        _ value: T,
        to path: Path.Crumb...,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where T: Encodable {
        try write(value, to: path, using: encoder)
    }
    
    public func write<T, P>(
        _ value: T,
        to path: P,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where T: Encodable, P: RandomAccessCollection, P.Element == Path.Crumb {
        try write(value, to: Path(path), using: encoder)
    }
    
    public func write<T>(
        _ value: T,
        to path: Path,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where T: Encodable {
        try write(encoder.encode(value), to: path)
    }
}
