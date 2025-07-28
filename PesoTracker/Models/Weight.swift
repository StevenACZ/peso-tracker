import Foundation

struct Weight: Codable, Identifiable {
    let id: Int
    let weight: Double
    let date: Date
    let notes: String?
    let userId: Int
    let createdAt: Date
    let updatedAt: Date
    let photos: [Photo]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case weight
        case date
        case notes
        case userId
        case createdAt
        case updatedAt
        case photos
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
        userId = try container.decode(Int.self, forKey: .userId)
        photos = try container.decodeIfPresent([Photo].self, forKey: .photos)
        
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
        try container.encode(userId, forKey: .userId)
        try container.encodeIfPresent(photos, forKey: .photos)
        
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
    var hasPhotos: Bool {
        return photos != nil && !photos!.isEmpty
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