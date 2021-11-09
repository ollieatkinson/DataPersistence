//
//  NSUbiquitousKeyValueStore.swift
//  
//
//  Created by Oliver Atkinson on 11/06/2021.
//

import Combine
import Foundation

extension NSUbiquitousKeyValueStore: DataPersistenceObject {
    
    public static let dataPersistenceKey = "NSUbiquitousKeyValueStoreDataPersistence"
    
    private var dictionary: [String: Any] {
        get { dictionary(forKey: NSUbiquitousKeyValueStore.dataPersistenceKey) ?? [:] }
        set { set(newValue, forKey: NSUbiquitousKeyValueStore.dataPersistenceKey)}
    }
    
    public func read(at path: CodingPath) throws -> Data {
        let data = try dictionary[path].or(throw: .doesNotExist(path)) as? Data
        return try data.or(throw: .typeMismatch(expected: Data.self, actual: type(of: dictionary[path])))
    }
    
    public func write(_ data: Data, to path: CodingPath) throws {
        dictionary[path] = data
    }
    
    public func delete(at path: CodingPath) throws {
        dictionary[path] = nil
    }
    
    public func deleteAll() throws {
        removeObject(forKey: NSUbiquitousKeyValueStore.dataPersistenceKey)
    }
}

extension NSUbiquitousKeyValueStore {
    
    func publisher(in notificationCenter: NotificationCenter = .default) -> NotificationCenter.Publisher {
        notificationCenter.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)
    }
}
