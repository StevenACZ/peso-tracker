import Foundation

struct Weight: Codable, Identifiable {
    let id: String
    let weight: Double
    let date: Date
    let notes: String?
    let photoURL: String?
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case weight
        case date
        case notes
        case photoURL = "photo_url"
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        weight = try container.decode(Double.self, forKey: .weight)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        userId = try container.decode(String.self, forKey: .userId)
        
        // Date decoding helper
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        // Decode date
        let dateString = try container.decode(String.self, forKey: .date)
        if let parsedDate = dateFormatter.date(from: dateString) {
            date = parsedDate
        } else {
            dateFormatter.formatOptions = [.withInternetDateTime]
            date = dateFormatter.date(from: dateString) ?? Date()
        }
        
        // Decode createdAt
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        if let parsedDate = dateFormatter.date(from: createdAtString) {
            createdAt = parsedDate
        } else {
            dateFormatter.formatOptions = [.withInternetDateTime]
            createdAt = dateFormatter.date(from: createdAtString) ?? Date()
        }
        
        // Decode updatedAt
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        if let parsedDate = dateFormatter.date(from: updatedAtString) {
            updatedAt = parsedDate
        } else {
            dateFormatter.formatOptions = [.withInternetDateTime]
            updatedAt = dateFormatter.date(from: updatedAtString) ?? Date()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(weight, forKey: .weight)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encodeIfPresent(photoURL, forKey: .photoURL)
        try container.encode(userId, forKey: .userId)
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        try container.encode(formatter.string(from: date), forKey: .date)
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
    }
}

// MARK: - Weight Request Models
struct WeightCreateRequest: Codable {
    let weight: Double
    let date: Date
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case weight
        case date
        case notes
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(weight, forKey: .weight)
        try container.encodeIfPresent(notes, forKey: .notes)
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        try container.encode(formatter.string(from: date), forKey: .date)
    }
}

struct WeightUpdateRequest: Codable {
    let weight: Double?
    let date: Date?
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case weight
        case date
        case notes
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(weight, forKey: .weight)
        try container.encodeIfPresent(notes, forKey: .notes)
        
        if let date = date {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            try container.encode(formatter.string(from: date), forKey: .date)
        }
    }
}

// MARK: - Weight Extensions
extension Weight {
    var hasPhoto: Bool {
        return photoURL != nil && !photoURL!.isEmpty
    }
    
    var hasNotes: Bool {
        return notes != nil && !notes!.isEmpty
    }
    
    var formattedWeight: String {
        return String(format: "%.1f kg", weight)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}