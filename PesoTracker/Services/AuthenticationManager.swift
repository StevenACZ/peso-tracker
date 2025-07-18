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
        let loginRequest = LoginRequest(email: email, password: password)
        let response = try await apiService.login(loginRequest)
        
        guard let token = response.token, let user = response.user else {
            throw NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
        }
        
        try keychainService.saveToken(token)
        currentUser = user
        isAuthenticated = true
    }
    
    func register(username: String, email: String, password: String) async throws {
        let registerRequest = RegisterRequest(username: username, email: email, password: password)
        let _ = try await apiService.register(registerRequest)
        // Registration successful, user needs to login
    }
    
    func logout() {
        try? keychainService.deleteToken()
        currentUser = nil
        isAuthenticated = false
    }
}