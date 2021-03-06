//
//  Dictionary.swift
//  
//
//  Created by Oliver Atkinson on 22/10/2021.
//

import Foundation

protocol CodingContainer {
    associatedtype Value
    func get(_ path: CodingPath) throws -> Value
    mutating func set(_ value: Value?, at path: CodingPath)
}

extension CodingContainer {

    subscript<K>(first: K, codingPath: K...) -> Value? where K: CodingKey {
        get { self[CodingPath([first] + codingPath)] }
        set { self[CodingPath([first] + codingPath)] = newValue }
    }

    subscript<K>(keys: [K]) -> Value? where K: CodingKey {
        get { self[CodingPath(keys)] }
        set { self[CodingPath(keys)] = newValue }
    }

    subscript(first: CodingKey, codingPath: CodingKey...) -> Value? {
        get { self[CodingPath([first] + codingPath)] }
        set { self[CodingPath([first] + codingPath)] = newValue }
    }

    subscript(keys: [CodingKey]) -> Value? {
        get { self[CodingPath(keys)] }
        set { self[CodingPath(keys)] = newValue }
    }
    
    subscript(first: CodingPath.Crumb, codingPath: CodingPath.Crumb...) -> Value? {
        get { self[CodingPath([first] + codingPath)] }
        set { self[CodingPath([first] + codingPath)] = newValue }
    }

    subscript(codingPath: CodingPath) -> Value? {
        get { try? get(codingPath) }
        set { set(newValue, at: codingPath) }
    }
}

extension Dictionary: CodingContainer where Key == String, Value == Any {

    func get(_ path: CodingPath) throws -> Value {
        guard let (head, remaining) = path.first else { return self }
        guard let value = self[head.stringValue] else { throw "\(path) → Key \(head.stringValue) does not exist at \(self)".error() }
        return try _get(remaining, from: value)
    }

    mutating func set(_ value: Value?, at path: CodingPath) {
        guard let (head, remaining) = path.first else { return }
        switch (head.stringValue, remaining) {
        case nil: return
        case let (key, remaining):
            self[key] = _set(value, at: remaining, on: self[key] as Any)
        }
    }
}

extension Array: CodingContainer where Element == Any {

    func get(_ path: CodingPath) throws -> Element {
        guard let (head, remaining) = path.first else { return self }
        guard let idx = head.intValue.map(bidirectionalIndex) else { throw "\(path) → Path indexing into array \(self) must be an Int - got: \(head.stringValue)".error() }
        guard indices.contains(idx) else { throw "\(path) → Array index '\(idx)' out of bounds".error() }
        return try _get(remaining, from: self[idx])
    }

    mutating func set(_ value: Element?, at path: CodingPath) {
        guard let (head, remaining) = path.first else { return }
        guard let idx = head.intValue.map(bidirectionalIndex) else { return }
        padded(to: idx, with: Any?.none as Any)
        switch (idx, remaining) {
        case nil: return
        case let (idx, remaining):
            self[idx] = _set(value, at: remaining, on: self[idx])
        }
    }

    func bidirectionalIndex(_ idx: Int) -> Int {
        guard idx < 0 else { return idx }
        guard !isEmpty else { return 0 }
        return (count + idx) % count
    }
}

extension RangeReplaceableCollection where Self: BidirectionalCollection {

    fileprivate mutating func padded(to size: Int, with value: @autoclosure () -> Element) {
        guard !indices.contains(index(startIndex, offsetBy: size)) else { return }
        append(contentsOf: (0..<(1 + size - count)).map { _ in value() })
    }
}

extension Collection {
    fileprivate var headAndTail: (head: Element, tail: SubSequence)? {
        guard let head = first else { return nil }
        return (head, dropFirst())
    }
}

private func _get(_ path: CodingPath, from any: Any) throws -> Any {
    switch any {
    case let array as [Any]: return try array.get(path)
    case let dictionary as [String: Any]: return try dictionary.get(path)
    case let fragment where path.isEmpty: return fragment as Any
    case let fragment: throw "\(path) → Path indexing into \(fragment) of \(type(of: fragment)) not allowed".error()
    }
}

private func _set(_ value: Any?, at path: CodingPath, on any: Any) -> Any {
    guard let (crumb, _) = path.first else { return flattenOptionality(value as Any) }
    switch crumb {
    case .int:
        var array = (any as? [Any]) ?? []
        array.set(value, at: path)
        return array
    case .string:
        var dictionary = (any as? [String: Any]) ?? [:]
        dictionary.set(value, at: path)
        return dictionary
    }
}
