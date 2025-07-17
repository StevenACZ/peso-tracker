//
//  KeychainServiceTests.swift
//  PesoTrackerTests
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import XCTest
@testable import PesoTracker

final class KeychainServiceTests: XCTestCase {
    
    var keychainService: KeychainService!
    let testToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.token"
    
    override func setUp() {
        super.setUp()
        keychainService = KeychainService.shared
        
        // Clean up any existing test data
        try? keychainService.deleteToken()
    }
    
    override func tearDown() {
        // Clean up after each test
        try? keychainService.deleteToken()
        keychainService = nil
        super.tearDown()
    }
    
    // MARK: - Save Token Tests
    
    func testSaveToken_Success() throws {
        // When
        try keychainService.saveToken(testToken)
        
        // Then
        let retrievedToken = try keychainService.getToken()
        XCTAssertEqual(retrievedToken, testToken)
    }
    
    func testSaveToken_OverwritesExistingToken() throws {
        // Given
        let firstToken = "first.token"
        let secondToken = "second.token"
        
        // When
        try keychainService.saveToken(firstToken)
        try keychainService.saveToken(secondToken)
        
        // Then
        let retrievedToken = try keychainService.getToken()
        XCTAssertEqual(retrievedToken, secondToken)
        XCTAssertNotEqual(retrievedToken, firstToken)
    }
    
    // MARK: - Get Token Tests
    
    func testGetToken_ReturnsNilWhenNoToken() throws {
        // When
        let token = try keychainService.getToken()
        
        // Then
        XCTAssertNil(token)
    }
    
    func testGetToken_ReturnsCorrectToken() throws {
        // Given
        try keychainService.saveToken(testToken)
        
        // When
        let retrievedToken = try keychainService.getToken()
        
        // Then
        XCTAssertEqual(retrievedToken, testToken)
    }
    
    // MARK: - Delete Token Tests
    
    func testDeleteToken_RemovesToken() throws {
        // Given
        try keychainService.saveToken(testToken)
        XCTAssertNotNil(try keychainService.getToken())
        
        // When
        try keychainService.deleteToken()
        
        // Then
        let retrievedToken = try keychainService.getToken()
        XCTAssertNil(retrievedToken)
    }
    
    func testDeleteToken_DoesNotThrowWhenNoToken() {
        // When/Then - Should not throw
        XCTAssertNoThrow(try keychainService.deleteToken())
    }
    
    // MARK: - Has Token Tests
    
    func testHasToken_ReturnsFalseWhenNoToken() {
        // When
        let hasToken = keychainService.hasToken()
        
        // Then
        XCTAssertFalse(hasToken)
    }
    
    func testHasToken_ReturnsTrueWhenTokenExists() throws {
        // Given
        try keychainService.saveToken(testToken)
        
        // When
        let hasToken = keychainService.hasToken()
        
        // Then
        XCTAssertTrue(hasToken)
    }
    
    func testHasToken_ReturnsFalseAfterDeletion() throws {
        // Given
        try keychainService.saveToken(testToken)
        XCTAssertTrue(keychainService.hasToken())
        
        // When
        try keychainService.deleteToken()
        
        // Then
        XCTAssertFalse(keychainService.hasToken())
    }
    
    // MARK: - Clear All Tests
    
    func testClearAll_RemovesAllData() throws {
        // Given
        try keychainService.saveToken(testToken)
        XCTAssertTrue(keychainService.hasToken())
        
        // When
        try keychainService.clearAll()
        
        // Then
        XCTAssertFalse(keychainService.hasToken())
        XCTAssertNil(try keychainService.getToken())
    }
    
    // MARK: - Edge Cases
    
    func testSaveEmptyToken() throws {
        // Given
        let emptyToken = ""
        
        // When
        try keychainService.saveToken(emptyToken)
        
        // Then
        let retrievedToken = try keychainService.getToken()
        XCTAssertEqual(retrievedToken, emptyToken)
    }
    
    func testSaveLongToken() throws {
        // Given
        let longToken = String(repeating: "a", count: 1000)
        
        // When
        try keychainService.saveToken(longToken)
        
        // Then
        let retrievedToken = try keychainService.getToken()
        XCTAssertEqual(retrievedToken, longToken)
    }
    
    func testSaveTokenWithSpecialCharacters() throws {
        // Given
        let specialToken = "token.with-special_chars@123!#$%^&*()"
        
        // When
        try keychainService.saveToken(specialToken)
        
        // Then
        let retrievedToken = try keychainService.getToken()
        XCTAssertEqual(retrievedToken, specialToken)
    }
}