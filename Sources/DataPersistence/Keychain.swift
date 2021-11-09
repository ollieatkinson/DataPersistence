//
//  Keychain.swift
//  
//
//  Created by Oliver Atkinson on 14/04/2021.
//

import Foundation

public struct Keychain: Equatable, Codable {
    
    public class Account: DataPersistenceObject, Equatable, Codable {
        public let keychain: Keychain
        public let name: String
        
        init(keychain: Keychain, name: String) {
            self.keychain = keychain
            self.name = name
        }
        
        public static func == (lhs: Account, rhs: Account) -> Bool {
            return lhs.keychain == rhs.keychain
                && lhs.name == rhs.name
        }
    }
    
    public let accessGroup: String?
    public let permission: Keychain.Permission
    public let synchronize: Bool
    
    public init(accessGroup: String? = nil, permission: Keychain.Permission = .whenUnlockedThisDeviceOnly, synchronize: Bool = false) {
        self.accessGroup = accessGroup
        self.permission = permission
        self.synchronize = synchronize
    }
    
    public static func account(_ name: String) -> Account {
        return Self().account(name)
    }
    
    public func account(_ name: String) -> Account {
        return Account(keychain: self, name: name)
    }
    
    public var sharedAccount: Account {
        
        let account: String
        
        if let group = accessGroup {
            account = "\(group)+shared"
        } else {
            account = Bundle.main.bundleIdentifier ?? "shared"
        }
        
        return Account(keychain: self, name: account)
    }
}

extension Keychain.Account {
    
    public func read(at path: CodingPath) throws -> Data {
        
        var query = keychainQuery(forPath: path)
        
        query[kSecReturnData] = kCFBooleanTrue
        query[kSecMatchLimit] = kSecMatchLimitOne
        
        var _data: AnyObject? = nil
        let os = SecItemCopyMatching(query as CFDictionary, &_data)

        switch os {
        case errSecItemNotFound: throw DataPersistenceError(.doesNotExist(path))
        case errSecSuccess: break
        default: throw "Failed with code: \(os)".error()
        }

        guard let data = _data as? Data else {
            assertionFailure("`data` should always be available if `status == errSecSuccess`")
            throw "`data` should always be available if `status == noErr`".error()
        }
        
        return data
    }
    
    public func write(_ data: Data, to path: CodingPath) throws {
        
        var query = keychainQuery(forPath: path)
        
        query[kSecValueData] = data
        
        var os = SecItemAdd(query as CFDictionary, nil)
        
        if os == errSecDuplicateItem {
            os = SecItemUpdate(query as CFDictionary, [ kSecValueData: data ] as CFDictionary)
        }
        
        if os != errSecSuccess {
            throw "Failed with code: \(os)".error()
        }
    }
    
    public func delete(at path: CodingPath) throws {
        if path.isEmpty {
            throw """
                    Cannot delete if the path is empty, please specify the path to the data you would like to delete.
                    Call `deleteAll` to remove everything for the current keychain account
                  """.error()
        }
        
        let os = SecItemDelete(keychainQuery(forPath: path) as CFDictionary)
        
        if os != errSecSuccess {
            throw "Failed with code: \(os)".error()
        }
    }
    
    public func readAll() throws -> [String: Data] {
        
        var query = GenericPasswordQuery(
            account: name,
            service: nil,
            permission: keychain.permission,
            group: keychain.accessGroup,
            synchronizable: keychain.synchronize && keychain.permission.isSynchronizationAllowed
        ).query
        
        query[kSecReturnData] = kCFBooleanTrue
        query[kSecMatchLimit] = kSecMatchLimitAll
        
        var _data: AnyObject? = nil
        let os = SecItemCopyMatching(query as CFDictionary, &_data)
        
        guard os == errSecSuccess else {
            throw "Failed with code: \(os)".error()
        }
        
        guard let data = _data as? [[CFString: Any]] else {
            throw "`data` should always be available if `status == noErr`".error()
        }
        return try data.reduce(into: [:]) { sum, next in
            let account = try (next[kSecAttrAccount] as? String)
                .or(throw: "No account".error())
            guard account == name else { return }
            let service = try (next[kSecAttrService] as? String)
                .or(throw: "No service for account \(account)".error())
            if let data = next[kSecValueData] as? Data {
                sum[service] = data
            }
        }
    }
    
