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
    
    public func read(dataAt path: Path) throws -> Data {
        let data = try dictionary[path].or(throw: "Object at \(path) does not exist".error()) as? Data
        return try data.or(throw: "Object at \(path) is not of type Data".error())
    }
    
    public func write(_ data: Data, to path: Path) throws {
        dictionary[path] = data
    }
    
    public func delete(dataAt path: Path) throws {
        dictionary[path] = nil
    }
    
    public func deleteAll() throws {
        removeObject(forKey: NSUbiquitousKeyValueStore.dataPersistenceKey)
    }
}

extension NSUbiquitousKeyValueStore {
    
    func publisher(in notificationCenter: NotificationCenter = .default) -> NotificationCenter.Publisher {
        notificationCenter.publisher(for: Self.didChangeExternallyNotification)
    }
}
