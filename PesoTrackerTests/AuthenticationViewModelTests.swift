//
//  AuthenticationViewModelTests.swift
//  PesoTrackerTests
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import XCTest
@testable import PesoTracker

@MainActor
final class AuthenticationViewModelTests: XCTestCase {
    
    var viewModel: AuthenticationViewModel!
    
    override func setUpWithError() throws {
        viewModel = AuthenticationViewModel()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertEqual(viewModel.email, "")
        XCTAssertEqual(viewModel.password, "")
        XCTAssertEqual(viewModel.username, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showPassword)
        XCTAssertEqual(viewModel.currentFlow, .welcome)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.validationErrors.isEmpty)
        XCTAssertFalse(viewModel.showErrorAlert)
        XCTAssertFalse(viewModel.showSuccessMessage)
        XCTAssertEqual(viewModel.successMessage, "")
    }
    
    // MARK: - Form Validation Tests
    
    func testIsFormValid_LoginFlow() {
        viewModel.currentFlow = .login
        
        // Empty fields should be invalid
        XCTAssertFalse(viewModel.isFormValid)
        
        // Only email filled should be invalid
        viewModel.email = "test@example.com"
        XCTAssertFalse(viewModel.isFormValid)
        
        // Both fields filled should be valid
        viewModel.password = "Password123"
        XCTAssertTrue(viewModel.isFormValid)
        
        // With validation errors should be invalid
        viewModel.validationErrors["email"] = "Invalid email"
        XCTAssertFalse(viewModel.isFormValid)
    }
    
    func testIsFormValid_RegisterFlow() {
        viewModel.currentFlow = .register
        
        // Empty fields should be invalid
        XCTAssertFalse(viewModel.isFormValid)
        
        // Partially filled should be invalid
        viewModel.username = "testuser"
        viewModel.email = "test@example.com"
        XCTAssertFalse(viewModel.isFormValid)
        
        // All fields filled should be valid
        viewModel.password = "Password123"
        XCTAssertTrue(viewModel.isFormValid)
        
        // With validation errors should be invalid
        viewModel.validationErrors["username"] = "Invalid username"
        XCTAssertFalse(viewModel.isFormValid)
    }
    
    func testIsFormValid_WelcomeFlow() {
        viewModel.currentFlow = .welcome
        
        // Welcome flow should always be invalid for form submission
        viewModel.email = "test@example.com"
        viewModel.password = "Password123"
        viewModel.username = "testuser"
        XCTAssertFalse(viewModel.isFormValid)
    }
    
    func testCanSubmit() {
        viewModel.currentFlow = .login
        viewModel.email = "test@example.com"
        viewModel.password = "Password123"
        
        // Should be able to submit when form is valid and not loading
        XCTAssertTrue(viewModel.canSubmit)
        
        // Should not be able to submit when loading
        viewModel.isLoading = true
        XCTAssertFalse(viewModel.canSubmit)
        
        // Should not be able to submit when form is invalid
        viewModel.isLoading = false
        viewModel.email = ""
        XCTAssertFalse(viewModel.canSubmit)
    }
    
    // MARK: - Navigation Tests
    
    func testSwitchToLogin() {
        viewModel.currentFlow = .welcome
        viewModel.errorMessage = "Some error"
        viewModel.validationErrors["field"] = "Error"
        viewModel.email = "test@example.com"
        
        viewModel.switchToLogin()
        
        XCTAssertEqual(viewModel.currentFlow, .login)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.validationErrors.isEmpty)
        XCTAssertEqual(viewModel.email, "")
    }
    
    func testSwitchToRegister() {
        viewModel.currentFlow = .welcome
        viewModel.errorMessage = "Some error"
        viewModel.validationErrors["field"] = "Error"
        viewModel.password = "password"
        
        viewModel.switchToRegister()
        
        XCTAssertEqual(viewModel.currentFlow, .register)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.validationErrors.isEmpty)
        XCTAssertEqual(viewModel.password, "")
    }
    
    func testSwitchToWelcome() {
        viewModel.currentFlow = .login
        viewModel.errorMessage = "Some error"
        viewModel.validationErrors["field"] = "Error"
        viewModel.username = "testuser"
        
        viewModel.switchToWelcome()
        
        XCTAssertEqual(viewModel.currentFlow, .welcome)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.validationErrors.isEmpty)
        XCTAssertEqual(viewModel.username, "")
    }
    
    // MARK: - Field Validation Tests
    
    func testValidateField_Username() {
        viewModel.username = "invalid_username_"
        
        viewModel.validateField("username")
        
        XCTAssertNotNil(viewModel.validationErrors["username"])
        XCTAssertEqual(viewModel.validationErrors["username"], "Username cannot end with an underscore")
        
        // Test valid username
        viewModel.username = "validuser"
        viewModel.validateField("username")
        
        XCTAssertNil(viewModel.validationErrors["username"])
    }
    
    func testValidateField_Email() {
        viewModel.email = "invalid-email"
        
        viewModel.validateField("email")
        
        XCTAssertNotNil(viewModel.validationErrors["email"])
        XCTAssertEqual(viewModel.validationErrors["email"], "Please enter a valid email address")
        
        // Test valid email
        viewModel.email = "test@example.com"
        viewModel.validateField("email")
        
        XCTAssertNil(viewModel.validationErrors["email"])
    }
    
    func testValidateField_Password() {
        viewModel.password = "weak"
        
        viewModel.validateField("password")
        
        XCTAssertNotNil(viewModel.validationErrors["password"])
        XCTAssertEqual(viewModel.validationErrors["password"], "Password must be at least 8 characters long")
        
        // Test valid password
        viewModel.password = "StrongPass123"
        viewModel.validateField("password")
        
        XCTAssertNil(viewModel.validationErrors["password"])
    }
    
    func testValidateCurrentForm_LoginFlow() {
        viewModel.currentFlow = .login
        viewModel.email = "invalid-email"
        viewModel.password = "weak"
        
        viewModel.validateCurrentForm()
        
        XCTAssertNotNil(viewModel.validationErrors["email"])
        XCTAssertNotNil(viewModel.validationErrors["password"])
    }
    
    func testValidateCurrentForm_RegisterFlow() {
        viewModel.currentFlow = .register
        viewModel.username = "_invalid"
        viewModel.email = "invalid-email"
        viewModel.password = "weak"
        
        viewModel.validateCurrentForm()
        
        XCTAssertNotNil(viewModel.validationErrors["username"])
        XCTAssertNotNil(viewModel.validationErrors["email"])
        XCTAssertNotNil(viewModel.validationErrors["password"])
    }
    
    func testValidateCurrentForm_WelcomeFlow() {
        viewModel.currentFlow = .welcome
        viewModel.validationErrors["test"] = "error"
        
        viewModel.validateCurrentForm()
        
        XCTAssertTrue(viewModel.validationErrors.isEmpty)
    }
    
    // MARK: - UI Helper Tests
    
    func testClearErrors() {
        viewModel.errorMessage = "Some error"
        viewModel.validationErrors["field"] = "Error"
        viewModel.showErrorAlert = true
        
        viewModel.clearErrors()
        
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.validationErrors.isEmpty)
        XCTAssertFalse(viewModel.showErrorAlert)
    }
    
    func testClearForm() {
        viewModel.email = "test@example.com"
        viewModel.password = "password"
        viewModel.username = "username"
        viewModel.showPassword = true
        
        viewModel.clearForm()
        
        XCTAssertEqual(viewModel.email, "")
        XCTAssertEqual(viewModel.password, "")
        XCTAssertEqual(viewModel.username, "")
        XCTAssertFalse(viewModel.showPassword)
    }
    
    func testTogglePasswordVisibility() {
        XCTAssertFalse(viewModel.showPassword)
        
        viewModel.togglePasswordVisibility()
        XCTAssertTrue(viewModel.showPassword)
        
        viewModel.togglePasswordVisibility()
        XCTAssertFalse(viewModel.showPassword)
    }
    
    func testDismissErrorAlert() {
        viewModel.showErrorAlert = true
        viewModel.errorMessage = "Some error"
        
        viewModel.dismissErrorAlert()
        
        XCTAssertFalse(viewModel.showErrorAlert)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testDismissSuccessMessage() {
        viewModel.showSuccessMessage = true
        
        viewModel.dismissSuccessMessage()
        
        XCTAssertFalse(viewModel.showSuccessMessage)
    }
    
    // MARK: - Accessibility Tests
    
    func testFormAccessibilityLabel() {
        viewModel.currentFlow = .welcome
        XCTAssertEqual(viewModel.formAccessibilityLabel, "Welcome screen with authentication options")
        
        viewModel.currentFlow = .login
        XCTAssertEqual(viewModel.formAccessibilityLabel, "Login form with email and password fields")
        
        viewModel.currentFlow = .register
        XCTAssertEqual(viewModel.formAccessibilityLabel, "Registration form with username, email, and password fields")
    }
    
    func testSubmitButtonAccessibilityHint() {
        viewModel.currentFlow = .login
        viewModel.email = "test@example.com"
        viewModel.password = "Password123"
        
        XCTAssertEqual(viewModel.submitButtonAccessibilityHint, "Double tap to log in")
        
        viewModel.email = ""
        XCTAssertEqual(viewModel.submitButtonAccessibilityHint, "Complete all fields to enable login")
        
        viewModel.currentFlow = .register
        viewModel.username = "testuser"
        viewModel.email = "test@example.com"
        viewModel.password = "Password123"
        
        XCTAssertEqual(viewModel.submitButtonAccessibilityHint, "Double tap to create account")
        
        viewModel.username = ""
        XCTAssertEqual(viewModel.submitButtonAccessibilityHint, "Complete all fields to enable registration")
    }
    
    // MARK: - Keyboard Shortcut Tests
    
    func testHandleReturnKey_LoginFlow() {
        viewModel.currentFlow = .login
        viewModel.email = "test@example.com"
        viewModel.password = "Password123"
        
        // This test verifies the method doesn't crash
        // Actual login testing would require mocking the AuthenticationManager
        viewModel.handleReturnKey()
        
        // Should not crash and should maintain state
        XCTAssertEqual(viewModel.currentFlow, .login)
    }
    
    func testHandleReturnKey_RegisterFlow() {
        viewModel.currentFlow = .register
        viewModel.username = "testuser"
        viewModel.email = "test@example.com"
        viewModel.password = "Password123"
        
        // This test verifies the method doesn't crash
        viewModel.handleReturnKey()
        
        // Should not crash and should maintain state
        XCTAssertEqual(viewModel.currentFlow, .register)
    }
    
    func testHandleEscapeKey() {
        viewModel.currentFlow = .login
        
        viewModel.handleEscapeKey()
        
        XCTAssertEqual(viewModel.currentFlow, .welcome)
        
        // Should not change if already on welcome
        viewModel.handleEscapeKey()
        XCTAssertEqual(viewModel.currentFlow, .welcome)
    }
    
    // MARK: - Animation Property Tests
    
    func testAnimationProperties() {
        // Test that animation properties are accessible and don't crash
        let _ = viewModel.transitionAnimation
        let _ = viewModel.springAnimation
        
        // These properties should be accessible without issues
        XCTAssertTrue(true) // If we reach here, properties are accessible
    }
}