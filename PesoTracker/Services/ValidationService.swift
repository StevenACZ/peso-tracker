//
//  ValidationService.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation

/// Service for validating user input according to authentication requirements
class ValidationService {
    
    // MARK: - Singleton
    static let shared = ValidationService()
    private init() {}
    
    // MARK: - Validation Rules
    
    /// Validate username according to requirements
    /// - Parameter username: Username to validate
    /// - Returns: ValidationResult indicating success or failure with message
    func validateUsername(_ username: String) -> ValidationResult {
        // Check if empty
        guard !username.isEmpty else {
            return .invalid("Username is required")
        }
        
        // Check minimum length
        guard username.count >= 3 else {
            return .invalid("Username must be at least 3 characters long")
        }
        
        // Check maximum length
        guard username.count <= 20 else {
            return .invalid("Username must be no more than 20 characters long")
        }
        
        // Check for valid characters (alphanumeric and underscores only)
        let allowedCharacterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        let usernameCharacterSet = CharacterSet(charactersIn: username)
        
        guard allowedCharacterSet.isSuperset(of: usernameCharacterSet) else {
            return .invalid("Username can only contain letters, numbers, and underscores")
        }
        
        // Check that it doesn't start with underscore
        guard !username.hasPrefix("_") else {
            return .invalid("Username cannot start with an underscore")
        }
        
        // Check that it doesn't end with underscore
        guard !username.hasSuffix("_") else {
            return .invalid("Username cannot end with an underscore")
        }
        
        return .valid
    }
    
    /// Validate email format according to requirements
    /// - Parameter email: Email to validate
    /// - Returns: ValidationResult indicating success or failure with message
    func validateEmail(_ email: String) -> ValidationResult {
        // Check if empty
        guard !email.isEmpty else {
            return .invalid("Email is required")
        }
        
        // Check basic email format using regex
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        guard emailPredicate.evaluate(with: email) else {
            return .invalid("Please enter a valid email address")
        }
        
        // Check maximum length
        guard email.count <= 254 else {
            return .invalid("Email address is too long")
        }
        
        return .valid
    }
    
    /// Validate password strength according to requirements
    /// - Parameter password: Password to validate
    /// - Returns: ValidationResult indicating success or failure with message
    func validatePassword(_ password: String) -> ValidationResult {
        // Check if empty
        guard !password.isEmpty else {
            return .invalid("Password is required")
        }
        
        // Check minimum length
        guard password.count >= 8 else {
            return .invalid("Password must be at least 8 characters long")
        }
        
        // Check maximum length
        guard password.count <= 128 else {
            return .invalid("Password must be no more than 128 characters long")
        }
        
        // Check for at least one lowercase letter
        let lowercaseRegex = ".*[a-z].*"
        let lowercasePredicate = NSPredicate(format: "SELF MATCHES %@", lowercaseRegex)
        guard lowercasePredicate.evaluate(with: password) else {
            return .invalid("Password must contain at least one lowercase letter")
        }
        
        // Check for at least one uppercase letter
        let uppercaseRegex = ".*[A-Z].*"
        let uppercasePredicate = NSPredicate(format: "SELF MATCHES %@", uppercaseRegex)
        guard uppercasePredicate.evaluate(with: password) else {
            return .invalid("Password must contain at least one uppercase letter")
        }
        
        // Check for at least one number
        let numberRegex = ".*[0-9].*"
        let numberPredicate = NSPredicate(format: "SELF MATCHES %@", numberRegex)
        guard numberPredicate.evaluate(with: password) else {
            return .invalid("Password must contain at least one number")
        }
        
        return .valid
    }
    
    // MARK: - Convenience Methods
    
    /// Validate all login fields
    /// - Parameters:
    ///   - email: Email to validate
    ///   - password: Password to validate
    /// - Returns: Dictionary of field names to validation results
    func validateLoginFields(email: String, password: String) -> [String: ValidationResult] {
        return [
            "email": validateEmail(email),
            "password": validatePassword(password)
        ]
    }
    
    /// Validate all registration fields
    /// - Parameters:
    ///   - username: Username to validate
    ///   - email: Email to validate
    ///   - password: Password to validate
    /// - Returns: Dictionary of field names to validation results
    func validateRegistrationFields(username: String, email: String, password: String) -> [String: ValidationResult] {
        return [
            "username": validateUsername(username),
            "email": validateEmail(email),
            "password": validatePassword(password)
        ]
    }
    
    /// Check if all validation results are valid
    /// - Parameter results: Dictionary of validation results
    /// - Returns: True if all results are valid, false otherwise
    func allFieldsValid(_ results: [String: ValidationResult]) -> Bool {
        return results.values.allSatisfy { $0.isValid }
    }
    
    /// Get error messages from validation results
    /// - Parameter results: Dictionary of validation results
    /// - Returns: Dictionary of field names to error messages (only for invalid fields)
    func getErrorMessages(_ results: [String: ValidationResult]) -> [String: String] {
        return results.compactMapValues { result in
            result.errorMessage
        }
    }
}