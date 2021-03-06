//
//  UserDefaults.swift
//  
//
//  Created by Oliver Atkinson on 14/04/2021.
//

import Foundation

extension UserDefaults: DataPersistenceObject {
    
    public static let dataPersistenceKey = "UserDefaultsDataPersistence"

    private var dictionary: [String: Any] {
        get { dictionary(forKey: UserDefaults.dataPersistenceKey) ?? [:] }
        set { set(newValue, forKey: UserDefaults.dataPersistenceKey)}
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
        removeObject(forKey: UserDefaults.dataPersistenceKey)
    }
}
