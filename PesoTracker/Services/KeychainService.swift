//
//  KeychainService.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation
import Security

/// Service for secure storage and retrieval of sensitive data using macOS Keychain
class KeychainService {
    
    // MARK: - Singleton
    static let shared = KeychainService()
    private init() {}
    
    // MARK: - Configuration
    private let service = Configuration.Security.keychainService
    private let tokenKey = Configuration.Security.tokenKey
    
    // MARK: - Public Methods
    
    /// Save JWT token to Keychain
    /// - Parameter token: JWT token string to save
    /// - Throws: KeychainError if save operation fails
    func saveToken(_ token: String) throws {
        let data = Data(token.utf8)
        
        // Delete existing token first
        try? deleteToken()
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    /// Retrieve JWT token from Keychain
    /// - Returns: JWT token string if found, nil otherwise
    /// - Throws: KeychainError if retrieval fails
    func getToken() throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        switch status {
        case errSecSuccess:
            guard let data = result as? Data,
                  let token = String(data: data, encoding: .utf8) else {
                throw KeychainError.invalidData
            }
            return token
            
        case errSecItemNotFound:
            return nil
            
        default:
            throw KeychainError.retrievalFailed(status)
        }
    }
    
    /// Delete JWT token from Keychain
    /// - Throws: KeychainError if deletion fails
    func deleteToken() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        // Success or item not found are both acceptable
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deletionFailed(status)
        }
    }
    
    /// Check if token exists in Keychain
    /// - Returns: true if token exists, false otherwise
    func hasToken() -> Bool {
        do {
            return try getToken() != nil
        } catch {
            return false
        }
    }
    
    /// Clear all stored data (useful for logout or reset)
    func clearAll() throws {
        try deleteToken()
    }
}

// MARK: - Keychain Errors
enum KeychainError: LocalizedError {
    case saveFailed(OSStatus)
    case retrievalFailed(OSStatus)
    case deletionFailed(OSStatus)
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let status):
            return "Failed to save to Keychain. Status: \(status)"
        case .retrievalFailed(let status):
            return "Failed to retrieve from Keychain. Status: \(status)"
        case .deletionFailed(let status):
            return "Failed to delete from Keychain. Status: \(status)"
        case .invalidData:
            return "Invalid data retrieved from Keychain"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .saveFailed, .retrievalFailed, .deletionFailed:
            return "Please try again. If the problem persists, you may need to log in again."
        case .invalidData:
            return "The stored data appears to be corrupted. Please log in again."
        }
    }
}

// MARK: - OSStatus Extension
extension OSStatus {
    var keychainErrorDescription: String {
        switch self {
        case errSecSuccess:
            return "Success"
        case errSecItemNotFound:
            return "Item not found"
        case errSecDuplicateItem:
            return "Duplicate item"
        case errSecAuthFailed:
            return "Authentication failed"
        case errSecUserCanceled:
            return "User canceled"
        default:
            return "Unknown error (\(self))"
        }
    }
}