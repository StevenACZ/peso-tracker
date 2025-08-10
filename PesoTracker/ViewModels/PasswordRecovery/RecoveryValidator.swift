import Foundation

// MARK: - Recovery Validator
class RecoveryValidator {
    
    private let authService = AuthService.shared
    
    // MARK: - Email Validation
    
    func validateEmail(_ email: String) -> ValidationResult {
        if email.isEmpty {
            return ValidationResult(
                isValid: false,
                state: .none,
                error: nil
            )
        } else if !authService.validateEmail(email) {
            return ValidationResult(
                isValid: false,
                state: .invalid,
                error: getDetailedEmailError(email)
            )
        } else {
            return ValidationResult(
                isValid: true,
                state: .valid,
                error: nil
            )
        }
    }
    
    // MARK: - Code Validation
    
    func validateVerificationCode(_ code: String) -> ValidationResult {
        if code.isEmpty {
            return ValidationResult(
                isValid: false,
                state: .none,
                error: nil
            )
        } else if code.count != 6 || !code.allSatisfy({ $0.isNumber }) {
            return ValidationResult(
                isValid: false,
                state: .invalid,
                error: getDetailedCodeError(code)
            )
        } else {
            return ValidationResult(
                isValid: true,
                state: .valid,
                error: nil
            )
        }
    }
    
    // MARK: - Password Validation
    
    func validatePassword(_ password: String) -> ValidationResult {
        if password.isEmpty {
            return ValidationResult(
                isValid: false,
                state: .none,
                error: nil
            )
        } else if !authService.validatePassword(password) {
            return ValidationResult(
                isValid: false,
                state: .invalid,
                error: getDetailedPasswordError(password)
            )
        } else {
            return ValidationResult(
                isValid: true,
                state: .valid,
                error: nil
            )
        }
    }
    
    // MARK: - Confirm Password Validation
    
    func validateConfirmPassword(newPassword: String, confirmPassword: String) -> ValidationResult {
        if confirmPassword.isEmpty {
            return ValidationResult(
                isValid: false,
                state: .none,
                error: nil
            )
        } else if newPassword != confirmPassword {
            return ValidationResult(
                isValid: false,
                state: .invalid,
                error: "Las contraseñas no coinciden"
            )
        } else {
            return ValidationResult(
                isValid: true,
                state: .valid,
                error: nil
            )
        }
    }
    
    // MARK: - Navigation Validation
    
    func validateNavigationTransition(from currentStep: PasswordRecoveryState.RecoveryStep, 
                                     to newStep: PasswordRecoveryState.RecoveryStep,
                                     emailPersisted: Bool,
                                     resetToken: String?) -> NavigationValidationResult {
        
        // Check if navigation is allowed
        guard canNavigateToStep(newStep, emailPersisted: emailPersisted, resetToken: resetToken) else {
            return NavigationValidationResult(
                isValid: false,
                errorMessage: "Transición de navegación inválida"
            )
        }
        
        // Ensure email persistence throughout flow
        if newStep != .requestCode && !emailPersisted {
            return NavigationValidationResult(
                isValid: false,
                errorMessage: "Error de sesión. Por favor reinicia el proceso."
            )
        }
        
        // Ensure reset token exists for password reset
        if newStep == .resetPassword && resetToken == nil {
            return NavigationValidationResult(
                isValid: false,
                errorMessage: "Código no verificado. Por favor verifica el código primero."
            )
        }
        
        return NavigationValidationResult(isValid: true, errorMessage: nil)
    }
    
    // MARK: - Private Helper Methods
    
    private func canNavigateToStep(_ step: PasswordRecoveryState.RecoveryStep, 
                                  emailPersisted: Bool, 
                                  resetToken: String?) -> Bool {
        switch step {
        case .requestCode:
            return true
        case .verifyCode:
            return emailPersisted
        case .resetPassword:
            return resetToken != nil
        case .completed:
            return resetToken != nil
        }
    }
    
    private func getDetailedEmailError(_ email: String) -> String {
        if email.isEmpty {
            return Constants.ErrorMessages.PasswordRecovery.emailRequired
        } else if !email.contains("@") {
            return "El email debe contener @"
        } else if !email.contains(".") {
            return "El email debe contener un dominio válido"
        } else {
            return Constants.ErrorMessages.PasswordRecovery.emailInvalid
        }
    }
    
    private func getDetailedPasswordError(_ password: String) -> String {
        if password.isEmpty {
            return Constants.ErrorMessages.PasswordRecovery.passwordRequired
        } else if password.count < Constants.Validation.minPasswordLength {
            return Constants.ErrorMessages.PasswordRecovery.passwordTooShort
        } else if password.count > Constants.Validation.maxPasswordLength {
            return Constants.ErrorMessages.PasswordRecovery.passwordTooLong
        } else {
            return "La contraseña no cumple con los requisitos"
        }
    }
    
    private func getDetailedCodeError(_ code: String) -> String {
        if code.isEmpty {
            return Constants.ErrorMessages.PasswordRecovery.codeRequired
        } else if code.count < Constants.Validation.verificationCodeLength {
            return "El código debe tener \(Constants.Validation.verificationCodeLength) dígitos"
        } else if code.count > Constants.Validation.verificationCodeLength {
            return "El código no puede tener más de \(Constants.Validation.verificationCodeLength) dígitos"
        } else if !code.allSatisfy({ $0.isNumber }) {
            return "El código solo puede contener números"
        } else {
            return Constants.ErrorMessages.PasswordRecovery.codeInvalid
        }
    }
}

// MARK: - Validation Result Models

struct ValidationResult {
    let isValid: Bool
    let state: AuthTextField.ValidationState
    let error: String?
}

struct NavigationValidationResult {
    let isValid: Bool
    let errorMessage: String?
}