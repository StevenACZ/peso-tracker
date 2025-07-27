import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    // MARK: - Form Fields
    @Published var loginEmail = ""
    @Published var loginPassword = ""
    @Published var registerUsername = ""
    @Published var registerEmail = ""
    @Published var registerPassword = ""
    @Published var confirmPassword = ""
    
    // MARK: - Validation States
    @Published var isLoginFormValid = false
    @Published var isRegisterFormValid = false
    @Published var emailValidationError: String?
    @Published var passwordValidationError: String?
    @Published var usernameValidationError: String?
    @Published var confirmPasswordError: String?
    
    // MARK: - Services
    private let authService = AuthService.shared
    
    // MARK: - Initialization
    init() {
        // Observe authentication state from AuthService
        authService.$isAuthenticated
            .assign(to: &$isAuthenticated)
        
        authService.$currentUser
            .assign(to: &$currentUser)
        
        // Setup form validation
        setupFormValidation()
    }
    
    // MARK: - Form Validation Setup
    private func setupFormValidation() {
        // Login form validation
        Publishers.CombineLatest($loginEmail, $loginPassword)
            .map { email, password in
                !email.isEmpty && !password.isEmpty && self.authService.validateEmail(email)
            }
            .assign(to: &$isLoginFormValid)
        
        // Register form validation (simplified - no confirm password)
        Publishers.CombineLatest3($registerUsername, $registerEmail, $registerPassword)
            .map { username, email, password in
                !username.isEmpty &&
                !email.isEmpty &&
                !password.isEmpty &&
                self.authService.validateUsername(username) &&
                self.authService.validateEmail(email) &&
                self.authService.validatePassword(password)
            }
            .assign(to: &$isRegisterFormValid)
        
        // Real-time email validation
        $loginEmail
            .combineLatest($registerEmail)
            .map { loginEmail, registerEmail in
                let emailToValidate = !loginEmail.isEmpty ? loginEmail : registerEmail
                if emailToValidate.isEmpty {
                    return nil
                }
                return self.authService.validateEmail(emailToValidate) ? nil : "Formato de email inválido"
            }
            .assign(to: &$emailValidationError)
        
        // Real-time password validation
        $registerPassword
            .map { password in
                if password.isEmpty {
                    return nil
                }
                return self.authService.validatePassword(password) ? nil : "La contraseña debe tener entre \(Constants.Validation.minPasswordLength) y \(Constants.Validation.maxPasswordLength) caracteres"
            }
            .assign(to: &$passwordValidationError)
        
        // Real-time username validation
        $registerUsername
            .map { username in
                if username.isEmpty {
                    return nil
                }
                return self.authService.validateUsername(username) ? nil : "El nombre de usuario debe tener entre \(Constants.Validation.minUsernameLength) y \(Constants.Validation.maxUsernameLength) caracteres"
            }
            .assign(to: &$usernameValidationError)
        
        // Confirm password validation
        Publishers.CombineLatest($registerPassword, $confirmPassword)
            .map { password, confirmPassword in
                if confirmPassword.isEmpty {
                    return nil
                }
                return password == confirmPassword ? nil : "Las contraseñas no coinciden"
            }
            .assign(to: &$confirmPasswordError)
    }
    
    // MARK: - Authentication Methods
    
    func login() async {
        guard isLoginFormValid else {
            showErrorMessage("Por favor completa todos los campos correctamente")
            return
        }
        
        isLoading = true
        clearError()
        
        do {
            let user = try await authService.login(email: loginEmail, password: loginPassword)
            
            // Clear form on successful login
            clearLoginForm()
            
            print("Login exitoso para usuario: \(user.username)")
            
        } catch {
            showErrorMessage(authService.handleAuthError(error))
        }
        
        isLoading = false
    }
    
    func register() async {
        guard isRegisterFormValid else {
            showErrorMessage("Por favor completa todos los campos correctamente")
            return
        }
        
        isLoading = true
        clearError()
        
        do {
            let user = try await authService.register(
                username: registerUsername,
                email: registerEmail,
                password: registerPassword
            )
            
            // Clear form on successful registration
            clearRegisterForm()
            
            print("Registro exitoso para usuario: \(user.username)")
            
        } catch {
            showErrorMessage(authService.handleAuthError(error))
        }
        
        isLoading = false
    }
    
    func logout() {
        authService.logout()
        clearAllForms()
        print("Usuario desconectado")
    }
    
    // MARK: - Helper Methods
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    private func clearError() {
        errorMessage = nil
        showError = false
    }
    
    private func clearLoginForm() {
        loginEmail = ""
        loginPassword = ""
    }
    
    private func clearRegisterForm() {
        registerUsername = ""
        registerEmail = ""
        registerPassword = ""
        confirmPassword = ""
    }
    
    private func clearAllForms() {
        clearLoginForm()
        clearRegisterForm()
    }
    
    // MARK: - Validation Helpers
    
    func getEmailFieldColor() -> Color {
        if emailValidationError != nil {
            return .red
        }
        return .primary
    }
    
    func getPasswordFieldColor() -> Color {
        if passwordValidationError != nil {
            return .red
        }
        return .primary
    }
    
    func getUsernameFieldColor() -> Color {
        if usernameValidationError != nil {
            return .red
        }
        return .primary
    }
    
    func getConfirmPasswordFieldColor() -> Color {
        if confirmPasswordError != nil {
            return .red
        }
        return .primary
    }
    
    // MARK: - Authentication Status
    
    func checkAuthenticationStatus() {
        authService.refreshAuthenticationStatus()
        
        // Validate token if exists
        if authService.isTokenValid() {
            // Token exists and is valid
            isAuthenticated = true
        } else {
            // Token is invalid or doesn't exist
            isAuthenticated = false
            currentUser = nil
            // Clear invalid token
            authService.logout()
        }
    }
    
    func isTokenValid() -> Bool {
        return authService.isTokenValid()
    }
    
    // MARK: - Auto-logout on token expiration
    func handleTokenExpiration() {
        showErrorMessage("Tu sesión ha expirado. Por favor inicia sesión nuevamente.")
        logout()
    }
}