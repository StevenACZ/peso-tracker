//
//  WeightEntry.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation

struct WeightEntry: Codable, Identifiable {
    let id: Int
    let weight: String // Your API returns weight as string
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
    
    var weightValue: Double {
        return Double(weight) ?? 0.0
    }
    
    var formattedDate: String {
        // Simple date formatting - you can improve this later
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        if let date = dateFormatter.date(from: date) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM dd, yyyy"
            return displayFormatter.string(from: date)
        }
        return date
    }
    
    var formattedWeight: String {
        return String(format: "%.1f kg", weightValue)
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
        return data.last?.weightValue
    }
    
    var startingWeight: Double? {
        return data.first?.weightValue
    }
}