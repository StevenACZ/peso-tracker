//
//  Goal.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation

struct Goal: Codable, Identifiable {
    let id: Int
    let userId: Int
    let targetWeight: Double
    let targetDate: String
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case targetWeight = "target_weight"
        case targetDate = "target_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Custom decoder to handle target_weight as string from API
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        targetDate = try container.decode(String.self, forKey: .targetDate)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        
        // Handle targetWeight as either String or Double
        if let weightString = try? container.decode(String.self, forKey: .targetWeight) {
            targetWeight = Double(weightString) ?? 0.0
        } else {
            targetWeight = try container.decode(Double.self, forKey: .targetWeight)
        }
    }
    
    // Custom encoder for sending data back to API
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(targetWeight, forKey: .targetWeight) // Send as Double
        try container.encode(targetDate, forKey: .targetDate)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
    }
    
    var formattedTargetWeight: String {
        return String(format: "%.1f kg", targetWeight)
    }
    
    var formattedTargetDate: String {
        let dateFormatter = DateFormatter()
        // Try different date formats that the API might return
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd"
        ]
        
        for format in formats {
            dateFormatter.dateFormat = format
            if let parsedDate = dateFormatter.date(from: targetDate) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "MMM dd, yyyy"
                return displayFormatter.string(from: parsedDate)
            }
        }
        
        // If no format works, return the original string
        return targetDate
    }
}

struct GoalResponse: Codable {
    let data: [Goal]
}

struct CreateGoalRequest: Codable {
    let targetWeight: Double
    let targetDate: String
    
    enum CodingKeys: String, CodingKey {
        case targetWeight = "target_weight"
        case targetDate = "target_date"
    }
}

struct CreateGoalResponse: Codable {
    let message: String
    let data: Goal
}