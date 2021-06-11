//
//  Codable.swift
//  
//
//  Created by Oliver Atkinson on 14/04/2021.
//

import class Foundation.JSONDecoder
import class Foundation.JSONEncoder

extension Encodable {
    
    public func write<D>(
        to storage: inout D,
        at path: Path.Crumb...,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where D: DataPersistence {
        try write(to: &storage, at: path, using: encoder)
    }
    
    public func write<D, P>(
        to storage: inout D,
        at path: P,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where D: DataPersistence, P: RandomAccessCollection, P.Element == Path.Crumb {
        try write(to: &storage, at: Path(path), using: encoder)
    }
    
    public func write<D>(
        to storage: inout D,
        at path: Path,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where D: DataPersistence {
        try write(to: &storage, at: path, using: encoder)
    }
    
    public func write<D>(
        to storage: D,
        at path: Path.Crumb...,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where D: DataPersistenceObject {
        try write(to: storage, at: path, using: encoder)
    }
    
    public func write<D, P>(
        to storage: D,
        at path: P,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where D: DataPersistenceObject, P: RandomAccessCollection, P.Element == Path.Crumb {
        try write(to: storage, at: Path(path), using: encoder)
    }
    
    public func write<D>(
        to storage: D,
        at path: Path,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where D: DataPersistenceObject {
        try storage.write(self, to: path, using: encoder)
    }
}

extension Decodable {
    
    public func read<D>(
        from storage: D,
        at path: Path.Crumb...,
        using decoder: JSONDecoder = JSONDecoder()
    ) throws -> Self where D: DataPersistence {
        try read(from: storage, at: path, using: decoder)
    }
    
    public func read<D, P>(
        from storage: D,
        at path: P,
        using decoder: JSONDecoder = JSONDecoder()
    ) throws -> Self where D: DataPersistence, P: RandomAccessCollection, P.Element == Path.Crumb {
        try storage.read(Self.self, at: path, using: decoder)
    }
}

