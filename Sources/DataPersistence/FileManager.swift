//
//  FileManager.swift
//  
//
//  Created by Oliver Atkinson on 15/04/2021.
//

import Foundation

extension FileManager: DataPersistenceObject {
    
    private var home: URL {
        URL(fileURLWithPath: NSHomeDirectory())
    }

    public var app: File {
        .init(self, at: home)
    }
    
    public func read(at path: CodingPath) throws -> Data {
        try app.read(at: path)
    }
    
    public func write(_ data: Data, to path: CodingPath) throws {
        try app.write(data, to: path)
    }
    
    public func delete(at path: CodingPath) throws {
        try app.delete(at: path)
    }
    
    public func deleteAll() throws {
        try app.deleteAll()
    }
    
    public func iCloud(containerIdentifier identifier: String? = nil) throws -> File {
        try .init(
            self,
            at: url(forUbiquityContainerIdentifier: identifier)
                .or(throw: "The container could not be located or iCloud storage is unavailable for the current user/device".error())
        )
    }
    
    public class File: DataPersistenceObject {
        
        public let fileManager: FileManager
        public let url: URL
        
        init(_ fileManager: FileManager, at url: URL) {
            self.fileManager = fileManager
            self.url = url
        }
        
        convenience init(_ fileManager: FileManager, at path: String) {
            self.init(
                fileManager,
                at: path.hasPrefix("~")
                    ? fileManager.home.appendingPathComponent(String(path.dropFirst()))
                    : URL(fileURLWithPath: path)
            )
        }
        
        public func read(at path: CodingPath) throws -> Data {
            try Data(contentsOf: URL(baseURL: url, path: path))
        }
        
        public func write(_ data: Data, to path: CodingPath) throws {
            let url = URL(baseURL: self.url, path: path)
            try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            guard fileManager.createFile(atPath: url.path, contents: data) else {
                throw "Failed to create file at \(url.path)".error()
            }
        }
        
        public func delete(at path: CodingPath) throws {
            try fileManager.removeItem(at: URL(baseURL: url, path: path))
        }
        
        public func deleteAll() throws {
            try fileManager.removeItem(at: url)
        }
        
        public func url(for path: CodingPath) -> URL {
            URL(baseURL: url, path: path)
        }
    }
}

extension URL {
    
    fileprivate init(baseURL: URL, path: CodingPath) {
        self = baseURL
        for (component, _) in path {
            appendPathComponent(component.stringValue)
        }
    }
}
