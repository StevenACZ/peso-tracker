//
//  Configuration.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation

struct Configuration {
    
    // MARK: - Environment Detection
    enum Environment {
        case development
        case staging
        case production
        
        static var current: Environment {
            #if DEBUG
            return .development
            #else
            return .production
            #endif
        }
    }
    
    // MARK: - API Configuration
    struct API {
        static var baseURL: String {
            return Bundle.main.apiBaseURL ?? "http://100.111.122.121:3000"
        }
        
        static let timeout: TimeInterval = 30.0
        static let loginEndpoint = "/api/auth/login"
        static let registerEndpoint = "/api/auth/register"
    }
    
    // MARK: - Security Configuration
    struct Security {
        static let keychainService = "com.pesotracker.app"
        static let tokenKey = "jwt_token"
    }
    
    // MARK: - Validation Rules
    struct Validation {
        static let minPasswordLength = 8
        static let maxPasswordLength = 128
        static let minUsernameLength = 3
        static let maxUsernameLength = 30
    }
}

// MARK: - Bundle Extension for Configuration
extension Bundle {
    
    /// Get configuration value from Info.plist or xcconfig
    func configurationValue(for key: String) -> String? {
        return object(forInfoDictionaryKey: key) as? String
    }
    
    /// Get API base URL from configuration
    var apiBaseURL: String? {
        return configurationValue(for: "API_BASE_URL")
    }
    
    /// Get environment from configuration
    var environment: String {
        return configurationValue(for: "ENVIRONMENT") ?? "development"
    }
}
