//
//  KeyChainManager.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 14/05/23.
//

import Foundation

class KeychainService {
    
    static let shared = KeychainService()
    
    func saveSessionToKeychain(with data: String) -> Bool {
        let query = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrService as String : Constants.SERVICE_KEY as AnyObject,
            kSecAttrAccount as String : Constants.SESSION_KEY as AnyObject,
            kSecValueData as String : data.data(using: .utf8) as AnyObject
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status != errSecDuplicateItem, status == errSecSuccess else {
            return false
        }
        return true
    }
    
    func getSessionFromKeychain() -> Data? {
        let query: [String : AnyObject] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrService as String : Constants.SERVICE_KEY as AnyObject,
            kSecAttrAccount as String : Constants.SESSION_KEY as AnyObject,
            kSecReturnData as String : kCFBooleanTrue,
            kSecMatchLimit as String : kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            return result as? Data
        } else {
            return nil
        }
    }
    
    func deleteSessionFromKeychain() -> Bool {
        let query: [String : AnyObject] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrService as String : Constants.SERVICE_KEY as AnyObject,
            kSecAttrAccount as String : Constants.SESSION_KEY as AnyObject
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            return true
        } else {
            return false
        }
    }
}
