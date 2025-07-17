//
//  APIService.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation

/// Service for handling HTTP communication with the Peso Tracker API
class APIService {
    
    // MARK: - Singleton
    static let shared = APIService()
    private init() {}
    
    // MARK: - Configuration
    private let baseURL = Configuration.API.baseURL
    private let timeout = Configuration.API.timeout
    
    // MARK: - URLSession
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout * 2
        return URLSession(configuration: config)
    }()
    
    // MARK: - HTTP Methods
    enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
    
    // MARK: - Authentication Methods
    
    /// Login user with email and password
    /// - Parameter request: LoginRequest containing email and password
    /// - Returns: AuthResponse with token and user data
    /// - Throws: APIError for various failure scenarios
    func login(_ request: LoginRequest) async throws -> AuthResponse {
        let endpoint = Configuration.API.loginEndpoint
        return try await makeRequest(
            endpoint: endpoint,
            method: .POST,
            body: request,
            responseType: AuthResponse.self
        )
    }
    
    /// Register new user
    /// - Parameter request: RegisterRequest containing username, email, and password
    /// - Returns: AuthResponse with success message
    /// - Throws: APIError for various failure scenarios
    func register(_ request: RegisterRequest) async throws -> AuthResponse {
        let endpoint = Configuration.API.registerEndpoint
        return try await makeRequest(
            endpoint: endpoint,
            method: .POST,
            body: request,
            responseType: AuthResponse.self
        )
    }
    
    // MARK: - Authenticated Requests
    
    /// Make authenticated request with JWT token
    /// - Parameters:
    ///   - endpoint: API endpoint path
    ///   - method: HTTP method
    ///   - body: Optional request body
    /// - Returns: Decoded response of specified type
    /// - Throws: APIError for various failure scenarios
    func makeAuthenticatedRequest<T: Codable, U: Codable>(
        endpoint: String,
        method: HTTPMethod,
        body: U? = nil,
        responseType: T.Type
    ) async throws -> T {
        // Get token from keychain
        guard let token = try KeychainService.shared.getToken() else {
            throw APIError.authenticationRequired
        }
        
        return try await makeRequest(
            endpoint: endpoint,
            method: method,
            body: body,
            responseType: responseType,
            authToken: token
        )
    }
    
    // MARK: - Generic Request Method
    
    /// Generic method for making HTTP requests
    /// - Parameters:
    ///   - endpoint: API endpoint path
    ///   - method: HTTP method
    ///   - body: Optional request body
    ///   - responseType: Expected response type
    ///   - authToken: Optional JWT token for authentication
    /// - Returns: Decoded response of specified type
    /// - Throws: APIError for various failure scenarios
    private func makeRequest<T: Codable, U: Codable>(
        endpoint: String,
        method: HTTPMethod,
        body: U? = nil,
        responseType: T.Type,
        authToken: String? = nil
    ) async throws -> T {
        
        // Construct URL
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authentication header if token provided
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add request body if provided
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw APIError.encodingError(error.localizedDescription)
            }
        }
        
        // Make request
        do {
            let (data, response) = try await session.data(for: request)
            
            // Check HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success - decode response
                do {
                    let decoder = JSONDecoder()
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw APIError.decodingError(error.localizedDescription)
                }
                
            case 400:
                // Bad Request - likely validation errors
                if let errorResponse = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                    if let details = errorResponse.details {
                        throw APIError.validationError(details)
                    } else {
                        throw APIError.badRequest
                    }
                } else {
                    throw APIError.badRequest
                }
                
            case 401:
                // Unauthorized
                throw APIError.unauthorized
                
            case 403:
                // Forbidden
                throw APIError.forbidden
                
            case 404:
                // Not Found
                throw APIError.notFound
                
            case 429:
                // Too Many Requests
                throw APIError.rateLimited
                
            case 500...599:
                // Server Error
                if let errorResponse = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                    throw APIError.serverError(errorResponse.error)
                } else {
                    throw APIError.serverError("Internal server error")
                }
                
            default:
                throw APIError.unexpectedStatusCode(httpResponse.statusCode)
            }
            
        } catch let error as APIError {
            throw error
        } catch {
            // Network or other errors
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    throw APIError.networkError(.noConnection)
                case .timedOut:
                    throw APIError.networkError(.timeout)
                case .cannotFindHost, .cannotConnectToHost:
                    throw APIError.networkError(.hostUnreachable)
                default:
                    throw APIError.networkError(.unknown(urlError.localizedDescription))
                }
            } else {
                throw APIError.networkError(.unknown(error.localizedDescription))
            }
        }
    }
}

// APIError and NetworkError are now defined in AuthModels.swift
