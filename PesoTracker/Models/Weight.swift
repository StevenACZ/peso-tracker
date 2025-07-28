import Foundation

struct Weight: Codable, Identifiable {
    let id: Int
    let weight: Double
    let date: Date
    let notes: String?
    let hasPhoto: Bool
    
    // New API structure - nested photo object
    let photo: WeightPhoto?
    
    // API metadata
    let userId: Int?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case weight
        case date
        case notes
        case hasPhoto
        case photo
        case userId
        case createdAt
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        
        // Handle weight as string from API
        if let weightString = try? container.decode(String.self, forKey: .weight) {
            weight = Double(weightString) ?? 0.0
        } else {
            weight = try container.decode(Double.self, forKey: .weight)
        }
        
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        
        // Decode photo object and handle hasPhoto
        photo = try container.decodeIfPresent(WeightPhoto.self, forKey: .photo)
        
        // Handle hasPhoto: prioritize explicit field from API, fallback to photo presence
        if let explicitHasPhoto = try container.decodeIfPresent(Bool.self, forKey: .hasPhoto) {
            hasPhoto = explicitHasPhoto
        } else {
            hasPhoto = photo != nil
        }
        
        // API metadata
        userId = try container.decodeIfPresent(Int.self, forKey: .userId)
        
        // Date decoding helper
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        // Decode date (required)
        let dateString = try container.decode(String.self, forKey: .date)
        if let parsedDate = dateFormatter.date(from: dateString) {
            date = parsedDate
        } else {
            dateFormatter.formatOptions = [.withInternetDateTime]
            date = dateFormatter.date(from: dateString) ?? Date()
        }
        
        // Decode optional dates
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            if let parsedDate = dateFormatter.date(from: createdAtString) {
                createdAt = parsedDate
            } else {
                dateFormatter.formatOptions = [.withInternetDateTime]
                createdAt = dateFormatter.date(from: createdAtString)
            }
        } else {
            createdAt = nil
        }
        
        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt) {
            if let parsedDate = dateFormatter.date(from: updatedAtString) {
                updatedAt = parsedDate
            } else {
                dateFormatter.formatOptions = [.withInternetDateTime]
                updatedAt = dateFormatter.date(from: updatedAtString)
            }
        } else {
            updatedAt = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(weight, forKey: .weight)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(hasPhoto, forKey: .hasPhoto)
        try container.encodeIfPresent(photo, forKey: .photo)
        try container.encodeIfPresent(userId, forKey: .userId)
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        try container.encode(formatter.string(from: date), forKey: .date)
        
        if let createdAt = createdAt {
            try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        }
        
        if let updatedAt = updatedAt {
            try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
        }
    }
}


// MARK: - WeightPhoto Model
struct WeightPhoto: Codable, Identifiable {
    let id: Int
    let userId: Int
    let weightId: Int
    let thumbnailUrl: String
    let mediumUrl: String
    let fullUrl: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case weightId
        case thumbnailUrl
        case mediumUrl
        case fullUrl
        case createdAt
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        weightId = try container.decode(Int.self, forKey: .weightId)
        thumbnailUrl = try container.decode(String.self, forKey: .thumbnailUrl)
        mediumUrl = try container.decode(String.self, forKey: .mediumUrl)
        fullUrl = try container.decode(String.self, forKey: .fullUrl)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        createdAt = dateFormatter.date(from: createdAtString) ?? Date()
        
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        updatedAt = dateFormatter.date(from: updatedAtString) ?? Date()
    }
}

// MARK: - Weight Extensions
extension Weight {
    // Backward compatibility - delegate to hasPhoto
    var hasPhotos: Bool {
        return hasPhoto
    }
    
    var hasNotes: Bool {
        return notes != nil && !notes!.isEmpty
    }
    
    var formattedWeight: String {
        return String(format: "%.2f kg", weight)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}