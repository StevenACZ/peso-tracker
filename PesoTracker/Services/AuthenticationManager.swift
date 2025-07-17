//
//  AuthenticationManager.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation
import SwiftUI

/// Main authentication manager that coordinates login, registration, and session management
@MainActor
class AuthenticationManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = AuthenticationManager()
    private init() {}
    
    // MARK: - Published Properties
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    var isAuthenticated: Bool {
        switch authenticationState {
        case .authenticated:
            return true
        default:
            return false
        }
    }
    
    var isAuthenticating: Bool {
        switch authenticationState {
        case .authenticating:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Services
    private let apiService = APIService.shared
    private let keychainService = KeychainService.shared
    
    // MARK: - Initialization
    func initialize() async {
        await checkAuthenticationStatus()
    }
    
    // MARK: - Authentication Methods
    
    /// Login user with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    /// - Throws: AuthenticationError for various failure scenarios
    func login(email: String, password: String) async throws {
        // Clear any previous errors
        errorMessage = nil
        
        // Set loading state
        authenticationState = .authenticating
        isLoading = true
        
        do {
            // Create login request
            let loginRequest = LoginRequest(email: email, password: password)
            
            // Make API call
            let response = try await apiService.login(loginRequest)
            
            // Validate response
            guard let token = response.token, let user = response.user else {
                throw AuthenticationError.invalidResponse
            }
            
            // Save token to keychain
            try keychainService.saveToken(token)
            
            // Update state
            currentUser = user
            authenticationState = .authenticated(user)
            isLoading = false
            
        } catch let error as APIError {
            // Handle API errors
            isLoading = false
            authenticationState = .unauthenticated
            
            switch error {
            case .unauthorized:
                throw AuthenticationError.invalidCredentials
            case .validationError(let validationErrors):
                throw AuthenticationError.validationError(validationErrors)
            case .networkError(let networkError):
                throw AuthenticationError.networkError(networkError)
            default:
                throw AuthenticationError.apiError(error)
            }
            
        } catch let error as KeychainError {
            // Handle keychain errors
            isLoading = false
            authenticationState = .unauthenticated
            throw AuthenticationError.keychainError(error)
            
        } catch {
            // Handle unexpected errors
            isLoading = false
            authenticationState = .unauthenticated
            throw AuthenticationError.networkError(error)
        }
    }
    
    /// Register new user
    /// - Parameters:
    ///   - username: Desired username
    ///   - email: User's email address
    ///   - password: User's password
    /// - Throws: AuthenticationError for various failure scenarios
    func register(username: String, email: String, password: String) async throws {
        // Clear any previous errors
        errorMessage = nil
        
        // Set loading state
        authenticationState = .authenticating
        isLoading = true
        
        do {
            // Create register request
            let registerRequest = RegisterRequest(
                username: username,
                email: email,
                password: password
            )
            
            // Make API call
            let response = try await apiService.register(registerRequest)
            
            // Validate response
            guard let user = response.user else {
                throw AuthenticationError.invalidResponse
            }
            
            // Registration successful - user needs to login
            // (Your API doesn't return token on registration)
            isLoading = false
            authenticationState = .unauthenticated
            
            // Note: User will need to login after successful registration
            
        } catch let error as APIError {
            // Handle API errors
            isLoading = false
            authenticationState = .unauthenticated
            
            switch error {
            case .validationError(let validationErrors):
                throw AuthenticationError.validationError(validationErrors)
            case .networkError(let networkError):
                throw AuthenticationError.networkError(networkError)
            default:
                throw AuthenticationError.apiError(error)
            }
            
        } catch {
            // Handle unexpected errors
            isLoading = false
            authenticationState = .unauthenticated
            throw AuthenticationError.networkError(error)
        }
    }
    
    /// Logout current user
    func logout() {
        do {
            // Remove token from keychain
            try keychainService.deleteToken()
        } catch {
            // Log error but continue with logout
            print("Warning: Failed to delete token from keychain: \(error)")
        }
        
        // Clear state
        currentUser = nil
        authenticationState = .unauthenticated
        errorMessage = nil
        isLoading = false
    }
    
    /// Check if user is already authenticated (on app launch)
    func checkAuthenticationStatus() async {
        do {
            // Check if token exists in keychain
            guard let token = try keychainService.getToken() else {
                authenticationState = .unauthenticated
                return
            }
            
            // TODO: Validate token with server (when you add a /me endpoint)
            // For now, we'll assume token is valid if it exists
            // In a real app, you'd want to verify the token with the server
            
            // Token exists, but we don't have user data
            // You might want to add a /me endpoint to your API to get current user
            authenticationState = .unauthenticated
            
            // Uncomment when you add a /me endpoint:
            /*
            do {
                let user = try await apiService.getCurrentUser()
                currentUser = user
                authenticationState = .authenticated(user)
            } catch {
                // Token is invalid, remove it
                try? keychainService.deleteToken()
                authenticationState = .unauthenticated
            }
            */
            
        } catch {
            // Error reading from keychain
            authenticationState = .unauthenticated
        }
    }
    
    // MARK: - Error Handling
    
    /// Set error message for UI display
    /// - Parameter error: AuthenticationError to display
    func setError(_ error: AuthenticationError) {
        errorMessage = error.errorDescription
    }
    
    /// Clear current error message
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Utility Methods
    
    /// Check if user has valid authentication token
    var hasValidToken: Bool {
        return keychainService.hasToken()
    }
    
    /// Get current authentication token (for debugging)
    func getCurrentToken() -> String? {
        return try? keychainService.getToken()
    }
}