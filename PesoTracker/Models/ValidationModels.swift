//
//  ValidationModels.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation

// MARK: - Validation Models
struct ValidationRule {
    let field: String
    let validator: (String) -> ValidationResult
}

enum ValidationResult {
    case valid
    case invalid(String)
    
    var isValid: Bool {
        switch self {
        case .valid:
            return true
        case .invalid:
            return false
        }
    }
    
    var errorMessage: String? {
        switch self {
        case .valid:
            return nil
        case .invalid(let message):
            return message
        }
    }
}

// MARK: - Authentication Errors
enum AuthenticationError: LocalizedError {
    case invalidCredentials
    case networkError(Error)
    case validationError([ValidationError])
    case keychainError(KeychainError)
    case apiError(APIError)
    case tokenExpired
    case invalidResponse
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .networkError:
            return "Network connection error. Please check your internet connection and try again."
        case .validationError(let errors):
            return errors.first?.msg ?? "Validation error occurred."
        case .keychainError(let keychainError):
            return keychainError.errorDescription ?? "Security error occurred. Please try logging in again."
        case .apiError(let apiError):
            return apiError.errorDescription
        case .tokenExpired:
            return "Your session has expired. Please log in again."
        case .invalidResponse:
            return "Invalid response from server. Please try again."
        case .serverError(let message):
            return message
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidCredentials:
            return "Please check your email and password and try again."
        case .networkError:
            return "Please check your internet connection and try again."
        case .validationError:
            return "Please correct the highlighted fields and try again."
        case .keychainError(let keychainError):
            return keychainError.recoverySuggestion
        case .apiError(let apiError):
            return apiError.recoverySuggestion
        case .tokenExpired:
            return "Please log in again to continue."
        case .invalidResponse, .serverError:
            return "Please try again later. If the problem persists, contact support."
        }
    }
}