    public func deleteAll() throws {
        
        let genericPassword: KeychainQuery = GenericPasswordQuery(
            account: name,
            service: nil,
            permission: keychain.permission,
            group: keychain.accessGroup,
            synchronizable: keychain.synchronize && keychain.permission.isSynchronizationAllowed
        )
        
        if keychain.synchronize && keychain.permission.isSynchronizationAllowed == false {
            print("⚠️", "This Keychain doesn't support synchronization as the accessibilityLevel \(keychain.permission.query) does not support it.")
        }
        
        let os = SecItemDelete(genericPassword.query as CFDictionary)
        
        if os != errSecSuccess {
            throw "Failed with code: \(os)".error()
        }
    }
    
    private func keychainQuery(forPath path: CodingPath) -> [CFString: Any] {
        
        let genericPassword: KeychainQuery = GenericPasswordQuery(
            account: name,
            service: path.string,
            permission: keychain.permission,
            group: keychain.accessGroup,
            synchronizable: keychain.synchronize && keychain.permission.isSynchronizationAllowed
        )
        
        if keychain.synchronize && keychain.permission.isSynchronizationAllowed == false {
            print("⚠️", "This Keychain doesn't support synchronization as the accessibilityLevel \(keychain.permission.query) does not support it.")
        }
        
        return genericPassword.query
    }
}

protocol KeychainQuery {
    var query: [CFString: Any] { get }
}

private struct GenericPasswordQuery: KeychainQuery, Equatable {
    
    let account: String
    let service: String?
    let permission: Keychain.Permission
    
    let group: String?
    let synchronizable: Bool
    
    var query: [CFString: Any] {
        
        var o: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccessible: permission.query,
            kSecAttrAccount: account
        ]
        
        if let service = service {
            o[kSecAttrService] = service
        }
        
        // Access group is not supported on any simulators.
        #if !targetEnvironment(simulator)
        if let accessGroup = group {
            o[kSecAttrAccessGroup] = accessGroup
        }
        #endif
        
        if synchronizable {
            o[kSecAttrSynchronizable] = kCFBooleanTrue
        }
        
        return o
    }
}

extension Keychain {
    
    public enum Permission: String, Codable, CustomStringConvertible {
        
        /// The data in the keychain item can be accessed only while the device is unlocked by the user.
        case whenUnlocked
        
        /// The data in the keychain item can be accessed only while the device is unlocked by the user.
        case whenUnlockedThisDeviceOnly
        
        /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
        case afterFirstUnlock
        
        /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
        case afterFirstUnlockThisDeviceOnly
        
        /// The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.
        case whenPasscodeSetThisDeviceOnly
        
        public var query: CFString {
            switch self {
            case .whenUnlocked: return kSecAttrAccessibleWhenUnlocked
            case .whenUnlockedThisDeviceOnly: return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            case .afterFirstUnlock: return kSecAttrAccessibleAfterFirstUnlock
            case .afterFirstUnlockThisDeviceOnly: return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            case .whenPasscodeSetThisDeviceOnly: return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
            }
        }
        
        public var isSynchronizationAllowed: Bool {
            switch self {
            case .afterFirstUnlock, .whenUnlocked:
                return true
            case .afterFirstUnlockThisDeviceOnly, .whenPasscodeSetThisDeviceOnly, .whenUnlockedThisDeviceOnly:
                return false
            }
        }
        
        public var description: String {
            switch self {
            case .whenUnlocked:
                return "\(kSecAttrAccessibleWhenUnlocked) - The data in the keychain item can be accessed only while the device is unlocked by the user."
            case .whenUnlockedThisDeviceOnly:
                return "\(kSecAttrAccessibleWhenUnlockedThisDeviceOnly) - The data in the keychain item can be accessed only while the device is unlocked by the user."
            case .afterFirstUnlock:
                return "\(kSecAttrAccessibleAfterFirstUnlock) - The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user."
            case .afterFirstUnlockThisDeviceOnly:
                return "\(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly) The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user."
            case .whenPasscodeSetThisDeviceOnly:
                return "\(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly) The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device."
            }
        }
    }
}

