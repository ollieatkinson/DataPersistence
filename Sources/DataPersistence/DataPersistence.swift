//
//  DataPersistence.swift
//
//
//  Created by Oliver Atkinson on 14/04/2021.
//

import struct Foundation.Data
import class Foundation.JSONDecoder
import class Foundation.JSONEncoder

public protocol DataPersistence {
    func read(at path: CodingPath) throws -> Data
    mutating func write(_ data: Data, to path: CodingPath) throws
    mutating func delete(at path: CodingPath) throws
    mutating func deleteAll() throws
}

extension DataPersistence {

    public func read<P>(
        at path: P
    ) throws -> Data where P: RandomAccessCollection, P.Element == CodingPath.Crumb {
        try read(at: CodingPath(path))
    }

    public mutating func write<P>(
        _ data: Data,
        to path: P
    ) throws where P: RandomAccessCollection, P.Element == CodingPath.Crumb {
        try write(data, to: CodingPath(path))
    }

    public mutating func delete<P>(
        at path: P
    ) throws where P: RandomAccessCollection, P.Element == CodingPath.Crumb {
        try delete(at: CodingPath(path))
    }
}

public protocol DataPersistenceObject: AnyObject, DataPersistence {
    func read(at path: CodingPath) throws -> Data
    func write(_ data: Data, to path: CodingPath) throws
    func delete(at path: CodingPath) throws
    func deleteAll() throws
}

extension DataPersistenceObject {

    public func read<P>(
        at path: P
    ) throws -> Data where P: RandomAccessCollection, P.Element == CodingPath.Crumb {
        try read(at: CodingPath(path))
    }

    public func delete<P>(
        at path: P
    ) throws where P: RandomAccessCollection, P.Element == CodingPath.Crumb {
        try delete(at: CodingPath(path))
    }
}

extension DataPersistence {
    
    public func read(
        at first: CodingPath.Crumb,
        _ rest: CodingPath.Crumb...
    ) throws -> Data {
        try read(at: [first] + rest)
    }

    public mutating func write(
        _ data: Data,
        to first: CodingPath.Crumb,
        _ rest: CodingPath.Crumb...
    ) throws {
        try write(data, to: [first] + rest)
    }

    public mutating func delete(
        at first: CodingPath.Crumb,
        _ rest: CodingPath.Crumb...
    ) throws {
        try delete(at: [first] + rest)
    }
}

extension DataPersistenceObject {

    public func write(
        _ data: Data,
        to first: CodingPath.Crumb,
        _ rest: CodingPath.Crumb...
    ) throws {
        try write(data, to: CodingPath([first] + rest))
    }
    
    public func delete(
        at first: CodingPath.Crumb,
        _ rest: CodingPath.Crumb...
    ) throws {
        try delete(at: [first] + rest)
    }
}

extension DataPersistence {

    public func result(at path: CodingPath.Crumb...) -> Result<Data, Error> {
        result(at: path)
    }

    public func result<P>(at path: P) -> Result<Data, Error> where P: RandomAccessCollection, P.Element == CodingPath.Crumb {
        result(at: CodingPath(path))
    }

    public func result(at path: CodingPath) -> Result<Data, Error> {
        Result { try read(at: path) }
    }
}
