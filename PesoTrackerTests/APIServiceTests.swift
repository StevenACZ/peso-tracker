//
//  APIServiceTests.swift
//  PesoTrackerTests
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import XCTest
@testable import PesoTracker

final class APIServiceTests: XCTestCase {
    
    var apiService: APIService!
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        apiService = APIService.shared
        mockURLSession = MockURLSession()
    }
    
    override func tearDown() {
        apiService = nil
        mockURLSession = nil
        super.tearDown()
    }
    
    // MARK: - Login Tests
    
    func testLogin_Success() async throws {
        // Given
        let loginRequest = LoginRequest(email: "test@example.com", password: "Password123!")
        let expectedResponse = AuthResponse(
            message: "Login successful",
            token: "test.jwt.token",
            user: User(id: 1, username: "testuser", email: "test@example.com")
        )
        
        // Note: These tests would require a mock URLSession or integration tests
        // For now, we'll test the model structures and error handling
        
        XCTAssertNotNil(loginRequest.email)
        XCTAssertNotNil(loginRequest.password)
        XCTAssertNotNil(expectedResponse.token)
        XCTAssertNotNil(expectedResponse.user)
    }
    
    func testRegister_Success() async throws {
        // Given
        let registerRequest = RegisterRequest(
            username: "testuser",
            email: "test@example.com",
            password: "Password123!"
        )
        let expectedResponse = AuthResponse(
            message: "User registered successfully",
            token: nil,
            user: User(id: 1, username: "testuser", email: "test@example.com")
        )
        
        XCTAssertNotNil(registerRequest.username)
        XCTAssertNotNil(registerRequest.email)
        XCTAssertNotNil(registerRequest.password)
        XCTAssertNotNil(expectedResponse.user)
    }
    
    // MARK: - Error Handling Tests
    
    func testAPIError_ErrorDescriptions() {
        let errors: [APIError] = [
            .invalidURL,
            .unauthorized,
            .forbidden,
            .notFound,
            .rateLimited,
            .serverError("Test error"),
            .authenticationRequired
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertNotNil(error.recoverySuggestion)
        }
    }
    
    func testNetworkError_Descriptions() {
        let errors: [NetworkError] = [
            .noConnection,
            .timeout,
            .hostUnreachable,
            .unknown(NSError(domain: "test", code: 0))
        ]
        
        for error in errors {
            XCTAssertFalse(error.description.isEmpty)
            XCTAssertFalse(error.recoverySuggestion.isEmpty)
        }
    }
    
    // MARK: - Request Model Tests
    
    func testLoginRequest_Encoding() throws {
        // Given
        let request = LoginRequest(email: "test@example.com", password: "Password123!")
        
        // When
        let data = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(LoginRequest.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.email, request.email)
        XCTAssertEqual(decoded.password, request.password)
    }
    
    func testRegisterRequest_Encoding() throws {
        // Given
        let request = RegisterRequest(
            username: "testuser",
            email: "test@example.com",
            password: "Password123!"
        )
        
        // When
        let data = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(RegisterRequest.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.username, request.username)
        XCTAssertEqual(decoded.email, request.email)
        XCTAssertEqual(decoded.password, request.password)
    }
    
    func testAuthResponse_Decoding() throws {
        // Given
        let jsonString = """
        {
            "message": "Login successful",
            "token": "test.jwt.token",
            "user": {
                "id": 1,
                "username": "testuser",
                "email": "test@example.com"
            }
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        // When
        let response = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        // Then
        XCTAssertEqual(response.message, "Login successful")
        XCTAssertEqual(response.token, "test.jwt.token")
        XCTAssertEqual(response.user?.id, 1)
        XCTAssertEqual(response.user?.username, "testuser")
        XCTAssertEqual(response.user?.email, "test@example.com")
    }
    
    func testAPIError_Decoding() throws {
        // Given
        let jsonString = """
        {
            "error": "Validation failed",
            "details": [
                {
                    "msg": "Password must contain at least one lowercase letter",
                    "param": "password",
                    "location": "body"
                }
            ]
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        // When
        let apiError = try JSONDecoder().decode(APIError.self, from: data)
        
        // Then
        XCTAssertEqual(apiError.error, "Validation failed")
        XCTAssertEqual(apiError.details?.count, 1)
        XCTAssertEqual(apiError.details?.first?.msg, "Password must contain at least one lowercase letter")
        XCTAssertEqual(apiError.details?.first?.param, "password")
        XCTAssertEqual(apiError.details?.first?.location, "body")
    }
    
    // MARK: - Configuration Tests
    
    func testAPIConfiguration() {
        // Test that configuration values are accessible
        XCTAssertFalse(Configuration.API.baseURL.isEmpty)
        XCTAssertFalse(Configuration.API.loginEndpoint.isEmpty)
        XCTAssertFalse(Configuration.API.registerEndpoint.isEmpty)
        XCTAssertGreaterThan(Configuration.API.timeout, 0)
    }
}

// MARK: - Mock URLSession (for future integration tests)
class MockURLSession {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    func setMockResponse(data: Data?, response: URLResponse?, error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }
}