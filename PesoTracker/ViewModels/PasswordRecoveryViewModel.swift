import Foundation
import SwiftUI
import Combine

@MainActor
class PasswordRecoveryViewModel: ObservableObject {
    
    // MARK: - State Management
    @Published var state = PasswordRecoveryState()
    
    // MARK: - Handlers
    private let emailHandler = EmailRecoveryHandler()
    private let codeHandler = CodeVerificationHandler()
    private let passwordHandler = PasswordResetHandler()
    private let validator = RecoveryValidator()
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupFormValidation()
    }
    
    // MARK: - Form Validation Setup
    private func setupFormValidation() {
        // Email validation
        state.$email
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] email in
                guard let self = self else { return }
                self.emailHandler.validateEmail(email, state: self.state)
            }
            .store(in: &cancellables)
        
        // Verification code validation
        state.$verificationCode
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] code in
                guard let self = self else { return }
                self.codeHandler.validateVerificationCode(code, state: self.state)
            }
            .store(in: &cancellables)
        
        // New password validation
        state.$newPassword
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] password in
                guard let self = self else { return }
                self.passwordHandler.validateNewPassword(password, state: self.state)
            }
            .store(in: &cancellables)
        
        // Confirm password validation
        Publishers.CombineLatest(state.$newPassword, state.$confirmPassword)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] newPassword, confirmPassword in
                guard let self = self else { return }
                self.passwordHandler.validateConfirmPassword(
                    newPassword: newPassword, 
                    confirmPassword: confirmPassword, 
                    state: self.state
                )
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Recovery Process Methods
    
    func requestPasswordReset() async {
        await emailHandler.requestPasswordReset(for: state)
    }
    
    func verifyResetCode() async {
        await codeHandler.verifyResetCode(for: state)
    }
    
    func resetPasswordWithCode() async {
        await passwordHandler.resetPasswordWithCode(for: state)
    }
    
    // MARK: - Flow Management
    
    func resetFlow() {
        state.resetAllState()
    }
    
    func cancelFlow() {
        // Ensure we can cancel from current state
        if !state.canNavigateBack && state.isLoading {
            // If we're in the middle of an operation, don't allow cancellation
            return
        }
        
        resetFlow()
        state.shouldNavigateToLogin = true
    }
    
    // MARK: - Public Interface - Delegates to State
    
    func dismissError() {
        state.dismissError()
    }
    
    func canProceedToNextStep() -> Bool {
        return state.canProceedToNextStep()
    }
    
    func getCurrentStepTitle() -> String {
        return state.getCurrentStepTitle()
    }
    
    func getCurrentStepDescription() -> String {
        return state.getCurrentStepDescription()
    }
    
    // MARK: - Navigation Validation Methods
    
    func canProceedFromCurrentStep() -> Bool {
        return state.canProceedFromCurrentStep()
    }
    
    func canNavigateToStep(_ step: PasswordRecoveryState.RecoveryStep) -> Bool {
        return state.canNavigateToStep(step)
    }
    
    func validateNavigationTransition(to newStep: PasswordRecoveryState.RecoveryStep) -> Bool {
        let result = validator.validateNavigationTransition(
            from: state.currentStep, 
            to: newStep, 
            emailPersisted: state.emailPersisted, 
            resetToken: state.resetToken
        )
        
        if !result.isValid, let errorMessage = result.errorMessage {
            if errorMessage.contains("reinicia el proceso") {
                state.resetAllState()
            }
            state.showErrorMessage(errorMessage)
        }
        
        return result.isValid
    }
    
    func handleNavigationEdgeCase() {
        // Check for invalid state transitions
        if state.currentStep == .verifyCode && !state.emailPersisted {
            state.showErrorMessage("Sesión inválida. Reiniciando proceso...")
            state.resetAllState()
            return
        }
        
        if state.currentStep == .resetPassword && state.resetToken == nil {
            state.showErrorMessage("Sesión expirada. Reiniciando proceso...")
            state.resetAllState()
            return
        }
        
        // Auto-cleanup after completion
        if state.currentStep == .completed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.resetFlow()
            }
        }
        
        // Check for expired sessions
        if state.currentStep != .requestCode && !state.validateFlowIntegrity() {
            state.showErrorMessage("La sesión ha expirado. Por favor inicia el proceso nuevamente.")
            state.resetAllState()
        }
    }
    
    // MARK: - Navigation State Management
    
    func clearNavigationFlags() {
        state.clearNavigationFlags()
    }
    
    func validateFlowIntegrity() -> Bool {
        return state.validateFlowIntegrity()
    }
    
    // MARK: - Retry Functionality
    
    func retryCurrentOperation() async {
        guard let step = state.retryStep else { return }
        
        state.disableRetry()
        state.clearError()
        
        switch step {
        case .requestCode:
            await emailHandler.retryEmailRequest(for: state)
        case .verifyCode:
            await codeHandler.retryCodeVerification(for: state)
        case .resetPassword:
            await passwordHandler.retryPasswordReset(for: state)
        case .completed:
            break
        }
    }
    
    // MARK: - Edge Case Handling
    
    func handleEdgeCases() {
        handleNavigationEdgeCase()
    }
}