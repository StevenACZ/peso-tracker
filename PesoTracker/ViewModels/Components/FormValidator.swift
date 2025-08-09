import Foundation
import SwiftUI

/// Handles form validation logic for authentication forms
class FormValidator: ObservableObject {
    
    // MARK: - Email Validation
    static func validateEmail(_ email: String) -> Bool {
        let emailRegex = Constants.Validation.emailRegex
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func getEmailValidationError(_ email: String) -> String? {
        if email.isEmpty { return nil }
        return validateEmail(email) ? nil : "Formato de email inválido"
    }
    
    // MARK: - Password Validation
    static func validatePassword(_ password: String) -> Bool {
        return password.count >= Constants.Validation.minPasswordLength &&
               password.count <= Constants.Validation.maxPasswordLength
    }
    
    static func getPasswordValidationError(_ password: String) -> String? {
        if password.isEmpty { return nil }
        return validatePassword(password) ? nil : "La contraseña debe tener entre \(Constants.Validation.minPasswordLength) y \(Constants.Validation.maxPasswordLength) caracteres"
    }
    
    // MARK: - Username Validation
    static func validateUsername(_ username: String) -> Bool {
        return username.count >= Constants.Validation.minUsernameLength &&
               username.count <= Constants.Validation.maxUsernameLength &&
               !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    static func getUsernameValidationError(_ username: String) -> String? {
        if username.isEmpty { return nil }
        return validateUsername(username) ? nil : "El nombre de usuario debe tener entre \(Constants.Validation.minUsernameLength) y \(Constants.Validation.maxUsernameLength) caracteres"
    }
    
    // MARK: - Confirm Password Validation
    static func getConfirmPasswordError(password: String, confirmPassword: String) -> String? {
        if confirmPassword.isEmpty { return nil }
        return password == confirmPassword ? nil : "Las contraseñas no coinciden"
    }
    
    // MARK: - Form Validation
    static func isLoginFormValid(email: String, password: String) -> Bool {
        return !email.isEmpty && !password.isEmpty && validateEmail(email)
    }
    
    static func isRegisterFormValid(username: String, email: String, password: String) -> Bool {
        return !username.isEmpty &&
               !email.isEmpty &&
               !password.isEmpty &&
               validateUsername(username) &&
               validateEmail(email) &&
               validatePassword(password)
    }
    
    // MARK: - Field Colors
    static func getFieldColor(hasError: Bool) -> Color {
        return hasError ? .red : .primary
    }
}