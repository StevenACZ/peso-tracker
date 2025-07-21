//
//  WeightEntry.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation

struct WeightEntry: Codable, Identifiable {
    let id: Int
    let weight: Double
    let date: String
    let userId: Int?
    let notes: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case weight
        case date
        case userId = "user_id"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Custom decoder to handle weight as string from API
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decodeIfPresent(Int.self, forKey: .userId)
        date = try container.decode(String.self, forKey: .date)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        
        // Handle weight as either String or Double
        if let weightString = try? container.decode(String.self, forKey: .weight) {
            weight = Double(weightString) ?? 0.0
        } else {
            weight = try container.decode(Double.self, forKey: .weight)
        }
    }
    
    // Custom initializer for creating WeightEntry instances
    init(
        id: Int,
        userId: Int?,
        weight: Double,
        date: String,
        notes: String? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.weight = weight
        self.date = date
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Custom encoder for sending data back to API
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(weight, forKey: .weight) // Send as Double
        try container.encode(date, forKey: .date)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
    }
    
    var weightValue: Double {
        return weight
    }
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        // Try different date formats that the API might return
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd"
        ]
        
        for format in formats {
            dateFormatter.dateFormat = format
            if let parsedDate = dateFormatter.date(from: date) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "MMM dd, yyyy"
                return displayFormatter.string(from: parsedDate)
            }
        }
        
        // If no format works, return the original string
        return date
    }
    
    var formattedWeight: String {
        return String(format: "%.1f kg", weight)
    }
}

struct Pagination: Codable {
    let total: Int
    let limit: Int
    let offset: Int
    let hasMore: Bool
}

struct WeightResponse: Codable {
    let data: [WeightEntry]
    let pagination: Pagination
    
    // Computed properties for compatibility
    var weights: [WeightEntry] {
        return data
    }
    
    var currentWeight: Double? {
        return data.first?.weightValue // Most recent (first in sorted array)
    }
    
    var startingWeight: Double? {
        return data.last?.weightValue // Oldest (last in sorted array)
    }
}