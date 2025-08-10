import Foundation

// MARK: - Email Recovery Handler
@MainActor
class EmailRecoveryHandler {
    
    private let authService = AuthService.shared
    private let validator = RecoveryValidator()
    
    // MARK: - Email Recovery Process
    
    func requestPasswordReset(for state: PasswordRecoveryState) async {
        // Validate email before proceeding
        guard state.isEmailValid else {
            state.showErrorMessage("Por favor ingresa un email válido")
            return
        }
        
        guard state.canProceedFromCurrentStep() else {
            state.showErrorMessage("No se puede proceder desde el estado actual")
            return
        }
        
        // Update state for loading
        state.isLoading = true
        state.clearError()
        state.canNavigateBack = false
        
        do {
            // Make API request
            let _ = try await authService.requestPasswordReset(email: state.email)
            
            // Persist email for the entire flow
            state.persistEmail()
            
            // Show success message and transition to next step
            state.showSuccess("Si el email existe, recibirás un código de restablecimiento.", duration: 2.0) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    state.currentStep = .verifyCode
                }
            }
            
        } catch {
            // Handle errors
            let errorMessage = authService.handlePasswordRecoveryError(error)
            state.showErrorMessage(errorMessage)
            
            // Handle specific error cases
            if let apiError = error as? APIError {
                handlePasswordResetError(apiError, state: state)
            }
        }
        
        // Reset loading state
        state.isLoading = false
        state.canNavigateBack = true
    }
    
    // MARK: - Email Validation
    
    func validateEmail(_ email: String, state: PasswordRecoveryState) {
        let result = validator.validateEmail(email)
        
        state.emailValidationError = result.error
        state.emailValidationState = result.state
        state.isEmailValid = result.isValid
    }
    
    // MARK: - Error Handling
    
    private func handlePasswordResetError(_ error: APIError, state: PasswordRecoveryState) {
        switch error {
        case .networkError(_):
            // Offer retry for network errors
            state.enableRetry(for: .requestCode)
            
        case .serverError(let code, _):
            if code == 404 {
                // Email not found - clear email field for correction
                state.email = ""
                state.emailValidationState = .none
                state.isEmailValid = false
            } else if code == 429 {
                // Rate limiting - show specific message
                state.showErrorMessage(Constants.ErrorMessages.PasswordRecovery.rateLimitExceeded)
            } else if code >= 500 {
                // Server errors - offer retry
                state.enableRetry(for: .requestCode)
            }
            
        default:
            break
        }
    }
    
    // MARK: - Retry Functionality
    
    func retryEmailRequest(for state: PasswordRecoveryState) async {
        state.disableRetry()
        state.clearError()
        await requestPasswordReset(for: state)
    }
}