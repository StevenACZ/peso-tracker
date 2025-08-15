import Foundation
import SwiftUI
import Combine

@MainActor
class PasswordRecoveryViewModel: ObservableObject {
    
    // MARK: - Direct Published Properties (Fixed Binding Architecture)
    @Published var email = ""
    @Published var verificationCode = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    
    // MARK: - Validation States (Immediate Response)
    @Published var isEmailValid = false
    @Published var isCodeValid = false
    @Published var isPasswordValid = false
    @Published var passwordsMatch = false
    @Published var canSendCode = false
    @Published var canVerifyCode = false
    @Published var canResetPassword = false
    
    // MARK: - Flow State
    @Published var currentStep: RecoveryStep = .requestCode
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showCodeModal = false
    @Published var showSuccessMessage = false
    @Published var successMessage = ""
    @Published var shouldNavigateToLogin = false
    
    // MARK: - Internal State
    private var resetToken: String?
    private var emailPersisted = false
    
    // MARK: - Services and Handlers (Keep for API calls)
    private let emailHandler = EmailRecoveryHandler()
    private let codeHandler = CodeVerificationHandler()
    private let passwordHandler = PasswordResetHandler()
    private let validator = RecoveryValidator()
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    enum RecoveryStep {
        case requestCode
        case verifyCode
        case resetPassword
        case completed
    }
    
    // MARK: - Initialization
    init() {
        setupFormValidation()
    }
    
    // MARK: - Form Validation Setup (Fixed Architecture - Same as AuthViewModel)
    private func setupFormValidation() {
        // Email validation - IMMEDIATE response using .assign()
        $email
            .map { email in
                AuthService.shared.validateEmail(email)
            }
            .assign(to: &$isEmailValid)
        
        // Can send code validation - IMMEDIATE
        $isEmailValid
            .map { $0 }
            .assign(to: &$canSendCode)
        
        // Verification code validation - IMMEDIATE (6 digits)
        $verificationCode
            .map { code in
                code.count == 6 && code.allSatisfy { $0.isNumber }
            }
            .assign(to: &$isCodeValid)
        
        // Can verify code validation - IMMEDIATE
        $isCodeValid
            .map { $0 }
            .assign(to: &$canVerifyCode)
        
        // Password validation - IMMEDIATE
        $newPassword
            .map { password in
                AuthService.shared.validatePassword(password)
            }
            .assign(to: &$isPasswordValid)
        
        // Password matching validation - IMMEDIATE
        Publishers.CombineLatest($newPassword, $confirmPassword)
            .map { newPassword, confirmPassword in
                !newPassword.isEmpty && !confirmPassword.isEmpty && newPassword == confirmPassword
            }
            .assign(to: &$passwordsMatch)
        
        // Can reset password validation - IMMEDIATE
        Publishers.CombineLatest($isPasswordValid, $passwordsMatch)
            .map { isValid, match in
                isValid && match
            }
            .assign(to: &$canResetPassword)
    }
    
    // MARK: - Recovery Process Methods (Updated to use direct properties)
    
    func requestPasswordReset() async {
        guard canSendCode else { return }
        
        isLoading = true
        clearError()
        
        do {
            let _ = try await AuthService.shared.requestPasswordReset(email: email)
            
            // Success - store email and show code modal
            emailPersisted = true
            showCodeModal = true
            currentStep = .verifyCode
            
        } catch {
            showErrorMessage(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    func verifyResetCode() async {
        guard canVerifyCode else { return }
        
        isLoading = true
        clearError()
        
        do {
            let response = try await AuthService.shared.verifyResetCode(email: email, code: verificationCode)
            
            // Success - store token and navigate to reset
            resetToken = response.resetToken
            showSuccessMessage("Código correcto")
            
            // Auto-dismiss after 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showCodeModal = false
                self.showSuccessMessage = false
                self.currentStep = .resetPassword
            }
            
        } catch {
            showErrorMessage(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    func resetPasswordWithCode() async {
        guard canResetPassword, let token = resetToken else { return }
        
        isLoading = true
        clearError()
        
        do {
            let _ = try await AuthService.shared.resetPassword(
                token: token, 
                newPassword: newPassword
            )
            
            // Success - show message and navigate to login
            showSuccessMessage("Contraseña establecida correctamente")
            currentStep = .completed
            
            // Auto-navigate to login after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.resetFlow()
                self.shouldNavigateToLogin = true
            }
            
        } catch {
            showErrorMessage(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    // MARK: - Flow Management
    
    func resetFlow() {
        // Clear all form fields
        email = ""
        verificationCode = ""
        newPassword = ""
        confirmPassword = ""
        
        // Reset flow state
        currentStep = .requestCode
        isLoading = false
        clearError()
        showCodeModal = false
        showSuccessMessage = false
        successMessage = ""
        
        // Clear internal state
        resetToken = nil
        emailPersisted = false
    }
    
    func cancelFlow() {
        // Don't allow cancellation during loading
        if isLoading {
            return
        }
        
        resetFlow()
        shouldNavigateToLogin = true
    }
    
    // MARK: - Utility Methods
    
    func clearError() {
        errorMessage = nil
        showError = false
    }
    
    func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    func dismissError() {
        clearError()
    }
    
    func showSuccessMessage(_ message: String) {
        successMessage = message
        showSuccessMessage = true
    }
    
    // MARK: - Navigation Validation
    
    func canProceedToNextStep() -> Bool {
        switch currentStep {
        case .requestCode:
            return canSendCode
        case .verifyCode:
            return canVerifyCode
        case .resetPassword:
            return canResetPassword
        case .completed:
            return false
        }
    }
    
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
            return "Ingresa el código de 6 dígitos enviado a tu email"
        case .resetPassword:
            return "Establece tu nueva contraseña"
        case .completed:
            return "Contraseña actualizada exitosamente"
        }
    }
    
    // MARK: - Flow Validation
    
    func validateFlowIntegrity() -> Bool {
        switch currentStep {
        case .requestCode:
            return true
        case .verifyCode:
            return emailPersisted && !email.isEmpty
        case .resetPassword:
            return emailPersisted && resetToken != nil
        case .completed:
            return true
        }
    }
    
    func handleNavigationEdgeCase() {
        if !validateFlowIntegrity() {
            showErrorMessage("Sesión inválida. Reiniciando proceso...")
            resetFlow()
        }
    }
}