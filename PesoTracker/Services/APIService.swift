import Foundation
import Security

// MARK: - API Error Types
enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case networkError(Error)
    case serverError(Int, String?)
    case authenticationFailed
    case invalidResponse
    case tokenExpired
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .noData:
            return "No se recibieron datos"
        case .decodingError(let error):
            return "Error al decodificar datos: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Error al codificar datos: \(error.localizedDescription)"
        case .networkError(let error):
            return "Error de conexión: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Error del servidor (\(code)): \(message ?? "Error desconocido")"
        case .authenticationFailed:
            return "Credenciales inválidas"
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        case .tokenExpired:
            return "Sesión expirada"
        }
    }
}

// MARK: - HTTP Method
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

// MARK: - API Response
struct APIResponse<T: Codable> {
    let data: T?
    let message: String?
    let success: Bool
}

// MARK: - APIService Class
class APIService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = APIService()
    
    // MARK: - Properties
    private let session: URLSession
    private let baseURL: String
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    
    // MARK: - Initialization
    private init() {
        self.baseURL = Constants.API.baseURL
        
        // Log API service initialization
        print("🌐 [API SERVICE] Initializing with base URL: \(baseURL)")
        print("🌐 [API SERVICE] Timeout configured: \(Constants.API.timeout)s")
        
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
    
    // MARK: - JWT Token Management
    private func getJWTToken() -> String? {
        return KeychainHelper.shared.get(key: Constants.Keychain.jwtToken)
    }
    
    private func setAuthorizationHeader(for request: inout URLRequest) {
        if let token = getJWTToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: Constants.API.Headers.authorization)
        }
    }
    
    // MARK: - Request Building
    private func buildRequest(
        endpoint: String,
        method: HTTPMethod,
        body: Data? = nil,
        requiresAuth: Bool = true
    ) throws -> URLRequest {
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(Constants.API.Headers.applicationJSON, forHTTPHeaderField: Constants.API.Headers.contentType)
        
        // Add authorization header if required
        if requiresAuth {
            setAuthorizationHeader(for: &request)
        }
        
        // Add body if provided
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    // MARK: - Generic Request Method
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Encodable? = nil,
        responseType: T.Type,
        requiresAuth: Bool = true
    ) async throws -> T {
        
        // Encode body if provided
        var requestBody: Data?
        if let body = body {
            do {
                requestBody = try jsonEncoder.encode(body)
            } catch {
                throw APIError.encodingError(error)
            }
        }
        
        // Build request
        let request = try buildRequest(
            endpoint: endpoint,
            method: method,
            body: requestBody,
            requiresAuth: requiresAuth
        )
        
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
    
    // MARK: - Convenience Methods
    
    /// GET request
    func get<T: Codable>(
        endpoint: String,
        responseType: T.Type,
        requiresAuth: Bool = true
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: .GET,
            responseType: responseType,
            requiresAuth: requiresAuth
        )
    }
    
    /// POST request
    func post<T: Codable>(
        endpoint: String,
        body: Encodable? = nil,
        responseType: T.Type,
        requiresAuth: Bool = true
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: .POST,
            body: body,
            responseType: responseType,
            requiresAuth: requiresAuth
        )
    }
    
    /// PUT request
    func put<T: Codable>(
        endpoint: String,
        body: Encodable? = nil,
        responseType: T.Type,
        requiresAuth: Bool = true
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: .PUT,
            body: body,
            responseType: responseType,
            requiresAuth: requiresAuth
        )
    }
    
    /// PATCH request
    func patch<T: Codable>(
        endpoint: String,
        body: Encodable? = nil,
        responseType: T.Type,
        requiresAuth: Bool = true
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: .PATCH,
            body: body,
            responseType: responseType,
            requiresAuth: requiresAuth
        )
    }
    
    /// DELETE request
    func delete<T: Codable>(
        endpoint: String,
        responseType: T.Type,
        requiresAuth: Bool = true
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: .DELETE,
            responseType: responseType,
            requiresAuth: requiresAuth
        )
    }
    
    // MARK: - Multipart Form Data (for photo uploads)
    func uploadMultipart<T: Codable>(
        endpoint: String,
        parameters: [String: String],
        imageData: Data?,
        imageKey: String = "photo",
        responseType: T.Type,
        requiresAuth: Bool = true
    ) async throws -> T {
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        
        // Add authorization header if required
        if requiresAuth {
            setAuthorizationHeader(for: &request)
        }
        
        // Create multipart form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: Constants.API.Headers.contentType)
        
        var body = Data()
        
        // Add text parameters
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add image data if provided
        if let imageData = imageData {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(imageKey)\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // Execute request
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decodedResponse = try jsonDecoder.decode(T.self, from: data)
                    return decodedResponse
                } catch {
                    throw APIError.decodingError(error)
                }
                
            case 401:
                throw APIError.authenticationFailed
                
            case 403:
                // Forbidden - token expired
                KeychainHelper.shared.delete(key: Constants.Keychain.jwtToken)
                throw APIError.tokenExpired
                
            default:
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
}