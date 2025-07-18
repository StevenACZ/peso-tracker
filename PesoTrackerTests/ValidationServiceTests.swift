//
//  ValidationServiceTests.swift
//  PesoTrackerTests
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import XCTest
@testable import PesoTracker

final class ValidationServiceTests: XCTestCase {
    
    var validationService: ValidationService!
    
    override func setUpWithError() throws {
        validationService = ValidationService.shared
    }
    
    override func tearDownWithError() throws {
        validationService = nil
    }
    
    // MARK: - Username Validation Tests
    
    func testValidateUsername_ValidUsernames() {
        let validUsernames = [
            "john123",
            "user_name",
            "test123",
            "abc",
            "user123_test",
            "JohnDoe123"
        ]
        
        for username in validUsernames {
            let result = validationService.validateUsername(username)
            XCTAssertTrue(result.isValid, "Username '\(username)' should be valid")
            XCTAssertNil(result.errorMessage, "Valid username should not have error message")
        }
    }
    
    func testValidateUsername_EmptyUsername() {
        let result = validationService.validateUsername("")
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Username is required")
    }
    
    func testValidateUsername_TooShort() {
        let result = validationService.validateUsername("ab")
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Username must be at least 3 characters long")
    }
    
    func testValidateUsername_TooLong() {
        let longUsername = String(repeating: "a", count: 21)
        let result = validationService.validateUsername(longUsername)
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Username must be no more than 20 characters long")
    }
    
    func testValidateUsername_InvalidCharacters() {
        let invalidUsernames = [
            "user@name",
            "user-name",
            "user.name",
            "user name",
            "user#name",
            "user$name"
        ]
        
        for username in invalidUsernames {
            let result = validationService.validateUsername(username)
            XCTAssertFalse(result.isValid, "Username '\(username)' should be invalid")
            XCTAssertEqual(result.errorMessage, "Username can only contain letters, numbers, and underscores")
        }
    }
    
    func testValidateUsername_StartsWithUnderscore() {
        let result = validationService.validateUsername("_username")
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Username cannot start with an underscore")
    }
    
    func testValidateUsername_EndsWithUnderscore() {
        let result = validationService.validateUsername("username_")
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Username cannot end with an underscore")
    }
    
    // MARK: - Email Validation Tests
    
    func testValidateEmail_ValidEmails() {
        let validEmails = [
            "test@example.com",
            "user.name@domain.co.uk",
            "user+tag@example.org",
            "123@example.com",
            "test.email.with+symbol@example.com"
        ]
        
        for email in validEmails {
            let result = validationService.validateEmail(email)
            XCTAssertTrue(result.isValid, "Email '\(email)' should be valid")
            XCTAssertNil(result.errorMessage, "Valid email should not have error message")
        }
    }
    
    func testValidateEmail_EmptyEmail() {
        let result = validationService.validateEmail("")
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Email is required")
    }
    
    func testValidateEmail_InvalidFormat() {
        let invalidEmails = [
            "invalid-email",
            "@example.com",
            "test@",
            "test.example.com",
            "test@example",
            "test..test@example.com",
            "test@.example.com",
            "test@example..com"
        ]
        
        for email in invalidEmails {
            let result = validationService.validateEmail(email)
            XCTAssertFalse(result.isValid, "Email '\(email)' should be invalid")
            XCTAssertEqual(result.errorMessage, "Please enter a valid email address")
        }
    }
    
    func testValidateEmail_TooLong() {
        let longEmail = String(repeating: "a", count: 250) + "@example.com"
        let result = validationService.validateEmail(longEmail)
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Email address is too long")
    }
    
    // MARK: - Password Validation Tests
    
    func testValidatePassword_ValidPasswords() {
        let validPasswords = [
            "Password123",
            "MySecure1Pass",
            "Test123Pass",
            "Abcdef123",
            "ComplexP@ss1"
        ]
        
        for password in validPasswords {
            let result = validationService.validatePassword(password)
            XCTAssertTrue(result.isValid, "Password '\(password)' should be valid")
            XCTAssertNil(result.errorMessage, "Valid password should not have error message")
        }
    }
    
    func testValidatePassword_EmptyPassword() {
        let result = validationService.validatePassword("")
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Password is required")
    }
    
    func testValidatePassword_TooShort() {
        let result = validationService.validatePassword("Pass1")
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Password must be at least 8 characters long")
    }
    
    func testValidatePassword_TooLong() {
        let longPassword = String(repeating: "a", count: 129)
        let result = validationService.validatePassword(longPassword)
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Password must be no more than 128 characters long")
    }
    
    func testValidatePassword_NoLowercase() {
        let result = validationService.validatePassword("PASSWORD123")
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Password must contain at least one lowercase letter")
    }
    
    func testValidatePassword_NoUppercase() {
        let result = validationService.validatePassword("password123")
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Password must contain at least one uppercase letter")
    }
    
    func testValidatePassword_NoNumber() {
        let result = validationService.validatePassword("Password")
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Password must contain at least one number")
    }
    
    // MARK: - Convenience Methods Tests
    
    func testValidateLoginFields_ValidFields() {
        let results = validationService.validateLoginFields(
            email: "test@example.com",
            password: "Password123"
        )
        
        XCTAssertTrue(validationService.allFieldsValid(results))
        XCTAssertTrue(validationService.getErrorMessages(results).isEmpty)
    }
    
    func testValidateLoginFields_InvalidFields() {
        let results = validationService.validateLoginFields(
            email: "invalid-email",
            password: "weak"
        )
        
        XCTAssertFalse(validationService.allFieldsValid(results))
        
        let errorMessages = validationService.getErrorMessages(results)
        XCTAssertEqual(errorMessages["email"], "Please enter a valid email address")
        XCTAssertEqual(errorMessages["password"], "Password must be at least 8 characters long")
    }
    
    func testValidateRegistrationFields_ValidFields() {
        let results = validationService.validateRegistrationFields(
            username: "testuser",
            email: "test@example.com",
            password: "Password123"
        )
        
        XCTAssertTrue(validationService.allFieldsValid(results))
        XCTAssertTrue(validationService.getErrorMessages(results).isEmpty)
    }
    
    func testValidateRegistrationFields_InvalidFields() {
        let results = validationService.validateRegistrationFields(
            username: "_invalid",
            email: "invalid-email",
            password: "weak"
        )
        
        XCTAssertFalse(validationService.allFieldsValid(results))
        
        let errorMessages = validationService.getErrorMessages(results)
        XCTAssertEqual(errorMessages["username"], "Username cannot start with an underscore")
        XCTAssertEqual(errorMessages["email"], "Please enter a valid email address")
        XCTAssertEqual(errorMessages["password"], "Password must be at least 8 characters long")
    }
    
    func testAllFieldsValid_MixedResults() {
        let validResults: [String: ValidationResult] = [
            "field1": .valid,
            "field2": .valid
        ]
        XCTAssertTrue(validationService.allFieldsValid(validResults))
        
        let mixedResults: [String: ValidationResult] = [
            "field1": .valid,
            "field2": .invalid("Error message")
        ]
        XCTAssertFalse(validationService.allFieldsValid(mixedResults))
    }
    
    func testGetErrorMessages_OnlyInvalidFields() {
        let results: [String: ValidationResult] = [
            "valid_field": .valid,
            "invalid_field": .invalid("Error message")
        ]
        
        let errorMessages = validationService.getErrorMessages(results)
        XCTAssertEqual(errorMessages.count, 1)
        XCTAssertEqual(errorMessages["invalid_field"], "Error message")
        XCTAssertNil(errorMessages["valid_field"])
    }
}