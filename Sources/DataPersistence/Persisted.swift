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
    
    let key: Path
    var persistence: DataPersistence
    let defaultValue: Value
    
    public var decoder = JSONDecoder()
    public var encoder = JSONEncoder()
    
    public var wrappedValue: Value {
        get {
            do {
                let value = try persistence.read(Value.self, at: key, using: decoder)
                defer { on.read.send(value) }
                return value
            } catch {
                defer { on.error.send(error) }
                return defaultValue
            }
        }
        mutating set {
            do {
                try persistence.write(newValue, to: key, using: encoder)
                on.write.send(newValue)
            } catch {
                on.error.send(error)
            }
        }
    }
    
    public mutating func delete() {
        do {
            let oldValue = wrappedValue
            try persistence.delete(dataAt: key)
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
    
    public var projectedValue: Persisted { self }
}

extension Persisted {
    
    init<Keys>(_ persistence: DataPersistence, _ key: Keys, _ defaultValue: Value) where Keys: RandomAccessCollection, Keys.Element == Path.Crumb {
        self.persistence = persistence
        self.key = Path(key)
        self.defaultValue = defaultValue
    }
    
}

extension Persisted {
    
    public init(in persistence: DataPersistence, at key: Path.Crumb..., default defaultValue: Value) {
        self.init(in: persistence, at: key, default: defaultValue)
    }
    
    public init<Keys>(in persistence: DataPersistence, at key: Keys, default defaultValue: Value) where Keys: RandomAccessCollection, Keys.Element == Path.Crumb {
        self.init(persistence, key, defaultValue)
    }
    
    public init(wrappedValue: Value, in persistence: DataPersistence, at key: Path.Crumb..., default defaultValue: Value) {
        self.init(wrappedValue: wrappedValue, in: persistence, at: key, default: defaultValue)
    }
    
    public init<Keys>(wrappedValue: Value, in persistence: DataPersistence, at key: Keys, default defaultValue: Value) where Keys: RandomAccessCollection, Keys.Element == Path.Crumb {
        self.init(in: persistence, at: key, default: defaultValue)
        self.wrappedValue = wrappedValue
    }
}

extension Persisted where Value: ExpressibleByNilLiteral {
    
    public init(in persistence: DataPersistence, at key: Path.Crumb..., default defaultValue: Value = nil) {
        self.init(in: persistence, at: key, default: defaultValue)
    }
    
    public init<Keys>(in persistence: DataPersistence, at key: Keys, default defaultValue: Value = nil) where Keys: RandomAccessCollection, Keys.Element == Path.Crumb {
        self.init(persistence, key, defaultValue)
    }
}
