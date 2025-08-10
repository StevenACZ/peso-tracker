import Foundation

// MARK: - Code Verification Handler
@MainActor
class CodeVerificationHandler {
    
    private let authService = AuthService.shared
    private let validator = RecoveryValidator()
    
    // MARK: - Code Verification Process
    
    func verifyResetCode(for state: PasswordRecoveryState) async {
        // Validate code before proceeding
        guard state.isCodeValid else {
            state.showErrorMessage("Por favor ingresa un código válido de 6 dígitos")
            return
        }
        
        guard state.canProceedFromCurrentStep() else {
            state.showErrorMessage("No se puede proceder desde el estado actual")
            return
        }
        
        guard state.emailPersisted else {
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
            let response = try await authService.verifyResetCode(
                email: state.email, 
                code: state.verificationCode
            )
            
            if response.valid {
                // Store reset token and show success
                state.setResetToken(response.resetToken)
                
                state.showSuccess("¡Código verificado correctamente!", duration: 2.0) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        state.currentStep = .resetPassword
                        state.shouldNavigateToResetPassword = true
                    }
                }
            } else {
                // Invalid code
                state.showErrorMessage("Código incorrecto. Por favor verifica e intenta nuevamente.")
                clearCodeField(state: state)
            }
            
        } catch {
            // Handle errors
            let errorMessage = authService.handlePasswordRecoveryError(error)
            state.showErrorMessage(errorMessage)
            
            // Handle specific error cases
            if let apiError = error as? APIError {
                handleCodeVerificationError(apiError, state: state)
            }
        }
        
        // Reset loading state
        state.isLoading = false
        state.canNavigateBack = true
    }
    
    // MARK: - Code Validation
    
    func validateVerificationCode(_ code: String, state: PasswordRecoveryState) {
        let result = validator.validateVerificationCode(code)
        
        state.codeValidationError = result.error
        state.codeValidationState = result.state
        state.isCodeValid = result.isValid
    }
    
    // MARK: - Helper Methods
    
    private func clearCodeField(state: PasswordRecoveryState) {
        state.verificationCode = ""
        state.codeValidationState = .none
        state.isCodeValid = false
    }
    
    // MARK: - Error Handling
    
    private func handleCodeVerificationError(_ error: APIError, state: PasswordRecoveryState) {
        switch error {
        case .networkError(_):
            // Offer retry for network errors
            state.enableRetry(for: .verifyCode)
            
        case .serverError(let code, let message):
            if code == 400 {
                if let msg = message, msg.lowercased().contains("expired") {
                    // Code expired - offer to request new code
                    showCodeExpiredError(state: state)
                } else if let msg = message, msg.lowercased().contains("attempts") {
                    // Max attempts exceeded
                    showMaxAttemptsError(state: state)
                } else {
                    // Invalid code - clear field for retry
                    clearCodeField(state: state)
                }
            } else if code == 429 {
                // Rate limiting
                state.showErrorMessage(Constants.ErrorMessages.PasswordRecovery.rateLimitExceeded)
            } else if code >= 500 {
                // Server errors - offer retry
                state.enableRetry(for: .verifyCode)
            }
            
        default:
            // Clear code field for any other error
            clearCodeField(state: state)
        }
    }
    
    // MARK: - Specific Error Handlers
    
    private func showCodeExpiredError(state: PasswordRecoveryState) {
        state.showErrorMessage(Constants.ErrorMessages.PasswordRecovery.codeExpired)
        
        // Reset to request code step
        state.currentStep = .requestCode
        state.verificationCode = ""
        state.clearResetToken()
    }
    
    private func showMaxAttemptsError(state: PasswordRecoveryState) {
        let message = Constants.ErrorMessages.PasswordRecovery.maxAttemptsExceeded + ". Por favor solicita un nuevo código."
        state.showErrorMessage(message)
        
        // Reset to request code step
        state.currentStep = .requestCode
        state.verificationCode = ""
        state.clearResetToken()
    }
    
    // MARK: - Retry Functionality
    
    func retryCodeVerification(for state: PasswordRecoveryState) async {
        state.disableRetry()
        state.clearError()
        await verifyResetCode(for: state)
    }
}