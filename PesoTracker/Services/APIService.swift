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
    
    // MARK: - Modular Components
    private let httpClient: HTTPClient
    private let authHandler: AuthenticationHandler
    private let multipartBuilder: MultipartFormBuilder
    
    // MARK: - Initialization
    private init() {
        let baseURL = Constants.API.baseURL
        
        // Log API service initialization
        print("🌐 [API SERVICE] Initializing with base URL: \(baseURL)")
        print("🌐 [API SERVICE] Timeout configured: \(Constants.API.timeout)s")
        
        // Initialize modular components
        self.httpClient = HTTPClient(baseURL: baseURL)
        self.authHandler = AuthenticationHandler()
        self.multipartBuilder = MultipartFormBuilder(httpClient: httpClient)
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
            requestBody = try httpClient.encodeBody(body)
        }
        
        // Get auth headers if required
        let headers = requiresAuth ? authHandler.getAuthHeaders() : [:]
        
        // Build request
        let request = try httpClient.buildRequest(
            endpoint: endpoint,
            method: method,
            body: requestBody,
            headers: headers
        )
        
        // Execute request
        return try await httpClient.performRequest(request, responseType: responseType)
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
        
        // Get auth headers if required
        let authHeaders = requiresAuth ? authHandler.getAuthHeaders() : [:]
        
        // Delegate to multipart builder
        return try await multipartBuilder.uploadMultipart(
            endpoint: endpoint,
            parameters: parameters,
            imageData: imageData,
            imageKey: imageKey,
            responseType: responseType,
            authHeaders: authHeaders
        )
    }
}