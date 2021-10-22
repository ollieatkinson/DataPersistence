//
//  Persisted.swift
//  
//
//  Created by Oliver Atkinson on 14/04/2021.
//

import Foundation
import Combine

@propertyWrapper
public struct Persisted<Value> where Value: Codable {
    
    let key: CodingPath
    var persistence: DataPersistenceObject
    let defaultValue: Value
    
    public var decoder = JSONDecoder()
    public var encoder = JSONEncoder()
    
    public var wrappedValue: Value {
        get {
            do {

                let value = try Value.read(from: persistence, at: key, using: decoder)
                defer { on.read.send(value) }
                return value
            } catch {
                defer { on.error.send(error) }
                return defaultValue
            }
        }
        mutating set {
            do {
                try newValue.write(to: persistence, at: key, using: encoder)
                on.write.send(newValue)
            } catch {
                on.error.send(error)
            }
        }
    }
    
    public mutating func delete() {
        do {
            let oldValue = wrappedValue
            try persistence.delete(at: key)
            on.delete.send(oldValue)
        } catch {
            on.error.send(error)
        }
    }
    
    public var on = (
        read: PassthroughSubject<Value, Never>(),
        write: PassthroughSubject<Value, Never>(),
        delete: PassthroughSubject<Value, Never>(),
        error: PassthroughSubject<Error, Never>()
    )
    
    public var projectedValue: Persisted {
        get { self }
        set { self = newValue }
    }
}

extension Persisted {
    
    init<Keys>(_ persistence: DataPersistenceObject, _ key: Keys, _ defaultValue: Value) where Keys: RandomAccessCollection, Keys.Element == CodingKey {
        self.persistence = persistence
        self.key = CodingPath(key)
        self.defaultValue = defaultValue
    }
}

extension Persisted {
    
    public init(in persistence: DataPersistenceObject, at key: CodingPath.Crumb..., default defaultValue: Value) {
        self.init(in: persistence, at: key, default: defaultValue)
    }
    
    public init<Keys>(in persistence: DataPersistenceObject, at key: Keys, default defaultValue: Value) where Keys: RandomAccessCollection, Keys.Element == CodingKey {
        self.init(persistence, key, defaultValue)
    }
    
    public init(wrappedValue: Value, in persistence: DataPersistenceObject, at key: CodingPath.Crumb..., default defaultValue: Value) {
        self.init(wrappedValue: wrappedValue, in: persistence, at: key, default: defaultValue)
    }
    
    public init<Keys>(wrappedValue: Value, in persistence: DataPersistenceObject, at key: Keys, default defaultValue: Value) where Keys: RandomAccessCollection, Keys.Element == CodingKey {
        self.init(in: persistence, at: key, default: defaultValue)
        self.wrappedValue = wrappedValue
    }
}

extension Persisted where Value: ExpressibleByNilLiteral {
    
    public init(in persistence: DataPersistenceObject, at key: CodingPath.Crumb..., default defaultValue: Value = nil) {
        self.init(in: persistence, at: key, default: defaultValue)
    }
    
    public init<Keys>(in persistence: DataPersistenceObject, at key: Keys, default defaultValue: Value = nil) where Keys: RandomAccessCollection, Keys.Element == CodingKey {
        self.init(persistence, key, defaultValue)
    }
}
