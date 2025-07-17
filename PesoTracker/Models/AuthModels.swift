//
//  AuthModels.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation

// MARK: - Request Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let username: String
    let email: String
    let password: String
}

// MARK: - Response Models
struct AuthResponse: Codable {
    let message: String
    let token: String?
    let user: User?
}

// APIError is defined below as an enum

struct ValidationError: Codable {
    let msg: String
    let param: String
    let location: String
}

// MARK: - Server Error Response
struct ServerErrorResponse: Codable {
    let error: String
    let details: [ValidationError]?
}

// MARK: - Authentication State
enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated(User)
}

enum AuthenticationFlow {
    case welcome
    case login
    case register
}

// MARK: - API Errors
enum APIError: LocalizedError, Codable {
    case invalidURL
    case encodingError(String)
    case decodingError(String)
    case networkError(NetworkError)
    case invalidResponse
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case serverError(String)
    case unexpectedStatusCode(Int)
    case validationError([ValidationError])
    case authenticationRequired
    
    // For Codable support
    enum CodingKeys: String, CodingKey {
        case error
        case details
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let errorMessage = try container.decode(String.self, forKey: .error)
        let details = try container.decodeIfPresent([ValidationError].self, forKey: .details)
        
        if let details = details {
            self = .validationError(details)
        } else {
            self = .serverError(errorMessage)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .validationError(let errors):
            try container.encode("Validation failed", forKey: .error)
            try container.encode(errors, forKey: .details)
        case .serverError(let message):
            try container.encode(message, forKey: .error)
        default:
            try container.encode(self.errorDescription ?? "Unknown error", forKey: .error)
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL configuration"
        case .encodingError:
            return "Failed to encode request data"
        case .decodingError:
            return "Failed to decode server response"
        case .networkError(let networkError):
            return networkError.description
        case .invalidResponse:
            return "Invalid response from server"
        case .badRequest:
            return "Invalid request data"
        case .unauthorized:
            return "Invalid credentials or session expired"
        case .forbidden:
            return "Access denied"
        case .notFound:
            return "Requested resource not found"
        case .rateLimited:
            return "Too many requests. Please try again later"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unexpectedStatusCode(let code):
            return "Unexpected server response (code: \(code))"
        case .validationError(let errors):
            return errors.first?.msg ?? "Validation error"
        case .authenticationRequired:
            return "Authentication required. Please log in"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidURL, .encodingError, .decodingError:
            return "This appears to be a technical issue. Please contact support"
        case .networkError(let networkError):
            return networkError.recoverySuggestion
        case .invalidResponse, .unexpectedStatusCode:
            return "Please try again. If the problem persists, contact support"
        case .badRequest, .validationError:
            return "Please check your input and try again"
        case .unauthorized, .authenticationRequired:
            return "Please log in again"
        case .forbidden:
            return "You don't have permission to perform this action"
        case .notFound:
            return "The requested resource could not be found"
        case .rateLimited:
            return "Please wait a moment before trying again"
        case .serverError:
            return "Please try again later. If the problem persists, contact support"
        }
    }
}

// MARK: - Network Errors
enum NetworkError: Error, Codable {
    case noConnection
    case timeout
    case hostUnreachable
    case unknown(String)
    
    var description: String {
        switch self {
        case .noConnection:
            return "No internet connection available"
        case .timeout:
            return "Request timed out"
        case .hostUnreachable:
            return "Cannot reach the server"
        case .unknown(let message):
            return "Network error: \(message)"
        }
    }
    
    var recoverySuggestion: String {
        switch self {
        case .noConnection:
            return "Please check your internet connection and try again"
        case .timeout:
            return "Please check your connection and try again"
        case .hostUnreachable:
            return "Please check your connection or try again later"
        case .unknown:
            return "Please check your connection and try again"
        }
    }
}