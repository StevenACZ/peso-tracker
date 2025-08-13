import Foundation
import SwiftUI

/// Universal Validation Service - Consolidates FormValidator, WeightFormValidator, and RecoveryValidator
/// Provides centralized validation logic compatible with existing code
class UniversalValidationService {
    
    // MARK: - Singleton
    static let shared = UniversalValidationService()
    private init() {}
    
    // MARK: - Email Validation
    
    /// Validate email format using regex (compatible with FormValidator)
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = Constants.Validation.emailRegex
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// Get email validation error message (compatible with FormValidator)
    func getEmailValidationError(_ email: String) -> String? {
        if email.isEmpty { return nil }
        return validateEmail(email) ? nil : getDetailedEmailError(email)
    }
    
    private func getDetailedEmailError(_ email: String) -> String {
        if !email.contains("@") {
            return "El email debe contener @"
        } else if !email.contains(".") {
            return "El email debe contener un dominio válido"
        } else {
            return "Formato de email inválido"
        }
    }
    
    // MARK: - Password Validation
    
    /// Validate password length (compatible with FormValidator)
    func validatePassword(_ password: String) -> Bool {
        return password.count >= Constants.Validation.minPasswordLength &&
               password.count <= Constants.Validation.maxPasswordLength
    }
    
    /// Get password validation error message (compatible with FormValidator)
    func getPasswordValidationError(_ password: String) -> String? {
        if password.isEmpty { return nil }
        return validatePassword(password) ? nil : "La contraseña debe tener entre \(Constants.Validation.minPasswordLength) y \(Constants.Validation.maxPasswordLength) caracteres"
    }
    
    // MARK: - Username Validation
    
    /// Validate username length and format (compatible with FormValidator)
    func validateUsername(_ username: String) -> Bool {
        return username.count >= Constants.Validation.minUsernameLength &&
               username.count <= Constants.Validation.maxUsernameLength &&
               !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Get username validation error message (compatible with FormValidator)
    func getUsernameValidationError(_ username: String) -> String? {
        if username.isEmpty { return nil }
        return validateUsername(username) ? nil : "El nombre de usuario debe tener entre \(Constants.Validation.minUsernameLength) y \(Constants.Validation.maxUsernameLength) caracteres"
    }
    
    // MARK: - Password Confirmation Validation
    
    /// Validate password confirmation matches (compatible with FormValidator)
    func getConfirmPasswordError(password: String, confirmPassword: String) -> String? {
        if confirmPassword.isEmpty { return nil }
        return password == confirmPassword ? nil : "Las contraseñas no coinciden"
    }
    
    // MARK: - Weight Validation
    
    /// Validate weight value and range (compatible with WeightFormValidator)
    func validateWeight(_ weightText: String) -> Bool {
        guard !weightText.isEmpty else { return false }
        guard let weightValue = Double(weightText.replacingOccurrences(of: ",", with: ".")) else { return false }
        return weightValue >= Constants.Validation.minWeight && weightValue <= Constants.Validation.maxWeight
    }
    
    /// Get weight validation error message (compatible with WeightFormValidator)
    func getWeightValidationError(_ weightText: String) -> String? {
        guard !weightText.isEmpty else { return "El peso es requerido" }
        guard let weightValue = Double(weightText.replacingOccurrences(of: ",", with: ".")) else {
            return "Ingresa un peso válido"
        }
        guard weightValue >= Constants.Validation.minWeight && weightValue <= Constants.Validation.maxWeight else {
            return "El peso debe estar entre \(String(format: "%.1f", Constants.Validation.minWeight)) y \(String(format: "%.0f", Constants.Validation.maxWeight)) kg"
        }
        return nil
    }
    
    // MARK: - Date Validation
    
    /// Validate date is not in future and not too old (compatible with WeightFormValidator)
    func validateDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        // Don't allow future dates
        if date > now { return false }
        
        // Don't allow dates more than 2 years ago
        if let twoYearsAgo = calendar.date(byAdding: .year, value: -2, to: now), date < twoYearsAgo {
            return false
        }
        
        return true
    }
    
