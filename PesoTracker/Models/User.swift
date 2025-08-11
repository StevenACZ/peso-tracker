import Foundation

struct User: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case createdAt = "created_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle ID as either String or Int
        if let stringId = try? container.decode(String.self, forKey: .id) {
            id = stringId
        } else if let intId = try? container.decode(Int.self, forKey: .id) {
            id = String(intId)
        } else {
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(
                codingPath: container.codingPath + [CodingKeys.id],
                debugDescription: "Expected String or Int for id"
            ))
        }
        
        username = try container.decode(String.self, forKey: .username)
        email = try container.decode(String.self, forKey: .email)
        
        // Handle date decoding - try different formats
        if let dateString = try? container.decode(String.self, forKey: .createdAt) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            formatter.timeZone = TimeZone(identifier: "UTC")
            
            if let date = formatter.date(from: dateString) {
                createdAt = date
            } else {
                // Fallback to basic ISO8601 format
                formatter.formatOptions = [.withInternetDateTime]
                createdAt = formatter.date(from: dateString) ?? Date()
            }
        } else {
            // If no date string, use current date
            createdAt = Date()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(email, forKey: .email)
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(identifier: "UTC")
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
    }
}

// MARK: - Authentication Response Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let username: String
    let email: String
    let password: String
}

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let tokenType: String
    let user: User
    
    // Legacy support - computed properties for backward compatibility
    var token: String { return accessToken }
    var expiresAt: Date { return Date().addingTimeInterval(TimeInterval(expiresIn)) }
    
    enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
        case expiresIn
        case tokenType
        case user
        
        // Legacy key for decoding old format
        case token
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        user = try container.decode(User.self, forKey: .user)
        
        // Try new format first
        if let newAccessToken = try? container.decode(String.self, forKey: .accessToken) {
            // New API format
            accessToken = newAccessToken
            refreshToken = try container.decode(String.self, forKey: .refreshToken)
            expiresIn = try container.decode(Int.self, forKey: .expiresIn)
            tokenType = try container.decode(String.self, forKey: .tokenType)
        } else {
            // Legacy format support
            accessToken = try container.decode(String.self, forKey: .token)
            refreshToken = "" // Default for legacy
            expiresIn = 900 // Default 15 minutes
            tokenType = "Bearer"
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(accessToken, forKey: .accessToken)
        try container.encode(refreshToken, forKey: .refreshToken)
        try container.encode(expiresIn, forKey: .expiresIn)
        try container.encode(tokenType, forKey: .tokenType)
        try container.encode(user, forKey: .user)
    }
}

// MARK: - Refresh Token Models
struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

struct RefreshTokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let tokenType: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
        case expiresIn
        case tokenType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        accessToken = try container.decode(String.self, forKey: .accessToken)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
        expiresIn = try container.decode(Int.self, forKey: .expiresIn)
        tokenType = try container.decodeIfPresent(String.self, forKey: .tokenType) ?? "Bearer"
    }
}

// MARK: - Availability Check Models
struct AvailabilityResponse: Codable {
    let email: AvailabilityStatus?
    let username: AvailabilityStatus?
    
    // Computed properties for easier access with defaults
    var emailAvailable: Bool {
        return email?.available ?? true
    }
    
    var usernameAvailable: Bool {
        return username?.available ?? true
    }
    
    var emailChecked: Bool {
        return email?.checked ?? false
    }
    
    var usernameChecked: Bool {
        return username?.checked ?? false
    }
}

struct AvailabilityStatus: Codable {
    let available: Bool
    let checked: Bool
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle both boolean and potential other formats
        if let availableBool = try? container.decode(Bool.self, forKey: .available) {
            available = availableBool
        } else {
            // Default to false if not available or can't decode
            available = false
        }
        
        if let checkedBool = try? container.decode(Bool.self, forKey: .checked) {
            checked = checkedBool
        } else {
            // Default to true if not specified (assume it was checked)
            checked = true
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case available
        case checked
    }
}