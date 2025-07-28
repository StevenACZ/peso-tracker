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
        
        let fullURL = baseURL + endpoint
        print("🌐 [HTTP CLIENT] Building request:")
        print("   📍 Base URL: '\(baseURL)'")
        print("   📍 Endpoint: '\(endpoint)'")
        print("   📍 Full URL: '\(fullURL)'")
        print("   🔧 Method: \(method.rawValue)")
        
        guard let url = URL(string: fullURL) else {
            print("❌ [HTTP CLIENT] Invalid URL: '\(fullURL)'")
            throw APIError.invalidURL
        }
        
        print("✅ [HTTP CLIENT] URL constructed successfully: \(url.absoluteString)")
        
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
        print("🚀 [HTTP CLIENT] Executing request to: \(request.url?.absoluteString ?? "unknown")")
        do {
            let (data, response) = try await session.data(for: request)
            print("📦 [HTTP CLIENT] Received response: \(data.count) bytes")
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Handle HTTP status codes
            print("📡 [HTTP CLIENT] HTTP Status: \(httpResponse.statusCode)")
            switch httpResponse.statusCode {
            case 200...299:
                // Success - decode response
                print("✅ [HTTP CLIENT] Success response, decoding...")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 [HTTP CLIENT] Response body: \(responseString)")
                }
                do {
                    let decodedResponse = try jsonDecoder.decode(T.self, from: data)
                    print("✅ [HTTP CLIENT] Successfully decoded response")
                    return decodedResponse
                } catch {
                    print("❌ [HTTP CLIENT] Decoding error: \(error)")
                    throw APIError.decodingError(error)
                }
                
            case 401:
                // Unauthorized - token expired or invalid
                throw APIError.authenticationFailed
                
            case 403:
                // Forbidden - token expired
                // Clear the expired token
                KeychainHelper.shared.delete(key: Constants.Keychain.jwtToken)
                throw APIError.tokenExpired
                
            default:
                // Server error
                let errorMessage = String(data: data, encoding: .utf8)
                print("❌ [HTTP CLIENT] Server error \(httpResponse.statusCode): \(errorMessage ?? "No message")")
                throw APIError.serverError(httpResponse.statusCode, errorMessage)
            }
            
        } catch {
            if error is APIError {
                print("❌ [HTTP CLIENT] API Error: \(error)")
                throw error
            } else {
                print("❌ [HTTP CLIENT] Network Error: \(error)")
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
}