    /// Get date validation error message (compatible with WeightFormValidator)
    func getDateValidationError(_ date: Date) -> String? {
        let calendar = Calendar.current
        let now = Date()
        
        if date > now {
            return "No puedes registrar un peso en el futuro"
        }
        
        if let twoYearsAgo = calendar.date(byAdding: .year, value: -2, to: now), date < twoYearsAgo {
            return "La fecha no puede ser anterior a 2 años"
        }
        
        return nil
    }
    
    // MARK: - Verification Code Validation
    
    /// Validate verification code format and length (compatible with RecoveryValidator)
    func validateVerificationCode(_ code: String) -> Bool {
        return code.count == Constants.Validation.verificationCodeLength &&
               code.allSatisfy({ $0.isNumber })
    }
    
    /// Get verification code validation error message
    func getVerificationCodeError(_ code: String) -> String? {
        if code.isEmpty { return nil }
        if code.count != Constants.Validation.verificationCodeLength {
            return "El código debe tener exactamente \(Constants.Validation.verificationCodeLength) dígitos"
        }
        if !code.allSatisfy({ $0.isNumber }) {
            return "El código solo puede contener números"
        }
        return nil
    }
    
    // MARK: - Form Validation (Complete Forms)
    
    /// Validate complete login form (compatible with FormValidator)
    func isLoginFormValid(email: String, password: String) -> Bool {
        return !email.isEmpty && !password.isEmpty && validateEmail(email)
    }
    
    /// Validate complete registration form (compatible with FormValidator)
    func isRegisterFormValid(username: String, email: String, password: String) -> Bool {
        return !username.isEmpty &&
               !email.isEmpty &&
               !password.isEmpty &&
               validateUsername(username) &&
               validateEmail(email) &&
               validatePassword(password)
    }
    
    /// Validate complete weight form (compatible with WeightFormValidator)
    func validateWeightForm(weight: String, date: Date) -> Bool {
        return validateWeight(weight) && validateDate(date)
    }
    
    // MARK: - RecoveryValidator Compatibility
    
    /// Create ValidationResult compatible with RecoveryValidator
    func validateEmailForRecovery(_ email: String) -> ValidationResult {
        if email.isEmpty {
            return ValidationResult(isValid: false, state: .none, error: nil)
        }
        
        if !validateEmail(email) {
            return ValidationResult(isValid: false, state: .invalid, error: getDetailedEmailError(email))
        }
        
        return ValidationResult(isValid: true, state: .valid, error: nil)
    }
    
    /// Create ValidationResult for password recovery
    func validatePasswordForRecovery(_ password: String) -> ValidationResult {
        if password.isEmpty {
            return ValidationResult(isValid: false, state: .none, error: nil)
        }
        
        if !validatePassword(password) {
            return ValidationResult(isValid: false, state: .invalid, error: getPasswordValidationError(password))
        }
        
        return ValidationResult(isValid: true, state: .valid, error: nil)
    }
    
    /// Create ValidationResult for verification code
    func validateVerificationCodeForRecovery(_ code: String) -> ValidationResult {
        if code.isEmpty {
            return ValidationResult(isValid: false, state: .none, error: nil)
        }
        
        if !validateVerificationCode(code) {
            return ValidationResult(isValid: false, state: .invalid, error: getVerificationCodeError(code))
        }
        
        return ValidationResult(isValid: true, state: .valid, error: nil)
    }
    
    /// Create ValidationResult for password confirmation
    func validateConfirmPasswordForRecovery(newPassword: String, confirmPassword: String) -> ValidationResult {
        if confirmPassword.isEmpty {
            return ValidationResult(isValid: false, state: .none, error: nil)
        }
        
        if newPassword != confirmPassword {
            return ValidationResult(isValid: false, state: .invalid, error: "Las contraseñas no coinciden")
        }
        
        return ValidationResult(isValid: true, state: .valid, error: nil)
    }
}

// MARK: - UI Utilities
extension UniversalValidationService {
    
    /// Get color for field based on error state (compatible with FormValidator)
    static func getFieldColor(hasError: Bool) -> Color {
        return hasError ? .red : .primary
    }
}