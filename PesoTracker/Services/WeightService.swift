//
//  WeightService.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation

class WeightService {
    private let baseURL = "http://localhost:3000"
    
    func fetchWeights() async throws -> WeightResponse {
        guard let token = try? KeychainService.shared.getToken() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token"])
        }
        
        guard let url = URL(string: "\(baseURL)/api/weights") else {
            throw NSError(domain: "URL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "Network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            if httpResponse.statusCode == 200 {
                let weightResponse = try JSONDecoder().decode(WeightResponse.self, from: data)
                return weightResponse
            } else {
                throw NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch weights"])
            }
        } catch {
            throw NSError(domain: "Network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network connection error. Please check your internet connection and try again."])
        }
    }
}