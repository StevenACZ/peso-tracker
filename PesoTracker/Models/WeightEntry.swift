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
    let userId: Int
    
    var formattedDate: String {
        // Simple date formatting
        return date
    }
    
    var formattedWeight: String {
        return String(format: "%.1f kg", weight)
    }
}

struct WeightResponse: Codable {
    let weights: [WeightEntry]
    let currentWeight: Double?
    let startingWeight: Double?
}