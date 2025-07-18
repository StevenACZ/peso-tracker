//
//  AuthenticationViewModel.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation
import SwiftUI

/// ViewModel for managing authentication state and user interactions
@MainActor
class AuthenticationViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    // Form fields
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    
    // UI State
    @Published var isLoading = false
    @Published var showPassword = false
    @Published var currentFlow: AuthenticationFlow = .welcome
    
    // Error handling
    @Published var errorMessage: String?
    @Published var validationErrors: [String: String] = [:]
    @Published var showErrorAlert = false
    
    // Success states
    @Published var showSuccessMessage = false
    @Published var successMessage = ""
    
    // MARK: - Dependencies
    private let authManager = AuthenticationManager.shared
    private let validator = ValidationService.shared
    
    // MARK: - Computed Properties
    
    var isFormValid: Bool {
        switch currentFlow {
        case .login:
            return !email.isEmpty && !password.isEmpty && validationErrors.isEmpty
        case .register:
            return !username.isEmpty && !email.isEmpty && !password.isEmpty && validationErrors.isEmpty
        case .welcome:
            return false
        }
    }
    
    var canSubmit: Bool {
        return isFormValid && !isLoading
    }
    
    // MARK: - Authentication Actions
    
    /// Perform login with current form data
    func login() async {
        guard canSubmit else { return }
        
        // Clear previous errors
        clearErrors()
        
        // Validate fields
        let validationResults = validator.validateLoginFields(email: email, password: password)
        let errors = validator.getErrorMessages(validationResults)
        
        guard errors.isEmpty else {
            validationErrors = errors
            return
        }
        
        // Set loading state
        isLoading = true
        
        do {
            // Attempt login
            try await authManager.login(email: email, password: password)
            
            // Success - show confirmation
            showSuccessMessage(message: "Welcome back! Logging you in...")
            
            // Clear form
            clearForm()
            
        } catch let error as AuthenticationError {
            handleAuthenticationError(error)
        } catch {
            handleGenericError(error)
        }
        
        isLoading = false
    }
    
    /// Perform registration with current form data
    func register() async {
        guard canSubmit else { return }
        
        // Clear previous errors
        clearErrors()
        
        // Validate fields
        let validationResults = validator.validateRegistrationFields(
            username: username,
            email: email,
            password: password
        )
        let errors = validator.getErrorMessages(validationResults)
        
        guard errors.isEmpty else {
            validationErrors = errors
            return
        }
        
        // Set loading state
        isLoading = true
        
        do {
            // Attempt registration
            try await authManager.register(username: username, email: email, password: password)
            
            // Success - show message and switch to login
            showSuccessMessage(message: "Account created successfully! Please log in.")
            
            // Clear form and switch to login
            clearForm()
            switchToLogin()
            
        } catch let error as AuthenticationError {
            handleAuthenticationError(error)
        } catch {
            handleGenericError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - Navigation Actions
    
    /// Switch to login flow
    func switchToLogin() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentFlow = .login
        }
        clearErrors()
        clearForm()
    }
    
    /// Switch to registration flow
    func switchToRegister() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentFlow = .register
        }
        clearErrors()
        clearForm()
    }
    
    /// Switch to welcome flow
    func switchToWelcome() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentFlow = .welcome
        }
        clearErrors()
        clearForm()
    }
    
    // MARK: - Validation
    
    /// Validate current form fields in real-time
    func validateCurrentForm() {
        switch currentFlow {
        case .login:
            let results = validator.validateLoginFields(email: email, password: password)
            validationErrors = validator.getErrorMessages(results)
        case .register:
            let results = validator.validateRegistrationFields(username: username, email: email, password: password)
            validationErrors = validator.getErrorMessages(results)
        case .welcome:
            validationErrors.removeAll()
        }
    }
    
    /// Validate specific field
    func validateField(_ field: String) {
        switch field {
        case "username":
            let result = validator.validateUsername(username)
            if let error = result.errorMessage {
                validationErrors["username"] = error
            } else {
                validationErrors.removeValue(forKey: "username")
            }
        case "email":
            let result = validator.validateEmail(email)
            if let error = result.errorMessage {
                validationErrors["email"] = error
            } else {
                validationErrors.removeValue(forKey: "email")
            }
        case "password":
            let result = validator.validatePassword(password)
            if let error = result.errorMessage {
                validationErrors["password"] = error
            } else {
                validationErrors.removeValue(forKey: "password")
            }
        default:
            break
        }
    }
    
    // MARK: - Error Handling
    
    private func handleAuthenticationError(_ error: AuthenticationError) {
        switch error {
        case .validationError(let validationErrors):
            // Handle server validation errors
            var errorDict: [String: String] = [:]
            for validationError in validationErrors {
                errorDict[validationError.param] = validationError.msg
            }
            self.validationErrors = errorDict
            
        case .invalidCredentials:
            errorMessage = "Invalid email or password. Please check your credentials and try again."
            showErrorAlert = true
            
        case .networkError:
            errorMessage = "Network connection error. Please check your internet connection and try again."
            showErrorAlert = true
            
        default:
            errorMessage = error.errorDescription ?? "An unexpected error occurred. Please try again."
            showErrorAlert = true
        }
    }
    
    private func handleGenericError(_ error: Error) {
        errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        showErrorAlert = true
    }
    
    // MARK: - UI Helpers
    
    /// Clear all errors
    func clearErrors() {
        errorMessage = nil
        validationErrors.removeAll()
        showErrorAlert = false
    }
    
    /// Clear form fields
    func clearForm() {
        email = ""
        password = ""
        username = ""
        showPassword = false
    }
    
    /// Show success message with animation
    private func showSuccessMessage(message: String) {
        successMessage = message
        withAnimation(.easeInOut(duration: 0.3)) {
            showSuccessMessage = true
        }
        
        // Hide success message after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.showSuccessMessage = false
            }
        }
    }
    
    /// Toggle password visibility
    func togglePasswordVisibility() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showPassword.toggle()
        }
    }
    
    /// Dismiss error alert
    func dismissErrorAlert() {
        showErrorAlert = false
        errorMessage = nil
    }
    
    /// Dismiss success message
    func dismissSuccessMessage() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showSuccessMessage = false
        }
    }
    
    // MARK: - Keyboard Shortcuts
    
    /// Handle return key press
    func handleReturnKey() {
        switch currentFlow {
        case .login:
            if canSubmit {
                Task {
                    await login()
                }
            }
        case .register:
            if canSubmit {
                Task {
                    await register()
                }
            }
        case .welcome:
            break
        }
    }
    
    /// Handle escape key press
    func handleEscapeKey() {
        if currentFlow != .welcome {
            switchToWelcome()
        }
    }
    
    // MARK: - Accessibility
    
    /// Get accessibility label for current form
    var formAccessibilityLabel: String {
        switch currentFlow {
        case .welcome:
            return "Welcome screen with authentication options"
        case .login:
            return "Login form with email and password fields"
        case .register:
            return "Registration form with username, email, and password fields"
        }
    }
    
    /// Get accessibility hint for submit button
    var submitButtonAccessibilityHint: String {
        switch currentFlow {
        case .login:
            return canSubmit ? "Double tap to log in" : "Complete all fields to enable login"
        case .register:
            return canSubmit ? "Double tap to create account" : "Complete all fields to enable registration"
        case .welcome:
            return ""
        }
    }
    
    // MARK: - Animation Helpers
    
    /// Get animation for current transition
    var transitionAnimation: Animation {
        .easeInOut(duration: 0.4)
    }
    
    /// Get spring animation for interactive elements
    var springAnimation: Animation {
        .spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)
    }
}