//
//  SecureStorage.swift
//  GoogleServices
//
//  Created by Julian Parkfy on 16/05/2018.
//  Copyright © 2018 Julian. All rights reserved.
//

import Foundation


protocol SecureStorable: Codable {
    
}

protocol SecureStorage {
    
    @discardableResult func set<T>(value: T, key: String) -> Bool where T: SecureStorable
    func get<T>(_ key: String) -> T? where T: SecureStorable
    @discardableResult func clear() -> Bool
    
}

final class SecureStorageImpl: SecureStorage {
    
    @discardableResult func set<T>(value: T, key: String) -> Bool where T: SecureStorable {
        let data = try! JSONEncoder().encode(value)
        return self.set(data, key: key)
    }
    
    func get<T>(_ key: String) -> T? where T: SecureStorable {
        let data = self.getData(key)
        if let data = data {
            let object = try! JSONDecoder().decode(T.self, from: data)
            return object
        }
        return nil
    }
    
    @discardableResult func clear() -> Bool {
        let query: [String: Any] = [
            SecureStorageOptions.SecureClass : kSecClassGenericPassword,
            ]
        
        let result = SecItemDelete(query as CFDictionary)
        return result == noErr
    }
    
    //MARK: - Private
    private func set(_ value: Data, key: String, access: SecureStorageAccess = .accessibleWhenUnlockedThisDeviceOnly) -> Bool {
        let _ = self.delete(key)
        let query: [String: Any] = [
            SecureStorageOptions.SecureClass : kSecClassGenericPassword,
            SecureStorageOptions.ValueKey    : key,
            SecureStorageOptions.ValueData   : value,
            SecureStorageOptions.Accesible   : access.value,
            ]
        
        let result = SecItemAdd(query as CFDictionary, nil)
        
        return result == noErr
    }
    
    private func getData(_ key: String) -> Data? {
        
        let query: [String: Any] = [
            SecureStorageOptions.SecureClass : kSecClassGenericPassword,
            SecureStorageOptions.ValueKey    : key,
            SecureStorageOptions.ReturnData  : kCFBooleanTrue,
            SecureStorageOptions.MatchLimit  : kSecMatchLimitOne,
            ]
        
        var result: AnyObject?
        let resultCode = withUnsafePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer(mutating: $0))
        }
        
        if resultCode == noErr {
            return result as? Data
        }
        return nil
    }
    
    private func delete(_ key: String) -> Bool {
        let query: [String: Any] = [
            SecureStorageOptions.SecureClass : kSecClassGenericPassword,
            SecureStorageOptions.ValueKey    : key,
            ]
        
        let result = SecItemDelete(query as CFDictionary)
        
        return result == noErr
    }
    
    //MARK: - Constants
    private struct SecureStorageOptions {
        static let SecureClass = kSecClass as String
        static let ValueData   = kSecValueData as String
        static let ValueKey    = kSecAttrAccount as String
        static let Accesible   = kSecAttrAccessible as String
        static let ReturnData  = kSecReturnData as String
        static let MatchLimit  = kSecMatchLimit as String
    }
    
}
