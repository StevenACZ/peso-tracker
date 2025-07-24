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
    
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var isValidPassword: Bool {
        password.count >= 6 && password.rangeOfCharacter(from: .uppercaseLetters) != nil
    }
    
    var canLogin: Bool {
        !email.isEmpty && isValidEmail && !password.isEmpty && password.count >= 6
    }
    
    var canRegister: Bool {
        !username.isEmpty && username.count >= 3 && isValidEmail && isValidPassword
    }
    
    func login() async {
        guard canLogin else { return }
        
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
        guard canRegister else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.register(username: username, email: email, password: password)
            print("✅ AuthViewModel: Registration successful")
            
            // Iniciar sesión automáticamente después del registro exitoso
            try await authManager.login(email: email, password: password)
            print("✅ AuthViewModel: Auto-login after registration successful")
        } catch {
            print("❌ AuthViewModel: Registration or auto-login failed: \(error)")
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