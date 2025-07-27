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
                
                var url = "\(protocolValue)://\(host)"
                if !port.isEmpty {
                    url += ":\(port)"
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
            static let weights = "/weights"
            static let goals = "/goals"
            static let photos = "/photos"
            static let profile = "/profile"
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
}