//
//  AuthenticationManager.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation

@MainActor
class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    private init() {}
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    private let apiService = APIService.shared
    private let keychainService = KeychainService.shared
    
    func initialize() async {
        // Check if user has token
        if let _ = try? keychainService.getToken() {
            isAuthenticated = true
        }
    }
    
    func login(email: String, password: String) async throws {
        print("🔐 AuthManager: Starting login for email: \(email)")
        
        let loginRequest = LoginRequest(email: email, password: password)
        let response = try await apiService.login(loginRequest)
        
        print("🔐 AuthManager: Received response from API")
        
        guard let token = response.token, let user = response.user else {
            print("❌ AuthManager: Invalid response - missing token or user")
            throw NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
        }
        
        print("🔐 AuthManager: Saving token to keychain")
        try keychainService.saveToken(token)
        
        print("🔐 AuthManager: Login successful for user: \(user.username)")
        currentUser = user
        isAuthenticated = true
    }
    
    func register(username: String, email: String, password: String) async throws {
        print("📝 AuthManager: Starting registration for email: \(email)")
        
        let registerRequest = RegisterRequest(username: username, email: email, password: password)
        let _ = try await apiService.register(registerRequest)
        
        print("✅ AuthManager: Registration successful, user needs to login")
        // Registration successful, user needs to login
    }
    
    func logout() {
        try? keychainService.deleteToken()
        currentUser = nil
        isAuthenticated = false
    }
}