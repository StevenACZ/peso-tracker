//
//  Constants.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation

// MARK: - Deprecated Constants
// These constants are kept for backward compatibility
// Use Configuration struct instead for new code

enum APIConstants {
    static let baseURL = Configuration.API.baseURL
    static let loginEndpoint = Configuration.API.loginEndpoint
    static let registerEndpoint = Configuration.API.registerEndpoint
    static let requestTimeout = Configuration.API.timeout
}

enum KeychainConstants {
    static let service = Configuration.Security.keychainService
    static let tokenKey = Configuration.Security.tokenKey
}

enum ValidationConstants {
    static let minPasswordLength = Configuration.Validation.minPasswordLength
    static let maxPasswordLength = Configuration.Validation.maxPasswordLength
    static let minUsernameLength = Configuration.Validation.minUsernameLength
    static let maxUsernameLength = Configuration.Validation.maxUsernameLength
}