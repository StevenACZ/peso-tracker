//
//  AuthenticationManagerTests.swift
//  PesoTrackerTests
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import XCTest
@testable import PesoTracker

@MainActor
final class AuthenticationManagerTests: XCTestCase {
    
    var authManager: AuthenticationManager!
    
    override func setUp() async throws {
        try await super.setUp()
        authManager = AuthenticationManager.shared
        
        // Clean up any existing state
        authManager.logout()
    }
    
    override func tearDown() async throws {
        // Clean up after each test
        authManager.logout()
        authManager = nil
        try await super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        // Then
        XCTAssertFalse(authManager.isAuthenticated)
        XCTAssertFalse(authManager.isAuthenticating)
        XCTAssertNil(authManager.currentUser)
        XCTAssertNil(authManager.errorMessage)
        XCTAssertFalse(authManager.isLoading)
        
        switch authManager.authenticationState {
        case .unauthenticated:
            XCTAssertTrue(true) // Expected state
        default:
            XCTFail("Expected unauthenticated state")
        }
    }
    
    // MARK: - Authentication State Tests
    
    func testAuthenticationStateComputed() {
        // Given - Unauthenticated state
        XCTAssertFalse(authManager.isAuthenticated)
        XCTAssertFalse(authManager.isAuthenticating)
        
        // When - Set to authenticating
        authManager.authenticationState = .authenticating
        
        // Then
        XCTAssertFalse(authManager.isAuthenticated)
        XCTAssertTrue(authManager.isAuthenticating)
        
        // When - Set to authenticated
        let testUser = User(id: 1, username: "testuser", email: "test@example.com")
        authManager.authenticationState = .authenticated(testUser)
        
        // Then
        XCTAssertTrue(authManager.isAuthenticated)
        XCTAssertFalse(authManager.isAuthenticating)
    }
    
    // MARK: - Logout Tests
    
    func testLogout_ClearsState() {
        // Given - Set some state
        let testUser = User(id: 1, username: "testuser", email: "test@example.com")
        authManager.currentUser = testUser
        authManager.authenticationState = .authenticated(testUser)
        authManager.errorMessage = "Some error"
        authManager.isLoading = true
        
        // When
        authManager.logout()
        
        // Then
        XCTAssertNil(authManager.currentUser)
        XCTAssertNil(authManager.errorMessage)
        XCTAssertFalse(authManager.isLoading)
        XCTAssertFalse(authManager.isAuthenticated)
        
        switch authManager.authenticationState {
        case .unauthenticated:
            XCTAssertTrue(true) // Expected
        default:
            XCTFail("Expected unauthenticated state after logout")
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testSetError() {
        // Given
        let error = AuthenticationError.invalidCredentials
        
        // When
        authManager.setError(error)
        
        // Then
        XCTAssertEqual(authManager.errorMessage, error.errorDescription)
    }
    
    func testClearError() {
        // Given
        authManager.errorMessage = "Some error"
        
        // When
        authManager.clearError()
        
        // Then
        XCTAssertNil(authManager.errorMessage)
    }
    
    // MARK: - Token Utility Tests
    
    func testHasValidToken() {
        // Initially should be false
        XCTAssertFalse(authManager.hasValidToken)
        
        // After saving a token, should be true
        do {
            try KeychainService.shared.saveToken("test.token")
            XCTAssertTrue(authManager.hasValidToken)
        } catch {
            XCTFail("Failed to save test token: \(error)")
        }
        
        // After logout, should be false again
        authManager.logout()
        XCTAssertFalse(authManager.hasValidToken)
    }
    
    func testGetCurrentToken() {
        // Initially should be nil
        XCTAssertNil(authManager.getCurrentToken())
        
        // After saving a token
        let testToken = "test.jwt.token"
        do {
            try KeychainService.shared.saveToken(testToken)
            XCTAssertEqual(authManager.getCurrentToken(), testToken)
        } catch {
            XCTFail("Failed to save test token: \(error)")
        }
        
        // After logout, should be nil again
        authManager.logout()
        XCTAssertNil(authManager.getCurrentToken())
    }
    
    // MARK: - Check Authentication Status Tests
    
    func testCheckAuthenticationStatus_NoToken() async {
        // Given - No token in keychain
        authManager.logout()
        
        // When
        await authManager.checkAuthenticationStatus()
        
        // Then
        XCTAssertFalse(authManager.isAuthenticated)
        switch authManager.authenticationState {
        case .unauthenticated:
            XCTAssertTrue(true) // Expected
        default:
            XCTFail("Expected unauthenticated state when no token")
        }
    }
    
    func testCheckAuthenticationStatus_WithToken() async {
        // Given - Token exists in keychain
        do {
            try KeychainService.shared.saveToken("test.token")
        } catch {
            XCTFail("Failed to save test token: \(error)")
            return
        }
        
        // When
        await authManager.checkAuthenticationStatus()
        
        // Then - Currently returns unauthenticated because we don't have /me endpoint
        // This test will need to be updated when you add user validation
        XCTAssertFalse(authManager.isAuthenticated)
    }
    
    // MARK: - Integration Tests (Mock-based)
    
    func testLoginRequest_Structure() {
        // Test that we can create login requests properly
        let request = LoginRequest(email: "test@example.com", password: "Password123!")
        
        XCTAssertEqual(request.email, "test@example.com")
        XCTAssertEqual(request.password, "Password123!")
    }
    
    func testRegisterRequest_Structure() {
        // Test that we can create register requests properly
        let request = RegisterRequest(
            username: "testuser",
            email: "test@example.com",
            password: "Password123!"
        )
        
        XCTAssertEqual(request.username, "testuser")
        XCTAssertEqual(request.email, "test@example.com")
        XCTAssertEqual(request.password, "Password123!")
    }
}