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
        
        guard let token = try? KeychainService.shared.getToken() else {
            print("❌ WeightService: No authentication token found")
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token"])
        }
        
        guard let url = URL(string: "\(baseURL)/api/weights") else {
            print("❌ WeightService: Invalid URL")
            throw NSError(domain: "URL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        print("🌐 WeightService: Making request to \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ WeightService: Invalid response type")
                throw NSError(domain: "Network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            print("📊 WeightService: Response status code: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 WeightService: Response body: \(responseString)")
            }
            
            if httpResponse.statusCode == 200 {
                let weightResponse = try JSONDecoder().decode(WeightResponse.self, from: data)
                print("✅ WeightService: Successfully fetched weights")
                return weightResponse
            } else {
                print("❌ WeightService: Failed with status \(httpResponse.statusCode)")
                throw NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch weights"])
            }
        } catch {
            print("❌ WeightService: Network error: \(error.localizedDescription)")
            throw NSError(domain: "Network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network connection error. Please check your internet connection and try again."])
        }
    }
}