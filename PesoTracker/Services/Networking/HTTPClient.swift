import Foundation

class HTTPClient {
    
    // MARK: - Properties
    private let session: URLSession
    private let baseURL: String
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    
    // MARK: - Initialization
    init(baseURL: String) {
        self.baseURL = baseURL
        
        // Configure URLSession
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Constants.API.timeout
        config.timeoutIntervalForResource = Constants.API.timeout
        self.session = URLSession(configuration: config)
        
        // Configure JSON Decoder
        self.jsonDecoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.DateFormats.api
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        self.jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        // Configure JSON Encoder
        self.jsonEncoder = JSONEncoder()
        self.jsonEncoder.dateEncodingStrategy = .formatted(dateFormatter)
    }
    
    // MARK: - Request Building
    func buildRequest(
        endpoint: String,
        method: HTTPMethod,
        body: Data? = nil,
        headers: [String: String] = [:]
    ) throws -> URLRequest {
        
        // Ensure proper URL construction with slash
        let cleanBaseURL = baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let cleanEndpoint = endpoint.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let fullURL = cleanBaseURL + "/" + cleanEndpoint
        
        guard let url = URL(string: fullURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(Constants.API.Headers.applicationJSON, forHTTPHeaderField: Constants.API.Headers.contentType)
        
        // Add custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add body if provided
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    // MARK: - Generic Request Method
    func performRequest<T: Codable>(
        _ request: URLRequest,
        responseType: T.Type
    ) async throws -> T {
        
        // Execute request
        do {
            let (data, response) = try await session.data(for: request)
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Handle HTTP status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success - decode response
                do {
                    let decodedResponse = try jsonDecoder.decode(T.self, from: data)
                    return decodedResponse
                } catch {
                    throw APIError.decodingError(error)
                }
                
            case 401:
                // Unauthorized - try to refresh token first
                print("🔐 [HTTP CLIENT] 401 Unauthorized - attempting token refresh")
                if let refreshedRequest = await attemptTokenRefreshAndRetry(request) {
                    return try await performRequestWithoutRetry(refreshedRequest, responseType: responseType)
                } else {
                    throw APIError.authenticationFailed
                }
                
            case 403:
                // Forbidden - try to refresh token first
                print("🔐 [HTTP CLIENT] 403 Forbidden - attempting token refresh")
                if let refreshedRequest = await attemptTokenRefreshAndRetry(request) {
                    return try await performRequestWithoutRetry(refreshedRequest, responseType: responseType)
                } else {
                    throw APIError.tokenExpired
                }
                
            default:
                // Server error
                let errorMessage = String(data: data, encoding: .utf8)
                throw APIError.serverError(httpResponse.statusCode, errorMessage)
            }
            
        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError(error)
            }
        }
    }
    
    // MARK: - JSON Encoding
    func encodeBody<T: Encodable>(_ body: T) throws -> Data {
        do {
            return try jsonEncoder.encode(body)
        } catch {
            throw APIError.encodingError(error)
        }
    }
    
    // MARK: - Request without retry (to avoid infinite loops)
    private func performRequestWithoutRetry<T: Codable>(
        _ request: URLRequest,
        responseType: T.Type
    ) async throws -> T {
        
        // Execute request
        do {
            let (data, response) = try await session.data(for: request)
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Handle HTTP status codes (without retry logic)
            switch httpResponse.statusCode {
            case 200...299:
                // Success - decode response
                do {
                    let decodedResponse = try jsonDecoder.decode(T.self, from: data)
                    return decodedResponse
                } catch {
                    throw APIError.decodingError(error)
                }
                
            case 401:
                throw APIError.authenticationFailed
                
            case 403:
                throw APIError.tokenExpired
                
            default:
                // Server error
                let errorMessage = String(data: data, encoding: .utf8)
                throw APIError.serverError(httpResponse.statusCode, errorMessage)
            }
            
        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError(error)
            }
        }
    }
    
    // MARK: - Token Refresh and Retry Logic
    private func attemptTokenRefreshAndRetry(
        _ originalRequest: URLRequest
    ) async -> URLRequest? {
        do {
            // Try to refresh the token
            let _ = try await AuthService.shared.refreshToken()
            
            // Update the request with new authorization header
            var refreshedRequest = originalRequest
            let authHeaders = AuthenticationHandler().getAuthHeaders()
            for (key, value) in authHeaders {
                refreshedRequest.setValue(value, forHTTPHeaderField: key)
            }
            
            print("✅ [HTTP CLIENT] Token refreshed successfully, retrying original request")
            return refreshedRequest
            
        } catch {
            print("❌ [HTTP CLIENT] Token refresh failed: \(error)")
            await triggerAutoLogout()
            return nil
        }
    }
    
    // MARK: - Auto Logout Helper
    private func triggerAutoLogout() async {
        await MainActor.run {
            AuthService.shared.forceLogoutDueToExpiredToken()
        }
    }
}