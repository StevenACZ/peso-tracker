import Foundation
import SwiftUI
import Combine

// MARK: - Password Recovery State
@MainActor
class PasswordRecoveryState: ObservableObject {
    
    // MARK: - Recovery Step Enum
    enum RecoveryStep {
        case requestCode
        case verifyCode
        case resetPassword
        case completed
    }
    
    // MARK: - Flow State
    @Published var currentStep: RecoveryStep = .requestCode
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    // MARK: - Form Fields
    @Published var email = ""
    @Published var verificationCode = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    
    // MARK: - Validation States
    @Published var isEmailValid = false
    @Published var isCodeValid = false
    @Published var isPasswordValid = false
    @Published var passwordsMatch = false
    
    // MARK: - Real-time Validation States
    @Published var emailValidationState: AuthTextField.ValidationState = .none
    @Published var codeValidationState: AuthTextField.ValidationState = .none
    @Published var passwordValidationState: AuthTextField.ValidationState = .none
    @Published var confirmPasswordValidationState: AuthTextField.ValidationState = .none
    
    // MARK: - Error Messages
    @Published var emailValidationError: String?
    @Published var codeValidationError: String?
    @Published var passwordValidationError: String?
    @Published var confirmPasswordError: String?
    
    // MARK: - Modal States
    @Published var showSuccessMessage = false
    @Published var successMessage = ""
    
    // MARK: - Navigation State
    @Published var shouldNavigateToResetPassword = false
    @Published var shouldNavigateToLogin = false
    @Published var canNavigateBack = true
    
    // MARK: - Retry Functionality
    @Published var canRetry = false
    @Published var retryStep: RecoveryStep?
    
    // MARK: - Private Properties
    private(set) var resetToken: String?
    private(set) var emailPersisted = false
    
    // MARK: - State Management
    
    func setResetToken(_ token: String) {
        resetToken = token
    }
    
    func clearResetToken() {
        resetToken = nil
    }
    
    func persistEmail() {
        if !email.isEmpty && isEmailValid {
            emailPersisted = true
        }
    }
    
    func clearEmailPersistence() {
        emailPersisted = false
    }
    
    // MARK: - Error Handling
    
    func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    func clearError() {
        errorMessage = nil
        showError = false
    }
    
    func dismissError() {
        showError = false
        errorMessage = nil
    }
    
    // MARK: - Success Messages
    
    func showSuccess(_ message: String, duration: TimeInterval = 1.5, completion: @escaping () -> Void = {}) {
        successMessage = message
        showSuccessMessage = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.showSuccessMessage = false
            self.successMessage = ""
            completion()
        }
    }
    
    // MARK: - Navigation State Management
    
    func clearNavigationFlags() {
        shouldNavigateToResetPassword = false
        shouldNavigateToLogin = false
    }
    
    func enableRetry(for step: RecoveryStep) {
        retryStep = step
        canRetry = true
    }
    
    func disableRetry() {
        canRetry = false
        retryStep = nil
    }
    
    // MARK: - Step Validation
    
    func canProceedToNextStep() -> Bool {
        switch currentStep {
        case .requestCode:
            return isEmailValid
        case .verifyCode:
            return isCodeValid
        case .resetPassword:
            return isPasswordValid && passwordsMatch
        case .completed:
            return false
        }
    }
    
    func canProceedFromCurrentStep() -> Bool {
        switch currentStep {
        case .requestCode:
            return isEmailValid && !isLoading
        case .verifyCode:
            return isCodeValid && !isLoading && emailPersisted
        case .resetPassword:
            return isPasswordValid && passwordsMatch && !isLoading && resetToken != nil
        case .completed:
            return false
        }
    }
    
    func canNavigateToStep(_ step: RecoveryStep) -> Bool {
        switch step {
        case .requestCode:
            return true
        case .verifyCode:
            return currentStep == .requestCode && emailPersisted
        case .resetPassword:
            return currentStep == .verifyCode && resetToken != nil
        case .completed:
            return currentStep == .resetPassword && resetToken != nil
        }
    }
    
    func validateFlowIntegrity() -> Bool {
        switch currentStep {
        case .requestCode:
            return true
        case .verifyCode:
            return emailPersisted && !email.isEmpty
        case .resetPassword:
            return resetToken != nil
        case .completed:
            return true
        }
    }
    
    // MARK: - Step Information
    
    func getCurrentStepTitle() -> String {
        switch currentStep {
        case .requestCode:
            return "Recuperar Contraseña"
        case .verifyCode:
            return "Verificar Código"
        case .resetPassword:
            return "Nueva Contraseña"
        case .completed:
            return "Completado"
        }
    }
    
    func getCurrentStepDescription() -> String {
        switch currentStep {
        case .requestCode:
            return "Ingresa tu email para recibir un código de recuperación"
        case .verifyCode:
            return "Ingresa el código de 6 dígitos que enviamos a tu email"
        case .resetPassword:
            return "Establece tu nueva contraseña"
        case .completed:
            return "Tu contraseña ha sido actualizada exitosamente"
        }
    }
    
    // MARK: - Reset Flow
    
    func resetAllState() {
        // Clear all form data
        email = ""
        verificationCode = ""
        newPassword = ""
        confirmPassword = ""
        
        // Clear validation states
        emailValidationState = .none
        codeValidationState = .none
        passwordValidationState = .none
        confirmPasswordValidationState = .none
        
        // Clear validation flags
        isEmailValid = false
        isCodeValid = false
        isPasswordValid = false
        passwordsMatch = false
        
        // Clear error messages
        emailValidationError = nil
        codeValidationError = nil
        passwordValidationError = nil
        confirmPasswordError = nil
        
        // Clear modal states
        showSuccessMessage = false
        successMessage = ""
        
        // Clear navigation states
        shouldNavigateToResetPassword = false
        shouldNavigateToLogin = false
        canNavigateBack = true
        
        // Clear temporary data
        resetToken = nil
        emailPersisted = false
        
        // Clear retry state
        canRetry = false
        retryStep = nil
        
        // Reset to initial step
        currentStep = .requestCode
        
        // Clear general error state
        clearError()
    }
}