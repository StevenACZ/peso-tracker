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
    let token: String
    let user: User
    let expiresAt: Date
    
    enum CodingKeys: String, CodingKey {
        case token
        case user
        case expiresAt = "expires_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        token = try container.decode(String.self, forKey: .token)
        user = try container.decode(User.self, forKey: .user)
        
        // Handle expiresAt - try different formats or use default
        if let dateString = try? container.decode(String.self, forKey: .expiresAt) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            if let date = formatter.date(from: dateString) {
                expiresAt = date
            } else {
                formatter.formatOptions = [.withInternetDateTime]
                expiresAt = formatter.date(from: dateString) ?? Date().addingTimeInterval(3600)
            }
        } else {
            // Default to 1 hour from now if no expiration provided
            expiresAt = Date().addingTimeInterval(3600)
        }
    }
}