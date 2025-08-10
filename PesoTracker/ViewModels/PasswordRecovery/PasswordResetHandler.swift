import Foundation

// MARK: - Password Reset Handler
@MainActor
class PasswordResetHandler {
    
    private let authService = AuthService.shared
    private let validator = RecoveryValidator()
    
    // MARK: - Password Reset Process
    
    func resetPasswordWithCode(for state: PasswordRecoveryState) async {
        // Validate passwords before proceeding
        guard state.isPasswordValid && state.passwordsMatch else {
            state.showErrorMessage("Por favor completa todos los campos correctamente")
            return
        }
        
        guard state.canProceedFromCurrentStep() else {
            state.showErrorMessage("No se puede proceder desde el estado actual")
            return
        }
        
        guard let token = state.resetToken else {
            state.showErrorMessage("Error de sesión. Por favor reinicia el proceso.")
            state.resetAllState()
            return
        }
        
        // Update state for loading
        state.isLoading = true
        state.clearError()
        state.canNavigateBack = false
        
        do {
            // Make API request
            let _ = try await authService.resetPassword(
                token: token,
                newPassword: state.newPassword
            )
            
            // Show success and complete flow
            state.showSuccess("Contraseña establecida correctamente", duration: 2.0) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    state.currentStep = .completed
                    state.shouldNavigateToLogin = true
                }
            }
            
        } catch {
            // Handle errors
            let errorMessage = authService.handlePasswordRecoveryError(error)
            state.showErrorMessage(errorMessage)
            
            // Handle specific error cases
            if let apiError = error as? APIError {
                handlePasswordResetWithCodeError(apiError, state: state)
            }
        }
        
        // Reset loading state
        state.isLoading = false
        state.canNavigateBack = true
    }
    
    // MARK: - Password Validation
    
    func validateNewPassword(_ password: String, state: PasswordRecoveryState) {
        let result = validator.validatePassword(password)
        
        state.passwordValidationError = result.error
        state.passwordValidationState = result.state
        state.isPasswordValid = result.isValid
    }
    
    func validateConfirmPassword(newPassword: String, confirmPassword: String, state: PasswordRecoveryState) {
        let result = validator.validateConfirmPassword(
            newPassword: newPassword, 
            confirmPassword: confirmPassword
        )
        
        state.confirmPasswordError = result.error
        state.confirmPasswordValidationState = result.state
        state.passwordsMatch = result.isValid
    }
    
    // MARK: - Helper Methods
    
    private func clearPasswordFields(state: PasswordRecoveryState) {
        state.newPassword = ""
        state.confirmPassword = ""
        state.passwordValidationState = .none
        state.confirmPasswordValidationState = .none
        state.isPasswordValid = false
        state.passwordsMatch = false
    }
    
    // MARK: - Error Handling
    
    private func handlePasswordResetWithCodeError(_ error: APIError, state: PasswordRecoveryState) {
        switch error {
        case .networkError(_):
            // Offer retry for network errors
            state.enableRetry(for: .resetPassword)
            
        case .serverError(let code, let message):
            if code == 400 {
                if let msg = message, msg.lowercased().contains("expired") {
                    // Token/code expired - restart flow
                    showTokenExpiredError(state: state)
                } else if let msg = message, msg.lowercased().contains("password") {
                    // Password validation error - clear password fields
                    clearPasswordFields(state: state)
                }
            } else if code == 429 {
                // Rate limiting
                state.showErrorMessage(Constants.ErrorMessages.PasswordRecovery.rateLimitExceeded)
            } else if code >= 500 {
                // Server errors - offer retry
                state.enableRetry(for: .resetPassword)
            }
            
        default:
            break
        }
    }
    
    // MARK: - Specific Error Handlers
    
    private func showTokenExpiredError(state: PasswordRecoveryState) {
        state.showErrorMessage(Constants.ErrorMessages.PasswordRecovery.sessionExpired)
        state.resetAllState()
    }
    
    // MARK: - Retry Functionality
    
    func retryPasswordReset(for state: PasswordRecoveryState) async {
        state.disableRetry()
        state.clearError()
        await resetPasswordWithCode(for: state)
    }
}