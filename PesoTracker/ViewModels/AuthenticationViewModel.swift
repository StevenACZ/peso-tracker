//
//  AuthenticationViewModel.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var isLoading = false
    @Published var currentFlow: AuthenticationFlow = .welcome
    @Published var errorMessage: String?
    @Published var showErrorAlert = false
    
    private let authManager = AuthenticationManager.shared
    
    func login() async {
        guard !email.isEmpty && !password.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.login(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
        
        isLoading = false
    }
    
    func register() async {
        guard !username.isEmpty && !email.isEmpty && !password.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.register(username: username, email: email, password: password)
            switchToLogin()
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
        
        isLoading = false
    }
    
    func switchToLogin() {
        currentFlow = .login
        clearForm()
    }
    
    func switchToRegister() {
        currentFlow = .register
        clearForm()
    }
    
    func switchToWelcome() {
        currentFlow = .welcome
        clearForm()
    }
    
    func dismissErrorAlert() {
        showErrorAlert = false
        errorMessage = nil
    }
    
    private func clearForm() {
        email = ""
        password = ""
        username = ""
        errorMessage = nil
    }
}