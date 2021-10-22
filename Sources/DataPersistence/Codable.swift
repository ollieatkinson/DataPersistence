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
        at path: CodingPath.Crumb...,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where D: DataPersistence {
        try write(to: &storage, at: CodingPath(path), using: encoder)
    }

    public func write<D>(
        to storage: inout D,
        at path: CodingPath,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where D: DataPersistence {
        try write(to: &storage, at: path, using: encoder)
    }

    public func write(
        to storage: inout DataPersistence,
        at path: CodingPath.Crumb...,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws {
        try write(to: &storage, at: CodingPath(path), using: encoder)
    }

    public func write(
        to storage: inout DataPersistence,
        at path: CodingPath,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws {
        try storage.write(encoder.encode(self), to: path)
    }
    
    public func write<D>(
        to storage: D,
        at path: CodingPath.Crumb...,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where D: DataPersistenceObject {
        try write(to: storage, at: CodingPath(path), using: encoder)
    }

    public func write<D>(
        to storage: D,
        at path: CodingPath,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where D: DataPersistenceObject {
        try storage.write(encoder.encode(self), to: path)
    }

    public func write(
        to storage: DataPersistenceObject,
        at path: CodingPath.Crumb...,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws {
        try write(to: storage, at: CodingPath(path), using: encoder)
    }

    public func write(
        to storage: DataPersistenceObject,
        at path: CodingPath,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws {
        try storage.write(encoder.encode(self), to: path)
    }
}

extension Decodable {
    
    public static func read<D>(
        from storage: D,
        at path: CodingPath.Crumb...,
        using decoder: JSONDecoder = JSONDecoder()
    ) throws -> Self where D: DataPersistence {
        try read(from: storage, at: CodingPath(path), using: decoder)
    }

    public static func read<D>(
        from storage: D,
        at path: CodingPath,
        using decoder: JSONDecoder = JSONDecoder()
    ) throws -> Self where D: DataPersistence {
        try decoder.decode(Self.self, from: storage.read(at: path))
    }

    public static func read(
        from storage: DataPersistence,
        at path: CodingPath.Crumb...,
        using decoder: JSONDecoder = JSONDecoder()
    ) throws -> Self {
        try read(from: storage, at: CodingPath(path), using: decoder)
    }

    public static func read(
        from storage: DataPersistence,
        at path: CodingPath,
        using decoder: JSONDecoder = JSONDecoder()
    ) throws -> Self {
        try decoder.decode(Self.self, from: storage.read(at: path))
    }
}
