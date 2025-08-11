import Foundation

struct Constants {
    
    // MARK: - Build Configuration Logging
    static func logBuildConfiguration() {
        #if DEBUG
        print("Configuration: Debug")
        #else
        print("Configuration: Release")
        #endif
        print("Base URL: \(API.baseURL)")
    }
    
    // MARK: - API Configuration
    struct API {
        static let baseURL: String = {
            // Build URL from xcconfig components
            if let protocolValue = Bundle.main.object(forInfoDictionaryKey: "API_PROTOCOL") as? String,
               let host = Bundle.main.object(forInfoDictionaryKey: "API_HOST") as? String,
               !protocolValue.isEmpty && !host.isEmpty {
                
                let port = Bundle.main.object(forInfoDictionaryKey: "API_PORT") as? String ?? ""
                let basePath = Bundle.main.object(forInfoDictionaryKey: "API_BASE_PATH") as? String ?? ""
                
                var url = "\(protocolValue)://\(host)"
                
                // Add port if specified (for development with localhost:3000)
                if !port.isEmpty {
                    url += ":\(port)"
                }
                
                // Add base path if specified (for production /peso-tracker/v1)
                if !basePath.isEmpty {
                    url += basePath
                }
                
                return url
            }
            
            return "XCCONFIG_NOT_LOADED"
        }()
        static let timeout: TimeInterval = 30.0
        
        // Endpoints
        struct Endpoints {
            static let login = "/auth/login"
            static let register = "/auth/register"
            static let logout = "/auth/logout"
            static let forgotPassword = "/auth/forgot-password"
            static let verifyResetCode = "/auth/verify-reset-code"
            static let resetPassword = "/auth/reset-password"
            static let weights = "/weights"
            static let goals = "/goals"
            static let photos = "/photos"
            static let profile = "/profile"
            static let dashboard = "/dashboard"
            static let weightsPrediction = "/weights/prediction"
        }
        
        // Headers
        struct Headers {
            static let contentType = "Content-Type"
            static let authorization = "Authorization"
            static let applicationJSON = "application/json"
            static let multipartFormData = "multipart/form-data"
        }
    }
    
    // MARK: - App Configuration
    struct App {
        static let name = "PesoTracker"
        static let version = "1.0.0"
        static let bundleIdentifier = "com.pesotracker.app"
    }
    
    // MARK: - Keychain Keys
    struct Keychain {
        static let jwtToken = "peso_tracker_jwt_token"
        static let userID = "peso_tracker_user_id"
    }
    
    // MARK: - UserDefaults Keys
    struct UserDefaults {
        static let hasCompletedOnboarding = "has_completed_onboarding"
        static let lastSyncDate = "last_sync_date"
        static let preferredWeightUnit = "preferred_weight_unit"
        static let cachedUserData = "cached_user_data"
        static let cachedUsername = "cached_username"
        static let cachedUserEmail = "cached_user_email"
        static let cachedUserId = "cached_user_id"
        
        // Theme Settings
        static let themePreference = "theme_preference"
        
        // Data Export Settings
        static let lastExportPath = "last_export_path"
    }
    
    // MARK: - UI Constants
    struct UI {
        static let dashboardLeftPanelRatio: CGFloat = 0.35
        static let dashboardRightPanelRatio: CGFloat = 0.65
        static let cornerRadius: CGFloat = 8.0
        static let smallCornerRadius: CGFloat = 4.0
        static let standardPadding: CGFloat = 16.0
        static let smallPadding: CGFloat = 8.0
        static let largePadding: CGFloat = 24.0
    }
    
    // MARK: - Validation
    struct Validation {
        static let minPasswordLength = 6
        static let maxPasswordLength = 128
        static let minUsernameLength = 3
        static let maxUsernameLength = 50
        static let minWeight: Double = 1.0
        static let maxWeight: Double = 1000.0
        static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        // Password Recovery Validation
        static let verificationCodeLength = 6
        static let maxPasswordResetAttempts = 5
        static let passwordResetTimeoutMinutes = 15
        static let codeExpirationMinutes = 10
        static let rateLimitWaitMinutes = 5
    }
    
    // MARK: - Date Formats
    struct DateFormats {
        static let api = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        static let display = "dd/MM/yyyy"
        static let displayWithTime = "dd/MM/yyyy HH:mm"
    }
    
    // MARK: - Image Configuration
    struct Images {
        static let maxImageSize: CGFloat = 1024.0
        static let compressionQuality: CGFloat = 0.8
        static let allowedImageTypes = ["jpg", "jpeg", "png"]
    }
    
    // MARK: - Error Messages
    struct ErrorMessages {
        // Password Recovery Errors
        struct PasswordRecovery {
            static let emailRequired = "El email es requerido"
            static let emailInvalid = "Formato de email inválido"
            static let emailNotFound = "No se encontró una cuenta con este email"
            static let codeRequired = "El código es requerido"
            static let codeInvalid = "El código debe tener 6 dígitos numéricos"
            static let codeIncorrect = "El código ingresado es incorrecto"
            static let codeExpired = "El código ha expirado. Solicita uno nuevo"
            static let codeUsed = "Este código ya ha sido utilizado"
            static let maxAttemptsExceeded = "Has excedido el número máximo de intentos"
            static let passwordRequired = "La contraseña es requerida"
            static let passwordTooShort = "La contraseña debe tener al menos \(Validation.minPasswordLength) caracteres"
            static let passwordTooLong = "La contraseña no puede tener más de \(Validation.maxPasswordLength) caracteres"
            static let passwordsDoNotMatch = "Las contraseñas no coinciden"
            static let sessionExpired = "La sesión ha expirado. Inicia el proceso nuevamente"
            static let rateLimitExceeded = "Demasiados intentos. Espera \(Validation.rateLimitWaitMinutes) minutos"
        }
        
        // Network Errors
        struct Network {
            static let noConnection = "No hay conexión a internet"
            static let timeout = "La conexión ha expirado"
            static let serverUnavailable = "Servidor no disponible"
            static let connectionLost = "Se perdió la conexión de red"
            static let genericError = "Error de conexión"
        }
        
        // Server Errors
        struct Server {
            static let internalError = "Error interno del servidor"
            static let badGateway = "Servidor no disponible temporalmente"
            static let serviceUnavailable = "Servicio no disponible"
            static let gatewayTimeout = "Tiempo de espera agotado"
            static let genericError = "Error del servidor"
        }
    }
}