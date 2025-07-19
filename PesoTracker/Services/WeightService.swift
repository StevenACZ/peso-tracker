//
//  WeightService.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation

class WeightService {
    private let baseURL = "http://100.111.122.121:3000"
    
    func fetchWeights() async throws -> WeightResponse {
        print("⚖️ WeightService: Starting to fetch weights")
        
        // Use the APIService instead of direct network calls
        let apiService = APIService.shared
        return try await apiService.getWeights()
    }
}