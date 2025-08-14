import Foundation

/// Utility for parsing and cleaning error messages from various sources
/// Consolidates error message handling across the application
struct ErrorMessageParser {
    
    // MARK: - Public Methods
    
    /// Parse and clean error message from API responses
    /// Extracts user-friendly messages from server errors and API responses
    static func parseAPIError(from rawError: String) -> String {
        // Try to extract clean message from server error
        guard rawError.contains("Error del servidor") && rawError.contains("{") else {
            return rawError
        }
        
        // Find the JSON part safely
        guard let jsonStart = rawError.firstIndex(of: "{"),
              let jsonEnd = rawError.lastIndex(of: "}"),
              jsonStart < jsonEnd else {
            return rawError
        }
        
        // Extract and parse JSON
        let jsonString = String(rawError[jsonStart...jsonEnd])
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            return rawError
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                // Try different possible message keys
                if let message = extractMessageFromJSON(json) {
                    return message
                }
            }
        } catch {
            // JSON parsing failed, return original message
            return rawError
        }
        
        return rawError
    }
    
    /// Parse error from APIError objects
    static func parseAPIError(from apiError: APIError) -> String {
        switch apiError {
        case .invalidURL:
            return "URL inválida"
        case .noData:
            return "No se recibieron datos del servidor"
        case .invalidResponse:
            return "Respuesta del servidor inválida"
        case .networkError(let error):
            return "Error de conexión: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Error procesando respuesta: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Error preparando datos: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return formatServerError(code: code, message: message)
        case .authenticationFailed:
            return "Error de autenticación. Verifica tus credenciales"
        case .tokenExpired:
            return "Sesión expirada. Por favor, inicia sesión nuevamente"
        }
    }
    
    /// Parse error from any Error object
    static func parseGenericError(from error: Error) -> String {
        if let apiError = error as? APIError {
            return parseAPIError(from: apiError)
        }
        
        // Handle URLError specifically
        if let urlError = error as? URLError {
            return parseURLError(urlError)
        }
        
        // Handle other Swift errors
        let errorDescription = error.localizedDescription
        
        // Check if it's a server error string that needs parsing
        if errorDescription.contains("Error del servidor") {
            return parseAPIError(from: errorDescription)
        }
        
        return errorDescription
    }
    
    /// Get user-friendly message for validation errors
    static func parseValidationError(field: String, error: ValidationError) -> String {
        let fieldName = getFieldDisplayName(field)
        
        switch error {
        case .required:
            return "\(fieldName) es requerido"
        case .invalidFormat:
            return "\(fieldName) tiene un formato inválido"
        case .tooShort(let minLength):
            return "\(fieldName) debe tener al menos \(minLength) caracteres"
        case .tooLong(let maxLength):
            return "\(fieldName) no puede tener más de \(maxLength) caracteres"
        case .outOfRange(let min, let max):
            return "\(fieldName) debe estar entre \(min) y \(max)"
        case .custom(let message):
            return message
        }
    }
    
    // MARK: - Private Helper Methods
    
    private static func extractMessageFromJSON(_ json: [String: Any]) -> String? {
        // Try common message keys in order of preference
        let messageKeys = ["message", "error", "description", "detail", "msg"]
        
        for key in messageKeys {
            if let message = json[key] as? String, !message.isEmpty {
                return message
            }
        }
        
        // Try nested error objects
        if let errors = json["errors"] as? [String: Any] {
            for (_, value) in errors {
                if let message = value as? String, !message.isEmpty {
                    return message
                }
                if let messageArray = value as? [String], let firstMessage = messageArray.first {
                    return firstMessage
                }
            }
        }
        
        // Try error arrays
        if let errorArray = json["errors"] as? [String], let firstError = errorArray.first {
            return firstError
        }
        
        return nil
    }
    
    private static func formatServerError(code: Int, message: String?) -> String {
        if let message = message, !message.isEmpty {
            return "Error del servidor (\(code)): \(message)"
        } else {
            return "Error del servidor (\(code)). Intenta más tarde."
        }
    }
    
    private static func parseURLError(_ urlError: URLError) -> String {
        switch urlError.code {
        case .notConnectedToInternet:
            return "Sin conexión a internet"
        case .timedOut:
            return "Tiempo de espera agotado"
        case .cannotFindHost:
            return "No se puede conectar al servidor"
        case .cannotConnectToHost:
            return "Error de conexión al servidor"
        case .networkConnectionLost:
            return "Conexión perdida"
        case .dnsLookupFailed:
            return "Error de DNS"
        case .badURL:
            return "URL inválida"
        case .cancelled:
            return "Operación cancelada"
        default:
            return "Error de red: \(urlError.localizedDescription)"
        }
    }
    
    private static func getFieldDisplayName(_ field: String) -> String {
        switch field.lowercased() {
        case "email":
            return "El email"
        case "password":
            return "La contraseña"
        case "weight":
            return "El peso"
        case "date":
            return "La fecha"
        case "notes":
            return "Las notas"
        case "targetweight":
            return "El peso objetivo"
        case "targetdate":
            return "La fecha objetivo"
        case "code":
            return "El código"
        case "newpassword":
            return "La nueva contraseña"
        case "confirmpassword":
            return "La confirmación de contraseña"
        default:
            return "El campo \(field)"
        }
    }
}

// MARK: - Validation Error Enum

enum ValidationError {
    case required
    case invalidFormat
    case tooShort(minLength: Int)
    case tooLong(maxLength: Int)
    case outOfRange(min: Double, max: Double)
    case custom(message: String)
}

// MARK: - Convenience Extensions

extension ErrorMessageParser {
    
    /// Quick method for common API error parsing
    static func cleanMessage(from error: Error) -> String {
        return parseGenericError(from: error)
    }
    
    /// Parse error for UI display with fallback
    static func userFriendlyMessage(from error: Error, fallback: String = "Ha ocurrido un error inesperado") -> String {
        let parsed = parseGenericError(from: error)
        return parsed.isEmpty ? fallback : parsed
    }
    
    /// Check if error indicates network/connectivity issues
    static func isNetworkError(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            return [.notConnectedToInternet, .timedOut, .cannotFindHost, 
                   .cannotConnectToHost, .networkConnectionLost].contains(urlError.code)
        }
        
        if let apiError = error as? APIError {
            switch apiError {
            case .networkError, .noData, .invalidResponse:
                return true
            default:
                return false
            }
        }
        
        return false
    }
    
    /// Check if error indicates authentication issues
    static func isAuthenticationError(_ error: Error) -> Bool {
        if let apiError = error as? APIError {
            switch apiError {
            case .authenticationFailed, .tokenExpired:
                return true
            default:
                return false
            }
        }
        
        return false
    }
}