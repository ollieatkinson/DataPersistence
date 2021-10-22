//
//  Cache.swift
//  
//
//  Created by Oliver Atkinson on 14/04/2021.
//

import Foundation

public class Cache: DataPersistenceObject {
    
    private let ns: NSCache<NSString, NSData>
    
    public init(_ cache: NSCache<NSString, NSData> = .init()) {
        ns = cache
    }
    
    public convenience init(countLimit: Int, totalCostLimit: Int) {
        
        let cache = NSCache<NSString, NSData>()
        
        cache.countLimit = countLimit
        cache.totalCostLimit = totalCostLimit
        
        self.init(cache)
    }
    
    public func read(at path: CodingPath) throws -> Data {
        guard let data = ns.object(forKey: path.string as NSString) else {
            throw "No data found at path \(path)".error()
        }
        return data as Data
    }
    
    public func write(_ data: Data, to path: CodingPath) throws {
        ns.setObject(data as NSData, forKey: path.string as NSString, cost: data.count)
    }
    
    public func delete(at path: CodingPath) throws {
        ns.removeObject(forKey: path.string as NSString)
    }
    
    public func deleteAll() throws {
        ns.removeAllObjects()
    }
}
